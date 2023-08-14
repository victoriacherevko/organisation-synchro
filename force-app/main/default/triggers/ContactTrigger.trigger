trigger ContactTrigger on Contact (before insert, after insert, after delete, before update, after update) {

    // Execute trigger logic only for specific trigger events and contexts
    if (Trigger.isInsert && Trigger.isBefore) {
        ContactTriggerHandler.onBeforeInsert(Trigger.new);
    }

    if (Trigger.isInsert && Trigger.isAfter) {
        ContactTriggerHandler.onAfterInsert(Trigger.newMap);
    }

    if (Trigger.isDelete && Trigger.isAfter) {
        ContactTriggerHandler.onAfterDelete(Trigger.oldMap);
    }

    if (Trigger.isUpdate && Trigger.isBefore) {
        ContactTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
    }

    if (Trigger.isUpdate && Trigger.isAfter) {
        ContactTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
    }

}