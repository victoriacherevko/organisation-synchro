@isTest
public with sharing class DeleteExternalAccountsBatchTest {
    
    @isTest
    static void when_Accounts_Deleted_Should_Delete_External_Accounts() {
        // Arrange
        ExternalObjectManager.setMock(new ExternalObjectManagerMock());
        
        Account testAccount1 = new Account(Name = 'Test Account 1');
        Account testAccount2 = new Account(Name = 'Test Account 2');
        insert new List<Account>{testAccount1, testAccount2};

        Map<Id, Account> accountsToDelete = new Map<Id, Account> ([SELECT Id, External_Account__c FROM Account WHERE Id IN (:testAccount1.Id, :testAccount2.Id)]);

        // Act
        Test.startTest();
        delete [SELECT Id FROM Account WHERE Id IN (:testAccount1.Id, :testAccount2.Id)];
        Test.stopTest();

        // Assert
        List<Id> accountIds = new List<Id>();
        for (Account account : accountsToDelete.values()) {
            accountIds.add(account.External_Account__c);
        }
        List<Account__x> externalAccounts = ExternalObjectManager.queryAccountsByExternalId(accountIds);
        System.assertEquals(0, externalAccounts.size(), 'External accounts were not deleted');
    }

}