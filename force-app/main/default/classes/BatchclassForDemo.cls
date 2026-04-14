public with sharing class BatchclassForDemo implements Database.Batchable<SObject>, Database.Stateful, Database.RaisesPlatformEvents {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Ratings__c FROM Review__c WHERE Account__r.Id != null]);
    }

    public void execute(Database.BatchableContext bc, List<Review__c> revList) {
        List<Review__c> addrev = new List<Review__c>();
        List<Review__c> invalidRecords = new List<Review__c>();

        for (Review__c rev : revList) {
            if (rev.Ratings__c == 'Hire') {
                invalidRecords.add(rev);
            } else {
                rev.Ratings__c = 'Hire - Some Reservations';
                addrev.add(rev);
            }
        }

        // Update valid records
        if (!addrev.isEmpty()) {
            update addrev;
        }

        // Throw exception for invalid records
        if (!invalidRecords.isEmpty()) {
            throw new DmlException(invalidRecords.size() + ' Review Records cannot be updated because they have "Hire" rating.');
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Batch class complete');
    }
}