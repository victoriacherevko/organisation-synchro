public with sharing class ContactTriggerHandler {
    
    // Private flag to track whether an external callout is needed within the trigger context
    private static Boolean isExternalCallout = false;

    // Method processes a before-insert event for a list of new Contacts
    public static void onBeforeInsert(List<Contact> newContacts) {
        for (Contact newContact : newContacts) {
            if (newContact.Is_External_Edit__c == true) {
                isExternalCallout = true;
                newContact.Is_External_Edit__c = false;
            }
        }
    }

    // Method handles actions after new Contact records have been inserted
    public static void onAfterInsert(Map<Id, Contact> newContactsMap) {
        if (!System.isBatch() && !System.isFuture() && !isExternalCallout) {
            Database.executeBatch(new InsertExternalContactBatch(newContactsMap), 5);
        }
    }

    // Method handles actions after Contact records have been deleted
    public static void onAfterDelete(Map<Id, Contact> oldContactsMap) {
        if (!System.isBatch() && !System.isFuture()) {
            Database.executeBatch(new DeleteExternalContactBatch(oldContactsMap), 5);
        }
    }

    // Method processes a before-update event for a list of Contacts
    public static void onBeforeUpdate(List<Contact> newContacts, Map<Id, Contact> oldContactsMap) {
        for (Contact newContact : newContacts) {
            if (newContact.Is_External_Edit__c == true) {
                isExternalCallout = true;
                newContact.Is_External_Edit__c = false;
            }
        }
    }

    // Method handles actions after Contact records have been updated
    public static void onAfterUpdate(Map<Id, Contact> newContactsMap, Map<Id, Contact> oldContactsMap) {
        if (!System.isBatch() && !System.isFuture() && !isExternalCallout) {
            Database.executeBatch(new UpdateExternalContactBatch(newContactsMap, oldContactsMap), 5);
        }
    }

}