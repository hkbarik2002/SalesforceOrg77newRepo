public interface TriggerInterface {
    void beforeInser(List<SObject> newRecordList);
    void afterInser(List<SObject> newRecordList,Map<Id,SObject> newRecordMap);
    void beforeUpdate(Map<Id,SObject> newRecordMap,Map<Id,SObject> oldRecordMap);
    void afterUpdate(Map<Id,SObject> newRecordMap,Map<Id,SObject> oldRecordMap);
    void beforeDelete(List<SObject> oldRecordList,Map<Id,SObject> oldRecordMap);
    void afterDelete(Map<Id,SObject> oldRecordMap);
    void afterUndelete(List<SObject> newRecordList,Map<Id,SObject> newRecordMap);
}