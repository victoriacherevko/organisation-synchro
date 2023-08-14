@isTest
public with sharing class DeleteExternalContactBatchTest {

    @isTest
    static void when_Contacts_Deleted_Should_Delete_External_Contacts() {
        // Arrange
        ExternalObjectManager.setMock(new ExternalObjectManagerMock());
        
        Account account = new Account(Name = 'Test Account 1');
        insert account;

        Contact testContact1 = new Contact(AccountId = account.Id, LastName = 'Test Contact 1');
        Contact testContact2 = new Contact(AccountId = account.Id, LastName = 'Test Contact 2');
        insert new List<Contact>{testContact1, testContact2};

        Map<Id, Contact> contactsToDelete = new Map<Id, Contact> ([SELECT Id, External_Contact__c FROM Contact WHERE Id IN (:testContact1.Id, :testContact2.Id)]);

        // Act
        Test.startTest();
        delete [SELECT Id FROM Contact WHERE Id IN (:testContact1.Id, :testContact2.Id)];
        Test.stopTest();

        // Assert
        List<Id> contactIds = new List<Id>();
        for (Contact contact : contactsToDelete.values()) {
            contactIds.add(contact.External_Contact__c);
        }
        List<Contact__x> externalContacts = ExternalObjectManager.queryContactsByExternalId(contactIds);
        System.assertEquals(0, externalContacts.size(), 'External contacts were not deleted');
    }

}