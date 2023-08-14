public with sharing class UpdateExternalAccountsBatch implements Database.Batchable<sObject> {

    // Maps containing the new and old Account records to compare and update
    Map<Id, Account> newAccounts;
    Map<Id, Account> oldAccounts;

    // Mapping of Salesforce fields to corresponding external fields
    Map<String, String> fieldsMap = new Map<String, String>{
        'Name' => 'Name__c',
        'AccountNumber' => 'AccountNumber__c',
        'Site' => 'Site__c',
        'Rating' => 'Rating__c',
        'Phone' => 'Phone__c',
        'Industry' => 'Industry__c',

        'BillingCity' => 'BillingCity__c',
        'BillingCountry' => 'BillingCountry__c',
        'BillingGeocodeAccuracy' => 'BillingGeocodeAccuracy__c',
        'BillingLatitude' => 'BillingLatitude__c',
        'BillingLongitude' => 'BillingLongitude__c',
        'BillingState' => 'BillingState__c',
        'BillingStreet' => 'BillingStreet__c',
        'BillingPostalCode' => 'BillingPostalCode__c',

        'ShippingCity' => 'ShippingCity__c',
        'ShippingCountry' => 'ShippingCountry__c',
        'ShippingGeocodeAccuracy' => 'ShippingGeocodeAccuracy__c',
        'ShippingLatitude' => 'ShippingLatitude__c',
        'ShippingLongitude' => 'ShippingLongitude__c',
        'ShippingState' => 'ShippingState__c',
        'ShippingStreet' => 'ShippingStreet__c',
        'ShippingPostalCode' => 'ShippingPostalCode__c'
    };

    // Constructor for the batch class. Accepts maps of new and old Account records
    public UpdateExternalAccountsBatch(Map<Id, Account> newAccounts, Map<Id, Account> oldAccounts) {
        this.newAccounts = newAccounts;
        this.oldAccounts = oldAccounts;
    }


    // The start method is called at the beginning of the batch execution.
    // It returns a query locator for selecting the external Account__x records to update
    public Database.QueryLocator start(Database.BatchableContext BC){

        Set<Id> ids = newAccounts.keySet();

        String fieldsStr = String.join(new List<String>(fieldsMap.keySet()), ', ');

        String query = 'SELECT Id, External_Account__c, '+ fieldsStr +' FROM Account WHERE Id IN :ids';
        return Database.getQueryLocator(query);
    }

    // The execute method is called for each batch of records to be processed.
    // It updates corresponding external Account__x records based on local Account changes
    public void execute(Database.BatchableContext BC, List<Account> scope){

        // Create a list to store the external Account__x records
        List<Id> accountExternalIds = new List<Id>();
        // Loop through the Account records in the batch scope
        for (Account account : scope) {
            accountExternalIds.add(account.External_Account__c);
        }

        // Query the external Account__x records based on the external Account IDs
        List<Account__x> externalAccounts = ExternalObjectManager.queryAccountsByExternalId(accountExternalIds);
        // Create a map to associate external Account__x record IDs with the records themselves
        Map<Id, Account__x> externalAccountsMap = new Map<Id, Account__x>();
        for (Account__x account : externalAccounts) {
            externalAccountsMap.put(account.ExternalId, account);
        }

        List<Account__x> externalAccountsToUpdate = new List<Account__x>();
        for (Account account : scope) {
            // Skip Account records without external Account IDs
            if (account.External_Account__c == null) {
                continue;
            }

            Account newAccount = newAccounts.get(account.Id);
            Account__x externalAccount = externalAccountsMap.get(account.External_Account__c);

            // Loop through the fields to be updated
            for (String field : fieldsMap.keySet()) {
                String externalField = fieldsMap.get(field);
                externalAccount.put(externalField, newAccount.get(field));
                if (externalAccountsToUpdate.contains(externalAccount) == false) {
                    externalAccountsToUpdate.add(externalAccount);
                }
            }
        }

        // Mark the external Account__x records for external edit
        for (Account__x account : externalAccountsToUpdate) {
            account.Is_External_Edit_c__c = true;
        }

        // Update the external Account__x records
        ExternalObjectManager.updateRecords(externalAccountsToUpdate);
     }

    // The finish method is called after all batches have been processed
     public void finish(Database.BatchableContext BC){
    }
}