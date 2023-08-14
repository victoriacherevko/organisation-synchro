public with sharing class InsertExternalAccountsBatch implements Database.Batchable<sObject> {
    
    // Map containing the new Account records to insert
    Map<Id, Account> newAccounts;

    // Constructor for the batch class. Accepts a map of new Account records
    public InsertExternalAccountsBatch(Map<Id, Account> newAccounts) {
        this.newAccounts = newAccounts;
    }

    // The start method is called at the beginning of the batch execution.
    // It returns a query locator for selecting the new Account records to process
    public Database.QueryLocator start(Database.BatchableContext BC){

        Set<Id> ids = newAccounts.keySet();
        String query = 'SELECT Id, Name FROM Account WHERE Id IN :ids';
        return Database.getQueryLocator(query);
    }

    // The execute method is called for each batch of records to be processed.
    // It creates corresponding external Account__x records, inserts them and
    // updates the local Account records with their external IDs
    public void execute(Database.BatchableContext BC, List<Account> scope){

        // Create a list to store the external Account__x records
        List<Account__x> externalAccounts = new List<Account__x>();
        // Create a map to associate Account Ids with their respective Account records
        Map<Id, Account> accountsMap = new Map<Id, Account>();

        // Loop through the Account records in the batch scope
        for (Account a : scope) {
            Account__x externalAccount = new Account__x(
                Name__c = a.Name,
                External_Account_c__c = a.Id,
                Is_External_Edit_c__c = true
            );
            externalAccounts.add(externalAccount);
            accountsMap.put(a.Id, a);
        }

        // Insert the external Account__x records
        ExternalObjectManager.insertRecords(externalAccounts);

        List<Id> savedExternalAccountsIds = new List<Id>();
        
        // Loop through the saved external Account__x records
        for (Account__x exAccount : externalAccounts) {
            savedExternalAccountsIds.add(exAccount.Id);
        }

        // Query the saved external Account__x records by their Ids
        for (Account__x savedAccount : ExternalObjectManager.queryAccountsById(savedExternalAccountsIds)) {
            Account localAccount = accountsMap.get(savedAccount.External_Account_c__c);
            localAccount.External_Account__c = savedAccount.ExternalId;
        }

        update scope;
     }

    // The finish method is called after all batches have been processed.
    // It executes a separate batch to update the original new Account records
    // with the external IDs obtained after insertion
     public void finish(Database.BatchableContext BC){
        Database.executeBatch(new UpdateExternalAccountsBatch(newAccounts, null), 5);
    }
}