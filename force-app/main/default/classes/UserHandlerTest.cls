@IsTest
private class UserHandlerTest {
    @IsTest
    static void testBehavior() {
        List<User> usersList = new List<User>();
        List<Account> accountsList = new List<Account>();
        List<Contact> contactsList = new List<Contact>();
        Map<Id, User> newUsersMap = new Map<Id, User>();
        Map<Id, User> oldUsersMap = new Map<Id, User>();

        Account testAcct = new Account(Name = 'Test Account', Type = 'Representing Agency');

        accountsList.add(testAcct);

        Account testAcct2 = new Account(Name = 'Test Account 2', Type = 'Representing Agency');

        accountsList.add(testAcct2);

        insert accountsList;

        Contact testCon =new Contact(AccountId = testAcct.Id, FirstName = 'Test', LastName = 'Contact', Email = 'test.contactdfasdfsadfs@som.com');

        contactsList.add(testCon);

        Contact testCon2 =new Contact(AccountId = testAcct2.Id, FirstName = 'Test', LastName = 'Contacttwo', Email = 'test.contacttwodfasdfsadfs@som.com');

        contactsList.add(testCon2);

        insert contactsList;

        Profile p = [SELECT Id FROM Profile WHERE Name='Treasury Community Plus User' LIMIT 1];

        User testUser = new User();

        testUser.FirstName = 'Test';
        testUser.LastName = 'User';
        testUser.Email = 'test.contactdfasdfsadfs@som.com';
        testUser.Alias = 'tuser';
        testUser.ProfileId = p.Id;
        testUser.Username = 'test.contactdfasdfsadfs@som.com';
        testUser.TimeZoneSidKey = 'America/New_York';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.IsActive = true;
        testUser.ContactId = testCon.Id;

        usersList.add(testUser);

        User testUser2 = new User();

        testUser2.FirstName = 'Test';
        testUser2.LastName = 'Usertwo';
        testUser2.Email = 'test.usertwodfasdfsadfs@som.com';
        testUser2.Alias = 'tuser2';
        testUser2.ProfileId = p.Id;
        testUser2.Username = 'test.usertwodfasdfsadfs@som.com';
        testUser2.TimeZoneSidKey = 'America/New_York';
        testUser2.LocaleSidKey = 'en_US';
        testUser2.EmailEncodingKey = 'UTF-8';
        testUser2.LanguageLocaleKey = 'en_US';
        testUser2.IsActive = true;
        testUser2.ContactId = testCon2.Id;

        usersList.add(testUser2);

        insert usersList;

        oldUsersMap.put(testUser.Id, testUser);

        testUser2.IsActive = false;

        oldUsersMap.put(testUser2.Id, testUser2);

        UserHandler.afterUpdate(usersList, oldUsersMap);

        System.assertEquals(testUser2.IsActive, false);
        System.assertEquals(usersList.size(), 2);
    }
}