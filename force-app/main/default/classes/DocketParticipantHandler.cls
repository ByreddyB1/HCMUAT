public without sharing class DocketParticipantHandler {
    
    public static void afterInsertDocketParticipantHandler(List<Docket_Participant__c> newList){
        shareDocketRecord(newList,null);
    }

    public static void afterUpdateDocketParticipantHandler(List<Docket_Participant__c> newList,Map<Id,Docket_Participant__c> oldMap){
        shareDocketRecord(newList,oldMap);
    }

    public static void afterDeleteDocketParticipantHandler(List<Docket_Participant__c> oldList){
        deleteShareDocketRecord(oldList);
    }

    public static void shareDocketRecord(List<Docket_Participant__c> newList,Map<Id,Docket_Participant__c> oldMap){
        Set<Id> setOfDocketIToDeleteIds = new Set<Id>();
        Set<Id> setOfContactToDeleteIds = new Set<Id>();
        Map<Id,Id> mapOfDocketPartToContactId = new Map<Id,Id>();

        try{
            for(Docket_Participant__c docPart : newList){
                if(oldMap == null || docPart.Authorization_End_Date__c != oldMap.get(docPart.Id).Authorization_End_Date__c 
                   || docPart.Role__c != oldMap.get(docPart.Id).Role__c 
                   || docPart.Status__c != oldMap.get(docPart.Id).Status__c
                   || docPart.Receive_Confidential_Information__c != oldMap.get(docPart.Id).Receive_Confidential_Information__c 
                   || docPart.All_of_the_above__c != oldMap.get(docPart.Id).All_of_the_above__c 
                   || docPart.Authorization_Start_Date__c != oldMap.get(docPart.Id).Authorization_Start_Date__c
                   || docPart.Contact__c != oldMap.get(docPart.Id).Contact__c
                  )
                    
                    //if contact is changed on the docket participant, delete the sharing from old contact
                    if(oldMap != null && docPart.Contact__c != oldMap.get(docPart.Id).Contact__c && oldMap.get(docPart.Id).Contact__c != null){
                        setOfDocketIToDeleteIds.add(docPart.Docket__c);
                        setOfContactToDeleteIds.add(oldMap.get(docPart.Id).Contact__c);
                    }
                //if criteria matching, add the shares
                if(DocketUtil.checkCriteriaToShareDocket(docPart)){
                    mapOfDocketPartToContactId.put(docPart.Docket__c,docPart.Contact__c);
                }else{ //otherwise remove the share
                    setOfDocketIToDeleteIds.add(docPart.Docket__c);
                    setOfContactToDeleteIds.add(docPart.Contact__c);
                }
            }
            //delete the shares if there
            if(setOfDocketIToDeleteIds.size()>0){
                DocketUtil.deleteShares(setOfDocketIToDeleteIds,setOfContactToDeleteIds);
            }
            
            //create new shares
            if(mapOfDocketPartToContactId.size()>0){
                DocketUtil.createShares(mapOfDocketPartToContactId);
            }
        } catch(Exception e){
            System.debug(e.getMessage());
        }
    }

    public static void deleteShareDocketRecord(List<Docket_Participant__c> oldList){
        try{
            Set<Id> setOfDocketIdsToDeleteIds = new Set<Id>();
            Set<Id> setOfContactToDeleteIds = new Set<Id>();
            
            for(Docket_Participant__c docPart : oldList){
                setOfDocketIdsToDeleteIds.add(docPart.Docket__c);
                setOfContactToDeleteIds.add(docPart.Contact__c);
            } 
            
            if(setOfDocketIdsToDeleteIds.size() > 0){
                DocketUtil.deleteShares(setOfDocketIdsToDeleteIds,setOfContactToDeleteIds);
            }
        } catch(Exception e){
            
        }
    }
}