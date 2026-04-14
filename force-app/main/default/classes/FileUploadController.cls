public with sharing class FileUploadController {
    @AuraEnabled
    public static void uploadFile(Id recordId, String fileName, String base64Data) {
        try {
            // Create ContentVersion for the file
            ContentVersion cv = new ContentVersion();
            cv.Title = fileName;
            cv.PathOnClient = fileName;
            cv.VersionData = EncodingUtil.base64Decode(base64Data);
            cv.IsMajorVersion = true;
            insert cv;
            
            // Get the ContentDocumentId
            Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;
            
            // Link the file to the record (e.g., Contact)
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = contentDocumentId;
            cdl.LinkedEntityId = recordId; // Attach to the Contact
            cdl.ShareType = 'V'; // Viewer access
            insert cdl;
        } catch (Exception e) {
            throw new AuraHandledException('Error uploading file: ' + e.getMessage());
        }
    }
}