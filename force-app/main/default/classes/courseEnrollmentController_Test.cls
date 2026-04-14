@IsTest
public with sharing class courseEnrollmentController_Test {
    @TestSetup
    static void setUpDataForTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User newUser = new User(
            FirstName = 'TestPro',
        LastName = 'User',
        Alias = 'tuser',
        Email = 'test.user@example.com',
        Username = 'testPro01@Gamil.com',  // must be globally unique
        ProfileId = p.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US'
            );
        insert newUser;
        
        List<Contact> conList = new List<Contact>{
            new Contact(FirstName = 'Giri',LastName = 'Dhari',	Phone = '582732232'),
            new Contact(FirstName = 'Golu',LastName = 'Raju',	Phone = '574875345')
        };
        insert conList;
        
        List<Course__c> courseList = new List<Course__c>{
            new Course__c(Name = 'Excel',Instructor__c = newUser.Id,Max_Seats__c = 60,Available_Seats__c = 60),
            new Course__c(Name = 'Jawa',Instructor__c = newUser.Id,Max_Seats__c = 50,Available_Seats__c = 50)
        };
        insert courseList;
        
        List<Enrollment__c> enrolmentList = new List<Enrollment__c>{
            new Enrollment__c(Student__c = conList[0].Id,Course__c = courseList[0].Id,Status__c = 'Requested'),
            new Enrollment__c(Student__c = conList[1].Id,Course__c = courseList[1].Id,Status__c = 'Requested')
        };
        insert enrolmentList;
    }
    @IsTest
    static void testgetCourseRelatedData(){
        Course__c c  = [select Id from Course__c limit 1];
        test.startTest();
        courseEnrollmentController.getCourse();
        courseEnrollmentController.getStudentData();
        courseEnrollmentController.getCourseRelatedData(c.Id);
        courseEnrollmentController.getEnrollmentRelatedData(c.Id);
        test.stopTest();
    }
    // creatEnrolmentRecord(Id sId,Id cId,String status)
    @IsTest
    static void testcreatEnrolmentRecord(){
        Course__c c  = [select Id from Course__c limit 1];
        contact con = [select id from contact limit 1];
        Enrollment__c en = [select id from Enrollment__c limit 1];
        test.startTest();
        courseEnrollmentController.creatEnrolmentRecord(con.Id,c.Id,'Requested');
        courseEnrollmentController.updateToApprove(en.Id);
        courseEnrollmentController.updateToReject(en.Id);
        test.stopTest();
    }
    
    @IsTest
    static void testcourseRelatedEnrolment(){
        test.startTest();
        courseEnrollmentController.courseRelatedEnrolment('Excel');
        courseEnrollmentController.getListStatus();
        test.stopTest();
    }
}