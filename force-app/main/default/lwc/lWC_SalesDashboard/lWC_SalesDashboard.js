import { LightningElement, track, wire } from 'lwc';
import getAccountOptions from '@salesforce/apex/SalesDashboardController.getAccountOptions';
import getStageOptions from '@salesforce/apex/SalesDashboardController.getStageOptions';
import getOpportunities from '@salesforce/apex/SalesDashboardController.getOpportunities';
export default class LWC_SalesDashboard extends LightningElement {
    @track accountOptions = [];
    @track selectedAccountId = '';
    @track stageOptions = [];
    @track selectedStage = '';
    @track startDate = '';
    @track endDate = '';
    @track opportunities = [];
    connectedCallback() {
        this.allAccountIdName();
    }
    allAccountIdName() {
        getAccountOptions()
            .then(data => {
                this.accountOptions = data.map(account => ({
                    label: account.Name,
                    value: account.Id
                }));
            }).catch(error => {
                console.error('Error fetching account options', error);
            });

    }
    handleAccountChange(event) {
        this.selectedAccountId = event.detail.value;
        const accountIdss = this.selectedAccountId;
        getStageOptions({ accounid: accountIdss })
            .then(result => {
                this.stageOptions = result.map(stage => ({
                    label: stage,
                    value: stage
                }));
            })
            .catch(error => {
                console.error('Error fetching stage options:', error);
            })
        //  console.log('this.selectedAccontId >>>>', JSON.stringify(this.selectedAccountId));
    }
    handelSearchClick() {
        getOpportunities({ accountId: this.selectedAccountId, stage: this.selectedStage })
            .then(result => {
                this.opportunities = result;
                // console.log('this.opportunities >>>>', JSON.stringify(this.opportunities));
            })
            .catch(error => {
                console.error('Error fetching stage options:', error);
            })
    }


    handleStageChange(event) {
        this.selectedStage = event.detail.value;
        //console.log('this.selectedStage >>>>', JSON.stringify(this.selectedStage));
    }
    handelStartDateChange(event) {
        this.startDate = event.detail.value;
        //console.log('this.startDate >>>>', JSON.stringify(this.startDate));
    }
    handelEndDateChange(event) {
        this.endDate = event.detail.value;
        //console.log('this.endDate >>>>', JSON.stringify(this.endDate));
    }
}