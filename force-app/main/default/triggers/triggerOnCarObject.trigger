trigger triggerOnCarObject on Car__c (after insert) {
    if(trigger.isAfter && trigger.isInsert){
        triggerOnCarObject_Hendler.fairPlatformEvent(trigger.new);
    }
    
}