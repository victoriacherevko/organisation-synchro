trigger AccountTrigger on Account(before insert, after insert, after delete, before update, after update) {

    // Execute trigger logic only for specific trigger events and contexts
    if (Trigger.isInsert && Trigger.isBefore) {
        AccountTriggerHandler.onBeforeInsert(Trigger.new);
    }

    if (Trigger.isInsert && Trigger.isAfter) {
        AccountTriggerHandler.onAfterInsert(Trigger.newMap);
    }

    if (Trigger.isDelete && Trigger.isAfter) {
        AccountTriggerHandler.onAfterDelete(Trigger.oldMap);
    }

    if (Trigger.isUpdate && Trigger.isBefore) {
        AccountTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
    }

    if (Trigger.isUpdate && Trigger.isAfter) {
        AccountTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
    }
}