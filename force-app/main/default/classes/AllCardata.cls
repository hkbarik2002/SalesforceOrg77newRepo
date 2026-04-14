public with sharing class AllCardata {
    @AuraEnabled(cacheable=true)
    public static List<Car__c> getAllCardata() {
        return [SELECT  id ,Name__c, Category__c, DailyRent__c FROM Car__c  WHERE DailyRent__c != null];
    }
}