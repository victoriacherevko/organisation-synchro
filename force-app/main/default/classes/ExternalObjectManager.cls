// This class serves as a manager for handling operations related to external objects.
// It provides methods for querying, inserting, updating, and deleting records in external objects
public virtual inherited sharing class ExternalObjectManager {

    static ExternalObjectManager instance = new ExternalObjectManager();
    @TestVisible static void setMock(ExternalObjectManager mock) { 
        instance = mock; 
    }

    public static List<Account__x> queryAccountsById(List<Id> recordsIds) {
        return instance.queryAccountsByIdInternal(recordsIds);
    }

    public static List<Contact__x> queryContactsById(List<Id> recordsIds) {
        return instance.queryContactsByIdInternal(recordsIds);
    }

    public static List<Account__x> queryAccountsByExternalId(List<String> externalIds) {
        return instance.queryAccountsByExternalIdInternal(externalIds);
    }

    public static List<Contact__x> queryContactsByExternalId(List<String> externalIds) {
        return instance.queryContactsByExternalIdInternal(externalIds);
    }

    public static void insertRecords(List<SObject> records) {
        instance.insertRecordsInternal(records);
    }

    public static void updateRecords(List<SObject> records) {
        instance.updateRecordsInternal(records);
    }

    public static void deleteRecords(List<SObject> records) {
        instance.deleteRecordsInternal(records);
    }


    protected virtual List<Account__x> queryAccountsByIdInternal(List<Id> recordsIds)
    {
        return [SELECT Id, ExternalId, External_Account_c__c FROM Account__x WHERE Id IN :recordsIds];
    }

    protected virtual List<Contact__x> queryContactsByIdInternal(List<Id> recordsIds)
    {
        return [SELECT Id, ExternalId, External_Contact_c__c FROM Contact__x WHERE Id IN :recordsIds];
    }

    protected virtual List<Account__x> queryAccountsByExternalIdInternal(List<String> externalIds) {
        return [SELECT Id, ExternalId FROM Account__x WHERE ExternalId IN :externalIds];
    }

    protected virtual List<Contact__x> queryContactsByExternalIdInternal(List<String> externalIds) {
        return [SELECT Id, ExternalId FROM Contact__x WHERE ExternalId IN :externalIds];
    }

    protected virtual void insertRecordsInternal(List<SObject> records)
    {
        Database.insertImmediate(records);
    }

    protected virtual void updateRecordsInternal(List<SObject> records)
    {
        Database.updateImmediate(records);
    }

    protected virtual void deleteRecordsInternal(List<SObject> records)
    {
        Database.deleteImmediate(records);
    }

}