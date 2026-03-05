import { LightningElement, track } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/FileUploadController.uploadFile';

// Import schema fields
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import ACCOUNT_NAME_FIELD from '@salesforce/schema/Account.Name';
import ACCOUNT_WEBSITE_FIELD from '@salesforce/schema/Account.Website';
import CONTACT_FIRSTNAME_FIELD from '@salesforce/schema/Contact.FirstName';
import CONTACT_LASTNAME_FIELD from '@salesforce/schema/Contact.LastName';
import CONTACT_EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import CONTACT_PHONE_FIELD from '@salesforce/schema/Contact.Phone';

export default class AccountContactFileForm extends NavigationMixin(LightningElement) {
    @track accountName = '';
    @track accountWebsite = '';
    @track contactFirstName = '';
    @track contactLastName = '';
    @track contactEmail = '';
    @track contactPhone = '';
    @track fileData = null; // Holds file data (filename and base64)

    // Handlers for input changes
    handleAccountNameChange(event) {
        this.accountName = event.target.value;
    }
    handleAccountWebsiteChange(event) {
        this.accountWebsite = event.target.value;
    }
    handleContactFirstNameChange(event) {
        this.contactFirstName = event.target.value;
    }
    handleContactLastNameChange(event) {
        this.contactLastName = event.target.value;
    }
    handleContactEmailChange(event) {
        this.contactEmail = event.target.value;
    }
    handleContactPhoneChange(event) {
        this.contactPhone = event.target.value;
    }

    // Handle file selection
    handleFileChange(event) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = () => {
                this.fileData = {
                    filename: file.name,
                    base64: reader.result.split(',')[1] // Extract base64 data
                };
            };
            reader.readAsDataURL(file);
        } else {
            this.fileData = null;
        }
    }

    // Save and navigate to Contact
    async handleSave() {
        await this.saveRecords();
        // Navigate to the new Contact record
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.contactId,
                objectApiName: 'Contact',
                actionName: 'view'
            }
        });
    }

    // Save and reset form
    async handleSaveAndNew() {
        await this.saveRecords();
        this.resetForm();
        this.showToast('Success', 'Records saved successfully. Form reset.', 'success');
    }

    // Cancel: Reset form
    handleCancel() {
        this.resetForm();
    }

    // Core save logic
    async saveRecords() {
        try {
            // Validate required fields
            if (!this.accountName || !this.contactFirstName || !this.contactLastName || !this.contactEmail) {
                throw new Error('Please fill in all required fields.');
            }

            // Create Account
            const accountFields = {};
            accountFields[ACCOUNT_NAME_FIELD.fieldApiName] = this.accountName;
            accountFields[ACCOUNT_WEBSITE_FIELD.fieldApiName] = this.accountWebsite;
            const accountRecord = { apiName: ACCOUNT_OBJECT.objectApiName, fields: accountFields };
            const account = await createRecord(accountRecord);

            // Create Contact linked to Account
            const contactFields = {};
            contactFields[CONTACT_FIRSTNAME_FIELD.fieldApiName] = this.contactFirstName;
            contactFields[CONTACT_LASTNAME_FIELD.fieldApiName] = this.contactLastName;
            contactFields[CONTACT_EMAIL_FIELD.fieldApiName] = this.contactEmail;
            contactFields[CONTACT_PHONE_FIELD.fieldApiName] = this.contactPhone;
            contactFields['AccountId'] = account.id; // Link to Account
            const contactRecord = { apiName: CONTACT_OBJECT.objectApiName, fields: contactFields };
            const contact = await createRecord(contactRecord);
            this.contactId = contact.id; // Store for navigation

            // Upload file if selected
            if (this.fileData) {
                await uploadFile({
                    recordId: contact.id,
                    fileName: this.fileData.filename,
                    base64Data: this.fileData.base64
                });
            }

            this.showToast('Success', 'Account, Contact, and file (if uploaded) created successfully.', 'success');
        } catch (error) {
            this.showToast('Error', error.message || 'An error occurred while saving.', 'error');
            throw error; // Re-throw to prevent navigation on error
        }
    }

    // Reset form
    resetForm() {
        this.accountName = '';
        this.accountWebsite = '';
        this.contactFirstName = '';
        this.contactLastName = '';
        this.contactEmail = '';
        this.contactPhone = '';
        this.fileData = null;
        // Reset file input
        const fileInput = this.template.querySelector('lightning-input[type="file"]');
        if (fileInput) {
            fileInput.value = '';
        }
    }

    // Show toast messages
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}