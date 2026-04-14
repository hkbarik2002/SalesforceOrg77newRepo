trigger InsurancePolicy_Trigger on InsurancePolicy__c  (after insert,after update,after delete,after undelete) {
    if(trigger.isAfter){
        Handler_InsuranceClameManagement.calculateTotalInusurancePolicys(trigger.new,trigger.oldMap);
    }
}