/******************************************************
 Author: Bhushan
 Description: This Apex class used in flow to make callout to create the duplicate account.
 ******************************************************/
public class duplicateAccountApexAction{


//Method which is used in flow to make callout to MiTreas system.
@InvocableMethod(label='Callout to create duplicate account')
public static List<outputResponse> createDuplicateAccount(List<APIParameters> inputParamList){
System.debug('Inside create duplicate account ==============>');
           
           List<outputResponse> outputResponse = new List<outputResponse>();
           
           String accountname;
           String IdentificationType;
           String IdentificationNumber;
           String FTIFlag;
           String BPnber;
           
           if(inputParamList != null && !inputParamList.isEmpty()){
           APIParameters params = inputParamList[0];
           accountname = params.accountname;
           IdentificationType = params.IdentificationType;
           IdentificationNumber = params.IdentificationNumber;
           FTIFlag = params.FTIFlag;
           BPnber = params.BPnber;
           }
           
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;
           
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
            
            Database.SaveResult sr = Database.insert(ac, dml);
            if (sr.isSuccess()) {
             System.debug('Duplicate account has been inserted in Salesforce!');
             }
            //insert ac;
            AccountId = ac.id;
            
            outputResponse addoutput = new outputResponse();
            addoutput.accountIDfrmDup = AccountId;
            
            outputResponse.add(addoutput);
            System.debug('outputResponse==============>'+outputResponse);
            
            System.debug('ac ==============>'+ac);
            System.debug('ac id ==============>'+AccountId);
            
           return outputResponse;

}


//Wrapper class for input parameters
  public class APIParameters{
    @InvocableVariable
    public String accountname;
    
    @InvocableVariable
    public String FTIFlag;
    
    @InvocableVariable
    public String IdentificationType;
    
    @InvocableVariable
    public String IdentificationNumber;
    
    @InvocableVariable
    public String BPnber;
    
    }

//Wrapper class for output parameters
   public class outputResponse{
   
    @InvocableVariable
    public Id accountIDfrmDup;
    
   }
   
}