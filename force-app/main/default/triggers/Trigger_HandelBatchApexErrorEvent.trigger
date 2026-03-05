trigger Trigger_HandelBatchApexErrorEvent on BatchApexErrorEvent (After insert) {
    if(trigger.isAfter && trigger.isInsert){
        HandelBatchApexErrorEvent.handelErrorEvent(trigger.new);
    }
}