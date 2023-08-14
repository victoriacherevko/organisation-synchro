public with sharing class AccountTriggerHandler {

    private static Boolean isExternalCallout = false;

    // Method processes a before-insert event for a list of new Accounts
    public static void onBeforeInsert(List<Account> newAccounts) {
        for (Account newAccount : newAccounts) {
            if (newAccount.Is_External_Edit__c == true) {
                isExternalCallout = true;
                newAccount.Is_External_Edit__c = false;
            }
        }
    }

    // Method handles actions after new Account records have been inserted
    public static void onAfterInsert(Map<Id, Account> newAccountsMap) {
        if (!System.isBatch() && !System.isFuture() && !isExternalCallout) {
            Database.executeBatch(new InsertExternalAccountsBatch(newAccountsMap), 5);
        }
    }

    // Method handles actions after Account records have been deleted
    public static void onAfterDelete(Map<Id, Account> oldAccountsMap) {
        if (!System.isBatch() && !System.isFuture()) {
            Database.executeBatch(new DeleteExternalAccountsBatch(oldAccountsMap), 5);
        }
    }

    // Method processes a before-update event for a list of Accounts
    public static void onBeforeUpdate(List<Account> newAccounts, Map<Id, Account> oldAccountsMap) {
        for (Account newAccount : newAccounts) {
            if (newAccount.Is_External_Edit__c == true) {
                isExternalCallout = true;
                newAccount.Is_External_Edit__c = false;
            }
        }
    }

    // Method handles actions after Account records have been updated
    public static void onAfterUpdate(Map<Id, Account> newAccountsMap, Map<Id, Account> oldAccountsMap) {
        if (!System.isBatch() && !System.isFuture() && !isExternalCallout) {
            Database.executeBatch(new UpdateExternalAccountsBatch(newAccountsMap, oldAccountsMap), 5);
        }
    }

}