public with sharing  class CustomerInsightsController {
    
    public class customWraper{
        @AuraEnabled public Id accountId{get;set;}
        // @AuraEnabled public string accountName{get;set;}
        @AuraEnabled public Decimal totalRevenue {get;set;}
        @AuraEnabled public string contactName{get;set;}
        @AuraEnabled public string contactEmail{get;set;}
    }
    
    
    @AuraEnabled(cacheable = true)
    public static List<customWraper> getTopCustomers(){
        // Map<Id, Map<String, Object>> FinalMap = new Map<Id, Map<String, Object>>();
        Set<Id> AccIs = new Set<Id>();
        Map<Id,Decimal> tdecimalAount = new Map<Id,Decimal>();
        For(AggregateResult agr:[Select AccountId,SUM(Amount) totalAmount from Opportunity where AccountId != null Group By AccountId  Order by Sum(Amount) Desc Limit 5]){
            Id ids = (Id)agr.get('AccountId');
            Decimal totalAmounts = (Decimal)agr.get('totalAmount');
            AccIs.add(ids);
            IF(!tdecimalAount.containsKey(ids)){
                tdecimalAount.put(ids,totalAmounts);
            }
        }
        System.Debug('tdecimalAount>>'+ tdecimalAount);
        Map<Id,Contact> primaryContact = new  Map<Id,Contact>();
        For(Contact con :[Select AccountId ,Name,Email,CreatedDate From Contact Where AccountId =:AccIs ORDER BY CreatedDate ASC]){
            If(!primaryContact.containsKey(con.AccountId)){
                primaryContact.Put(con.AccountId,con);
            }
        }
        System.debug('primaryContact>>>'+primaryContact);
        
        /*For(Id aid : AccIs){
Decimal totalAmount = tdecimalAount.get(aid);
Contact contact = primaryContact.get(aid);
Map<String, Object> Innermap = new Map<String, Object>();
Innermap.put('TotalReviniew',totalAmount);
Innermap.put('PrimaryContact',contact);
FinalMap.put(aid,Innermap);
}*/
        List<customWraper> wrapes  = new List<customWraper>();
        For(Id aid : AccIs){
            customWraper wrp = new customWraper();
            wrp.accountId = aid;
            wrp.totalRevenue = tdecimalAount.get(aid);
            wrp.contactName = primaryContact.containsKey(aid)?primaryContact.get(aid).Name:null;
            wrp.contactEmail = primaryContact.containsKey(aid)?primaryContact.get(aid).Email:null;
            wrapes.add(wrp);
        }
        System.debug('wrapes>>'+wrapes);
        return wrapes;
    }
    
    
    public class customWrapperClass2{
        @AuraEnabled public Id ids {get;set;}
        @AuraEnabled public List<Contact> contactList {get;set;}
        @AuraEnabled public List<Opportunity> opportunityList {get;set;}
    }
    @AuraEnabled(cacheable=true)
    public static list<customWrapperClass2> accountRelatedOppAndCon(){
        Set<Id> Accid = new Set<Id>();
        Map<Id,List<Contact>> conListmap = new Map<Id,List<Contact>>();
        For(Contact con : [Select AccountId,Name,Email From Contact Where AccountId != null And Email != null LIMIT 5]){
            Accid.add(con.AccountId);
            If(!conListmap.containskey(con.AccountId)){
                conListmap.put(con.AccountId,new List<Contact>());
            }
            conListmap.get(con.AccountId).add(con);
        }
        
        Map<Id,List<Opportunity>> oppListmap = new Map<Id,List<Opportunity>>();
        For(Opportunity opp : [Select AccountId,Name,Amount From Opportunity Where AccountId =: Accid And Amount != null LIMIT 5]){
            If(!oppListmap.containskey(opp.AccountId)){
                oppListmap.put(opp.AccountId,new List<Opportunity>());
            }
            oppListmap.get(opp.AccountId).add(opp);
        }
        List<customWrapperClass2> wrapperList = new List<customWrapperClass2>();
        For(Id Aid:Accid){
            customWrapperClass2 cwc = new customWrapperClass2();
            cwc.ids = Aid;
            cwc.contactList = conListmap.containsKey(Aid)?conListmap.get(Aid):null;
            cwc.opportunityList = oppListmap.containsKey(Aid)?oppListmap.get(Aid):null;
            wrapperList.add(cwc);
        }
        System.Debug('wrapperList>>>>>'+wrapperList);
        return wrapperList;
    }
}