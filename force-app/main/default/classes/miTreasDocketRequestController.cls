/******************************************************
 Author: Bhushan
 Description: This Apex class used to make callout to MiTreas system and display the details in LWC component, create the docket request records.
 ******************************************************/
public class miTreasDocketRequestController {

//Method to send Callout to MiTreas system and and display the details in LWC component
@AuraEnabled
Public static List<outputResponse> miTreasDocketRequest(string docketId){

List<outputResponse> outputResponse = new List<outputResponse>();
integer bpNumber = null;
String identiType = null;
String identiNumber = null;
Docket__c doc =[select id,Taxpayer_Account__r.BP_Number__c,Taxpayer_Account__r.Tax_ID__c from Docket__c where id=:docketId];

if(doc.Taxpayer_Account__r.BP_Number__c != null){
identiType = 'BP';
identiNumber = String.valueof(doc.Taxpayer_Account__r.BP_Number__c);

}else if(doc.Taxpayer_Account__r.Tax_ID__c != null){

String TaxID = doc.Taxpayer_Account__r.Tax_ID__c;

if(TaxID.startsWith('S')){

identiType = 'SSN';
identiNumber = TaxID.substring(1);

}else if(TaxID.startsWith('F')){

identiType = 'FEIN';
identiNumber = TaxID.substring(1);

}else{

AuraHandledException e = new AuraHandledException('BP Number/Tax ID not available for this docket.');
        e.setMessage('BP Number/Tax ID not available for this docket.');
        system.debug(e);
        throw e; 
}

}


HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);
        request.setEndpoint('callout:MiTreas_API_Call/sap/opu/odata/SAP/ZCM_I_061_SELECTED_ACC_API_SRV/ET_BPDETAILSSet?$filter=%20IdentificationType%20eq%20%27'+identiType+'%27%20and%20IdentificationNumber%20eq%20%27'+identiNumber+'%27&$format=json');
        
        Http http = new Http();
        
        try{
            System.debug('Request==============>'+request);
            HTTPResponse response = http.send(request);
        
            if(response.getStatusCode() == 200){
        
            String resBody = response.getBody(); 
            System.debug('MiTreas Callout Success - Http Code' + response.getStatusCode());
            System.debug('Success Response body' + response.getBody());
        
            Map<String, Object> resMap = (Map<String, Object>) JSON.deserializeUntyped(resBody);
            System.debug('resMap  ==============>'+resMap);
            
            Map<String, Object> rsMap = (Map<String, Object>) resMap.get('d');
            System.debug('rsMap  ==============>'+rsMap);
            
            List<Object> responseList = (List<Object>)rsMap.get('results');
            System.debug('responseList==============>'+responseList);
            System.debug('responseList size==============>'+responseList.size());
            
            for(Object result : responseList){
            
            Map<String, Object> recordMap = (Map<String, Object>) result;
              
             String responseErrorMessage = (String) recordMap.get('ErrorMessage');
                if(!String.isEmpty(responseErrorMessage)){
                    //throw new AuraHandledException(responseErrorMessage);
                    AuraHandledException e = new AuraHandledException(responseErrorMessage);
                    e.setMessage(responseErrorMessage);
                    system.debug(e);
                    throw e; 
                }
                  
            String Responsedts = response.getBody();
            integer StatusCode = response.getStatusCode();
            
            //date TaxStartDate = Date.parse((String) recordMap.get('TaxPeriodStartDate'));
           // System.debug('(String) recordMap.get('TaxPeriodStartDate')==============>'+(String) recordMap.get('TaxPeriodStartDate'));
           // System.debug('TaxStartDate check==============>'+TaxStartDate);
            
            String rawTaxPeriodStartDate = (String)recordMap.get('TaxPeriodStartDate');
            String formattedTaxPeriodStartDate = formatDateString(rawTaxPeriodStartDate);
                
            String rawTaxPeriodEndDate = (String)recordMap.get('TaxPeriodEndDate');
            String formattedTaxPeriodEndDate = formatDateString(rawTaxPeriodEndDate);
             
            String rawSystemDate = (String)recordMap.get('SystemDate');
            String formattedSystemDate = formatDateString(rawSystemDate);
                
            String rawIntentDate = (String)recordMap.get('IntentDate');
            String formattedIntentDate = formatDateString(rawIntentDate);
            
            String rawFinalAssmntDate = (String)recordMap.get('FinalAssmntDate');
            String formattedFinalAssmntDate = formatDateString(rawFinalAssmntDate);
                   
            outputResponse addoutput = new outputResponse();
            addoutput.IdentificationType = (String) recordMap.get('IdentificationType');
            addoutput.IdentificationNumber = (String) recordMap.get('IdentificationNumber');
            addoutput.SAPAccountNumber = (String) recordMap.get('SAPAccountNumber');
            addoutput.AccountName = (String) recordMap.get('AccountName');
            addoutput.AssessmentNumber = (String) recordMap.get('AssessmentNumber');
            addoutput.SystemDate = formattedSystemDate;
            addoutput.PrimarySecondaryAccount = (String) recordMap.get('PrimarySecondaryAccount');
            addoutput.ProjectCode = (String) recordMap.get('ProjectCode');
            addoutput.IntentDate = formattedIntentDate;
            addoutput.FTIFlag = (String) recordMap.get('FTIFlag');
            addoutput.TaxType = (String) recordMap.get('TaxType');
            addoutput.TaxPeriodStartDate = formattedTaxPeriodStartDate;
            System.debug('addoutput.TaxPeriodStartDate==============>'+addoutput.TaxPeriodStartDate);
            addoutput.TaxPeriodEndDate = formattedTaxPeriodEndDate;
            addoutput.OriginalTaxAmount = (String) recordMap.get('OriginalTaxAmount');
            addoutput.OriginalPenaltyAmount = (String) recordMap.get('OriginalPenaltyAmount');
            addoutput.OriginalInterestAmount = (String) recordMap.get('OriginalInterestAmount');
            addoutput.FinalAssessmentDate = formattedFinalAssmntDate;
            addoutput.HearingHoldIndicator = (String) recordMap.get('HearLck');
            outputResponse.add(addoutput);
            System.debug('outputResponse==============>'+outputResponse);
            
    
            }
        
            }else{
        
            System.debug('MiTreas Callout Failed' + response.getStatusCode());
            System.debug('Failed Response body' + response.getBody());
            //throw new AuraHandledException(response.getStatusCode()+'-'+response.getStatus());
            AuraHandledException e = new AuraHandledException(response.getStatusCode()+'-'+response.getStatus());
            e.setMessage(response.getStatusCode()+'-'+response.getStatus());
            system.debug(e);
            throw e; 
            }
        
        }catch(Exception ex){
            System.debug('Exception occurred while making the API call:' + ex.getMessage());    
            String exMsg = ex.getMessage();
            throw new AuraHandledException(exMsg);  
        }

return outputResponse;

}

//Method to create docket Request record
 @AuraEnabled
Public static void createDocketRequest(string docketId,String selectionList){

    System.debug('selectionList' + selectionList);
    List<outputResponse> selectedRecords = (List<outputResponse>)JSON.deserialize(selectionList, List<outputResponse>.class);
    System.debug('selectedRecords' + selectedRecords);
    List<Docket_Request__c> drList = new List<Docket_Request__c>();
    //System.debug('selectionlist' + selectionlist);
    
   try{
   
           Boolean duplicate = false;
           Id dupDocRqId = null;
   
   // Query Docket to get its type
        Docket__c docket = [SELECT Type__c FROM Docket__c WHERE Id = :docketId];

        // Determine the record type name for Docket Request based on Docket type
        String recordTypeName = docket.Type__c;
        
        System.debug('recordTypeName==============>' + recordTypeName);
        Id recordTypeId;
        // Get the record type ID dynamically
        if(docket.Type__c == 'Intent to Assess/Refund Denial or Adjustment'){
        recordTypeId = Schema.SObjectType.Docket_Request__c.getRecordTypeInfosByName().get('Intent to Assess').getRecordTypeId();
        }else{
        recordTypeId = Schema.SObjectType.Docket_Request__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        }
        System.debug('recordTypeId==============>' + recordTypeId);
        
   for(outputResponse sl:selectedRecords)
   {
   
     //Date slSystemdate = parseDateString(sl.SystemDate);
     System.debug('sl.TaxType==============>'+sl.TaxType);
       String taxType = sl.TaxType;
       String taxTypeVal = '';
       System.debug('TaxType==============>'+taxType);
       Map<String, MiTreas_Docket_Request_Mapping__mdt> docreqtaxMap = MiTreas_Docket_Request_Mapping__mdt.getAll();
       System.debug('docreqtaxMap values---- ' + docreqtaxMap.values());
       taxTypeVal = docreqtaxMap.get(taxType).Tax_Type_Value__c;
       System.debug('taxTypeVal=======' + taxTypeVal);
     
       Docket_Request__c dr = new Docket_Request__c();
       dr.Docket__c = docketId;
       dr.RecordTypeId = recordTypeId;
       dr.Identification_Type__c = sl.IdentificationType;
       dr.Identification_Number__c = sl.IdentificationNumber;
       dr.SAP_Account_number__c = sl.SAPAccountNumber;
       dr.Account_Name__c = sl.AccountName;
       dr.Intent_Number__c = sl.AssessmentNumber;
       System.debug('sl.SystemDate==============>'+sl.SystemDate);
       System.debug('parseDateStringMethod(sl.SystemDate)==============>'+parseDateStringMethod(sl.SystemDate));
       dr.System_Date__c = parseDateStringMethod(sl.SystemDate);
       dr.Primary__c = sl.PrimarySecondaryAccount;
       dr.Project_Code__c = sl.ProjectCode;
       System.debug('sl.IntentDate==============>'+sl.IntentDate);
       System.debug('parseDateStringMethod(sl.IntentDate)==============>'+parseDateStringMethod(sl.IntentDate));
       dr.Date_of_Notice__c = parseDateStringMethod(sl.IntentDate);
       if(!String.isEmpty(sl.FTIFlag)){
       dr.Contains_FTI__c = 'Yes';
       dr.FTI_Comments__c = 'S4';
       }else{
       dr.Contains_FTI__c = 'No';
       }
       System.debug('taxTypeVal==============>'+taxTypeVal);
       if(!String.isEmpty(taxTypeVal)){
       dr.Tax_Type__c = taxTypeVal;
       }
       System.debug('sl.TaxPeriodStartDate==============>'+sl.TaxPeriodStartDate);
       System.debug('parseDateStringMethod(sl.TaxPeriodStartDate)==============>'+parseDateStringMethod(sl.TaxPeriodStartDate));
       dr.Tax_Period_Start_Date__c = parseDateStringMethod(sl.TaxPeriodStartDate);
       System.debug('sl.TaxPeriodEndDate==============>'+sl.TaxPeriodEndDate);
       System.debug('parseDateStringMethod(sl.TaxPeriodEndDate)==============>'+parseDateStringMethod(sl.TaxPeriodEndDate));
       dr.Tax_Period_End_Date__c = parseDateStringMethod(sl.TaxPeriodEndDate);
       dr.Original_Tax_Amount__c = Decimal.valueOf(cleanDecimalString(sl.OriginalTaxAmount));
       dr.Original_Penalty_Amount__c = Decimal.valueOf(cleanDecimalString(sl.OriginalPenaltyAmount));
       dr.Original_Interest_Amount__c = Decimal.valueOf(cleanDecimalString(sl.OriginalInterestAmount));
       dr.Final_Assesment_Date__c = parseDateStringMethod(sl.FinalAssessmentDate);
       if(sl.HearingHoldIndicator != null){
       dr.Hearings_Hold_Indicator__c  = 'Yes';
       }else{
       dr.Hearings_Hold_Indicator__c = 'No';
       }
       drList.add(dr); 
       System.debug('drList==============>'+drList);
   }
    
    //insert drList;
    
    Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(drList);
            System.debug('Duplicate results: ' + results);
            for (Datacloud.FindDuplicatesResult findDupeResult : results) {
            System.debug('findDupeResult : ' + findDupeResult);
              for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
              System.debug('dupeResult : ' + dupeResult);
                for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                System.debug('matchResult : ' + matchResult);
                  for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                      System.debug('Duplicate Record find duplicates: ' + matchRecord.getRecord());
                       sObject matchrec;
                       matchrec = matchRecord.getRecord();
                      if(matchrec != null){
                      System.debug('matchrec: ' + matchrec);
                      System.debug('matchrec dup account id: ' + matchrec.Id);
                      dupDocRqId = matchrec.Id;
                      duplicate = true;
                      System.debug('dupDocRqId : ' + dupDocRqId);
                      
                      }
                  }
                }
              }
            }
            
            if(duplicate == true && dupDocRqId != null){
            AuraHandledException e = new AuraHandledException('You are creating a docket request with an existing assessment number.');
            e.setMessage('You are creating a docket request with an existing assessment number.');
            system.debug(e);
            throw e; 
            }else{
            insert drList;
            }
    
    }catch (Exception e) {

            String errorMsg = e.getMessage();
            throw new AuraHandledException(ErrorMsg);
     }
}


    
// Helper method to format date from "YYYYMMDD" to "MM/DD/YYYY"
    private static String formatDateString(String rawDate) {
        if (rawDate != null && rawDate.length() == 8) {
            Integer year = Integer.valueOf(rawDate.substring(0, 4));
            Integer month = Integer.valueOf(rawDate.substring(4, 6));
            Integer day = Integer.valueOf(rawDate.substring(6, 8));

            return month + '/' + day + '/' + year;
        }
        return null;
    }
    
private static Date parseDateStringMethod(String dateString) {
    try {
        if (dateString != null) {
            return Date.parse(dateString);
        }
    } catch (Exception e) {
        
        System.debug('Error parseDateStringMethod: ' + e.getMessage());
    }
    return null;
}

private static String cleanDecimalString(String decimalString) {
    // Remove any non-numeric characters and handle any other format issues
    // For example, replace commas with dots
    return decimalString.replaceAll('[^0-9.]', '');
}

Public class outputResponse {

    @AuraEnabled
    public String IdentificationType{get;set;}
    @AuraEnabled
    public String IdentificationNumber{get;set;}
    @AuraEnabled
    public String SAPAccountNumber{get;set;}
    @AuraEnabled
    public String AccountName{get;set;}
    @AuraEnabled
    public String AssessmentNumber{get;set;}
    @AuraEnabled
    public String SystemDate{get;set;}
    @AuraEnabled
    public String PrimarySecondaryAccount{get;set;}
    @AuraEnabled
    public String ProjectCode{get;set;}
    @AuraEnabled
    public String IntentDate{get;set;}
    @AuraEnabled
    public String FTIFlag{get;set;}
    @AuraEnabled
    public String TaxType{get;set;}
    @AuraEnabled
    public String TaxPeriodStartDate{get;set;}
    @AuraEnabled
    public String TaxPeriodEndDate{get;set;}
    @AuraEnabled
    public String OriginalTaxAmount{get;set;}
    @AuraEnabled
    public String OriginalPenaltyAmount{get;set;}
    @AuraEnabled
    public String OriginalInterestAmount{get;set;}
    @AuraEnabled
    public String FinalAssessmentDate{get;set;}
    @AuraEnabled
    public String HearingHoldIndicator{get;set;}
    
}




}