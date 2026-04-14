import { LightningElement, track, wire } from 'lwc';
import getAccounts from '@salesforce/apex/Account360Controller.getAccounts';
import accountRelatedObjectDetails from '@salesforce/apex/Account360Controller.accountRelatedObjectDetails';
import updateContacts from '@salesforce/apex/Account360Controller.updateContacts';
import creatOpportunity from '@salesforce/apex/Account360Controller.creatOpportunity';
import { refreshApex } from '@salesforce/apex';
//import { RefreshEvent } from 'lightning/refresh';

export default class Account360Dashboard extends LightningElement {

    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Stage Name', fieldName: 'StageName' },
        { label: 'Amount', fieldName: 'Amount' }];

    stages = [
        { label: 'Prospecting', value: 'Prospecting' },
        { label: 'Qualification', value: 'Qualification' },
        { label: 'Needs Analysis', value: 'Needs Analysis' },
        { label: 'Value Proposition', value: 'Value Proposition' },
        { label: 'Id. Decision Makers', value: 'Id. Decision Makers' },
        { label: 'Perception Analysis', value: 'Perception Analysis' },
        { label: 'Proposal/Price Quote', value: 'Proposal/Price Quote' },
        { label: 'Negotiation/Review', value: 'Negotiation/Review' },
        { label: 'Closed Won', value: 'Closed Won' },
        { label: 'Closed Lost', value: 'Closed Lost' }
    ];

    @track ShowContactAndOpportunity = false;
    @track listOfAccount = [];
    @track accountId = '';
    @track listOfContact = [];
    @track listOfOpportunity = [];
    @track upContactMap = new Map();
    wiredAccountsResult;
    AId;
    wiredAccountDetailsResult;
    @track ShowPopup = false;
    @track optionOne = false;
    @track optionTwo = false;
    @track openOppPage = false;
    @track oppData = {};

    connectedCallback() {
        this.fetchAccounts();
        this.accountId = this.AId;
    }

    fetchAccounts() {
        getAccounts()
            .then(result => {
                this.wiredAccountsResult = result;
                this.listOfAccount = result.map(acc => ({ label: acc.Name, value: acc.Id }));
                if (this.listOfAccount.length > 0) {
                    this.AId = this.listOfAccount[0].value;
                    //this.selectedAccountId = this.listOfAccount[0].value;
                }
            })
            .catch(error => {
                console.error('Account Not Found', error);
            });
    }
    handleAccountIdChange(event) {
        this.accountId = event.detail.value;
        this.ShowContactAndOpportunity = true;
    }

    @wire(accountRelatedObjectDetails, { AccId: '$accountId' })
    fetchDataFromAccount360(result) {
        this.wiredAccountDetailsResult = result;
        if (result.data) {
            this.listOfContact = result.data.conList;
            this.listOfOpportunity = result.data.oppList;
        } else if (result.error) {
            console.error('Record not Found', result.error);
        }
    }

    handleContactEmailUpdate(event) {
        const conId = event.target.dataset.id;
        const newEmail = event.target.value;

        const getContactEmail = this.listOfContact.find(con => con.Id === conId);
        if (getContactEmail) {
            let oldEmail = getContactEmail.Email;
            console.log('oldEmail>>>', JSON.stringify(oldEmail), ' newEmail>>>', JSON.stringify(newEmail));
            if (oldEmail != newEmail) {
                this.upContactMap.set(conId, { contactId: conId, contactEmail: newEmail });
            }
            else
                alert('First provide new Email Then Click Update Email');
        }
        // console.log('upContactMap >>> ', JSON.stringify([...this.upContactMap.values()]));

    }
    handleUpdateContact() {
        const uniqueChanges = [...this.upContactMap.values()];
        // console.log('uniqueChanges>>>', JSON.stringify(uniqueChanges));
        updateContacts({ changesJson: JSON.stringify(uniqueChanges) })
            .then(() => {
                console.log('sucess');
                this.refreshComponent();
            })
            .catch(error => {
                console.error('Update Fail', error);
            })
    }

    handleNewOpportunity() {
        this.ShowPopup = true;
        this.ShowContactAndOpportunity = false;
    }
    handleCheckboxChange(event) {
        const { name, checked } = event.target;
        if (name === 'optionOne') {
            this.optionOne = checked;
            if (checked) {
                this.optionTwo = false; // unselect optionTwo
            }
        }

        if (name === 'optionTwo') {
            this.optionTwo = checked;
            if (checked) {
                this.optionOne = false; // unselect optionOne
            }
        }
    }
    handleBack() {
        this.ShowPopup = false;
        this.ShowContactAndOpportunity = true;
    }
    handleClose() {
        this.ShowContactAndOpportunity = false;
    }
    handleNext() {
        this.openOppPage = true;
        this.ShowPopup = false;
    }
    handlepopupClose() {
        this.ShowPopup = true;
        this.openOppPage = false;
        this.optionOne = false;
    }
    get showContent() {
        return this.openOppPage && this.optionOne;
    }
    handelCreatOppInputChanges(event) {
        const field = event.target.name;
        const value = event.target.value;
        this.oppData[field] = value;
    }
    clickToSaveOpportunity() {
        console.log('this.oppData>>>', JSON.stringify(this.oppData));
        creatOpportunity({ accId: this.accountId, opp: this.oppData })
            .then(result => {
                console.log('Opportunity created sucessfully:', JSON.stringify(result));
                this.refreshComponent();
                //alert('Opportunity created successfully with Id: ' + result.Id);
            })
            .catch(error => {
                console.error('Error creating opportunity:', error);
                alert('Error: ' + error.body.message);
            });
        this.openOppPage = false;
        this.optionOne = false;
        this.ShowContactAndOpportunity = true;
    }

    refreshComponent() {
        refreshApex(this.wiredAccountsResult);
        refreshApex(this.wiredAccountDetailsResult);
    }
}