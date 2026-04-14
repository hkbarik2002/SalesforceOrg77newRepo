import { LightningElement, track } from 'lwc';
import getSalesData from '@salesforce/apex/SalesDashboardController.getSalesData';
import getAccountOptions from '@salesforce/apex/SalesDashboardController.getAccountOptions';

const CONTACT_COLUMNS = [{ label: 'Name', fieldName: 'Name', type: 'text' }];
const OPPORTUNITY_COLUMNS =
    [{ label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Stage', fieldName: 'StageName', type: 'text' }
    ];

export default class SalesDashboard extends LightningElement {
    @track selectedAccountIds = [];
    @track accountOptions = [];
    @track contactsData = [];
    @track opportunitiesData = [];
    @track filteredOpportunities = [];
    @track stageOptions = [];
    @track selectedStage = 'all';
    @track isLoading = false;
    @track error;

    contactColumns = CONTACT_COLUMNS;
    opportunityColumns = OPPORTUNITY_COLUMNS;

    connectedCallback() {
       // console.log('connectedCallback call ===>');
        this.loadAccountOptions();
    }

    loadAccountOptions() {
        getAccountOptions()
            .then(data => {
                this.accountOptions = data.map(account => ({
                    label: account.Name,
                    value: account.Id
                }));
                //console.log('Account Options => ', this.accountOptions);
            })
            .catch(error => {
                this.error = error.body ? error.body.message : error.message;
                //console.error('Error loading account options', this.error);
            });
    }

    async handleAccountChange(event) {
        this.selectedAccountIds = event.detail.value;
        await this.loadSalesData();
    }
    handleStageChange(event) {
        this.selectedStage = event.detail.value;
        this.filterOpportunities();
    }

    filterOpportunities() {
        // console.log('Selected Stage:', this.selectedStage);
        // console.log('All Stages in Opportunities:', this.opportunitiesData.map(o => o.StageName));
        if (this.selectedStage === 'all') {
            this.filteredOpportunities = [...this.opportunitiesData];
        } else {
            this.filteredOpportunities = this.opportunitiesData.filter(
                opp => opp.StageName === this.selectedStage
            );
        }
    }

    async loadSalesData() {
        if (!this.selectedAccountIds || this.selectedAccountIds.length === 0) {
            this.contactsData = [];
            this.opportunitiesData = [];
            this.filteredOpportunities = [];
            this.stageOptions = [];
            return;
        }

        this.isLoading = true;
        this.error = undefined;

        try {
            const result = await getSalesData({ accountIds: this.selectedAccountIds });
            const parsedData = JSON.parse(result);

            this.contactsData = [];
            Object.keys(parsedData.accountContacts).forEach(accountId => {
                this.contactsData.push(...parsedData.accountContacts[accountId]);
            });

            this.opportunitiesData = [];
            Object.keys(parsedData.accountOpportunities).forEach(accountId => {
                this.opportunitiesData.push(...parsedData.accountOpportunities[accountId]);
            });

            this.filteredOpportunities = [...this.opportunitiesData];

            this.stageOptions = [
                { label: 'All Stages', value: 'all' },
                ...Array.from(parsedData.uniqueOpportunityStages || []).map(stage => ({
                    label: stage,
                    value: stage
                }))
            ];
        } catch (error) {
            this.error = error.body?.message || error.message;
        } finally {
            this.isLoading = false;
        }
    }

    get hasData() {
        return this.contactsData.length > 0 || this.opportunitiesData.length > 0;
    }
}