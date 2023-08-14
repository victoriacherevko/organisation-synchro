public with sharing class UpdateExternalContactBatch implements Database.Batchable<sObject> {
    
    // Maps containing the new and old Contact records to compare and update
    Map<Id, Contact> newContacts;
    Map<Id, Contact> oldContacts;

    // Mapping of Salesforce fields to corresponding external fields
    Map<String, String> fieldsMap = new Map<String, String>{
        'LastName' => 'LastName__c',
        'FirstName' => 'FirstName__c',
        'Phone' => 'Phone__c',
        'MobilePhone' => 'MobilePhone__c',
        'Birthdate' => 'Birthdate__c',

        'MailingCity' => 'MailingCity__c',
        'MailingCountry' => 'MailingCountry__c',
        'MailingGeocodeAccuracy' => 'MailingGeocodeAccuracy__c',
        'MailingLatitude' => 'MailingLatitude__c',
        'MailingLongitude' => 'MailingLongitude__c',
        'MailingState' => 'MailingState__c',
        'MailingStreet' => 'MailingStreet__c',
        'MailingPostalCode' => 'MailingPostalCode__c'
    };

    // Constructor for the batch class. Accepts maps of new and old Contact records
    public UpdateExternalContactBatch(Map<Id, Contact> newContacts, Map<Id, Contact> oldContacts) {
        this.newContacts = newContacts;
        this.oldContacts = oldContacts;
    }

    // The start method is called at the beginning of the batch execution.
    // It returns a query locator for selecting the external Contact__x records to update
    public Database.QueryLocator start(Database.BatchableContext BC){

        Set<Id> ids = newContacts.keySet();

        String fieldsStr = String.join(new List<String>(fieldsMap.keySet()), ', ');

        String query = 'SELECT Id, External_Contact__c, AccountId, Account.External_Account__c, '+ fieldsStr +' FROM Contact WHERE Id IN :ids';
        return Database.getQueryLocator(query);
    }

    // The execute method is called for each batch of records to be processed.
    // It updates corresponding external Contact__x records based on local Contact changes
    public void execute(Database.BatchableContext BC, List<Contact> scope){

        // Create lists to store external Contact__x records and external Account__x records
        List<Id> contactExternalIds = new List<Id>();
        List<Id> accountExternalIds = new List<Id>();
        
        // Loop through the Contact records in the batch scope
        for (Contact contact : scope) {
            contactExternalIds.add(contact.External_Contact__c);
            // Check if the Contact has an associated Account with an external Account ID
            if (contact.AccountId != null && contact.Account.External_Account__c != null) {
                accountExternalIds.add(contact.Account.External_Account__c);
            }
        }

        // Query the external Contact__x records based on the external Contact IDs
        List<Contact__x> externalContacts = ExternalObjectManager.queryContactsByExternalId(contactExternalIds);
        // Create a map to associate external Contact__x record IDs with the records themselves
        Map<Id, Contact__x> externalContactsMap = new Map<Id, Contact__x>();
        for (Contact__x contact : externalContacts) {
            externalContactsMap.put(contact.ExternalId, contact);
        }

        // Query the external Account__x records based on the external Account IDs
        List<Account__x> externalAccounts = ExternalObjectManager.queryAccountsByExternalId(accountExternalIds);
        // Create a map to associate external Account__x record IDs with the records themselves
        Map<Id, Account__x> externalAccountsMap = new Map<Id, Account__x>();
        for (Account__x account : externalAccounts) {
            externalAccountsMap.put(account.ExternalId, account);
        }

        List<Contact__x> externalContactsToUpdate = new List<Contact__x>();
        for (Contact contact : scope) {
            // Skip Contact records without external Contact IDs
            if (contact.External_Contact__c == null) {
                continue;
            }

            Contact newContact = newContacts.get(contact.Id);
            Contact__x externalContact = externalContactsMap.get(contact.External_Contact__c);

            // Loop through the fields to be updated
            for (String field : fieldsMap.keySet()) {
                String externalField = fieldsMap.get(field);
                externalContact.put(externalField, newContact.get(field));
                
                // If the external Contact__x record is not in the list of records to update, add it
                if (externalContactsToUpdate.contains(externalContact) == false) {
                    externalContactsToUpdate.add(externalContact);
                }
            }

            // Check if the Contact has an associated Account
            if (contact.AccountId != null) {
                Account__x externalAccount = externalAccountsMap.get(contact.Account.External_Account__c);
                
                // Update the external Contact__x record's AccountId__c with the external Account's ID
                if (externalAccount != null) {
                    externalContact.AccountId__c = externalAccount.ExternalId;
                } else {
                    externalContact.AccountId__c = null;
                }

                // If the external Contact__x record is not in the list of records to update, add it
                if (externalContactsToUpdate.contains(externalContact) == false) {
                    externalContactsToUpdate.add(externalContact);
                }
            }
        }

        // Mark the external Contact__x records for external edit
        for (Contact__x contact : externalContactsToUpdate) {
            contact.Is_External_Edit_c__c = true;
        }

        // Update the external Contact__x records
        ExternalObjectManager.updateRecords(externalContactsToUpdate);
     }

    // The finish method is called after all batches have been processed
     public void finish(Database.BatchableContext BC){
    }
}