import { LightningElement, wire, track } from 'lwc';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class AccountViewer extends LightningElement {
    @track columns = [
        { label: 'Name', fieldName: 'Name', type: 'text', editable: true },
        { label: 'Annual Revenue', fieldName: 'AnnualRevenue', type: 'currency', editable: true },
        { label: 'Type', fieldName: 'Type', type: 'text', editable: true }
    ];

    accounts = [];
    wiredAccountsResult;

    @wire(getAccounts)
    wiredAccounts(result) {
        this.wiredAccountsResult = result;
        if (result.data) {
            this.accounts = result.data;
        } else if (result.error) {
            console.error(result.error);
        }
    }

    handleSave(event) {
        const recordInputs = event.detail.draftValues.map(draft => ({
            fields: { Id: draft.Id, Name: draft.Name, AnnualRevenue: draft.AnnualRevenue, Type: draft.Type }
        }));

        Promise.all(recordInputs.map(recordInput => updateRecord(recordInput)))
            .then(() => {
                this.showToast('Success', 'Records updated', 'success');
                this.template.querySelector('lightning-datatable').draftValues = [];
                return refreshApex(this.wiredAccountsResult);
            })
            .catch(error => {
                this.showToast('Error updating', error.body.message, 'error');
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}