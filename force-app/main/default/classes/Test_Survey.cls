/**
 * This class contains unit tests for validating the Survey classes
 */

@isTest(SeeAllData = false)
private class Test_Survey
{
    static testMethod void testSurveyBase()
    {
        Test.startTest();
        try
        {
            SurveyBase.LoadResponseInput testLoadResponseInput = new SurveyBase.LoadResponseInput();
            SurveyEntry testSurveyEntry = new SurveyEntry();
            SurveyBase.SurveyResponse testSurveyResponse = new SurveyBase.SurveyResponse(testLoadResponseInput);
            SurveyBase.SubmitResponseInput testSubmitResponseInput = new SurveyBase.SubmitResponseInput();
            SurveyBase.SubmitResponseResult testSubmitResponseResult = new SurveyBase.SubmitResponseResult();
            Set<String> testgetValidCSATs = SurveyBase.getValidCSATs();
            
        }
        catch (Exception e)
        {
            System.debug(' Exception Executing Survey Base Class Tests: ' + e.getMessage());
            throw e;
        }
        Test.stopTest();
    }
    
    static testMethod void testSurvey()
    {
        Test.startTest();
        try
        {
            Profile p = getProfile('System Administrator');
            User u = createUser(p);
            insert u;
            Account a = createAccount();
            insert a;
            Contact c = createContact(u.Id, a.Id);
            c.email = 'test@test.com.fail';
            insert c;
            Case ca = createCase(a.Id, 'Test Case', 'New');
            insert ca;
            
            Survey__c newS = new Survey__c();
            newS.Name = 'CSAT Survey';
            newS.OwnerId = u.Id;
            insert newS;
            
            Survey_Question__c newQ = new Survey_Question__c();
            newQ.OwnerId = u.Id;
            insert newQ;
            
            Survey_Question__c newFUQ = new Survey_Question__c();
            newFUQ.OwnerId = u.Id;
            newFUQ.Follows_Up__c = newQ.Id;
            insert newFUQ;
            
            Survey_Question_Assignment__c newQA = new Survey_Question_Assignment__c();
            newQA.Survey__c = newS.Id;
            newQA.Survey_Question__c = newQ.Id;
            insert newQA;
            
            ApexPages.StandardController stdC = new ApexPages.StandardController(newS);
            SurveyController sc = new SurveyController(stdC);
            
            sc.sId = newS.Id;
            sc.cId = c.Id;
            sc.zId = ca.Id;
            sc.PreLoadResponseDetail();
            
            SurveyBase.SurveyResponse sr = sc.ResponseDetails;
            
            SurveyBase.LoadResponseInput testInput = new SurveyBase.LoadResponseInput();
            testInput.sId = newS.Id;
            testInput.cId = c.Id;
            SurveyController.LoadResponseDetail(JSON.serialize(testInput));
            
            
            Survey_Response__c newSR = SurveyBase.getSurveyResponse(testInput);
            
            List<SurveyEntry> SEs = SurveyBase.getEntries(testInput);
            
            SurveyBase.SubmitResponseInput testSRInput = new SurveyBase.SubmitResponseInput();
            testSRInput.Id = SEs.get(0).answer.Id;
            testSRInput.response = 'Test response';
            testSRInput.detailresponse = 'Test details';
            SurveyController.SubmitResponse(JSON.serialize(testSRInput));
            
            SurveyController sc2 = new SurveyController(stdC);
            sc2.sId = testInput.sId;
            sc2.cId = testInput.cId;
            SurveyBase.SurveyResponse sr2 = sc2.ResponseDetails;
            
            Survey_Response__c sro = [SELECT Id, Downgrade_Explanation__c, Upgrade_Explanation__c
                                        FROM Survey_Response__c
                                       LIMIT 1
                                     ];
            sro.Downgrade_Explanation__c = 'test';
            sro.Upgrade_Explanation__c = 'test';
            
            update sro;
            
        }
        catch (Exception e)
        {
            System.debug(' Exception Executing Survey Class Tests: ' + e.getMessage());
            throw e;
        }
        Test.stopTest();
    }
    
    /*
     * Create a basic User sObject
     */
    public static User createUser(Profile profile) {
        return createUser(profile, 'testuser@place.com.usertest');
    }
    
    /*
     * Create a basic User sObject with a specified Username
     */
    public static User createUser(Profile profile, String username) {
        return new User(
            ProfileId = profile.Id,
            Username = username,
            IsActive = true,
            Alias = 'testuser',
            Email = 'testuser@place.com.usertest',
            EmailEncodingKey = 'UTF-8',
            FirstName = 'Test',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_CA',
            TimeZoneSidKey = 'America/New_York'
        );
    }
    
    /*
     * Create a list of basic User sObjects
     */
    public static List<User> createUserList(Integer numUsers) {
        List<User> userList = new List<User>();
        for (Integer i = 0; i < numUsers; i++) {
            String username = 'testuser' + i + '@place.com.usertest';
            userList.add(createUser(getProfile(), username));
        }
        return userList;
    }
    
    /*
     * Create a basic Account sObject
     */
    public static Account createAccount() {
        return new Account(
            AccountNumber = '12345678',
            BillingCity = 'Toronto',
            BillingCountry = 'Canada',
            //BillingCountryCode = 'CA',
            //BillingStateCode = 'ON',
            BillingPostalCode = 'M5J 2V5',
            BillingStreet = '25 York Street',
            Description = 'A test account',
            Industry = 'Technology',
            Name = 'Test Account',
            ShippingCity = 'Toronto',
            ShippingCountry = 'Canada',
            //ShippingCountryCode = 'CA',
            //ShippingStateCode = 'ON',
            ShippingPostalCode = 'M5J 2V5',
            ShippingStreet = '25 York Street'
        );
    }

    /*
     * Create a basic Lead sObject
     */
    public static Lead createLead() {
        return new Lead(
            FirstName = 'Lead',
            LastName = 'Test',
            Company = 'My Test Company',
            //Status = 'Qualified',
            Status = 'New',
            City = 'Toronto', 
            Country = 'Canada',
            //CurrencyIsoCode = 'CAD',
            Email = 'lead.test@email.com',
            PostalCode = 'M5J 2V5',
            Street = '25 York Street',
            Industry = 'Technology'
        );
    }
    
    /*
     * Create a basic Lead object with an owner.
     * @param   userId      the ID of the user to set as the owner of the Lead
     * @return              a Lead sObject
     */
    public static Lead createLead(Id userId) {
        Lead lead = createLead();
        // Set the owner of the Lead
        lead.OwnerId = userId;
        return lead;
    }
    
    /**
      * Create an opportuntiy with an owner and related to an account
      * @param userId the user who will be the opportunity owner
      * @param accountId the account that will be associated to the opportunity
      */
    public static Opportunity createOpportunity(Id userId, Id accountId) {
        return new Opportunity (
            OwnerId = userId,
            Name = 'Opp',
            AccountId = accountId,
            CloseDate = (Date.Today()).addDays(30),
            StageName = 'Qualify',
            type='New Business'
        );
    }
    
    /**
      * Create a contact with an owner and related to an account
      * @param  userId      the owner of the contact
      * @param  accountId   the account associated with this contact
      */
    public static Contact createContact(Id userId, Id accountId) {
        return new Contact(
            OwnerId = userId,
            AccountId = accountId,
            FirstName = 'Contact',
            LastName = 'Test',
            Title = 'Test Contact'
        );
    }
    
    /**
      * Create a basic Task 
      */
    public static Task createTask(String subject, String status, String description) {
        return new Task(
            Description = description,
            Status = status,
            Subject = subject
        );
    }
    
    /**
      * Create a basic Task sObject linked to an sObject via whoId (Lead, Contact, etc.) or whatId (Account, Opportunity, etc.)
      */
    public static Task createTask(Id whatId, Id whoId, String subject, String status, String description) {
        Task task = createTask(subject, status, description);
        task.WhatId = whatId;
        task.WhoId = whoId;
        return task;
    }
    
    /**
      * Create a basic Task sObject linked to an sObject via whoId (Lead, Contact, etc.) or whatId (Account, Opportunity, etc.)
      */
    public static Task createTask(Id whatId, Id whoId) {
        Task task = createTask('Test Subject', 'Not Started', 'Test Task Description');
        task.WhatId = whatId;
        task.WhoId = whoId;
        return task;
    }
    
    /**
      * Create a basic Case sObject linked to an Account
      */
    public static Case createCase(Id accountId, String subject, String status) {
        return new Case(
            AccountId = accountId,
            Status = status,
            Subject = subject
        );
    }
    
    /*
     * Get a User sObject based on Id.
     *
     * @param   userId      specify the ID of the user to retrieve
     * @return              a User sObject
     */
    public static User getUserById(Id userId) {
        System.debug('User ID: ' + userId);
        return [SELECT Id,
        ProfileId,
        Username,
        Alias,
        FirstName,
        LastName
        FROM User 
        WHERE Id = :userId];
    }   

    /*
     * Retrieve a Profile sObject
     *
     * @return      a Profile sObject
     */
    public static Profile getProfile() {
        for (Profile p : [SELECT Id, PermissionsModifyAllData, Name FROM Profile]) {
            if (p.PermissionsModifyAllData) {
                return p;
            }
        }
        
        return new Profile();
    }
    
    /*
     * Retrieve a Profile sObject based on Name
     *
     * @param   name    the name of the profile to retrieve
     * @return          a Profile sObject
     */
    public static Profile getProfile(String name) {
        return [SELECT Id, Name FROM Profile WHERE Name = :name];
    }
    
    /*
     * Retrieve an Account sObject
     *
     * @param   id  the id of the Account sObject to retrieve
     * @return      the Account sObject
     */
    public static Account getAccount(Id id) {
        return [SELECT Id, 
        OwnerId,
        AccountNumber
        FROM Account WHERE Id = :id];
    }

    /*
     * Retrieve a Map of Account sObjects
     *
     * @param   ids the list of ids of the Account sObjects to retrieve
     * @return      a Map of Account sObjects
     */
    public static Map<Id, Account> getAccountMap(List<Id> ids) {
        Map<Id, Account> accountMap = new Map<Id, Account>();
        for (Account a : [SELECT Id, 
                          OwnerId,
                          AccountNumber,
                          //CurrencyIsoCode,
                          ShippingCity,
                          ShippingCountry,
                          //ShippingCountryCode,
                          ShippingLatitude,
                          ShippingLongitude,
                          ShippingPostalCode,
                          ShippingState,
                          //ShippingStateCode,
                          ShippingStreet,
                          BillingCity,
                          BillingCountry,
                          //BillingCountryCode,
                          BillingLatitude,
                          BillingLongitude,
                          BillingPostalCode,
                          BillingState,
                          //BillingStateCode,
                          BillingStreet
                          FROM Account 
                          WHERE Id IN :ids]) {
            accountMap.put(a.Id, a);
        }
        return accountMap;
    }
        
    /*
     * Retrieve a Lead sObject
     *
     * @param   id  the id of the Lead sObject to retrieve
     * @return      the Lead sObject
     */
    public static Lead getLead(Id id) {
        List<Lead> leadList = [SELECT Id, 
                                OwnerId
                                FROM Lead WHERE Id = :id];
        if (leadList.size() > 0) {
            return leadList[0];
        } else {
            return null;
        }
    }
    
    /**
      * Retrieve an Opportunity sObject
      *
      * @param id the id of the Opportuntiy to retrive
      * @return The opportunity object
      */
    public static Opportunity getOpportunity(Id id) {
        return [SELECT Id,
                       Amount,
                       ContractId,
                       //CurrencyIsoCode,
                       Name,
                       //RecordTypeId,
                       StageName,
                       Type   
                FROM Opportunity
                WHERE Id = :id];
    }

    public static Task getTask(Id id) {
        return [SELECT  Id,
                        CreatedDate
                FROM Task
                WHERE Id = :id
                LIMIT 1];
    }

    /**
      * SF-534: Retrieve a Task by WhoId
      */
    public static Task getTaskByWhoId(Id whoId) {
        List<Task> taskList = [SELECT Id
                               FROM Task
                               WHERE WhoId = :whoId];
        if((null != taskList) && (taskList.size() == 1)) {
            return taskList[0];
        }   else {
            return null;
        }
    }

    /**
      * SF-534: Retrieve a Record Type by Developer Name and SObject
      */
    public static RecordType getRTbyDevName(String devName, String sObjName) {
        List<RecordType> rtList = [SELECT Id, Name
                                   FROM RecordType
                                   WHERE DeveloperName = :devName AND SobjectType = :sObjName];
        if((null != rtList) && (rtList.size() == 1)) {
            return rtList[0];
        }   else {
            return null;
        }
    }
    
    /**
      * SF-597: Retrieve list of Tasks by WhatId
      */
    public static List<Task> getTasksByWhatId(Id whatId) {
        List<Task> taskList = [SELECT 
                                    Id,
                                    Description,
                                    Status,
                                    Subject,
                                    WhatId
                               FROM Task
                               WHERE WhatId = :whatId];
        if (taskList.size() > 0) {
            return taskList;
        } else {
            return null;
        }
    }

    public static Task getTaskByWhatId(Id whatId) {
        List<Task> taskList = getTasksByWhatId(whatId);
        if (taskList != null) {
            return taskList[0];
        } else {
            return null;
        }
    }

    /**
      * Retrieve a Case sObject by ID.
      */
    public static Case getCase(Id caseId) {
        List<Case> caseList = getCase(new List<Id>{caseId});
        if(caseList != null && caseList.size() == 1) {
            return caseList[0];
        }   else {
            return null;
        }
    }

    /**
      * Retrieve a List of Case sObject by ID.
      */
    public static List<Case> getCase(List<Id> caseIdList) {
        List<Case> caseList = [ SELECT  Id,
                                        Status,
                                        CaseNumber
                                FROM Case
                                WHERE Id IN :caseIdList];
        return caseList;
    }
        
}