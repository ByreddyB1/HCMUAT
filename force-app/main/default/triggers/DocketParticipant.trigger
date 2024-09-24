trigger DocketParticipant on Docket_Participant__c (after insert, after update, after delete, after undelete) {
    if(Trigger.isInsert && Trigger.isAfter){
        DocketParticipantHandler.afterInsertDocketParticipantHandler(Trigger.New);
    }
	if(Trigger.isUpdate && Trigger.isAfter){
			DocketParticipantHandler.afterUpdateDocketParticipantHandler(Trigger.New,Trigger.oldMap);        
    }
    if(Trigger.isDelete && Trigger.isAfter){
        DocketParticipantHandler.afterDeleteDocketParticipantHandler(Trigger.old);        
    }
}