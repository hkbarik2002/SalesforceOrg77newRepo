import { LightningElement, track } from 'lwc';
import getAccount from '@salesforce/apex/PaginationForAccountController.getAccount';
import totalAccountCount from '@salesforce/apex/PaginationForAccountController.totalAccountCount';

const Colunm = [
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Type', fieldName: 'Type', type: 'text' },
    { label: 'BillingCity', fieldName: 'BillingCity', type: 'text' },
    { label: 'BillingState', fieldName: 'BillingState', type: 'Text' }
];
export default class PaginationForAccount extends LightningElement {
    Colunms = Colunm;
    @track records = [];

    pageSize = 5;
    pageNumber = 1;
    isLoading = false;

    connectedCallback() {
        this.loadData();
    }

    loadData() {
        this.isLoading = true;
        getAccount({ pageSize: this.pageSize, pageNumber: this.pageNumber })
            .then(result => {
                // console.log('result>>>', JSON.stringify(result));
                if (result.length > 0) {
                    this.records = [...this.records, ...result];
                    this.pageNumber++;
                } else {
                    this.disableInfiniteLoading = true;
                }
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    loadMoreData() {
        if (!this.isLoading) {
            this.loadData();
        }
    }

    /* Colunms = Colunm;
     @track totalRecord = 0;
     @track data = [];
     @track page = 1;
     @track pageSize = 5;
 
     get totalPages() {
         return Math.ceil(this.totalRecord / this.pageSize);
     }
     get isFirstPage() {
         return this.page === 1;
     }
     get isLastPage() {
         return this.page >= this.totalPages;
     }
 
     connectedCallback() {
         this.loadAccount();
     }
     loadAccount() {
         totalAccountCount()
             .then(data => {
                 this.totalRecord = data;
                 return getAccount({ pageSize: this.pageSize, pageNumber: this.page })
             })
             .then(res => {
                 this.data = res;
             })
             .catch(err => {
                 console.log('Error from Account: ', error);
             });
 
     }
     handlePrevious() {
         if (this.page > 1) {
             this.page--;
             this.loadAccount();
         }
     }
     handleNext() {
         if (this.page < this.totalPages) {
             this.page++;
             this.loadAccount();
         }
     }*/
}