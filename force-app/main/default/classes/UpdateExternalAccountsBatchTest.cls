@isTest
public with sharing class UpdateExternalAccountsBatchTest {
    
    @isTest
    static void when_Account_Updated_External_Account_Shoud_Update() {
        // Arrange
        ExternalObjectManager.setMock(new ExternalObjectManagerMock());
        Account testAccount1 = new Account(Name = 'Test Account 1');
        Account testAccount2 = new Account(Name = 'Test Account 2');
        insert new List<Account>{testAccount1, testAccount2};

        testAccount1.Name = 'Updated Test Account 1';
        testAccount2.Name = 'Updated Test Account 2';
        List<Account> accountsToUpdate = new List<Account>{testAccount1, testAccount2};

        // Act
        Test.startTest();
        update accountsToUpdate;
        Test.stopTest();

        // Assert
        List<Id> updatedAccountIds = new List<Id>();
        for (Account account : accountsToUpdate) {
            updatedAccountIds.add(account.Id);
        }

        List<Account> updatedAccounts = [SELECT Id, External_Account__c FROM Account WHERE Id IN :updatedAccountIds];
        List<Id> externalAccountsIds = new List<Id>();
        for (Account account : updatedAccounts) {
            externalAccountsIds.add(account.External_Account__c);
        }

        List<Account__x> externalAccounts = ExternalObjectManager.queryAccountsByExternalId(externalAccountsIds);
        System.assertEquals(2, externalAccounts.size(), 'External accounts were not updated');
        System.assertEquals('Updated Test Account 1', externalAccounts[0].Name__c, 'External account 1 was not updated');
        System.assertEquals('Updated Test Account 2', externalAccounts[1].Name__c, 'External account 2 was not updated');
    }

}