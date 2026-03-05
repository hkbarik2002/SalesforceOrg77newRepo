import { LightningElement, wire, track } from 'lwc';
import getAccountRecord from '@salesforce/apex/CreatTransactionLwcFormController.getAccountRecord';
import saveTransactionRecord from '@salesforce/apex/CreatTransactionLwcFormController.saveTransactionRecord';
export default class CreatTransactionLwcForm extends LightningElement {
    isTransaction = false;

    successCodeOptions = [
        { label: '101', value: '101' },
        { label: '201', value: '201' },
        { label: '301', value: '301' }
    ];

    @track transactionRec = {
        Name__c: '',
        Account__c: '',
        Success_Code__c: ''
    };

    @wire(getAccountRecord)
    gatAccountsData({ data, error }) {
        if (data) {
            this.accountOptions = data.map((account) => ({
                label: account.Name,
                value: account.Id
            }));
            console.log(' this.accountOptions>>>', this.accountOptions);
        } else if (error) {
            console.error('err>>>', error);
        }
    }


    handleClick() {
        this.isTransaction = true;
        console.log('Button Clicked');
    }

    haneldInputChange(event) {
        const field = event.target.dataset.field;
        this.transactionRec[field] = event.target.value;
        console.log('transactionRec>>>', this.transactionRec);
    }

    handleSave() {
        saveTransactionRecord({ trs: this.transactionRec })
            .then((result) => {
                console.log('result>>>', result);
                // this.isTransaction = false; 
            })
            .catch((error) => {
                console.error('error>>>', error);
            });
    }
}