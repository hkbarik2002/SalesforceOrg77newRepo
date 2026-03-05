@IsTest
public with sharing class ProjectObjectDashboardController_Test {
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
        
        list<Project__c> lProject = new List<Project__c>{
            new Project__c(Name = 'test1',Project_Manager__c = newUser.Id,Status__c = 'In Progress',Budget__c  = 20000),
            new Project__c(Name = 'test2',Project_Manager__c = newUser.Id,Status__c = 'In Progress',Budget__c  = 30000)
        };
        insert lProject;
        
        List<Project_Task__c> ptList = new List<Project_Task__c>{
            new Project_Task__c(Name__c ='pt001',Project__c=lProject[0].Id,Status__c='Completed',Assigned_To__c=newUser.Id),
            new Project_Task__c(Name__c ='pt002',Project__c=lProject[1].Id,Status__c='In Progress',Assigned_To__c=newUser.Id)
        };
        insert ptList;
    }
    @IsTest
    static void testFatchProjectData(){
        test.startTest();
        ProjectObjectDashboardController.getUserDetail();
        ProjectObjectDashboardController.FatchProjectData('In Progress');
        test.stopTest();
    }
    
    @IsTest
    static void testFatchProjectTaskData(){
        test.startTest();
        list<Project__c> lProject = [select id from Project__c];
        ProjectObjectDashboardController.FatchProjectTaskData(lProject[0].Id);
        test.stopTest();
    }
    // creatNewProjectTask(Id proId,String ptname ,Id ptuser ,String ptStatus )
    @IsTest
    static void testcreatNewProjectTask(){
        list<Project__c> lProject = [select id from Project__c];
        User u = [select id from User limit 1];
        test.startTest();
        ProjectObjectDashboardController.creatNewProjectTask(lProject[1].Id,'hkptForTest',u.Id ,'In Progress' );
        ProjectObjectDashboardController.deleteProject(lProject[0].Id);
        test.stopTest();
    }
    @IsTest
    static void testupdateProTaskRecord(){
        list<Project_Task__c> lProjectTask = new list<Project_Task__c>();
        for(Project_Task__c pt :[select id,Status__c from Project_Task__c limit 1]){
            pt.Status__c = 'In Progress';
            lProjectTask.add(pt);
        }
        test.startTest();
        ProjectObjectDashboardController.updateProTaskRecord(lProjectTask);
        test.stopTest();
    }
    
}