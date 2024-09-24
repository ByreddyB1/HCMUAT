public class testMiTreasAPI {    
    
    public static void submit() {
        
        String iType = 'BP';
        String iNumber = '1000020254';
        HttpRequest request = new HttpRequest();
        //request.setEndpoint('https://sap-ecc-dev.state.mi.us/sap/bc/zsalesforce/salesfroce?ID_TYPE=BP&ID_NUMBER=0000021309&Format=json&sap-client=170');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        //request.setEndpoint('callout:ECC_API_Callout/sap/bc/zsalesforce/salesfroce?ID_TYPE=BP&ID_NUMBER=0000021309&Format=json&sap-client=170');
        request.setEndpoint('callout:ECC_API_Callout/sap/bc/zsalesforce/salesfroce?ID_TYPE=BP&ID_NUMBER=0000051916&Format=json&sap-client=291');
        Http http = new Http();
        System.debug('Request==============>'+request);
        HTTPResponse response = http.send(request);
        
        String resBody = response.getBody(); 
        //String resBody = EntityUtils.toString(response.getEntity(),'UTF-8');
        
         System.debug('a.Description Response=======>'+resBody);         
        if (response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected-Failed ============>' +resBody+ '' +response.getStatusCode()+ ' ' +response.getStatus());
        } 
        else  
        {
            System.debug('ECC Success Response==============>'+resBody);
            
            
            
             account a = new account();
             a.Description = resBody;
             a.RecordTypeId = '0128y0000004LGxAAM';
             a.Name ='ECC API connection Test';
             insert a;
            System.debug('ECC Success Account description ==============>'+a.Description);
            
        }     
        
    }
             
  }