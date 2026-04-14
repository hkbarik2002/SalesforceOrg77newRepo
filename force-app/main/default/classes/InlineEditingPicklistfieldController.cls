public with sharing class InlineEditingPicklistfieldController {
    @AuraEnabled(cacheable=true)
    public static List<Project_Task__c> getProjectTaskData(){
        return [SELECT id ,Name__c, Status__c,Due_Date__c from Project_Task__c ];
    }
}