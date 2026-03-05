trigger trigger_Subscription on Subscription__c (after insert,after update,before insert,before delete,before update) {
    if(trigger.isBefore){
        handler_Subscription.preventDeletionCheck(trigger.new,trigger.old,trigger.oldMap);
    }
    if(trigger.isAfter){
        handler_Subscription.updateNextBillingDate(trigger.new);
    }
}