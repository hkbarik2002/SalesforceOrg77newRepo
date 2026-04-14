public with sharing class Handler_TreatmentObject {
    public static void calculateCustOfTreatment(List<Treatment__c> newListTreatment,List<Treatment__c> oldListTreatment) {
        if(Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete){
            Helper_TreatmentObject.calculateTotalCost(newListTreatment);
        }
        if(Trigger.isDelete){
            Helper_TreatmentObject.calculateTotalCost(oldListTreatment);
        }
    }
}