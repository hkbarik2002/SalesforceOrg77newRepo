public class AccountRelatedController {
    @AuraEnabled(cacheable=true)
    public static WrapperClass getRelatedOpps(){
        WrapperClass wc = new WrapperClass();
        
        Opportunity_Config__mdt config = [
            SELECT Rexo2026__Fields_to_Query__c 
            FROM  Rexo2026__Opportunity_Config__mdt 
            LIMIT 1
        ];
        string fields = config.Rexo2026__Fields_to_Query__c;
        //List<String> stList = fields.deleteWhitespace().split(',');
        //  OR
        integer i = 0;
        String oppAccFiled;
        List<String> stList  = new List<String>();
        for(string s : fields.split(',')){
            stList.add(s.trim());
            oppAccFiled = stList.contains('Amount')? stList.get(i) : null ;
            ++i;
        }
        wc.fields = stList;
        system.debug('fields>>>'+stList);
        string query;
        if(oppAccFiled != null){
            query = 'Select '+ fields+' from Opportunity where Amount != null AND '+oppAccFiled+ '> 150000' ;
        }else{
            query = 'Select '+ fields+' from Opportunity where Amount != null limit 10';
        }
        
        wc.oppList =  Database.query(query);
        if(!wc.oppList.isEmpty() && wc.fields != null){
            return wc;
        }else return null;
    }
    public class WrapperClass{
        @AuraEnabled public List<String> fields{get;set;}
        @AuraEnabled public List<Opportunity> oppList{get;set;}
        
    }
}