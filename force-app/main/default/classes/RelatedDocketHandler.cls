public class RelatedDocketHandler {
    public static void beforeInsert( List<Related_Docket__c > relatedDocketList ) {
        Set<Id> listOfDocketIds = new Set<Id>();
        Set<Id> listOfRelatedDocketIds = new Set<Id>();
        List<Related_Docket__c> listOfRDToUpdate = new List<Related_Docket__c>();
        for(Related_Docket__c rd : relatedDocketList){
            listOfDocketIds.add(rd.Docket__c);
            listOfRelatedDocketIds.add(rd.Related_Docket__c);
        }
        Map<String,Related_Docket__c>  mapOfRelatedDockets = getRelatedDockets(listOfRelatedDocketIds,listOfDocketIds);
        
        for(Related_Docket__c rd : relatedDocketList){
            String key = rd.Docket__c + '-' + rd.Related_Docket__c;
            if(mapOfRelatedDockets.containsKey(key)){
                rd.addError('This Related Docket already exists.  Please update the existing one instead of creating a new one');
            }
        }
    }
    public static void afterInsert( List<Related_Docket__c > relatedDocketList ) {
        RecursionHelper.runRelatedDocketTrigger = false;
        List<Related_Docket__c > newListToBeCreate=new List<Related_Docket__c >();
        List<String > docketId=new List<String >();
        List<String > relatedDocketId=new List<String >();
        for(Related_Docket__c rd:relatedDocketList){
            Related_Docket__c newRD=new Related_Docket__c(Docket__c =rd.Related_Docket__c ,Related_Docket__c =rd.Docket__c, Reason__c=rd.Reason__c  );
            newListToBeCreate.add(newRD);
        }
        insert newListToBeCreate;
        
    }
    public static void afterUpdate( List<Related_Docket__c > relatedDocketList ) {
        RecursionHelper.runRelatedDocketTrigger = false;
        Set<Id> listOfDocketIds = new Set<Id>();
        Set<Id> listOfRelatedDocketIds = new Set<Id>();
        List<Related_Docket__c> listOfRDToUpdate = new List<Related_Docket__c>();
        
        for(Related_Docket__c rd : relatedDocketList){
            listOfDocketIds.add(rd.Docket__c);
            listOfRelatedDocketIds.add(rd.Related_Docket__c);
        }
        Map<String,Related_Docket__c>  mapOfRelatedDockets = getRelatedDockets(listOfDocketIds,listOfRelatedDocketIds);
        
        for(Related_Docket__c rd : relatedDocketList){
            String key = rd.Related_Docket__c + '-' + rd.Docket__c;
            if(mapOfRelatedDockets.containsKey(key)){
                Related_Docket__c relatedDocket = mapOfRelatedDockets.get(key);
                relatedDocket.Reason__c = rd.Reason__c;
                listOfRDToUpdate.add(relatedDocket);
            }
        }
        if(listOfRDToUpdate.size()>0){
            update listOfRDToUpdate;
        }
    }
    public static void afterDelete( List<Related_Docket__c > relatedDocketList ) {
        RecursionHelper.runRelatedDocketTrigger = false;
        Set<Id> listOfDocketIds = new Set<Id>();
        Set<Id> listOfRelatedDocketIds = new Set<Id>();
        List<Related_Docket__c> listOfRDToDelete = new List<Related_Docket__c>();
        
        for(Related_Docket__c rd : relatedDocketList){
            listOfDocketIds.add(rd.Docket__c);
            listOfRelatedDocketIds.add(rd.Related_Docket__c);
        }
        
        Map<String,Related_Docket__c>  mapOfRelatedDockets = getRelatedDockets(listOfDocketIds,listOfRelatedDocketIds);
        
        for(Related_Docket__c rd : relatedDocketList){
            String key = rd.Related_Docket__c + '-' + rd.Docket__c;
            if(mapOfRelatedDockets.containsKey(key)){
                listOfRDToDelete.add(mapOfRelatedDockets.get(key));
            }
        }
        
        if(listOfRDToDelete.size()>0){
            delete listOfRDToDelete;
        }
    }
    
    private static Map<String,Related_Docket__c> getRelatedDockets(Set<Id> listOfDocketIds,Set<Id> listOfRelatedDocketIds){
        Map<String,Related_Docket__c> mapOfRelatedDockets = new Map<String,Related_Docket__c>();
        for(Related_Docket__c rd : [select id,Docket__c,Related_Docket__c,Reason__c from Related_Docket__c where Docket__c IN : listOfRelatedDocketIds AND Related_Docket__c IN: listOfDocketIds]){
            mapOfRelatedDockets.put(rd.Docket__c+'-'+rd.Related_Docket__c,rd);
        }
        return mapOfRelatedDockets;
    }
}