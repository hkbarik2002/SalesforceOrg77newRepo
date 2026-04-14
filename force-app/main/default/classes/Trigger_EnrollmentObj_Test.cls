@isTest
public class Trigger_EnrollmentObj_Test {
    
    @testSetup 
    static void setupData() {
        // Insert 3 Contacts
        List<Contact> listContact = new List<Contact>();
        for(Integer i = 1; i <= 3; i++) {
            listContact.add(new Contact(
                LastName = 'test' + i,
                Phone = '54265262643'
            ));
        }
        insert listContact;
        
        // Insert 3 Projects
        List<Project__c> listProject = new List<Project__c>();
        for(Integer i = 1; i <= 3; i++) {
            listProject.add(new Project__c(
                Name = 'test' + i,
                Status__c = 'Planned',
                Budget__c = 100 + i
            ));
        }
        insert listProject;
        
        Enrollment__c enr = new Enrollment__c(
            Student__c = listContact[0].Id,
            Status__c = 'Requested'
            //Course__c =listProject[0].Id
        );
        insert enr;
    }
    
    @isTest
    static void testEnrollmentInsert() {
        // Get data from @testSetup
        List<Contact> conList = [SELECT Id FROM Contact];
        List<Project__c> projectList = [SELECT Id FROM Project__c];
        system.debug(conList[0].Id +' '+projectList[0].Id);
        // Create Enrollment record
        Enrollment__c enr = new Enrollment__c(
            Student__c = conList[0].Id,
            Status__c = 'Requested'
           // Course__c = projectList[0].Id
        );
        insert enr;
        
        // Validate (ASSERTIONS)
        Enrollment__c insertedEnr = [SELECT Id, Student__c, Status__c, Course__c FROM Enrollment__c WHERE Id = :enr.Id];
        System.assertEquals('Requested', insertedEnr.Status__c, 'Status should match');
        System.assertEquals(conList[0].Id, insertedEnr.Student__c, 'Student should match');
        System.assertEquals(projectList[0].Id, insertedEnr.Course__c, 'Course should match');
    }
}