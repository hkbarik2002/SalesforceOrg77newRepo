public with sharing class GetProductDetails {
    @AuraEnabled(cacheable=true)
    public static List<Product2> GetProduct() {
        return [SELECT Id,Name, (select id,UnitPrice from PricebookEntries limit 1) FROM Product2 limit 40];
    }
}