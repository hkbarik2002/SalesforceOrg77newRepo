public class BatchForVehicleBooking implements Database.Batchable<sObject> {
    //implements Database.Batchable<sObject>
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id,CustomerName__c,Car__c,EndDate__c,Status__c FROM VehicleBooking__c WHERE  EndDate__c =:Date.today() OR Status__c ='Draft']);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        List<VehicleBooking__c> vbList = (List<VehicleBooking__c>)scope;
        System.debug('vbList >>> ' + vbList);
        List<VehicleBooking__c> deleteCar = new List<VehicleBooking__c>();
        Set<Id> CarId = new Set<Id>();
        for(VehicleBooking__c vb :vbList){
            if(vb.EndDate__c == Date.today() && vb.Status__c != 'Draft'){
                CarId.add(vb.Car__c);
            }
            if(vb.Status__c == 'Draft'){
                deleteCar.add(vb);
            }
        }
        system.debug('CarId>>>'+CarId);
        system.debug('deleteCar>>>'+deleteCar);
        if(CarId !=null){
            List<Car__c> carList = [select id ,status__c from Car__c where Id IN:CarId];
            List<Car__c> updataCarData = new List<Car__c>();
            for(Car__c c:carList){
                c.Status__c = 'Available';
                updataCarData.add(c);
            }
            system.debug('updataCarData>>>'+updataCarData);
            if(!updataCarData.isEmpty()){
                //update updataCarData;
            }
            
        }
        if(!deleteCar.isEmpty()){
           // delete deleteCar;
        }
    }
    public void finish(Database.BatchableContext bc){}
}