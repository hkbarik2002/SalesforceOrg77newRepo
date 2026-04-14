@IsTest
public with sharing class patientBillingController_Test {
    @TestSetup
    static void setupDataForTest(){
        List<Account> accountList = new List<Account >{
            new Account(Name ='Account1',Phone='7548265798'),
            new Account(Name ='Account2',Phone='7564745743')
        };
        insert accountList;
        
        List<Patient__c> patientList = new List<Patient__c >{
            new Patient__c(Name ='test1',DOB__c =date.newInstance(2010,10,15),Gender__c='Male',Contact_Info__c='7548265798'),
            new Patient__c(Name ='test2',DOB__c =date.newInstance(2010,10,05),Gender__c='Female',Contact_Info__c='72367627')
        };
        insert patientList;
        
        List<Appointment__c > appointList = new List<Appointment__c  >{
            new Appointment__c (Patient__c =patientList[0].Id,Doctor_Name__c =accountList[0].Id,Status__c='Scheduled', Date__c = Datetime.valueOf('2025-10-06 04:30:00')),
            new Appointment__c (Patient__c =patientList[1].Id,Doctor_Name__c =accountList[1].Id,Status__c='Scheduled', Date__c = Datetime.valueOf('2025-09-06 04:30:00'))
        };
        insert appointList;
        
        List<Treatment__c  > treatMentList = new List<Treatment__c   >{
            new Treatment__c  (Appointment__c =appointList[0].Id,Type__c ='Consultation',Cost__c=200),
            new Treatment__c  (Appointment__c =appointList[0].Id,Type__c ='Lab Test',Cost__c=300),
            new Treatment__c  (Appointment__c =appointList[1].Id,Type__c ='Consultation',Cost__c=200),
            new Treatment__c  (Appointment__c =appointList[1].Id,Type__c ='Lab Test',Cost__c=300)
        };
        insert treatMentList;
    }
    @IsTest
    static void getpatientRecordTestMethod(){
        
        Test.startTest();
        patientBillingController.getpatientRecord();
        patientBillingController.getAccountData();
        patientBillingController.getTreatmentType();
        patientBillingController.getPatienGender();
        patientBillingController.getAppointmentStatus();
        Test.stopTest();
        
    }
    @IsTest
    static void getpatientRecordTestMethodTestMethod(){
        List<Patient__c> patientList = [select id from Patient__c];
        Test.startTest();
        patientBillingController.getpatientAppointment(patientList[0].Id);
        Test.stopTest();
        
    }
    @IsTest
    static void getPatientTreatmentsAndBillTestMethod(){
        List<Appointment__c> appointMentList = [select id from Appointment__c];
        Test.startTest();
        patientBillingController.getPatientTreatmentsAndBill(appointMentList[0].Id);
        Test.stopTest();
        
    }
    @IsTest
    static void creatNewTreatmentsTestMethod(){
        List<Appointment__c> applist = [select id from Appointment__c];
        Treatment__c tr = new Treatment__c (Appointment__c =applist[0].Id,Type__c ='Procedure',Cost__c=400);
        Treatment__c tr1 = new Treatment__c (Appointment__c =null,Type__c =null,Cost__c=null);
        Test.startTest();
        patientBillingController.creatNewTreatments(tr);
        patientBillingController.creatNewTreatments(tr1);
        Test.stopTest();
        
    }
    @IsTest
    static void insertNewAppointmentRecordTestMethod(){
        List<Account> accList = [select id from Account];
        List<Patient__c> plist =[select id from Patient__c];
        Appointment__c appoin =  new Appointment__c (Patient__c =plist[0].Id,Doctor_Name__c =accList[0].Id,Status__c='Scheduled', Date__c = Datetime.valueOf('2025-11-06 04:40:00'));
        Test.startTest();
        patientBillingController.insertNewAppointmentRecord(appoin);
        Test.stopTest();
        
    }
    
    @IsTest
    static void insertNewPatientTestMethod(){
        Patient__c newPatient = new Patient__c(Name ='test3',DOB__c =date.newInstance(2009,10,15),Gender__c='Male',Contact_Info__c='7565457876');
        Test.startTest();
        patientBillingController.insertNewPatient(newPatient);
        Test.stopTest();
        
    }
    @IsTest
    static void updateBillPayTestMethod(){
        List<Appointment__c> applist = [select id from Appointment__c];
        Test.startTest();
        patientBillingController.updateBillPay(applist[0].Id,200);
        patientBillingController.updateBillPay(applist[0].Id,null);
        Test.stopTest();
        
    }
}