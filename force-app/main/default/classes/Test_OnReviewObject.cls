@isTest
public with sharing class Test_OnReviewObject {
    
    @TestSetup
    static void makeData() {
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('System Administrator', 'Standard User')];
        
        List<User> testUsers = new List<User>();
        
        User u1 = new User(
            FirstName = 'Test',
        LastName = 'User',
        Email = 'testuser@example.com',
        Alias = 'tuser',
        Username = 'testuser-' + System.currentTimeMillis() + '@example.com', // Username must be unique
        ProfileId = profiles[0].Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US'
            );
        
        testUsers.add(u1);
        insert testUsers;
        
        List<User> totalUsers = [SELECT Id, Name FROM User where Name Like 'Test%'];
        System.assertEquals(1, totalUsers.size());
        
        // Create Account
        List<Account> addAcc = new List<Account>();
        Account acc = new Account(
            Name = 'TestAcc',
        OwnerId = totalUsers[0].Id,
        CountReview__c = 0
            );
        addAcc.add(acc);
        insert addAcc;
        
        // Create Reviews
        List<Review__c> addRv = new List<Review__c>();
        for (Integer i = 0; i < 2; i++) {
            Review__c rv = new Review__c(
                Name = 'Rv' + i,
            Email__c = 'hb_salesforce@example.com'+i,
            Account__c = addAcc[0].Id
                );
            addRv.add(rv);
        }
        insert addRv;
    }
    
    @isTest
    static void inserReview() {
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 1];
        List<Review__c> addRv = new List<Review__c>();
        
        for (Account acc : accList) {
            Review__c newRv = new Review__c(
                Name = 'Rvv',
            Account__c = acc.Id
                );
            addRv.add(newRv);
        }
        insert addRv;
    }
    @isTest
    Static void inserReview1(){
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 1];
        List<Review__c> addRv = new List<Review__c>();
        
        for (Account acc : accList) {
            Review__c newRv = new Review__c(
                Name = 'Rvv',
            Email__c ='hb_salesforce@example.com0',
            Account__c = acc.Id
                );
            addRv.add(newRv);
        }try {
            insert addRv;  // This should fail
            System.assert(false, 'Expected DML to fail but it succeeded');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Already Exist'), 'Expected validation error not found');
        }
    }
    @isTest
    Static void UpdateReview(){
        // Map<id,Review__c> GetRev = new Map<id,Review__c>([Select id, Email__c,Account__c from Review__c where Name ='Rv0' AND Name != null]);
        List<Review__c> UpdateRev = new List<Review__c>();
        for(Review__c rev : [Select id, Email__c,Account__c from Review__c where Name ='Rv0' AND Name != null]){
            Review__c rev1 = new Review__c();
            rev1.Id = rev.ID;
            rev1.Email__c = 'hb_salesforce@example.com0';
            if (rev.Account__c != null) {
                rev1.Account__c = rev.Account__c;
            }
            UpdateRev.add(rev1);
        }
        try {
            update UpdateRev;
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Already Exist'), 'Expected validation error not found');
        }
    }
    @isTest
    Static void DeleteReview(){
        List<Account> acclist = [Select Id from Account Where Id != null];
        List<Review__c> revList = [select Id from Review__c where Account__c =:acclist[0].Id];
        try {
            Delete revList[0];
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Review not Delete'),'Review not Delete Sucessfully');
        }
    }
    @isTest
    Static void UndeleteReview(){
        List<Account> acclist = [Select Id from Account Where Id != null];
        Review__c rev = new Review__c(
            Name = 'Rev2',
            Account__c = acclist[0].Id,
            Email__c = 'hb_salesforce@example.com5'
        );
        try {
            Insert rev;

            Delete rev;

            Undelete rev;
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Review Undelete'),'Review not Undelete Sucessfully');
        }
    }
}