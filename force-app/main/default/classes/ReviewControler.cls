public with sharing class ReviewControler {
    @AuraEnabled(cacheable=true)
    public Static List<Review__c> getReview() {
        return [Select Name,Email__c,Ratings__c from Review__c limit 50];
    }
}