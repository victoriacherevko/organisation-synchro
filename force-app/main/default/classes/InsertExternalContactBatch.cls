public with sharing class InsertExternalContactBatch implements Database.Batchable<sObject> {

    // Map containing the new Contact records to insert
    Map<Id, Contact> newContacts;

    // Constructor for the batch class. Accepts a map of new Contact records
    public InsertExternalContactBatch(Map<Id, Contact> newContacts) {
        this.newContacts = newContacts;
    }

    // The start method is called at the beginning of the batch execution.
    // It returns a query locator for selecting the new Contact records to process
    public Database.QueryLocator start(Database.BatchableContext BC){

        Set<Id> ids = newContacts.keySet();
        String query = 'SELECT Id, LastName, FirstName FROM Contact WHERE Id IN :ids';
        return Database.getQueryLocator(query);
    }

    // The execute method is called for each batch of records to be processed.
    // It creates corresponding external Contact__x records, inserts them and
    // updates the local Contact records with their external IDs
    public void execute(Database.BatchableContext BC, List<Contact> scope) {

        // Create a list to store the external Contact__x records
        List<Contact__x> externalContacts = new List<Contact__x>();
        // Create a map to associate Contact Ids with their respective Contact records
        Map<Id, Contact> contactsMap = new Map<Id, Contact>();

        // Loop through the Contact records in the batch scope
        for (Contact c : scope) {
            Contact__x externalContact = new Contact__x(
                LastName__c = c.LastName,
                FirstName__c = c.FirstName,
                External_Contact_c__c = c.Id,
                Is_External_Edit_c__c = true
            );
            externalContacts.add(externalContact);
            contactsMap.put(c.Id, c);
        }

        // Insert the external Contact__x records
        ExternalObjectManager.insertRecords(externalContacts);

        List<Id> savedExternalContactIds = new List<Id>();
        // Loop through the saved external Contact__x records
        for (Contact__x exContact : externalContacts) {
            savedExternalContactIds.add(exContact.Id);
        }

        // Query the saved external Contact__x records by their Ids
        for (Contact__x savedContact : ExternalObjectManager.queryContactsById(savedExternalContactIds)) {
            Contact localContact = contactsMap.get(savedContact.External_Contact_c__c);
            localContact.External_Contact__c = savedContact.ExternalId;
        }

        update scope;
     }

    // The finish method is called after all batches have been processed.
    // It executes a separate batch to update the original new Contact records
    // with the external IDs obtained after insertion
     public void finish(Database.BatchableContext BC){
        Database.executeBatch(new UpdateExternalContactBatch(newContacts, null), 5);
    }
}