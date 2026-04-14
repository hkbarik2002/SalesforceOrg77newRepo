trigger Trigger_Contact on Contact (after insert,before insert,before update,after update,after delete,after undelete) {
    if(trigger.isBefore){
       // Handler_Contact.checkIsPrimaryFieldForInsert(trigger.new);
        Handler_Contact.checkEmailDuplicacy(trigger.new,trigger.oldMap);
    }
    //UD -> Update and Delete and unDelete
    if(trigger.isAfter){
        Handler_Contact.checkIsPrimaryFieldForUD(trigger.new,trigger.oldMap);
    }
    if(trigger.isBefore && (trigger.isInsert || trigger.IsUpdate)){
        Handler_Contact.checkEmailDuplicacy(trigger.new,trigger.oldMap);
    }
}