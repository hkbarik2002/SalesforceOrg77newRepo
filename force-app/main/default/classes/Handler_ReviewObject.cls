public with sharing class Handler_ReviewObject implements TriggerInterface{
    public static void beforeInser(List<SObject> newRecordList) {
         Helper_ReviewObject.checkEmailDuplicate((List<Review__c>)newRecordList);
    }


    public static void afterInser(List<SObject> newRecordList,Map<Id,SObject> newRecordMap) {
        List<Review__c> newRev = (List<Review__c>)newRecordList;
        Helper_ReviewObject.updateReviewCount(newRev);
    }


    public static void beforeUpdate(Map<Id,SObject> newRecordMap,Map<Id,SObject> oldRecordMap) {
         Helper_ReviewObject.checkEmailDuplicate((List<Review__c>)newRecordMap.Values());
    }


    public static void afterUpdate(Map<Id,SObject> newRecordMap,Map<Id,SObject> oldRecordMap) {
        List<Review__c> newRecord = new List<Review__c>();
        List<Review__c> newRev = (List<Review__c>)newRecordMap.values();
        for(Review__c r1 : newRev){
            Review__c oldrv = (Review__c)oldRecordMap.get(r1.Id);
            if(oldrv.Id != r1.Id){
                newRecord.add(r1);
            }
        }
        Helper_ReviewObject.updateReviewCount(newRecord);
    }


    public static void beforeDelete(List<SObject> oldRecordList,Map<Id,SObject> oldRecordMap) {
        
    }


    public static void afterDelete(Map<Id,SObject> oldRecordMap) {
        List<Review__c> newRev = (List<Review__c>)oldRecordMap.values();
        Helper_ReviewObject.updateReviewCount(newRev);
    }


    public static void afterUndelete(List<SObject> newRecordList,Map<Id,SObject> newRecordMap) {
        List<Review__c> newRev = (List<Review__c>) newRecordList;
        Helper_ReviewObject.updateReviewCount(newRev);
         Helper_ReviewObject.checkEmailDuplicate(newRev);
    }
}