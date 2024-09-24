/******************************************************
 Author: Bhushan
 Description: This Apex class used in flow to make callout to ECC system and create the account from response.
 ******************************************************/
public class eccCalloutApexAction{

//Method which is used in flow to make callout to MiTreas system.
@InvocableMethod(label='Callout to ECC From Flow')
public static List<outputResponse> eccCallout(List<APIParameters> inputParamList){
    
    List<outputResponse> outputResponse = new List<outputResponse>();
    
    String iType = null;
    String iNumber = null;
    
    if(inputParamList != null && !inputParamList.isEmpty()){

    APIParameters params = inputParamList[0];
    
    iType = params.identiType;
    iNumber = params.identiNumber;
    
    System.debug('iType input==============>'+iType);
    System.debug('iNumber input==============>'+iNumber);
        }
        
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);
        request.setEndpoint('callout:ECC_API_Callout/sap/bc/zsalesforce/salesfroce?ID_TYPE='+iType+'&ID_NUMBER='+iNumber+'&Format=json&sap-client=261');
        
        Http http = new Http();
        
        try{
            System.debug('Request==============>'+request);
            HTTPResponse response = http.send(request);
        
            if(response.getStatusCode() == 200){
        
            String resBody = response.getBody(); 
            System.debug('MiTreas Callout Success - Http Code' + response.getStatusCode());
            System.debug('Success Response body' + response.getBody());
            
            List<Object> responseList = (List<Object>)JSON.deserializeUntyped(resBody);
            System.debug('responseList==============>'+responseList);
            System.debug('responseList size==============>'+responseList.size());
            
            for(Object result : responseList){
            
            Map<String, Object> recordMap = (Map<String, Object>) result;
            
            String accountname = (String) recordMap.get('ACCOUNT_NAME');
            String FTIFlag = (String) recordMap.get('FTI_FLAG');
            String IdentificationType = (String) recordMap.get('ID_TYPE');
            String IdentificationNumber = (String) recordMap.get('ID_NUMBER');
            String ErrorMessage = (String) recordMap.get('ERROR_MESSAGE');
            String BPnber = (String) recordMap.get('ACCOUNT_NO');
            
            System.debug('accountname   ==============>'+accountname);
            System.debug('FTIFlag    ==============>'+FTIFlag);
            System.debug('IdentificationType ==============>'+IdentificationType);
            System.debug('IdentificationNumber ==============>'+IdentificationNumber);
            System.debug('ErrorMessage ==============>'+ErrorMessage);
            System.debug('BP Number ==============>'+BPnber);
            
            Id AccId = null;
            integer ErrorCode;
            Id duplicateId = null;
            boolean haveDuplicate;
            String aName;
            String aType;
            String aTaxID;
            String aCfti;
            
            if(ErrorMessage == ''){
            System.debug('Account create inside ==============>');
            List<accountOutput> accoutput = createAccount(accountname,FTIFlag,IdentificationType,IdentificationNumber,BPnber);
            if(!accOutput.isEmpty()){
            System.debug('Inside account output return ==============>');
            
            System.debug('accOutput ==============>'+accOutput);
            System.debug('accOutput[0].dupaccId ==============>'+accOutput[0].dupaccId);
            System.debug('accOutput[0].accId ==============>'+accOutput[0].accId);
            System.debug('accOutput[0].containsDuplicates ==============>'+accOutput[0].containsDuplicates);
            
            if(accOutput[0].dupaccId == null){
            AccId = accOutput[0].accId;
            }else{
            AccId = null;
            }
            
            if(accOutput[0].accId == null){
            duplicateId = accOutput[0].dupaccId;
            haveDuplicate = accOutput[0].containsDuplicates;
            }else{
            duplicateId = null;
            haveDuplicate = false;
            }
            
            System.debug('AccId ==============>'+AccId);
            System.debug('duplicateId ==============>'+duplicateId);
            System.debug('haveDuplicate ==============>'+haveDuplicate);
           
            }
            }else{
            ErrorCode = 420;
            System.debug('ErrorCode ==============>'+ErrorCode);
            }
            
            String Responsedts = response.getBody();
            integer StatusCode = response.getStatusCode();
            String Status = response.getStatus();
            
            outputResponse addoutput = new outputResponse();
            addoutput.accountID = AccId;
            addoutput.ErrorMessage = ErrorMessage;
            addoutput.StatusCode = StatusCode;
            addoutput.Status = Status;
            addoutput.OutputBPnber = BPnber;
            addoutput.OutputiType = IdentificationType;
            addoutput.OutputiNumber = IdentificationNumber;
            addoutput.ErrorCode = ErrorCode;
            System.debug('check here ==============>');
            System.debug('haveDuplicate ==============>'+haveDuplicate);
            System.debug('duplicateId ==============>'+duplicateId);
            System.debug('accountname ==============>'+accountname);
            System.debug('FTIFlag ==============>'+FTIFlag);
            addoutput.HasDuplicate = haveDuplicate;
            addoutput.DuplicateACID = duplicateId;
            addoutput.accountname = accountname;
            addoutput.FTIFlag = FTIFlag;
            
            outputResponse.add(addoutput);
            System.debug('outputResponse==============>'+outputResponse);
               
            break;
            }
        
            }else{
        
            System.debug('MiTreas statuscode not 200' + response.getStatusCode());
            System.debug('Response body status code not 200' + response.getBody());
            
            integer errorStatusCode = response.getStatusCode();
            String errorStatus = response.getStatus();
            
            outputResponse addErroroutput = new outputResponse();
            addErroroutput.StatusCode = errorStatusCode;
            addErroroutput.Status = errorStatus;
            outputResponse.add(addErroroutput);
            
            System.debug('Error outputResponse==============>'+outputResponse);
        
            }
        
        }catch(Exception ex){
            System.debug('Exception occurred while making the API call:' + ex.getMessage());
            
            
            
        }
            return outputResponse;
    }

//Method to create account record from response
public static list<accountOutput> createAccount(String accountname,String FTIFlag,String IdentificationType,String IdentificationNumber,String BPnber){
           System.debug('Inside create account ==============>');
           
           list<accountOutput> accountOutput = new list<accountOutput>();
           
           Id AcId = null;
           Boolean duplicate = false;
           Id duaccId = null;
           
            Account ac = new Account();
            ac.Name = accountname;
            if(IdentificationType == 'FEIN' && !IdentificationNumber.startsWith('TC')){
            ac.Type = 'Business Taxpayer';
            }else{
            ac.Type = 'Individual Taxpayer';
            }
            ac.RecordTypeId = System.Label.Account_RecordType;
            
            if(IdentificationType == 'FEIN'){
            ac.Tax_ID__c = 'F'+IdentificationNumber;
            }else if(IdentificationType == 'SSN'){
            ac.Tax_ID__c = 'S'+IdentificationNumber;
            }else if(IdentificationType == 'TR'){
            ac.Tax_ID__c = 'F'+IdentificationNumber;
            }else if(IdentificationType == 'TC'){
            ac.Tax_ID__c = 'F'+IdentificationNumber;
            }else if(IdentificationType == 'ME'){
            ac.Tax_ID__c = 'F'+IdentificationNumber;
            }else{
            ac.Tax_ID__c = IdentificationNumber;
            }
            
            ac.BP_Number__c = BPnber;
            
            ac.Contains_FTI__c = 'No';
            
            
            Id AccountId = null;
            
            
            List<Account> acctList = new List<Account>();
            acctList.add(ac);
            Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(acctList);
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
                      duaccId = matchrec.Id;
                      duplicate = true;
                      System.debug('duaccId : ' + duaccId);
                      
                      }
                  }
                }
              }
            }
            
            if(duaccId == null && !duplicate){
            System.debug('Duplicates not found');
                      Database.SaveResult saveResult = Database.insert(ac, false);
                      AcId = ac.Id;
            
            }
            
            accountOutput aOutput = new accountOutput();
           
            aOutput.accId = AcId;
            aOutput.containsDuplicates = duplicate ;
            aOutput.dupaccId = duaccId;
            
            accountOutput.add(aOutput);
            
            System.debug('accountOutput return==============>'+accountOutput);
            System.debug('aOutput.accId ==============>'+aOutput.accId);
            System.debug('aOutput.containsDuplicates ==============>'+aOutput.containsDuplicates);
            System.debug('aOutput.dupaccId ==============>'+aOutput.dupaccId);
           
            return accountOutput;
            }
          
//Wrapper class for input parameters
public class APIParameters{
    @InvocableVariable(required=true)
    public String identiType;
    
    @InvocableVariable(required=true)
    public String identiNumber;
    
    }

//Wrapper class for output parameters
   public class outputResponse{
   
    @InvocableVariable
    public Id accountID;
    
    @InvocableVariable
    public String ErrorMessage;
    
    @InvocableVariable
    public integer StatusCode;
    
    @InvocableVariable
    public String Status;
    
    @InvocableVariable
    public String OutputBPnber;
    
    @InvocableVariable
    public String OutputiType;
    
    @InvocableVariable
    public String OutputiNumber;
    
    @InvocableVariable
    public integer ErrorCode;
    
    @InvocableVariable
    public Boolean HasDuplicate;
    
    @InvocableVariable
    public Id DuplicateACID;
    
    @InvocableVariable
    public String accountname;
    
    @InvocableVariable
    public String FTIFlag;
    
    }
    
    //Wrapper class for account output.
   public class accountOutput{
   
    @InvocableVariable
    public Id accId;
    
    @InvocableVariable
    public Boolean containsDuplicates;
    
    @InvocableVariable
    public Id dupaccId;
    
    
    }



}