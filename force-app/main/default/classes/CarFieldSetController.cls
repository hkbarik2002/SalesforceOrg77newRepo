public class CarFieldSetController {
    
    @AuraEnabled(cacheable=true)
    public static wrapperClass getFieldSetFields(String objectName, String fieldSetName) {
        
        List<String> fieldList = new List<String>();
        wrapperClass wrp = new wrapperClass();
        try {
            
            if(String.isBlank(objectName) || String.isBlank(fieldSetName)) {
                return wrp;
            }
            
            objectName = objectName.trim();
            fieldSetName = fieldSetName.trim();
            
            Map<String, Schema.SObjectType> globalMap = Schema.getGlobalDescribe();
            
            Schema.SObjectType objType = globalMap.get(objectName);
            
            if(objType == null) {
                System.debug('Object not found: ' + objectName);
                return wrp;
            }
            
            Schema.DescribeSObjectResult describeResult = objType.getDescribe();
            
            Map<String, Schema.FieldSet> fieldSetMap = describeResult.fieldSets.getMap();
            
            if(!fieldSetMap.containsKey(fieldSetName)) {
                System.debug('FieldSet not found: ' + fieldSetName);
                return wrp;
            }
            
            Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
            
            for(Schema.FieldSetMember field : fieldSet.getFields()) {
                fieldList.add(field.getFieldPath());
            }
            system.debug('fieldList>>>>'+fieldList);
            wrp.fsString = fieldList;
            
            String query = 'SELECT Id';
            for(string fs : fieldList){
                query += ', '+fs;
            }
            query += ' FROM Rexo2026__Car__c LIMIT 10';
            List<Rexo2026__Car__c> cars = Database.query(query);
            system.debug('query>>>>'+ cars);
            wrp.CarsList = cars;
            system.debug('wrp>>>>'+ wrp);
            return wrp;
            
        } catch(Exception e) {
            System.debug('Line: ' + e.getLineNumber() +
                ' Message: ' + e.getMessage());
            return wrp;
        }
    }
    
    public class wrapperClass{
        @AuraEnabled public List<String> fsString{get;set;}
        @AuraEnabled public List<Rexo2026__Car__c> CarsList{get;set;}
        
    }
    
    /* @AuraEnabled(cacheable = true)
    public static Map<String, Object> getAllCarFsData(){
        
        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('Car__c').getDescribe();
        Schema.FieldSet fs = describeResult.fieldSets.getMap().get('Car_Field_Set');
        
        List<String> fieldNames = new List<String>();
        
        // Build query
        String query = 'SELECT Id';
        for (Schema.FieldSetMember f : fs.getFields()) {
            query += ', ' + f.getFieldPath();
            fieldNames.add(f.getFieldPath());
        }
        query += ' FROM Car__c LIMIT 1';
        
        List<Car__c> cars = Database.query(query);
        
        // Return both fields and data
        Map<String, Object> result = new Map<String, Object>();
        result.put('fields', fieldNames);
        result.put('records', cars);
        
        return result;
    }*/
}