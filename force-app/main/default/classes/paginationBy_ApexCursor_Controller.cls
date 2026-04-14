public with sharing class paginationBy_ApexCursor_Controller {
    
    @AuraEnabled(cacheable = true)
    public static List<Rexo2026__Car__c> getCarCursorData(Integer offsetPosition, Integer limitPosition) {
        try {
            if (offsetPosition != null && limitPosition != null) {
                
                Database.Cursor cursor;
                String cacheKey = 'conCursor';
                system.debug('Contains ----->'+ Cache.Session.contains(cacheKey));
                if (Cache.Session.contains(cacheKey)) {
                    System.debug('Get from cache');
                    cursor = (Database.Cursor) Cache.Session.get(cacheKey);
                } else {
                    System.debug('Insert to cache');
                    
                    cursor = Database.getCursor(
                        'SELECT Id, Rexo2026__Name__c, Rexo2026__DailyRent__c, Rexo2026__Status__c, Rexo2026__Category__c ' +
                        'FROM Rexo2026__Car__c ' +
                        'WHERE Rexo2026__DailyRent__c != null AND Rexo2026__Category__c != null'
                        );
                    
                    Cache.Session.put(cacheKey, cursor);
                }
                
                return cursor.fetch(offsetPosition, limitPosition);
            }
            return null;
            
        } catch (Exception e) {
            System.debug('Message ---->' + e.getMessage() + ' Line Number ----->' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
}