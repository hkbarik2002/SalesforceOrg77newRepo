trigger trigger_PolicyHolderObject on PolicyHolder__c (after insert,after update,after delete,after undelete,before insert,before update) {
    if(trigger.isAfter){
        handler_PolicyHolderObject.countTotalPolicyHolders(trigger.new,trigger.oldMap,trigger.old);
    }
    // Check email duplicacy
    if(trigger.isBefore){
        handler_PolicyHolderObject.checkEmailFiels(trigger.new,trigger.oldMap);
    }
}