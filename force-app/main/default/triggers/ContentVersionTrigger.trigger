trigger ContentVersionTrigger on ContentVersion (after insert,after update) {

    if(trigger.isInsert && trigger.isAfter){
        ContentVersionTriggerHandler.afterInsert(Trigger.new);
    }
    
}