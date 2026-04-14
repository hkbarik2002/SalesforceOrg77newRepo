trigger Trigger_OnCaseObject on Case (After Update) {
    if(trigger.isAfter && trigger.isUpdate){
        handler_OnCaseObject.creatJobAndJobLine(trigger.new,trigger.newMap,trigger.oldMap);
    }
}