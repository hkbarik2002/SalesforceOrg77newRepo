public class DemoStringAndInteger {
    
    public static void getFileData() {
        Map<String, Object> response = new Map<String, Object>();
        
        ContentVersion cv = [
            SELECT VersionData 
            FROM ContentVersion 
            WHERE Id ='068NS00000SyfrNYAR'
            LIMIT 1
        ];
        
        String csvData = cv.VersionData.toString();
        system.debug('csvData>>>'+csvData);
        // Parse CSV
        List<String> lines = csvData.split('\n');
        system.debug('lines>>>'+lines);
        List<String> headers = lines[0].split(',');
        system.debug('headers>>>'+headers);
        List<Map<String, String>> records = new List<Map<String, String>>();
        
        for (Integer i = 1; i < lines.size(); i++) {
            if (String.isBlank(lines[i])) continue;
            
            List<String> rowValues = lines[i].split(',');
            
            Map<String, String> rowObj = new Map<String, String>();
            
            for (Integer j = 0; j < headers.size(); j++) {
                rowObj.put(headers[j], rowValues[j]);
                //system.debug('rowObj>>>'+rowObj);
            }
            
            // add row number for UI tracking
            rowObj.put('id', String.valueOf(i));
           // system.debug('rowObj>>>'+rowObj);
            records.add(rowObj);
            //system.debug('records>>>'+records);
        }
        
        response.put('headers', headers);
        response.put('records', records);
       // system.debug('response>>>'+response);
        // return response;
    }
    /* public Static void checkString(String s1 ,String s2){
if (s1 == null || s2 == null || s1.length() != s2.length()) {
System.debug('>>> Not Match');
return;
}
List<String> sortedS1 = s1.toLowerCase().split('');
List<String> sortedS2 = s2.toLowerCase().split('');

sortedS1.sort();
sortedS2.sort();
system.debug('sortedS1>>>'+ sortedS1); 
system.debug('sortedS2>>>'+sortedS2);

System.debug(sortedS1 == sortedS2 ? '>>> true' : '>>> false');

}*/
}