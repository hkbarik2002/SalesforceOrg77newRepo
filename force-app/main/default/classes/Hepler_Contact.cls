public class Hepler_Contact {
    public static void checkIsPrimarytrueORfalse(Set<Id> AccId,List<Contact> newConList){
        //system.debug('AccId>>>'+AccId+'>>>newConList>>>'+newConList);
        List<Contact> con = [select id from Contact where AccountId =:AccId AND IsPrimary__c = true limit 1];
        //system.debug('con>>>'+con);
        boolean isTrueCheck = false;
        if(con.isEmpty()){
            for(Contact c:newConList){
                if(isTrueCheck == false){
                    c.IsPrimary__c = true;
                    isTrueCheck = true;
                }
            }
        }
    }
    
    public Static void updateIsPrimary (Set<Id> AccId){
        system.debug('AccId>>>> '+AccId);
        List<Contact> conlist = [SELECT Name, AccountId, IsPrimary__c ,CreatedDate FROM Contact  where AccountId IN:AccId ORDER BY CreatedDate  DESC];
        system.debug('conlist>>> '+conlist);
        Map<Id,Contact> mapOfContact = new Map<Id,Contact>();
        for(Contact con : conlist){
           // contact oldCon = (mapOfContact != null && mapOfContact.ContainsKey(con.AccountId))? mapOfContact.get(con.AccountId) : null;
            if(!mapOfContact.ContainsKey(con.AccountId) || con.CreatedDate > mapOfContact.get(con.AccountId).CreatedDate){
                mapOfContact.put(con.AccountId , con);
            }
        }
        system.debug('mapOfContact>>>> '+mapOfContact);
        List<Contact> UpContact = new List<Contact>();
        for(Contact c : conlist){
            Boolean AccMatch =  c.Id == mapOfContact.get(c.AccountId).Id;
            system.debug('AccMatch>>>> '+AccMatch);
            if(c.IsPrimary__c != AccMatch){
                c.IsPrimary__c = true;
                UpContact.add(c);
            }
        }
        system.debug('UpContact>>>> '+ UpContact);
        if(!UpContact.isEmpty()){
            update UpContact;
        }
    }
    
    /* public static void updateIsPrimaryField(List<Contact> newConList){
set<Id> Accid = new Set<Id>();
Set<Id> conId = new Set<Id>();
for(Contact c:newConList){
System.debug('c.IsPrimary__c'+c.IsPrimary__c);
if(c.IsPrimary__c == true){
Accid.add(c.AccountId);
conId.add(c.Id);
}
}
if (Accid.isEmpty()) {
return;
}
List<Contact> conList = [select Id,IsPrimary__c from Contact where Id NOT IN:conId And AccountId IN:Accid AND IsPrimary__c = true];
//System.debug('conList>>>'+conList);
List<Contact> UpdateConList = new List<Contact>();
For(Contact c:conList){
c.IsPrimary__c = false;
UpdateConList.add(c);
}
if(!UpdateConList.isEmpty()){
// System.debug('UpdateConList>>>'+UpdateConList);
update UpdateConList;
}
}*/
    
    public static void deletedIsPrimaryField(Map<Id,Contact> oldConMap){
        // system.debug('oldConMap>>>>'+oldConMap);
        Set<Id> accIds = new Set<Id>();
        for(Id conId:oldConMap.keySet()){
            Id AcId = oldConMap.containsKey(conId)?oldConMap.get(conId).AccountId:null;
            accIds.add(AcId);
        }
        // system.debug('accIds>>>>'+accIds);
        Contact conData = [SELECT  id ,IsPrimary__c from Contact  where AccountId =:accIds ORDER BY CreatedDate DESC limit 1];
        if(conData.IsPrimary__c == false){
            conData.IsPrimary__c = true;
            //system.debug('conData>>>>'+conData);
            update conData;
        }
    }
    public static void unDeletedIsPrimaryField(List<Contact> newConList){
        // system.debug('newConList>>>>'+newConList);
        Set<Id> accId = new Set<Id>();
        for(Contact c:newConList){
            if(c.IsPrimary__c == true){
                accId.add(c.AccountId);
            }
        }
        // system.debug('accId>>>>'+accId);
        Contact conData = [select id ,IsPrimary__c from Contact where AccountId =:accId AND IsPrimary__c = true limit 1];
        //  system.debug('conData>>>>'+conData);
        List<Contact> UpdateConList = new List<Contact>();
        if(conData != null && conData.IsPrimary__c == true){
            for(Contact con : newConList){
                Contact updatedCon = new Contact(Id = con.Id,IsPrimary__c = false);
                //con.IsPrimary__c = false;
                UpdateConList.add(updatedCon);
            }
        }
        //  system.debug('UpdateConList>>>>'+UpdateConList);
        if(!UpdateConList.isEmpty()){
            update UpdateConList;
        }
    }
    
    //Checking Email Duplicacys >>>>>>>>>>
    public static void checkEmailDuplicacys(List<Contact> newConList,Map<Id,Contact> oldConMap){
        //system.debug('checkEmailDuplicacys>>'+newConList+'<------>'+oldConMap);
        Set<Id> AccId = new Set<Id>();
        for(Contact con : newConList){
            if(con.Email == null) return;
            if(con.Id == null && con.Email != null && con.AccountId != null){
                AccId.add(con.AccountId);
            }
            if(con.Id != null && oldConMap.containsKey(con.Id)){
                String EmailCon = oldConMap.get(con.Id).Email;
                // system.debug('con.Email.toLowerCase()>>>>'+con.Email.toLowerCase()+'>>oldCon.Email.toLowerCase()>>>>>'+oldCon.Email.toLowerCase());
                if(EmailCon != null && con.Email.toLowerCase() == EmailCon.toLowerCase()){
                    return;
                }
                AccId.add(con.AccountId);
            }
        }
        Map<String,List<Contact>> mapEmailCon = new Map<String,List<Contact>>();
        //system.debug('AccId>>'+AccId);
        for(Contact qcon:[select Id,Name,Email from Contact where AccountId IN:AccId AND Email != null]){
            //if (qcon.Email == null) continue;
            if(!mapEmailCon.containsKey(qcon.Email)){
                mapEmailCon.put(qcon.Email,new List<Contact>());
            }
            mapEmailCon.get(qcon.Email).add(qcon);
        }
        // system.debug('mapEmailCon>>'+mapEmailCon);
        for(Contact cons : newConList){
            if (cons.Email == null) continue;
            List<Contact> getmapCon= mapEmailCon.containsKey(cons.Email) ? mapEmailCon.get(cons.Email):null;
            //system.debug('getmapCon.size()>>'+getmapCon.size());
            if(getmapCon != null && getmapCon.size() > 0){
                cons.addError('This Email Already Exists');
            }
        }
    }
}