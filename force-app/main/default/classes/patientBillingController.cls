public with sharing class patientBillingController {
    @AuraEnabled
    public static list<Patient__c> getpatientRecord(){
        try {
            return [select Id,Name from Patient__c];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable = true)
    public static list<Account> getAccountData(){
        try {
            return [select Id,Name from Account limit 20 offset 20];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //SELECT Id ,Doctor_Name__r.Name, Date__c,Status__c FROM Appointment__c where Patient__c = 'a0UNS0000092kxd2AA'
    @AuraEnabled
    public static list<wrapperClass1> getpatientAppointment(Id pId){
        try {
            list<wrapperClass1> wrapAppointMent = new list<wrapperClass1>();
            for(Appointment__c ap :[SELECT Id ,Doctor_Name__r.Name, Date__c,Status__c FROM Appointment__c where Patient__c =:pId]){
                wrapperClass1 wc = new wrapperClass1();
                wc.id = ap.Id;
                wc.Name = ap.Doctor_Name__r.Name;
                wc.Status = ap.Status__c;
                if (ap.Date__c != null) {
                    Datetime dt = ap.Date__c;
                    wc.Appointment_Date = dt.date();
                    String formattedTime = dt.format('HH:mm:ss');
                    wc.Appointment_Time = formattedTime;
                }
                wrapAppointMent.add(wc);
            }
            if(!wrapAppointMent.isEmpty()){
                return wrapAppointMent;
            }else return wrapAppointMent;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static list<wrapperClass2> getPatientTreatmentsAndBill(Id appoId){
        list<wrapperClass2> listOfTreatmentBill = new list<wrapperClass2>();
        system.debug('appoId>>'+appoId);
        if(appoId != null){
            wrapperClass2 wc = new wrapperClass2();
            wc.listOfTreatment = [select Type__c,Cost__c from Treatment__c where Appointment__c =:appoId];
            wc.listOfBilling = [select Total_Bill__c,Amount_Paid__c,Outstanding_Balance__c from Billing__c  where Appointment__c =: appoId];
            listOfTreatmentBill.add(wc);
        }
        if(!listOfTreatmentBill.isEmpty()){
            system.debug('listOfTreatmentBill>>'+listOfTreatmentBill);
            return listOfTreatmentBill;
        }else return listOfTreatmentBill;
        
    }
    @AuraEnabled(cacheable=true)
    public static List<string> getTreatmentType(){
        List<String> ttString = new List<String>();
        Schema.DescribeFieldResult field = Treatment__c.Type__c.getDescribe();
        for(Schema.PicklistEntry sp : field.getPicklistValues()){
            ttString.add(sp.getLabel());
        }
        if(!ttString.isEmpty()){
            return ttString;
        }else return ttString;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<string> getPatienGender(){
        List<String> pgString = new List<String>();
        Schema.DescribeFieldResult field = Patient__c.Gender__c.getDescribe();
        for(Schema.PicklistEntry sp : field.getPicklistValues()){
            pgString.add(sp.getLabel());
        }
        if(!pgString.isEmpty()){
            return pgString;
        }else return pgString;
    }
    @AuraEnabled(cacheable=true)
    public static List<string> getAppointmentStatus(){
        List<String> asString = new List<String>();
        Schema.DescribeFieldResult field = Appointment__c.Status__c.getDescribe();
        for(Schema.PicklistEntry sp : field.getPicklistValues()){
            asString.add(sp.getLabel());
        }
        if(!asString.isEmpty()){
            return asString;
        }else return asString;
    }
    
    @AuraEnabled
    public static string creatNewTreatments(Treatment__c newTreatment){
        system.debug('newTreatment>>>'+newTreatment);
        try {
            if(newTreatment != null && newTreatment.Appointment__c != null){
                insert newTreatment;
                return 'New treatment created';
            }else return 'Fail to creat new treatment';
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static string insertNewAppointmentRecord(Appointment__c newAppointmentData){
        system.debug('newAppointmentData>>>'+newAppointmentData);
        try {
            if(newAppointmentData != null){
                insert newAppointmentData;
                return newAppointmentData.Id;
            }else return 'Null';
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static string insertNewPatient(Patient__c newpatient){
        system.debug('newpatient>>>'+newpatient);
        try {
            if(newpatient != null){
                insert newpatient;
                return newpatient.Id;
            }else return 'Null';
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string updateBillPay(id appoId,Decimal bAmount){
        
        try {
            //system.debug('appoId>>>'+appoId+' >>bAmount>>'+bAmount);
            if(appoId == null || bAmount == null){
                system.debug('appoId>>>'+appoId+' >>bAmount>>'+bAmount);
                return 'Null parameter';
            }
            list<Billing__c> billList = new list<Billing__c>();
            for(Billing__c ab:[SELECT id,Amount_Paid__c FROM Billing__c WHERE Appointment__c  =:appoId limit 1]){
                system.debug('ab>>>'+ab);
                Billing__c nAB = new Billing__c();
                if(ab != null){
                    nAB.Id = ab.Id;
                    Decimal paid = (ab.Amount_Paid__c != null ? ab.Amount_Paid__c : 0);
                    Decimal amount = (bAmount != null ? bAmount : 0);
                    nAB.Amount_Paid__c = paid+amount;
                    billList.add(nAB);
                }
            }
            System.debug('billList>>>>'+billList);
            if(!billList.isEmpty()){
                update billList;
                return 'Bill amount updated';
            }else return 'Bill amount notUpdated';
        } catch (Exception e) {
            System.debug('error>>>'+e.getLinenumber()+' >>>message>>>>'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class wrapperClass1{
        @AuraEnabled public Id id{get;set;}
        @AuraEnabled public string Name{get;set;}
        @AuraEnabled public string Status{get;set;}
        @AuraEnabled public Date Appointment_Date{get;set;}
        @AuraEnabled public String Appointment_Time{get;set;}
    }
    public class wrapperClass2{
        @AuraEnabled public List<Treatment__c> listOfTreatment{get;set;}
        @AuraEnabled public List<Billing__c> listOfBilling{get;set;}
    }
}