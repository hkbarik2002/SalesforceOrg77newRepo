import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getApprovedLoans from '@salesforce/apex/LoanRepaymentPortalController.getApprovedLoans';
import fetchRemainingAmount from '@salesforce/apex/LoanRepaymentPortalController.fetchRemainingAmount';
import RepaymentAndPenalty from '@salesforce/apex/LoanRepaymentPortalController.RepaymentAndPenalty';
import creatNewRepayment from '@salesforce/apex/LoanRepaymentPortalController.creatNewRepayment';
import getActiveLoans from '@salesforce/apex/LoanRepaymentPortalController.getActiveLoans';

export default class LoanRepaymentPortal extends LightningElement {
    @track loanColumns = [
        { label: 'Label', fieldName: 'Name' },
        { label: 'Status', fieldName: 'Status__c' },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'View', name: 'view' },
                    { label: 'Repay', name: 'repay' }
                ]
            }
        }
    ];
    customerColumns = [
        { label: 'Loan Name', fieldName: 'loanName' },
        { label: 'Status', fieldName: 'status' },
        { label: 'Original Amount', fieldName: 'originalAmount' },
        { label: 'Total Repaid', fieldName: 'totalRepaid' },
        { label: 'Outstanding Balance', fieldName: 'outstandingBalance' },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'View', name: 'view' }
                ]
            }
        }
    ];

    @track repaymentColumns = [
        { label: 'Payment No', fieldName: 'Name' },
        { label: 'Paid Date', fieldName: 'Payment_Date__c', type: 'date' },
        { label: 'Amount Paid', fieldName: 'Amount_Paid__c', type: 'currency' }
    ];

    @track penaltyColumns = [
        { label: 'Penalty No', fieldName: 'Name' },
        { label: 'Penalty Date', fieldName: 'Penalty_Date__c', type: 'date' },
        { label: 'Amount', fieldName: 'Amount__c', type: 'currency' },
        { label: 'Reason', fieldName: 'Reason__c', type: 'text' }
    ];
    isAdmin = false;
    isCustomer = false;
    @track activeLoans;
    @track selectedLoan;
    loanMap = new Map();
    @track repayments;
    @track penalties;
    @track error;
    isModalOpen = false;
    isSelectedLoan = false;
    repayAmount;
    repayDate;
    customers;

    connectedCallback() {
        this.isCustomer = true;
        this.isAdmin = true;
        this.callgetActiveLoans();
    }
    async callgetActiveLoans() {
        const result = await getActiveLoans();
        if (result != null) {
            this.customers = result;
            // console.log('this.customers>>>', JSON.stringify(this.customers));
        }
    }

    @wire(getApprovedLoans)
    wireGetApprovedLoans({ error, data }) {
        if (data) {
            this.activeLoans = data;
            /*this.loanMap = new Map();

            data.forEach(loan => {
                let clonedLoan = JSON.parse(JSON.stringify(loan));
                this.loanMap.set(clonedLoan.Id, clonedLoan);
            });

            // ✅ Correct way to see the map
            console.log('Loan Map:', Array.from(this.loanMap.entries()));*/
        } else if (error) {
            console.error('Error:', error);
        }
    }
    handleLoanRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        this.selectedLoanId = row.Id;
        this.fetchRemainAmount();
        if (actionName === 'view') {
            this.isSelectedLoan = true;
            this.fetchRepaymentAndPenalty();
        }
        else if (actionName === 'repay') {
            //console.log('isModalOpen>>>>>>>>>>>');
            this.isSelectedLoan = false;
            this.isModalOpen = true;
        }
        /* if (this.loanMap.has(this.selectedLoanId)) {
             this.selectedLoan = this.loanMap.get(this.selectedLoanId);
             console.log('Selected Loan:', this.selectedLoan);
         } else {
             console.log('Loan not found for Id:', this.selectedLoanId);
         }
         console.log('Selected Loan Id:', this.selectedLoanId);
         console.log('Action:', actionName);*/
    }
    async fetchRemainAmount() {
        //console.log('lonIds>>>', JSON.stringify(this.selectedLoanId));
        const result = await fetchRemainingAmount({ lonIds: this.selectedLoanId });
        if (result != null) {
            //console.log('data>>>', JSON.stringify(result));
            this.selectedLoan = result;
        }

    }
    async fetchRepaymentAndPenalty() {
        const Data = await RepaymentAndPenalty({ lonId: this.selectedLoanId })
        if (Data != null) {
            //console.log('Loan Map>>>', Data);
            let wrapper = Data[this.selectedLoanId];
            if (wrapper != null) {
                this.repayments = wrapper.listOfRepayment;
                //console.log('this.repayments>>>', JSON.stringify(this.repayments));
                this.penalties = wrapper.listOfPenalty;
                //console.log('this.penalties>>>', JSON.stringify(this.penalties));
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.repayments = [];
            this.penalties = [];
        }
    }

    handleAmountChange(event) {
        this.repayAmount = event.detail.value;
    }
    handleDateChange(event) {
        this.repayDate = event.detail.value;
    }
    submitRepayment() {
        creatNewRepayment({ lonId: this.selectedLoanId, rAmount: this.repayAmount, rDate: this.repayDate })
            .then(res => {
                // console.log('res>>>>>', res);
                this.showToast('Success', 'Next payment due on: ' + res, 'success');

            })
            .catch(err => {
                console.error('Error:', err);
            })
    }

    refreshLoan() {
        this.isModalOpen = false;
        this.fetchRemainAmount();
        this.fetchRepaymentAndPenalty();
        this.isSelectedLoan = true;
    }
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}