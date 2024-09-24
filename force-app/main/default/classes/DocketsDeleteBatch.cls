global without sharing class DocketsDeleteBatch implements Database.Batchable<SObject>, Schedulable {
    global DocketsDeleteBatch() { }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date pastDate= Date.today().addYears(- Integer.valueof(System.Label.Number_of_Years_before_Docket_Deletion));

        system.debug('pastDate value: ' + pastDate);

        String queryString = 'SELECT Id, Closed_Date__c,Litigation_Hold__c,(SELECT ID FROM Participants__r),(SELECT ID FROM Docket_Attachments__r) FROM Docket__c WHERE Litigation_Hold__c=false AND Closed_Date__c < :pastDate';
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext bc, list<Docket__c> scope) {
        List<Docket__c> docketToBeDeleted = new List<Docket__c>();
        List<Docket_Attachment__c> docketAttachmentToBeDeleted = new List<Docket_Attachment__c>();
        List<Docket_Participant__c> docketParticipentToBeDeleted = new List<Docket_Participant__c>();

        for(Docket__c doc : scope){
            docketToBeDeleted.add(doc);
            docketParticipentToBeDeleted.addAll(doc.Participants__r);
            docketAttachmentToBeDeleted.addAll(doc.Docket_Attachments__r);
        }
        
        try{
            if(docketToBeDeleted.size()>0){
                if(docketAttachmentToBeDeleted.size()>0){
                    Delete docketAttachmentToBeDeleted;
                }

                if(docketParticipentToBeDeleted.size()>0){
                    Delete docketParticipentToBeDeleted;
                }

                Delete docketToBeDeleted;
            }
        } catch(Exception exc){
            System.debug('Exception in Docket delete batch: ' + exc.getMessage());
        } 
    }
    
    global void execute(SchedulableContext sc) {
        DocketsDeleteBatch batch = new DocketsDeleteBatch();
        Database.executebatch(batch);
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
}