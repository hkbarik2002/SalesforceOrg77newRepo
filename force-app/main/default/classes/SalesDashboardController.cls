public with sharing class SalesDashboardController {
    private static Set<Id> AccSet = new Set<Id>();
    @AuraEnabled(cacheable = true)
    public static List<Account> getAccountOptions() {
        AccSet.clear();
        For(Contact con:[Select AccountId from Contact where AccountId != null]){
            AccSet.Add(con.AccountId);
        }
        For(Opportunity opp:[Select AccountId from Opportunity where AccountId != null]){
            AccSet.add(opp.AccountId);
        }
        List<Account> accList = [Select Id,Name from Account where Id IN:AccSet];
        //system.debug(accList);
        return accList;
    }
    @AuraEnabled(cacheable = true)
    public static list<String> getStageOptions(List<Id> accounid){
        Set<String> StageSet = new Set<String>();
        For(Opportunity opp:[Select StageName From Opportunity where AccountId IN:accounid]){
            StageSet.add(opp.StageName);
        }
        list<String> StageList = new list<String>(StageSet);
        System.debug(StageList);
        return StageList;
    }
    @AuraEnabled(cacheable = true)
    public static List<OpportunityWrapper> getOpportunities(Id accountId, String stage){
        List<OpportunityWrapper> opportunityWraper = new List<OpportunityWrapper>();
        For(Opportunity opp:[Select Id,Name,StageName,CloseDate,Amount,(Select Id,Product2Id,Quantity,UnitPrice From OpportunityLineItems) From Opportunity Where AccountId =:accountId AND StageName =:stage ]){
            OpportunityWrapper wrapper = new OpportunityWrapper();
            wrapper.opportynitys = opp;
            wrapper.totalAmount = opp.Amount;
            wrapper.totalProduct = opp.OpportunityLineItems.size();
            opportunityWraper.add(wrapper);
        }
        return opportunityWraper;
    }
    public class OpportunityWrapper{
        @AuraEnabled public Opportunity opportynitys;
        @AuraEnabled public Integer totalProduct;
        @AuraEnabled public Decimal totalAmount;
        
    }
    
}