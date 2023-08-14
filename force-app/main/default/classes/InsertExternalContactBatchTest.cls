@isTest
public with sharing class InsertExternalContactBatchTest {

    @isTest
    static void when_Contact_Inserted_Shoud_Insert_External_Account() {
        // Arrange
        ExternalObjectManager.setMock(new ExternalObjectManagerMock());
        Account account = new Account(Name = 'Test Account 1');
        insert account;

        List<Contact> contactsToInsert = new List<Contact>{
            new Contact(AccountId = account.Id, LastName = 'Test Contact 1'),
            new Contact(AccountId = account.Id, LastName = 'Test Contact 2')
        };

        // Act
        Test.startTest();
        insert contactsToInsert;
        Test.stopTest();

        // Assert
        List<Id> insertedContactIds = new List<Id>();
        for (Contact contact : contactsToInsert) {
            insertedContactIds.add(contact.Id);
        }

        List<Contact> insertedContacts = [SELECT Id, External_Contact__c FROM Contact WHERE Id IN :insertedContactIds];
        List<Id> externalContactsIds = new List<Id>();
        for (Contact contact : insertedContacts) {
            externalContactsIds.add(contact.External_Contact__c);
        }

        List<Contact__x> externalContacts = ExternalObjectManager.queryContactsByExternalId(externalContactsIds);
        System.assertEquals(2, externalContacts.size(), 'External contacts were not inserted');
    }

}