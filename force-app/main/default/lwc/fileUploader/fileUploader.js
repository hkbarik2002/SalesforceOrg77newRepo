import { LightningElement, api, track } from 'lwc';

export default class FileUploader extends LightningElement {

    @api recordId;   // Automatically gets record Id when placed on record page
    @track files = [];

    columns = [
        { label: 'File Name', fieldName: 'name' },
        { label: 'Document Id', fieldName: 'documentId' },
        { label: 'Content Version Id', fieldName: 'contentVersionId' }
    ];

    handleUploadFinished(event) {
        console.log('uploadedFiles event>>', event);
        const uploadedFiles = event.detail.files;
        console.log('uploadedFiles>>', uploadedFiles)
        uploadedFiles.forEach(file => {
            this.files = [
                ...this.files,
                {
                    id: file.documentId,
                    name: file.name,
                    documentId: file.documentId,
                    contentVersionId: file.contentVersionId
                }
            ];
        });
    }
}