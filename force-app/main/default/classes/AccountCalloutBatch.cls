global class AccountCalloutBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id,Rexo2026__Name__c,Rexo2026__Status__c
            FROM Rexo2026__Car__c WHERE Rexo2026__Status__c = 'Available'
            LIMIT 50
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Rexo2026__Car__c> scope) {
        
        for (Rexo2026__Car__c acc : scope) {
            try {
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                
                req.setEndpoint('https://webhook.site/ebcae8b9-ea8d-4125-af53-067d9bd21aff');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setTimeout(60000);
                
                // 🔥 Prepare request body (send data)
                Map<String, Object> payload = new Map<String, Object>();
                payload.put('Id', acc.Id);
                payload.put('Name', acc.Rexo2026__Name__c);
                payload.put('Phone', acc.Rexo2026__Status__c);
                
                req.setBody(JSON.serialize(payload));
                
                HttpResponse res = http.send(req);
                
                // Optional: handle response
                if (res.getStatusCode() == 201 || res.getStatusCode() == 200) {
                    System.debug('Success for Account: ' + acc.Id);
                }
                
            } catch (Exception e) {
                System.debug('Error for Account ' + acc.Id + ': ' + e.getMessage());
            }
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('Batch Completed Successfully');
    }
}