public with sharing class Helper_TreatmentObject {
    public static void calculateTotalCost(List<Treatment__c> newListTreatment) {
        Set<Id> apId = new Set<Id>();
        for(Treatment__c tr :newListTreatment){
            apId.add(tr.Appointment__c);
        }
        
        Map<Id, Decimal> apptTotals = new Map<Id, Decimal>();
        List<Treatment__c> treatmentSize = [select Appointment__c ,Cost__c from Treatment__c  where Appointment__c  IN:apId];
        
        for(Treatment__c tr2 : treatmentSize){
            Decimal totalAmount = apptTotals.containsKey(tr2.Appointment__c)?apptTotals.get(tr2.Appointment__c):0;
            totalAmount += tr2.Cost__c != null?tr2.Cost__c:0;
            apptTotals.put(tr2.Appointment__c, totalAmount);
        }
        
        Map<Id, Billing__c> existingBillingMap = new Map<Id, Billing__c>();
        for(Billing__c bl : [SELECT Appointment__c, Total_Bill__c FROM Billing__c  WHERE Appointment__c IN :apId]){
            if(!existingBillingMap.containsKey(bl.Appointment__c)){
                existingBillingMap.put(bl.Appointment__c,bl);
            }
        }
        
        List<Billing__c> toInsert = new List<Billing__c>();
        List<Billing__c> toUpdate = new List<Billing__c>();
        
        for(Id apoId : apptTotals.keySet()){
            if(existingBillingMap.containsKey(apoId)){
                Billing__c bl = existingBillingMap.get(apoId);
                bl.Total_Bill__c = apptTotals.get(apoId);
                toUpdate.add(bl);
            }else {
                toInsert.add(new Billing__c( Appointment__c = apoId,Total_Bill__c = apptTotals.get(apoId)));
            }
        }
        
        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }
}