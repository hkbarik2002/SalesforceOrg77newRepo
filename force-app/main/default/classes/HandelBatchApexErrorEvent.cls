public with sharing class HandelBatchApexErrorEvent {
    public static void handelErrorEvent(List<BatchApexErrorEvent> errEventList) {
        Set<Id> asyncApexJobIds = new Set<Id>();
        for(BatchApexErrorEvent evt:errEventList){
            asyncApexJobIds.add(evt.AsyncApexJobId);
        }
        
        Map<Id,AsyncApexJob> jobs = new Map<Id,AsyncApexJob>(
            [SELECT id, ApexClass.Name FROM AsyncApexJob WHERE Id IN :asyncApexJobIds]
            );
        
        List<Review__c> records = new List<Review__c>();
        for(BatchApexErrorEvent evt:errEventList){
            //only handle events for the job(s) we care about
            if(jobs.get(evt.AsyncApexJobId).ApexClass.Name == 'BatchclassForDemo'){
                for (String item : evt.JobScope.split(',')) {
                    Review__c r = new Review__c();
                    r.Id = (Id) item;
                    r.Notes__c  = evt.StackTrace;
                    records.add(r);
                }
            }
        }
        try {
            update records;
        } catch (DmlException e) {
            System.debug('Error inserting tasks: ' + e.getMessage());
        }
    }
}