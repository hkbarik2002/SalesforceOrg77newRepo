trigger Trigger_EnrollmentObj on Enrollment__c (before insert,after insert,after delete,after undelete ) {
    if(trigger.isBefore){
        Handler_EnrollmentObj.checkSeatsAvailability(trigger.new);
    }
    if(trigger.isAfter){
        Handler_EnrollmentObj.dMLOnEnrollmentObj(trigger.new,trigger.old);
    }
   /* if(trigger.isBefore && trigger.isinsert){
        for(Integer i = 1; i<= 102;i++){
          list<Project__c> listProject =[SELECT Id, Name,Status__c, Start_Date__c FROM Project__c ];
        }
    }*/
}