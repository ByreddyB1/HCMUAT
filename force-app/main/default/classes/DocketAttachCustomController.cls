public without sharing class DocketAttachCustomController {
    @AuraEnabled
    public static List<DocumentWrapper> getAllDocs(Id parentId){
        try {
            List<DocumentWrapper> mapIdTitle = new List<DocumentWrapper>();
            Map<Id,Docket_Attachment__c> docketAttachmentIdRecordMap = new Map<Id,Docket_Attachment__c>();
            //This will return base url of request
            String sObjName = parentId.getSObjectType().getDescribe().getName();
            System.debug(sObjName);
            if(sObjName == 'Docket__c' || sObjName == 'Docket_Request__c' || sObjName == 'Portal_Request__c' || sObjName == 'Docket_Hearing__c' || sObjName == 'Docket_Abeyance__c'){
                String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
                String query = 'SELECT Id, Attachment_Type__c, Note__c, Taxpayer_Notes__c FROM Docket_Attachment__c WHERE ' + sObjName + ' =:parentId AND Visible_to_Community__c =\'Yes\' AND Contains_FTI__c =\'No\'';
                for(Docket_Attachment__c docketAttachment : Database.query(query)){
                    System.debug('==inside docketAttachmentLoop ==');
                    docketAttachmentIdRecordMap.put(docketAttachment.Id,docketAttachment);
                }
                if(!docketAttachmentIdRecordMap.keySet().isEmpty()){
                    List<ContentDocumentLink> files = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: docketAttachmentIdRecordMap.keySet()];
                    System.debug('==files=='+files.size());
                    Map<Id,Id> contentDocumentIdDocMap = new Map<Id,Id>();
                    for (ContentDocumentLink docLink : files) {
                        contentDocumentIdDocMap.put(docLink.ContentDocumentId,docLink.LinkedEntityId);
                    }
                    Map<Id,ContentVersion> contentVersionMap = new Map<Id,ContentVersion>([SELECT Id, ContentDocumentId, FileExtension, Title FROM ContentVersion WHERE ContentDocumentId IN : contentDocumentIdDocMap.keySet() AND IsLatest = true]) ;
                    Map<String,ContentDistribution> contentVIdContDistributionMap = new Map<String,ContentDistribution>();
                    for(ContentDistribution cd: [SELECT Id, ContentVersionId, DistributionPublicUrl FROM ContentDistribution WHERE ContentVersionId IN: contentVersionMap.keyset()]){
                        contentVIdContDistributionMap.put(cd.ContentVersionId,cd);
                    }
                    List<ContentDistribution> ContentDistributionList = new List<ContentDistribution>();
                    for(Id cid : contentVersionMap.keySet()){
                        if(contentVIdContDistributionMap.size() > 0 && !contentVIdContDistributionMap.containsKey(cid)){
                            ContentDistribution cd = new ContentDistribution(ContentVersionId=cid,PreferencesNotifyOnVisit=false,name=contentVersionMap.get(cid).Title,PreferencesAllowViewInBrowser=true,
                            PreferencesLinkLatestVersion = true,PreferencesAllowOriginalDownload=true);
                            ContentDistributionList.add(cd);
                        }else if(contentVIdContDistributionMap.size() == 0 ) {
                            ContentDistribution cd = new ContentDistribution(ContentVersionId=cid,PreferencesNotifyOnVisit=false,name=contentVersionMap.get(cid).Title,PreferencesAllowViewInBrowser=true,
                            PreferencesLinkLatestVersion = true,PreferencesAllowOriginalDownload=true);
                            ContentDistributionList.add(cd);
                        }
                    }
                    if(ContentDistributionList.size()>0){
                        insert ContentDistributionList;
                        for(ContentDistribution cd: [SELECT Id, ContentVersionId, DistributionPublicUrl FROM ContentDistribution WHERE Id IN: new Map<Id,ContentDistribution>(ContentDistributionList).keyset()]){
                            contentVIdContDistributionMap.put(cd.ContentVersionId,cd);
                        }
                    }
                    for(ContentVersion docLink : contentVersionMap.values()) {
                        if(contentDocumentIdDocMap.containsKey(docLink.ContentDocumentId)){
                            if(docketAttachmentIdRecordMap.containsKey(contentDocumentIdDocMap.get(docLink.ContentDocumentId))){
                                mapIdTitle.add(new DocumentWrapper(docLink.ContentDocumentId, docLink.Title,docLink.Id,baseUrl,
                                docketAttachmentIdRecordMap.get(contentDocumentIdDocMap.get(docLink.ContentDocumentId)).Attachment_Type__c,
                                docketAttachmentIdRecordMap.get(contentDocumentIdDocMap.get(docLink.ContentDocumentId)).Taxpayer_Notes__c,docLink.FileExtension,
                                contentVIdContDistributionMap.containsKey(docLink.Id) == true ? contentVIdContDistributionMap.get(docLink.Id).DistributionPublicUrl : ''));
                            }
                        }

                    }
                }
                System.debug('==returning=='+mapIdTitle.size());
            }

            return mapIdTitle;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() +' at line '+ e.getLineNumber());
        }
    }

    public class DocumentWrapper {
        @AuraEnabled
        public String docId;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String versionId;
        @AuraEnabled
        public String baseUrl;
        @AuraEnabled
        public String attachmentType;
        @AuraEnabled
        public String notes;
        @AuraEnabled
        public String fileExtension;
        @AuraEnabled
        public String fileVDUrl;
        DocumentWrapper(String docId,String name,String versionId,String baseUrl, String attachmentType,String notes,String fileExtension, String fileVDUrl){
            this.docId = docId;
            this.name = name;
            this.versionId = versionId;
            this.baseUrl = baseUrl;
            this.attachmentType = attachmentType;
            this.notes = notes;
            this.fileExtension =fileExtension;
            this.fileVDUrl = fileVDUrl;
        }
    }
}