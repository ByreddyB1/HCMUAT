trigger RelatedDocket on Related_Docket__c (after insert,after update,after delete,before insert) {
    if(RecursionHelper.runRelatedDocketTrigger){
        if(trigger.isAfter && trigger.isInsert){
            RelatedDocketHandler.afterInsert(Trigger.new);
        }
        if(trigger.isAfter && trigger.isUpdate){
            RelatedDocketHandler.afterUpdate(Trigger.new);
        }
        if(trigger.isAfter && trigger.isDelete){
            RelatedDocketHandler.afterDelete(Trigger.old);
        }
        if(trigger.isBefore && trigger.isInsert){
            RelatedDocketHandler.beforeInsert(Trigger.new);
        }
    }
}