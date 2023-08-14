@isTest
public with sharing class InsertExternalAccountsBatchTest {

    @isTest
    static void when_Account_Inserted_Shoud_Insert_External_Account() {
        // Arrange
        ExternalObjectManager.setMock(new ExternalObjectManagerMock());
        List<Account> accountsToInsert = new List<Account>{
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2')
        };

        // Act
        Test.startTest();
        insert accountsToInsert;
        Test.stopTest();

        // Assert
        List<Id> insertedAccountIds = new List<Id>();
        for (Account account : accountsToInsert) {
            insertedAccountIds.add(account.Id);
        }

        List<Account> insertedAccounts = [SELECT Id, External_Account__c FROM Account WHERE Id IN :insertedAccountIds];
        List<Id> externalAccountsIds = new List<Id>();
        for (Account account : insertedAccounts) {
            externalAccountsIds.add(account.External_Account__c);
        }

        List<Account__x> externalAccounts = ExternalObjectManager.queryAccountsByExternalId(externalAccountsIds);
        System.assertEquals(2, externalAccounts.size(), 'External accounts were not inserted');
    }

}