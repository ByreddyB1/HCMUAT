trigger ContentDocumentLink on ContentDocumentLink (before insert) {
    if(trigger.isBefore && trigger.isInsert){
        ContentDocumentLinkTriggerHandler.beforeInsert(Trigger.new);
    }
}