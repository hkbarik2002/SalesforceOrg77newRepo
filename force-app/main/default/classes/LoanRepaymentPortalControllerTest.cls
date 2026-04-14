@isTest
public with sharing class LoanRepaymentPortalControllerTest {
    @TestSetup
    static void DataSetup(){
        List<Account> listAccount = new List<Account>{
            new Account(Name = 'Raju', Phone = '748449383'),
            new Account(Name = 'Avhi', Phone = '478328323')
        };
        insert listAccount;
        
        List<Loan__c> lonList = new List<Loan__c>{
            new Loan__c(Amount__c = 10000,Status__c = 'Approved',Account__c = listAccount[0].Id),
            new Loan__c(Amount__c = 5000,Status__c = 'Approved',Account__c = listAccount[1].Id)
        };
        insert lonList;
        
        List<Repayment__c> repaymentList = new List<Repayment__c>{
            new Repayment__c(Payment_Date__c = Date.newInstance(2025, 9, 29),Amount_Paid__c = 2000,Loan__c = lonList[0].Id,Remaining_Balance__c = 8000),
            new Repayment__c(Payment_Date__c = Date.newInstance(2025, 9, 29),Amount_Paid__c = 1000,Loan__c = lonList[1].Id,Remaining_Balance__c = 4000)
        };
        insert repaymentList;
        
    }
    @IsTest
    static void testGetApprovedLoans(){
        Test.startTest();
        LoanRepaymentPortalController.getApprovedLoans();
        Test.stopTest();
    }
    @IsTest
    static void testfetchRemainingAmount(){
        Test.startTest();
        List<Loan__c> listLon = [select id from Loan__c];
        LoanRepaymentPortalController.fetchRemainingAmount(listLon[0].Id);
        Test.stopTest();
    }
    @IsTest
    static void testRepaymentAndPenalty() {
        Test.startTest();
        List<Loan__c> listLon = [SELECT Id FROM Loan__c LIMIT 1];
        LoanRepaymentPortalController.RepaymentAndPenalty(listLon[0].Id);
        Test.stopTest();
    }
    @IsTest
    static void testRepaymentAndPenalty_Negative() {
        Test.startTest();
        try {
            LoanRepaymentPortalController.RepaymentAndPenalty(null);
        } catch (AuraHandledException e) {}
        Test.stopTest();
    }
    
    
    @IsTest
    static void testcreatNewRepayment(){
        Test.startTest();
        List<Loan__c> listLon = [select id from Loan__c];
        LoanRepaymentPortalController.creatNewRepayment(listLon[0].Id,1000,Date.newInstance(2025, 10, 29));
        LoanRepaymentPortalController.getActiveLoans();
        Test.stopTest();
    }
    @IsTest
    static void testcreatNewRepayment_Negative(){
        Test.startTest();
        try{
            LoanRepaymentPortalController.creatNewRepayment(null,null,Date.newInstance(2025, 10, 29));
        }catch(Exception e){}
        Test.stopTest();
    }
    
}