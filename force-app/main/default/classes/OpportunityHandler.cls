public class OpportunityHandler {
    public static void creatRenewalObject(List<Opportunity> oppList,Map<Id,Opportunity> oldOppMap){
        List<Opportunity> qualifiedOpps = new List<Opportunity>();
        for(Opportunity opp: oppList){
            Opportunity oldOpp = oldOppMap.get(opp.Id);
            If(opp.StageName == 'Closed Won' && oldOpp.StageName != 'Closed Won'){
                qualifiedOpps.add(opp);
            }
        }
        
        if (!qualifiedOpps.isEmpty()) {
            System.enqueueJob(new RenewalOpportunityHandler(qualifiedOpps));
        }
    }
    
    public static void maxAmountFieldUpdate(List<Opportunity> oppList,Map<Id,Opportunity> oldOppMap){
        if(trigger.isInsert){
            Set<Id> AccId = new Set<Id>();
            for(Opportunity opp: oppList){
                if(opp.AccountId != null){
                    AccId.add(opp.AccountId);
                }
            }
            
            Map<Id,Opportunity> mapMaxOpportunity = new Map<Id,Opportunity>();
            
            for(Opportunity opp1 : [select id,AccountId,Amount,Opportunity_Max_Amount__c from Opportunity where AccountId In:AccId AND Opportunity_Max_Amount__c = true]){
                if(!mapMaxOpportunity.containsKey(opp1.AccountId)){
                    mapMaxOpportunity.put(opp1.AccountId,opp1);
                }
            }
            List<Opportunity> UpdateOppList = new List<Opportunity>();
            for(Opportunity opp2: oppList){
                
                if(mapMaxOpportunity.containsKey(opp2.AccountId) && opp2.Amount > mapMaxOpportunity.get(opp2.AccountId).Amount){
                    opp2.Opportunity_Max_Amount__c = true;
                    Opportunity updateOpp = mapMaxOpportunity.get(opp2.AccountId);
                    updateOpp.Opportunity_Max_Amount__c = false;
                    UpdateOppList.add(updateOpp);
                }else{
                    opp2.Opportunity_Max_Amount__c = true;
                }
            }
            if(!UpdateOppList.isEmpty()){
                update UpdateOppList;
            }
        }
        if(trigger.isUpdate){
            Set<Id> AccId = new Set<Id>();
            for(Opportunity opp: oppList){
                if(opp.AccountId != null && opp.Amount != oldOppMap.get(opp.Id).Amount){
                    AccId.add(opp.AccountId);
                }
            }
            
            Map<Id,Opportunity> mapMaxOpportunity = new Map<Id,Opportunity>();
            
            for(Opportunity opp1 : [select id,AccountId,Amount,Opportunity_Max_Amount__c from Opportunity where AccountId In:AccId AND Opportunity_Max_Amount__c = true]){
                if(!mapMaxOpportunity.containsKey(opp1.AccountId)){
                    mapMaxOpportunity.put(opp1.AccountId,opp1);
                }
            }
            List<Opportunity> UpdateOppList = new List<Opportunity>();
            for(Opportunity opp2: oppList){
                if(mapMaxOpportunity.containsKey(opp2.AccountId) && opp2.Amount > mapMaxOpportunity.get(opp2.AccountId).Amount){
                    opp2.Opportunity_Max_Amount__c = true;
                    Opportunity updateOpp = mapMaxOpportunity.get(opp2.AccountId);
                    updateOpp.Opportunity_Max_Amount__c = false;
                    UpdateOppList.add(updateOpp);
                }
            }
            if(!UpdateOppList.isEmpty()){
                update UpdateOppList;
            }
        }
    }
    
    public static void ownerUpdateMethod(List<Opportunity> oppList){
        if(trigger.isInsert){
            Set<Id> Accid = new Set<Id>();
            for(Opportunity opp : oppList){
                if(opp.AccountId != null){
                    Accid.add(opp.AccountId);
                }
            }
            Map<Id,Account> mapAccount = new Map<Id,Account>([select id,OwnerId from Account where id IN:Accid]);
            
            for(Opportunity opp : oppList){
                if(opp.OwnerId != mapAccount.get(opp.AccountId).OwnerId){
                    opp.OwnerId = mapAccount.get(opp.AccountId).OwnerId;
                }
            }
        }
    }
}