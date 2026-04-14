public class Handler_Contact {
    public static void checkIsPrimaryFieldForInsert(List<Contact> newConList){
        if(trigger.isInsert){
            set<Id> accID = new Set<Id>();
            for(Contact c:newConList){
                accID.add(c.AccountId);
            }
            Hepler_Contact.checkIsPrimarytrueORfalse(accID,newConList);
        }
    }
    public static void checkIsPrimaryFieldForUD(List<Contact> newConList,Map<Id,Contact> oldConMap){
        
        if(trigger.isInsert || trigger.isDelete){
            Set<Id> AccId = new Set<Id>();
            if(newConList != null){
                for(Contact Con : newConList){
                    if(con.AccountId != null){
                        AccId.add(con.AccountId);
                    }
                }
            }
            else{
                for(Id cId : oldConMap.KeySet()){
                    AccId.add(oldConMap.get(cId).AccountId);
                }
            }
            if(!AccId.isEmpty()){
                Hepler_Contact.updateIsPrimary(AccId);
            }
        }
    }
    static boolean isEmailcheck = false;
    public static void checkEmailDuplicacy(List<Contact> newConList,Map<Id,Contact> oldConMap){
        if(trigger.isInsert || trigger.isUpdate){
            system.debug('checkEmailDuplicacy>>');
            if(isEmailcheck) return;
            isEmailcheck = true;
            Hepler_Contact.checkEmailDuplicacys(newConList,oldConMap);
        }
    }
}