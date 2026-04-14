public with sharing class AccountHelper {
    public static void copyAccBillAddreToShipAdd(List<Account> accList, Map<Id, Account> oldAccMap) {
        for (Account acc : accList) {
            // Check if we should perform the copy
            if (shouldCopyAddress(acc, oldAccMap)) {
                syncAddress(acc);
            }
        }
    }
    
    private static Boolean shouldCopyAddress(Account acc, Map<Id, Account> oldAccMap) {
        // If checkbox is false, we do nothing
        if (!acc.CopyBillAddToShipAdd__c) return false;
        
        // Scenario: New Record (Insert)
        if (oldAccMap == null || !oldAccMap.containsKey(acc.Id)) {
            return true;
        }
        
        // Scenario: Update
        // Check if Billing Address changed OR if the checkbox was toggled to TRUE
        Account accData = oldAccMap.get(acc.Id);
        return (accData.ShippingCity != acc.BillingCity||
                accData.ShippingCountry != acc.BillingCountry||
                accData.ShippingGeocodeAccuracy != acc.BillingGeocodeAccuracy ||
                accData.ShippingLatitude != acc.BillingLatitude ||
                accData.ShippingLongitude != acc.BillingLongitude ||
                accData.ShippingPostalCode != acc.BillingPostalCode||
                accData.ShippingState != acc.BillingState ||
                accData.ShippingStreet != acc.BillingStreet);
    }
    
    private static void syncAddress(Account acc) {
        acc.ShippingStreet = acc.BillingStreet;
        acc.ShippingCity = acc.BillingCity;
        acc.ShippingState = acc.BillingState;
        acc.ShippingPostalCode = acc.BillingPostalCode;
        acc.ShippingCountry = acc.BillingCountry;
        acc.ShippingLatitude = acc.BillingLatitude;
        acc.ShippingLongitude = acc.BillingLongitude;
        acc.ShippingGeocodeAccuracy = acc.BillingGeocodeAccuracy;
    }
}