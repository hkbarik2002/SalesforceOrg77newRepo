trigger ClaimAssessment_Trigger on Claim_Assessment__c (after update,before update,after insert) {
    if(trigger.isAfter){
        Handler_InsuranceClameManagement.creatClamePayoutRecords(trigger.new);
    }
}