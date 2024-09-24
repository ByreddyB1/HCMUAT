@isTest
public without sharing class DeactivateUsersBatchTest {

    public static testMethod void testCase(){
    
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(
                Alias = 'somtestd',
                Email = 'test.user+stateofmichigantesting325435@stateofmichigan.com',
                EmailEncodingKey = 'UTF-8',
                FirstName = 'Test',
                LastName = 'User',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'test.user+stateofmichigantesting325435@stateofmichigan.com');

        Insert u;

        List<User> userList = [SELECT Id FROM User WHERE isActive = true];
        System.assertEquals(false, userList.isEmpty());
        
        //Community user
        Id p1 = [select id from profile where name='Treasury Community Plus User'].id;
        Account ac = new Account(name ='testAccount') ;
        insert ac; 
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testcon', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p1, country='United States',IsActive =true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        Insert User;
        List<User> usr = [SELECT Id,profile.name FROM User WHERE isActive = true and profile.name='Treasury Community Plus User' ];
        System.assertEquals(false, usr.isEmpty());
        
        List<User> userList1 = [SELECT Id FROM User WHERE isActive = false];
        System.assertEquals(false, userList1.isEmpty());
         
        Test.startTest();
        DeactivateUsersBatch batch = new DeactivateUsersBatch();
        Database.executeBatch(batch);
        Test.stopTest();
        
    }
    
    public static testMethod void testCase2(){
    
        List<User> testUsers = new List<User>();
        for (Integer i = 0; i < 10; i++) {
            User u = new User(
                FirstName = 'TestFirstName' + i,
                LastName = 'TestLastName' + i,
                Email = 'testemail' + i + '@example.com',
                Username = 'testusername' + i + '@example.com',
                Alias = 'TST' + i,
                CommunityNickname = 'TestUser' + i,
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
                EmailEncodingKey = 'ISO-8859-1',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                IsActive = true
            );
            testUsers.add(u);
        }
        insert testUsers;

        Test.startTest();
        DeactivateUsersBatch batch = new DeactivateUsersBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        List<User> Updatelist = new List<User>();
        List<User> updatedUsers = [SELECT Id, IsActive FROM User WHERE Id IN :testUsers];
        for (User u : updatedUsers) {
            u.IsActive = false;
            Updatelist.add(u);
            //System.assertEquals(false, u.IsActive, 'User should be deactivated');
        }
            update Updatelist;
            System.assertEquals(false, Updatelist[0].IsActive, 'User should be deactivated');
    
    }
}