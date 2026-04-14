trigger Trigger_OnReviewObject on Review__c (before insert,after insert,before update,after update,before delete,after delete,after undelete) {
    ID userid = UserInfo.getUserId();
    //if(userid == '005NS00000K4P9BYAV'){
        TriggerDispatcher.run(new Handler_ReviewObject() , trigger.OperationType);
    //}
}