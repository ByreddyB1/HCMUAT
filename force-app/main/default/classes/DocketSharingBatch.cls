global with sharing class DocketSharingBatch implements Database.Batchable<SObject> {
    global DocketSharingBatch() { }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String queryString = 'SELECT Contact__c, Docket__c FROM Docket_Participant__c WHERE Contact__c != null';
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext bc, list<Docket_Participant__c> scope) {
        try{
            Set<Id> setOfDocketIds = new Set<Id>();
            Set<Id> setOfContactIds = new Set<Id>();
            Set<Id> setOfUserIds = new Set<Id>();

            for(Docket_Participant__c docPart : scope){
                setOfDocketIds.add(docPart.Docket__c);
                setOfContactIds.add(docPart.Contact__c);
            }

            System.debug('scope.size() value: ' + scope.size());
            System.debug('setOfDocketIds value: ' + setOfDocketIds);
            System.debug('setOfContactIds value: ' + setOfContactIds);

            Map<Id, User> mapOfContactIdToUserId = new Map<Id, User>();

            for(User userRecord :[SELECT ContactId, CreatedDate FROM User WHERE ContactId IN :setOfContactIds]){
                mapOfContactIdToUserId.put(userRecord.ContactId, userRecord);
                setOfUserIds.add(userRecord.Id);
            }

            System.debug('mapOfContactIdToUserId value: ' + mapOfContactIdToUserId);
            System.debug('mapOfContactIdToUserId.size() value: ' + mapOfContactIdToUserId.size());
            System.debug('setOfUserIds value: ' + setOfUserIds);

            // Create a list of Docket__Share objects to be inserted.
            List<Docket__share> newDocketShrs = new List<Docket__share>();
            
            // Locate all existing sharing records for the Docket records in the batch.
            // Only records using an Apex sharing reason of TreasuryManual__c should be returned.
            List<Docket__share> oldDocketShrs = [SELECT Id FROM Docket__share WHERE ParentId IN :setOfDocketIds AND UserOrGroupId IN :setOfUserIds AND RowCause = :Schema.Docket__share.RowCause.TreasuryManual__c];
            
            for(Docket_Participant__c dp : scope){
                if(mapOfContactIdToUserId.get(dp.Contact__c) != null){
                    System.debug('dp value: ' + dp);

                    Docket__share docShare = new Docket__Share();

                    docShare.ParentId = dp.Docket__c;
                    docShare.AccessLevel = 'Edit';
                    docShare.UserOrGroupId = mapOfContactIdToUserId.get(dp.Contact__c).Id;
                    docShare.RowCause = Schema.Docket__share.RowCause.TreasuryManual__c;

                    newDocketShrs.add(docShare);
                }
            }
            
            // Delete the existing sharing records, which allows new sharing records to be written from scratch.
            if(oldDocketShrs.size() > 0){
                Database.DeleteResult[] dr = Database.delete(oldDocketShrs,false);
            }

            // Insert the new sharing records and capture the save result. 
            // The false parameter allows for partial processing if multiple records are passed into the operation.
            if(newDocketShrs.size() > 0){
                Database.SaveResult[] sr = Database.insert(newDocketShrs,false);
            }
        } catch(Exception exc){
            System.debug('Exception in DocketSharingBatch: ' + exc.getMessage());
        }
    }

    global void finish(Database.BatchableContext bc) {

    }
}