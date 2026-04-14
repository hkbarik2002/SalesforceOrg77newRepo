public class MassDeleteHelper {

    public static void deleteRecords(
        Mass_Delete_Config__mdt cfg,
        Set<Id> parentIds
    ) {
        if (parentIds.isEmpty()) return;

        String soql =
            'SELECT Id FROM ' + cfg.Child_Object__c +
            ' WHERE ' + cfg.Lookup_Field__c + ' IN :parentIds';
         system.debug('soql>>>'+soql);
        List<SObject> records;

        try {
            records = Database.query(soql);
        } catch (Exception e) {
            logError(null, cfg.Child_Object__c, e.getMessage());
            return;
        }

        if (records.isEmpty()) return;

        Database.DeleteResult[] results =
            Database.delete(records, false);
        system.debug('results>>>'+results);

        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                for (Database.Error err : results[i].getErrors()) {
                    logError(
                        records[i].Id,
                        cfg.Child_Object__c,
                        err.getMessage()
                    );
                }
            }
        }
    }

    private static void logError(
        Id recordId,
        String objectName,
        String message
    ) {
        system.debug('recordId>>>'+recordId+'---->'+'objectName>>>'+objectName+'----->'+'message>>>'+message);
        insert new Mass_Delete_Log__c(
            Record_Id__c = String.valueOf(recordId),
            Object_Name__c = objectName,
            Error_Message__c = message
        );
    }
}