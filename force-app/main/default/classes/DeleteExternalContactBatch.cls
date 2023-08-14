public with sharing class DeleteExternalContactBatch implements Database.Batchable<sObject> {

    // Map containing the Contact records to be deleted
    Map<Id, Contact> contactsToDelete;

    // Constructor for the batch class. Accepts a map of Contact records to delete
    public DeleteExternalContactBatch(Map<Id, Contact> contactsToDelete) {
        this.contactsToDelete = contactsToDelete;
    }
    
    // The start method is called at the beginning of the batch execution.
    // It returns an iterable containing the Contact records to be processed
    public Iterable<sObject> start(Database.BatchableContext BC){

        return contactsToDelete.values();
    }

    // The execute method is called for each batch of records to be processed.
    // It identifies the external contact IDs associated with the batch of Contact records
    // and queries the corresponding external object records to delete them
    public void execute(Database.BatchableContext BC, List<Contact> scope){

        List<Id> externalContactsIds = new List<Id>();
        
        for (Contact a : scope) {
            if (a.External_Contact__c != null) {
                externalContactsIds.add(a.External_Contact__c);
            }
        }
        
        List<Contact__x> externalContactsToDelete = ExternalObjectManager.queryContactsByExternalId(externalContactsIds);

        // Delete the external object records associated with the external contact IDs
        ExternalObjectManager.deleteRecords(externalContactsToDelete);
     }

    // The finish method is called after all batches have been processed
     public void finish(Database.BatchableContext BC){
    
    }
}