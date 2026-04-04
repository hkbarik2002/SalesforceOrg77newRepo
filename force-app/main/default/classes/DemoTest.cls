public class DemoTest {
    public static void testMethods(){
        // 1. Get the Record Type Info safely
        Schema.RecordTypeInfo rtInfo = SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Utility_Opportunity');
        
        // 2. Only run the ConnectApi call if the Record Type actually exists
        if (rtInfo != null) {
            Id recordTypeId = rtInfo.getRecordTypeId();
            
            ConnectApi.PicklistValuesCollection picklistCollection =
                ConnectApi.RecordUi.getPicklistValuesByRecordType('Opportunity', recordTypeId);
            if(picklistCollection != null){
                // System.debug('Values: ' + picklistCollection);
                ConnectApi.PicklistValues statusValues = picklistCollection.picklistFieldValues.get('Type');
                System.debug('statusValues: ' + statusValues);
                system.debug('statusValues.values: ' + statusValues.values);
            }
        } else {
            System.debug('Error: The Record Type "Utility_Opportunity" does not exist or the user lacks access.');
        }
    }
}