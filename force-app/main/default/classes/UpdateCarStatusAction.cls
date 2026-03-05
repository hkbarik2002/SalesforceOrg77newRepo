public class UpdateCarStatusAction {
    public class Request {
        @InvocableVariable
        public List<Id> carId;
    }
    
    public class Response {
        @InvocableVariable
        public List<Car__c> carlist;
    }
    @InvocableMethod(label='Update Car Status' description='Updates Status on Car record')
    public static List<Response> updateStatus(List<Request> requests) {
        //list<Response> output = new List<Response>();
        try{
            system.debug('requests>>>'+requests);
            set<Id> carId = new Set<Id>(); 
            for(Request req:requests){
                for(Id ids :req.carId){
                    carId.add(ids);
                }
            }
            system.debug('carId>>>'+carId);
            //Date dt = Date.today().addDays(1);
            List<VehicleBooking__c> vbList = [SELECT Id,Car__c,EndDate__c FROM VehicleBooking__c
                                              WHERE Car__c IN:carId  and EndDate__c = toDay];
            system.debug('vbList>>>'+vbList);
            
            List<Car__c> tcarl = new List<Car__c>();
            List<Response> output = new List<Response>();
            if(!vbList.isEmpty()){
                for (VehicleBooking__c vb : vbList) {
                    Car__c res = new Car__c();
                    res.Id = vb.Car__c;
                    res.Status__c = 'Available';
                    tcarl.add(res);
                }
                system.debug('tcarl>>>'+tcarl);
                Response res = new Response();
                res.carList = tcarL;
                
                output.add(res);
                
                return output;
            } else return output;
            
        }
        catch(Exception e){
            system.debug(e.getLineNumber() +' <------> '+ e.getMessage());
            return null;
        }
    }
}