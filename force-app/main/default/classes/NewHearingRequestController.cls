public with sharing class NewHearingRequestController {
    @AuraEnabled
    public static void createDocketRequestAndAttachment(String docketId,String selectedRequestType,List<MultipleDocketRequestDataWrapper> mulDocketRequestRecords,SingleDocketRequestDataWrapper singleDocketReqDeatils) {
        try{
            Map<String,Id> docketRecordTypeNameIdMap = new Map<String,Id>();
            List<BackendUseDataWrapper> datForFurtherUse = new List<BackendUseDataWrapper>();
            Integer count = 0;
            Map<Integer,Docket_Request__c> docketRequestListToBeCreateMap = new Map<Integer,Docket_Request__c>();
            if(selectedRequestType == 'Intent to Assess'){
                docketRecordTypeNameIdMap.put('Intent to Assess',Schema.SObjectType.Docket_Request__c.getRecordTypeInfosByDeveloperName().get('Intent_to_Assess').getRecordTypeId());
            }else if(selectedRequestType == 'Secondary Assessment'){
                docketRecordTypeNameIdMap.put('Secondary Assessment',Schema.SObjectType.Docket_Request__c.getRecordTypeInfosByDeveloperName().get('Secondary_Assessment').getRecordTypeId());
            }else if(selectedRequestType == 'Refund Denial or Adjustment'){
                docketRecordTypeNameIdMap.put('Refund Denial or Adjustment',Schema.SObjectType.Docket_Request__c.getRecordTypeInfosByDeveloperName().get('Refund_Denial_or_Adjustment').getRecordTypeId());
            }else if(selectedRequestType == 'License Denial'){
                docketRecordTypeNameIdMap.put('License Denial',Schema.SObjectType.Docket_Request__c.getRecordTypeInfosByDeveloperName().get('License_Denial').getRecordTypeId());
            }else if(selectedRequestType == 'Seizure'){
                docketRecordTypeNameIdMap.put('Seizure',Schema.SObjectType.Docket_Request__c.getRecordTypeInfosByDeveloperName().get('Seizure').getRecordTypeId());
            }else if(selectedRequestType == 'Intent to Assess/Refund Denial or Adjustment'){
                docketRecordTypeNameIdMap.put('Intent to Assess',Schema.SObjectType.Docket_Request__c.getRecordTypeInfosByDeveloperName().get('Intent_to_Assess').getRecordTypeId());
                docketRecordTypeNameIdMap.put('Refund Denial or Adjustment',Schema.SObjectType.Docket_Request__c.getRecordTypeInfosByDeveloperName().get('Refund_Denial_or_Adjustment').getRecordTypeId());
            }
            if(selectedRequestType == 'Intent to Assess' || selectedRequestType == 'Secondary Assessment' ||
                selectedRequestType == 'Refund Denial or Adjustment' || selectedRequestType == 'Intent to Assess/Refund Denial or Adjustment'){
                    if(mulDocketRequestRecords.size()>0){
                        for(MultipleDocketRequestDataWrapper mdr: mulDocketRequestRecords){
                            Docket_Request__c dr = new Docket_Request__c();
                            dr.Docket__c = docketId;
                            if(selectedRequestType == 'Intent to Assess/Refund Denial or Adjustment'){
                                dr.RecordTypeId = docketRecordTypeNameIdMap.get(mdr.subType);
                            }else{
                                dr.RecordTypeId = docketRecordTypeNameIdMap.get(selectedRequestType);
                            }
                            
                            dr.Date_of_Notice__c = mdr.dateOfNotice;
                            dr.Tax_Period_End_Date__c = mdr.taxEndDate;
                            dr.Tax_Type__c = mdr.taxType;
                            dr.Intent_Number__c = mdr.intentNumber;
                            docketRequestListToBeCreateMap.put(count,dr);
                            if(String.isNotEmpty(mdr.docketAttachmentType)){
                                BackendUseDataWrapper budw = new BackendUseDataWrapper();
                                budw.docketAttachmentType=mdr.docketAttachmentType;
                                budw.srNo=count;
                                budw.notes=mdr.taxpayerNotes;
                                budw.contentVersionIdList=mdr.contentVersionIdList;
                                datForFurtherUse.add(budw);
                               
                            }
                            count++;
                        }
                    }
            }else if(selectedRequestType == 'License Denial'){
                Docket_Request__c dr = new Docket_Request__c();
                dr.Docket__c = docketId;
                dr.RecordTypeId = docketRecordTypeNameIdMap.get(selectedRequestType);
                dr.Date_of_Notice__c = singleDocketReqDeatils.dateOfNotice;
                docketRequestListToBeCreateMap.put(count,dr);
                if(String.isNotEmpty(singleDocketReqDeatils.docketAttachmentType)){
                    BackendUseDataWrapper budw = new BackendUseDataWrapper();
                    budw.docketAttachmentType=singleDocketReqDeatils.docketAttachmentType;
                    budw.srNo=count;
                    budw.notes=singleDocketReqDeatils.taxpayerNotes;
                    budw.contentVersionIdList=singleDocketReqDeatils.contentVersionIdList;
                    datForFurtherUse.add(budw);
                    
                }
                count++;
            }else if(selectedRequestType == 'Seizure'){
                Docket_Request__c dr = new Docket_Request__c();
                dr.Docket__c = docketId;
                dr.RecordTypeId = docketRecordTypeNameIdMap.get(selectedRequestType);
                dr.Date_of_Notice__c = singleDocketReqDeatils.dateOfNotice;
                dr.Complaint_Number__c = singleDocketReqDeatils.complaintNumber;
                dr.Owner_Believed_to_Be__c = singleDocketReqDeatils.believedToBe;
                dr.Location_Where_Seized__c = singleDocketReqDeatils.seizedLocation;
                docketRequestListToBeCreateMap.put(count,dr);
                if(String.isNotEmpty(singleDocketReqDeatils.docketAttachmentType)){
                    BackendUseDataWrapper budw = new BackendUseDataWrapper();
                    budw.docketAttachmentType=singleDocketReqDeatils.docketAttachmentType;
                    budw.srNo=count;
                    budw.notes=singleDocketReqDeatils.taxpayerNotes;
                    budw.contentVersionIdList=singleDocketReqDeatils.contentVersionIdList;
                    datForFurtherUse.add(budw);
                    
                }
                count++;
            }
            if(docketRequestListToBeCreateMap.values().size()>0){
                insert docketRequestListToBeCreateMap.values();
                Map<String,Docket_Attachment__c> docketAttachmentListToBeCreateUpdate =new Map<String,Docket_Attachment__c>();
                List<ContentDocumentLink> ContentDocumentLinkListToBeInsert = new List<ContentDocumentLink>();
                if(datForFurtherUse.size()>0){
                    for(BackendUseDataWrapper bck:  datForFurtherUse){
                        if(bck.contentVersionIdList.size()>0){
                            for(String s : bck.contentVersionIdList){
                                Docket_Attachment__c da = new Docket_Attachment__c();
                                da.Docket__c = docketId;
                                da.Docket_Request__c = docketRequestListToBeCreateMap.get(bck.srNo).Id;
                                if(bck.docketAttachmentType == 'Supporting Documentation'){
                                    da.Attachment_Type__c = 'Request for Hearing/Informal Conference';
                                }else{
                                    da.Attachment_Type__c = bck.docketAttachmentType;
                                }
                                
                                da.Taxpayer_Notes__c = bck.notes;
                                da.Visible_to_Community__c = 'Yes';
                                da.Contains_FTI__c = 'No';
                                da.Attachment_Backup_Status__c ='Not Started';
                                docketAttachmentListToBeCreateUpdate.put(s,da);
                            }
                        }
                        
                    }
                }
                
                if(docketAttachmentListToBeCreateUpdate.values().size()>0){
                    insert docketAttachmentListToBeCreateUpdate.values();
                    for(String s:  docketAttachmentListToBeCreateUpdate.keySet()){
                                ContentDocumentLink cdl = new ContentDocumentLink();
                                cdl.ContentDocumentId = s;
                                cdl.LinkedEntityId = docketAttachmentListToBeCreateUpdate.get(s).Id;
                                cdl.Visibility = 'AllUsers';
                                ContentDocumentLinkListToBeInsert.add(cdl);
                    }
                }
                if(ContentDocumentLinkListToBeInsert.size()>0){
                    insert ContentDocumentLinkListToBeInsert;
                }
            }
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    private Static ContentDocumentLink uploadAttachment(string docAttchId,string contentDocumentId){

            ContentDocumentLink cdl = new ContentDocumentLink();

            cdl.ContentDocumentId = contentDocumentId;
            cdl.LinkedEntityId = docAttchId;
			cdl.Visibility = 'AllUsers';
            return cdl;
    }

    // wrapper class with @AuraEnabled and {get;set;} properties 
    public class BackendUseDataWrapper{
        
        @AuraEnabled
        public Integer srNo {get;set;}
        @AuraEnabled
        public String docketAttachmentType{get;set;}
        @AuraEnabled
        public String notes{get;set;}
        public List<String> contentVersionIdList{get;set;}
    }
    // wrapper class with @AuraEnabled and {get;set;} properties 
    public class SingleDocketRequestDataWrapper{
        @AuraEnabled
        public Date dateOfNotice{get;set;}
        @AuraEnabled
        public String complaintNumber{get;set;}
        @AuraEnabled
        public String believedToBe{get;set;}
        @AuraEnabled
        public String seizedLocation{get;set;}
        @AuraEnabled
        public String docketAttachmentType{get;set;}
        @AuraEnabled
        public String taxpayerNotes{get;set;}
        @AuraEnabled
        public List<String> contentVersionIdList{get;set;}
    }
    public class MultipleDocketRequestDataWrapper{
        @AuraEnabled
        public String subType{get;set;}
        @AuraEnabled
        public Date dateOfNotice{get;set;}
        @AuraEnabled
        public String intentNumber{get;set;}
        @AuraEnabled
        public Date taxEndDate{get;set;}
        @AuraEnabled
        public String taxType{get;set;}
        @AuraEnabled
        public String docketAttachmentType{get;set;}
        @AuraEnabled
        public String taxpayerNotes{get;set;}
        @AuraEnabled
        public List<String> contentVersionIdList{get;set;}
    }
}