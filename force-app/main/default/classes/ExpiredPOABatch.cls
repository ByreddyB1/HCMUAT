public with sharing class ExpiredPOABatch implements Database.batchable<sObject>, Database.Stateful {
    public ExpiredPOABatch() {

    }
    
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        
        String strQuery = 'SELECT Id, Name, Authorization_End_Date__c, Status__c FROM Docket_Participant__c WHERE Authorization_End_Date__c < TODAY AND Status__c=\'Active\'';
        return Database.getQueryLocator(strQuery);
    }

    public void execute(Database.BatchableContext info, List<Docket_Participant__c> lstDocketParticipant){
        try{
            for(Docket_Participant__c dp: lstDocketParticipant){
                dp.Status__c='Expired';
            }
            if(lstDocketParticipant.size()>0){
                Update lstDocketParticipant;
            }
        }catch(Exception e){
            System.debug('Error=>>'+e);
        }
    }

    public void finish(Database.BatchableContext info)
    {
        System.debug(logginglevel.INFO,'Execute Finish Method');
    }
}