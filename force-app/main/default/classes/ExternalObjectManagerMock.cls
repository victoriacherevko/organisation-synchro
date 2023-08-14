public with sharing class ExternalObjectManagerMock extends ExternalObjectManager {

    // Counter for generating unique IDs
    private static Integer s_num = 1;
    // Map to store records by object type
    private static Map<sObjectType, List<sObject>> recordsByType = new Map<sObjectType, List<sObject>>();

    // Override of the queryAccountsByIdInternal method for testing purposes
    // Queries and retrieves a list of external Account__x records by their corresponding Salesforce record Ids.
    // This method is used internally by the ExternalObjectManagerMock class to simulate querying external records
    protected override List<Account__x> queryAccountsByIdInternal(List<Id> recordsIds) {
        
        // Determine the type of the external object
        sObjectType accountType = Account__x.getSObjectType();
        // Initialize a list to store the queried external records
        List<Account__x> result = new List<Account__x>();

        // Iterate through the records of the corresponding type and select the ones with matching Ids
        for (SObject record : recordsByType.get(accountType))
        {
            if (recordsIds.contains(record.Id)) {
                result.add((Account__x)record);
            }
        }

        // Return the list of external records that match the given record Ids
        return result;
    }

    // Override of the queryContactsByIdInternal method for testing purposes
    // Queries and retrieves a list of external Contact__x records by their corresponding Salesforce record Ids.
    // This method is used internally by the ExternalObjectManagerMock class to simulate querying external records
    protected override List<Contact__x> queryContactsByIdInternal(List<Id> recordsIds) {
        
        // Determine the type of the external object
        sObjectType accountType = Contact__x.getSObjectType();
        // Initialize a list to store the queried external records
        List<Contact__x> result = new List<Contact__x>();

        // Iterate through the records of the corresponding type and select the ones with matching Ids
        for (SObject record : recordsByType.get(accountType))
        {
            if (recordsIds.contains(record.Id)) {
                result.add((Contact__x)record);
            }
        }

        // Return the list of external records that match the given record Ids
        return result;
    }

    // Override of the queryAccountsByExternalIdInternal method for testing purposes
    // Queries and retrieves a list of external Account__x records by their corresponding external record Ids.
    // This method is used internally by the ExternalObjectManagerMock class to simulate querying external records
    protected override List<Account__x> queryAccountsByExternalIdInternal(List<String> externalIds) {
        
        // Determine the type of the external object
        sObjectType accountType = Account__x.getSObjectType();
        // Initialize a list to store the queried external records
        List<Account__x> result = new List<Account__x>();

        // Check if there are records of the specified type
        if (!recordsByType.containsKey(accountType)) {
            return result;
        }

        // Iterate through the records of the corresponding type and select the ones with matching externalIds
        for (SObject record : recordsByType.get(accountType))
        {
            Account__x account = (Account__x)record;
            if (externalIds.contains(account.ExternalId)) {
                result.add(account);
            }
        }

        // Return the list of external records that match the given externalIds
        return result;
    }

    // Override of the queryContactsByExternalIdInternal method for testing purposes
    // Queries and retrieves a list of external Contact__x records by their corresponding external record Ids.
    // This method is used internally by the ExternalObjectManagerMock class to simulate querying external records
    protected override List<Contact__x> queryContactsByExternalIdInternal(List<String> externalIds) {
        
        // Determine the type of the external object
        sObjectType contactType = Contact__x.getSObjectType();
        // Initialize a list to store the queried external records
        List<Contact__x> result = new List<Contact__x>();

        // Check if there are records of the specified type
        if (!recordsByType.containsKey(contactType)) {
            return result;
        }

        // Iterate through the records of the corresponding type and select the ones with matching externalIds
        for (SObject record : recordsByType.get(contactType))
        {
            Contact__x contact = (Contact__x)record;
            if (externalIds.contains(contact.ExternalId)) {
                result.add(contact);
            }
        }

        // Return the list of external records that match the given externalIds
        return result;
    }

    // Inserts a list of SObject records into the mock records collection.
    // This method is used internally by the ExternalObjectManagerMock class to simulate inserting records
    protected override void insertRecordsInternal(List<SObject> records) {
        // Check if the list of records is empty or null
        if (records == null || records.isEmpty()) {
            return;
        }

        // Determine the type of the records in the list
        sObjectType type = records[0].getSObjectType();

        // If the records are of type Account__x, perform additional processing
        if (type == Account__x.getSObjectType()) {
            records = processInsert((List<Account__x>)records);
        }

        // Check if the recordsByType map already contains the record type
        if (recordsByType.containsKey(type)) {
            recordsByType.get(type).addAll(records);
        }
        else {
            recordsByType.put(type, records);
        }
    }

    // Updates the mock records collection with the provided list of SObject records.
    // This method is used internally by the ExternalObjectManagerMock class to simulate updating records
    protected override void updateRecordsInternal(List<SObject> records)
    {
        // Check if the list of records is empty or null
        if (records == null || records.isEmpty()) {
            return;
        }

        // Determine the type of the records in the list
        sObjectType type = records[0].getSObjectType();

        // Check if the recordsByType map contains the record type
        if (!recordsByType.containsKey(type)) {
            return;
        }

        // Iterate through the provided records and update the existing records collection
        for (SObject record : records) {
            List<SObject> existingRecords = recordsByType.get(type);
            List<SObject> recordsToRemove = new List<SObject>();
            
            // Find the matching existing records to be replaced
            for (SObject existingRecord : existingRecords) {
                if (existingRecord.Id == record.Id) {
                    recordsToRemove.add(existingRecord);
                }
            }

            // Remove the existing records that need to be replaced
            for (SObject recordToRemove : recordsToRemove) {
                existingRecords.remove(existingRecords.indexOf(recordToRemove));
            }

            // Add the updated record to the existing records collection
            existingRecords.add(record);
        }
    }

    // Deletes records from the mock records collection based on the provided list of SObject records.
    // This method is used internally by the ExternalObjectManagerMock class to simulate record deletion
    protected override void deleteRecordsInternal(List<SObject> records)
    {
        // Check if the list of records is empty or null
        if (records == null || records.isEmpty()) {
            return;
        }

        // Determine the type of the records in the list
        sObjectType type = records[0].getSObjectType();

        // Check if the recordsByType map contains the record type
        if (!recordsByType.containsKey(type)) {
            return;
        }

        // Iterate through the provided records and remove the corresponding records from the collection
        for (SObject record : records) {
            List<SObject> existingRecords = recordsByType.get(type);
            List<SObject> recordsToRemove = new List<SObject>();
            
            // Find the matching existing records to be removed
            for (SObject existingRecord : existingRecords) {
                if (existingRecord.Id == record.Id) {
                    recordsToRemove.add(existingRecord);
                }
            }

            // Remove the existing records that need to be deleted
            for (SObject recordToRemove : recordsToRemove) {
                existingRecords.remove(existingRecords.indexOf(recordToRemove));
            }
        }
    }

    // Processes the insertion of new external accounts, generating and assigning external IDs
    // to accounts that do not have them
    private List<Account__x> processInsert(List<Account__x> accounts) {
        // Get the sObjectType of Account__x
        sObjectType accountType = Account__x.getSObjectType();
        
        // Iterate through the provided accounts
        for (Account__x account : accounts) {
            // Check if the account's ExternalId is null
            if (account.ExternalId == null) {
                // Generate new external ID and assign it to the account
                account.Id = generateId(accountType);
                account.ExternalId = generateId(accountType);
            }
        }
        return accounts;
    }

    // Generates a new unique ID based on the given sObjectType's key prefix and a sequence number
    private static Id generateId(Schema.SObjectType sot) {
        String num = String.valueOf(s_num++);
        Id result = sot.getDescribe().getKeyPrefix() +
          '0'.repeat(12-num.length()) + num;

        return result;
    }

}