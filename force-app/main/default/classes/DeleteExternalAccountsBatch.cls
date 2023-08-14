public with sharing class DeleteExternalAccountsBatch implements Database.Batchable<sObject> {
    
    // Map containing the Account records to be deleted
    Map<Id, Account> accountsToDelete;

    // Constructor for the batch class. Accepts a map of Account records to delete
    public DeleteExternalAccountsBatch(Map<Id, Account> accountsToDelete) {
        this.accountsToDelete = accountsToDelete;
    }
    
    // The start method is called at the beginning of the batch execution.
    // It returns an iterable containing the Account records to be processed
    public Iterable<sObject> start(Database.BatchableContext BC){

        return accountsToDelete.values();
    }

    // The execute method is called for each batch of records to be processed.
    // It identifies the external account IDs associated with the batch of Account records
    // and queries the corresponding external object records to delete them
    public void execute(Database.BatchableContext BC, List<Account> scope){

        List<Id> externalAccountsIds = new List<Id>();
        
        for (Account a : scope) {
            if (a.External_Account__c != null) {
                externalAccountsIds.add(a.External_Account__c);
            }
        }

        List<Account__x> externalAccountsToDelete = ExternalObjectManager.queryAccountsByExternalId(externalAccountsIds);

        // Delete the external object records associated with the external account IDs
        ExternalObjectManager.deleteRecords(externalAccountsToDelete);
     }

    // The finish method is called after all batches have been processed
     public void finish(Database.BatchableContext BC){
    
    }
}