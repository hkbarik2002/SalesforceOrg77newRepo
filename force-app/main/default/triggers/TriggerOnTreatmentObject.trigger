trigger TriggerOnTreatmentObject on Treatment__c (after insert,after update,after delete,after undelete) {
    if(trigger.isAfter){
        Handler_TreatmentObject.calculateCustOfTreatment(trigger.new,trigger.old);
    }
}