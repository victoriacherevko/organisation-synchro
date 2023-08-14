@isTest
public with sharing class UpdateExternalContactBatchTest {

    @isTest
    static void when_Contact_Updated_External_Contact_Shoud_Update() {
        // Arrange
        ExternalObjectManager.setMock(new ExternalObjectManagerMock());
        Account account = new Account(Name = 'Test Account 1');
        insert account;
        Contact testContact1 = new Contact(AccountId = account.Id, LastName = 'Test Contact 1');
        Contact testContact2 = new Contact(AccountId = account.Id, LastName = 'Test Contact 2');
        insert new List<Contact>{testContact1, testContact2};

        testContact1.LastName = 'Updated Test Contact 1';
        testContact2.LastName = 'Updated Test Contact 2';
        List<Contact> contactsToUpdate = new List<Contact>{testContact1, testContact2};

        // Act
        Test.startTest();
        update contactsToUpdate;
        Test.stopTest();

        // Assert
        List<Id> updatedContactIds = new List<Id>();
        for (Contact contact : contactsToUpdate) {
            updatedContactIds.add(contact.Id);
        }

        List<Contact> updatedContacts = [SELECT Id, External_Contact__c FROM Contact WHERE Id IN :updatedContactIds];
        List<Id> externalContactsIds = new List<Id>();
        for (Contact contact : updatedContacts) {
            externalContactsIds.add(contact.External_Contact__c);
        }

        List<Contact__x> externalContacts = ExternalObjectManager.queryContactsByExternalId(externalContactsIds);
        System.assertEquals(2, externalContacts.size(), 'External contacts were not updated');
        System.assertEquals('Updated Test Contact 1', externalContacts[0].LastName__c, 'External contact 1 was not updated');
        System.assertEquals('Updated Test Contact 2', externalContacts[1].LastName__c, 'External contact 2 was not updated');
    }

}