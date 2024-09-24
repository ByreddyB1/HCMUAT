/******************************************************
 Author: Bhushan
 Description: Testy class for duplicateAccountApexAction.
 ******************************************************/
@isTest
public class duplicateAccountApexActionTest {

    @isTest
    static void testCreateDuplicateAccount() {
        // Prepare input parameters
        duplicateAccountApexAction.APIParameters inputParams = new duplicateAccountApexAction.APIParameters();
        inputParams.accountname = 'Test Account';
        inputParams.IdentificationType = 'FEIN';
        inputParams.IdentificationNumber = '123456789';
        inputParams.FTIFlag = 'No';
        inputParams.BPnber = 'SAP123456';

        List<duplicateAccountApexAction.APIParameters> inputParamList = new List<duplicateAccountApexAction.APIParameters>();
        inputParamList.add(inputParams);

        Test.startTest();
        List<duplicateAccountApexAction.outputResponse> result = duplicateAccountApexAction.createDuplicateAccount(inputParamList);
        Test.stopTest();

        // Assertions
        System.assertEquals(1, result.size());
        System.assertNotEquals(null, result[0].accountIDfrmDup);
        
        Account acc = [SELECT Id, Name, Type, Tax_ID__c, BP_Number__c, Contains_FTI__c FROM Account WHERE Id = :result[0].accountIDfrmDup];
        System.assertEquals('Test Account', acc.Name);
        System.assertEquals('Business Taxpayer', acc.Type);
        System.assertEquals('F123456789', acc.Tax_ID__c);
        System.assertEquals('SAP123456', acc.BP_Number__c);
        //System.assertEquals('No', acc.Contains_FTI__c);
    }
}