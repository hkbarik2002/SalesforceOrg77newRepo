public class WheatherDetailsClass {
    @AuraEnabled
    public static WheatherDetailsWrapper getWheatherDetail(string cityName){
        try{
            string apiKey = '7f5858a1a16dc0e2f49857121705e510';
            string endPoint = 'https://api.openweathermap.org/data/2.5/weather';
            endPoint += '?q='+cityName;
            endPoint += '&unit=metric';
            endPoint += '&APPID='+apiKey;
            system.debug(endPoint);
            
            
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPoint);
            req.setMethod('GET');
            HttpResponse res = http.send(req);
            system.debug('res '+ res+' Body '+JSON.deserializeUntyped(res.getBody()));
            
            WheatherDetailsWrapper wdw = new WheatherDetailsWrapper();
            if(res.getStatusCode() == 200){
                Map<string,object> result = (Map<string,object>)JSON.deserializeUntyped(res.getBody());
                system.debug('result >> '+ result);
                wdw.city = string.valueOf(result.get('name'));
                Map<string,object> mainResult = (Map<string,object>)(result.get('main'));
                system.debug('mainResult >> '+ mainResult);
                wdw.temperature = string.valueOf(mainResult.get('temp'));
                wdw.pressure = string.valueOf(mainResult.get('pressure'));
                wdw.humidity = string.valueOf(mainResult.get('humidity'));
                wdw.feelsLike = string.valueOf(mainResult.get('feels_like'));
                wdw.tempMin = string.valueOf(mainResult.get('temp_min'));
                wdw.rempMax = string.valueOf(mainResult.get('temp_max'));
                
            }
            system.debug('wheather >> '+ wdw);
            return wdw;
        }
        catch(Exception ex){
            System.debug('Exception type caught: ' + ex.getTypeName());    
            System.debug('Message: ' + ex.getMessage());    
            System.debug('Cause: ' + ex.getCause());    
            System.debug('Line number: ' + ex.getLineNumber());    
            System.debug('Stack trace: ' + ex.getStackTraceString());  
            WheatherDetailsWrapper wdwr = new WheatherDetailsWrapper();
            return wdwr;
        }
    }
    public class WheatherDetailsWrapper{
        @AuraEnabled public string city{get;set;}
        @AuraEnabled public string temperature{get;set;}
        @AuraEnabled public string pressure{get;set;}
        @AuraEnabled public string humidity{get;set;}
        @AuraEnabled public string feelsLike{get;set;}
        @AuraEnabled public string tempMin{get;set;}
        @AuraEnabled public string rempMax{get;set;}
    }
}