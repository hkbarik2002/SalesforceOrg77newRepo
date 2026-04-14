public with sharing class LeadTerratoryController {
    @AuraEnabled(cacheable=true)
    public static List<TerritoryWrapper> getLeads(){
        try {
            List<TerritoryWrapper> territoryWrapperList = new List<TerritoryWrapper>();
            for(Rexo2026__Territory__c  tr : [select Id,Name,Rexo2026__Region_Code__c,Rexo2026__Sales_Rep__r.Name,Rexo2026__Zip_Code_Pattern__c from Rexo2026__Territory__c where Rexo2026__Region_Code__c != null]){
                TerritoryWrapper trw = new TerritoryWrapper();
                trw.Ids = tr.Id;
                trw.Name = tr.Name;
                trw.zipCode = tr.Rexo2026__Zip_Code_Pattern__c;
                trw.regionCode = tr.Rexo2026__Region_Code__c;
                trw.ownerName = tr.Rexo2026__Sales_Rep__r.Name;
                territoryWrapperList.add(trw);
            }
            if(!territoryWrapperList.isEmpty()){
                return territoryWrapperList;
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class TerritoryWrapper{
        @AuraEnabled public Id Ids {get;set;}
        @AuraEnabled public string Name {get;set;}
        @AuraEnabled public string zipCode {get;set;}
        @AuraEnabled public string regionCode {get;set;}
        @AuraEnabled public string ownerName {get;set;}
        
    }
}