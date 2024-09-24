/******************************************************
 Author: Bhushan
 Description: Test class for eccCalloutApexAction Apex class.
 ******************************************************/
@isTest
public class eccCalloutApexActionTest {

@isTest
    static void testECCCallout() {
        // Set up the mock response
        String mockResponse = '[{"ID_TYPE":"BP","ID_NUMBER":"1234521309","ACCOUNT_NO":"0000021309","ACCOUNT_NAME":"CITY TEST","ASSESSMENT_NO":"000014102393N002","SYSTEM_DATE":"2024-06-20","PRIMARY_SECONDARY_ACCT":"P","PROJECT_CODE":"BEC","INTENT_DATE":"","FTI_FLAG":"No","TAX_TYPE":"DETI","TAX_PERIOD_START_DATE":"","TAX_PERIOD_END_DATE":"","ORIGINAL_TAX_AMOUNT":0,"ORIGINAL_PENALTY_AMOUNT":25.00,"ORIGINAL_INTEREST_AMOUNT":0,"FINAL_DATE":"","HEARING_HOLD":"X","FBTYP":"CTYI","ERROR_MESSAGE":""}]';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(mockResponse);
        res.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(res));

        // Prepare input parameters
        eccCalloutApexAction.APIParameters inputParams = new eccCalloutApexAction.APIParameters();
        inputParams.identiType = 'BP';
        inputParams.identiNumber = '1234521309';

        List<eccCalloutApexAction.APIParameters> inputParamList = new List<eccCalloutApexAction.APIParameters>();
        inputParamList.add(inputParams);

        Test.startTest();
        List<eccCalloutApexAction.outputResponse> result = eccCalloutApexAction.eccCallout(inputParamList);
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals('CITY TEST', result[0].accountname);
        System.assertEquals('No', result[0].FTIFlag);
        System.assertEquals('BP', result[0].OutputiType);
        System.assertEquals('1234521309', result[0].OutputiNumber);
        System.assertEquals('0000021309', result[0].OutputBPnber);
        System.assertEquals(200, result[0].StatusCode);
        System.assertEquals('', result[0].ErrorMessage);
    }
    
    @isTest
    static void testCreateAccount() {
        // Prepare the account creation test
        List<eccCalloutApexAction.accountOutput> accountOutput = eccCalloutApexAction.createAccount('Test Account', 'No', 'BP', '123456789', 'SAP123456');

        System.assertEquals(1, accountOutput.size());
        System.assertNotEquals(null, accountOutput[0].accId);
        System.assertEquals(false, accountOutput[0].containsDuplicates);
    }

    }