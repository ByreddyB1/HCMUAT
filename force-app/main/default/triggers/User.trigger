trigger User on User (after insert, after update) {
    if(trigger.isAfter && trigger.isInsert){
        UserHandler.afterInsert(Trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate){
        UserHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}