public class Batch_NotifySentToCustomer implements database.Batchable<sObject>,Database.Stateful {
    public Date tomorrowDate;
    public List<VehicleBooking__c> vehBook = new List<VehicleBooking__c>();
    public Map<Id,string> emailMap = new Map<Id,string>();
    public Batch_NotifySentToCustomer(){
        // Date tday = Date.toDay();
        this.tomorrowDate = Date.toDay().addDays(1);
    }
    public database.queryLocator start(Database.batchableContext bc){
        
        return database.getQueryLocator([SELECT Id,CustomerName__c, Email__c,StartDate__c, EndDate__c,Status__c  FROM VehicleBooking__c WHERE  Email__c != null AND StartDate__c =: tomorrowDate AND Status__c = 'Confirmed' ]);
    }
    public void execute(Database.batchableContext bc,List<sObject> scope){
        vehBook = (List<VehicleBooking__c>)scope;
        system.debug('vehBook>>>'+vehBook);
        // Map<Id,string> emailMap = new Map<Id,string>();
        for(VehicleBooking__c vb : vehBook){
            emailMap.put(vb.Id,vb.Email__c);
        }
        system.debug('emailMap>>>'+emailMap);
        /*List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
for(VehicleBooking__c vbc : vehBook){
String email = emailMap.containsKey(vbc.Id)? emailMap.get(vbc.Id) : null;
if(email != null){
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
mail.setSubject('Your Booking Details');
mail.setToAddresses(new String[] { emailMap.get(vbc.Id) });
mail.setPlainTextBody('Hello '+vbc.CustomerName__c+ ', your booking has been confirmed.');
mailList.add(mail);
}
}
System.debug('mailList>>>>'+mailList);
List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
if(!mailList.isEmpty()){
results =  Messaging.sendEmail(mailList);
system.debug('results>>>'+ results);
}*/
        
    }
    public void finish(Database.batchableContext bc){
        
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        for(VehicleBooking__c vbc : vehBook){
            String email = emailMap.containsKey(vbc.Id)? emailMap.get(vbc.Id) : null;
            if(email != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject('Your Booking Details');
                mail.setToAddresses(new String[] { emailMap.get(vbc.Id) });
                mail.setPlainTextBody('Hello '+vbc.CustomerName__c+ ', your booking has been confirmed.');
                mailList.add(mail);
            }
        }
        System.debug('mailList>>>>'+mailList);
        List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
        if(!mailList.isEmpty()){
            results =  Messaging.sendEmail(mailList);
            system.debug('results>>>'+ results);
        }
    }
}