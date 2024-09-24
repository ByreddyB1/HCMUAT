public without sharing class DocketUtil {
    public static Boolean checkCriteriaToShareDocket(Docket_Participant__c doc){
        System.debug('doc value: ' + doc);

        if(doc.Role__c == 'Taxpayer' || (doc.Role__c == 'Authorized Representative' && doc.Status__c == 'Active' &&
                (doc.Receive_Confidential_Information__c || doc.All_of_the_above__c) &&
                (doc.Authorization_End_Date__c == null || (Date.today() >= doc.Authorization_Start_Date__c && Date.today() < doc.Authorization_End_Date__c)))){
            System.debug('Share Docket');

            return true;
        } else{
            System.debug('Do Not Share Docket');

            return false;
        }
    }
        
    public static void deleteShares(Set<Id> setOfDocketPartIds,Set<Id> setOfContactIds){
        Map<Id,User> mapOfUsers = new Map<Id,User>([SELECT Id FROM user WHERE contactId IN :setOfContactIds]);
        List<Docket__share> alreadyShareRecord = [SELECT Id from Docket__Share WHERE ParentId =: setOfDocketPartIds and UserOrGroupId =: mapOfUsers.keySet()];

        if(alreadyShareRecord != null && alreadyShareRecord.size()>0){
            Database.delete(alreadyShareRecord,false);
        }
    }
    
    public static void createShares(Map<Id,Id> mapOfShares){
        Map<Id,Id> mapOfContactIdToUserId = new Map<Id,Id>();
        for(User userRecord : [select id,contactId from user where contactId IN: mapOfShares.values()]){
            mapOfContactIdToUserId.put(userRecord.contactId,userRecord.Id);
        }
        Map<Id,User> mapOfUsers = new Map<Id,User>([select id from user where contactId IN: mapOfShares.values()]);
        List<Docket__share> listOfSharesToInsert = new List<Docket__share>();
        
        for(Id docketId : mapOfShares.keySet()){
            if(mapOfContactIdToUserId.containsKey(mapOfShares.get(docketId))){
                Docket__share docShare = new Docket__Share();
                docShare.ParentId = docketId;
                docShare.AccessLevel = 'Edit';
                docShare.UserOrGroupId = mapOfContactIdToUserId.get(mapOfShares.get(docketId));
                docShare.RowCause = Schema.Docket__share.RowCause.TreasuryManual__c;
                listOfSharesToInsert.add(docShare);
            }
        }
        if(listOfSharesToInsert.size()>0){
            Database.insert(listOfSharesToInsert,false);
        }
    }
}