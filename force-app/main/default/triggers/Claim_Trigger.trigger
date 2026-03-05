trigger Claim_Trigger on Claim__c (after insert,after update,before insert) {
    if(trigger.isAfter){
        Handler_InsuranceClameManagement.creatAssessmentRecords(trigger.new);
    }
    if(trigger.isBefore){
        Handler_InsuranceClameManagement.checkIpRemainingamonts(trigger.new);
    }
}