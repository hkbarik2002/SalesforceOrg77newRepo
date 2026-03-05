trigger OpportunityTrigger on Opportunity (after insert, after update, after delete, after undelete,before insert,before update) {
    /*If(trigger.isAfter){
        List<Opportunity_Update_Event__e> events = new List<Opportunity_Update_Event__e>();
        events.add(new Opportunity_Update_Event__e	());
        EventBus.publish(events);
    }*/
    if(trigger.isAfter && trigger.isUpdate){
        OpportunityHandler.creatRenewalObject(trigger.new,trigger.oldMap);
    }
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
        OpportunityHandler.maxAmountFieldUpdate(trigger.new,trigger.oldMap);
    }
    if(trigger.isBefore && trigger.isInsert){
        OpportunityHandler.ownerUpdateMethod(trigger.new);
    }
}