import { LightningElement, track, wire } from 'lwc';
import searchByEmailId from '@salesforce/apex/LwcPracticeController.searchByEmailId';
import getAccountList from '@salesforce/apex/LwcPracticeController.getAccountList';
import CountTotlAccount from '@salesforce/apex/LwcPracticeController.CountTotlAccount';
export default class LwcPractice extends LightningElement {
    carColumns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Industry', fieldName: 'Industry' },
        { label: 'Website', fieldName: 'AnnualRevenue' }
    ];
    accLimit = 5;
    accOfset = 0;
    Result = [];
    Errors = '';
    countPage = 1;

    @wire(CountTotlAccount)
    wireCountTotlAccount({ error, data }) {
        if (data) {
            //console.log('>>>>>>Wire Data', JSON.stringify(data))
            this.totalAccount = Math.ceil(data.length / this.accLimit);
            //console.log('>>>>>>totalAccount', JSON.stringify(this.totalAccount))
        }
        else if (error) {
            this.totalAccount = 0;
        }
    }

    connectedCallback() {
        this.loadAccountRecord();
    }
    loadAccountRecord() {
        getAccountList({ offS: this.accOfset, limi: this.accLimit })
            .then(data => {
                // console.log('>>>>>>Data', JSON.stringify(data));
                this.Result = data;
            })
            .catch(err => {
                this.Result = [];
                this.Errors = err.body ? err.body.message : err.message;
            });
    }
    previous() {
        this.accOfset -= this.accLimit;
        this.loadAccountRecord();
        this.countPage -= 1;
        //console.log('>>>>>>previous this.countPage', this.countPage);
        if (this.countPage === 1) {
            this.previousDisabled = true;

        }
        else {
            this.previousDisabled = false;
            if (this.countPage === this.totalAccount || this.countPage < this.totalAccount) {
                this.nextDisabled = false;
            }
        }

    }
    next() {
        this.accOfset += this.accLimit;
        this.loadAccountRecord();
        this.countPage += 1;
        //console.log('>>>>>>next this.countPage', this.countPage);
        if (this.countPage === this.totalAccount) {
            this.nextDisabled = true;
        }
        else {
            this.nextDisabled = false;
            if (this.countPage === this.totalAccount || this.countPage < this.totalAccount) {
                this.previousDisabled = false;
            }

        }
    }

    /*handleLoadMore() {
        console.log('handleLoadMore Call>>');
        this.loadAccountRecord();
    }*/













    /* @track inputValue = '';
     @track Result = [];
     @track Errors = '';
     handelInputChage(event) {
         this.inputValue = event.target.value;
     }
     handelClick() {
         console.log('>>>>>>', JSON.stringify(this.inputValue));
         this.loadConOppData();
     }
     loadConOppData() {
         this.Result = [];
         this.Errors = '';
         searchByEmailId({ WebEmails: this.inputValue })
             .then(data => {
                 const tempResult = [];
                 console.log('>>>>>>Data', JSON.stringify(data));
                 // this.Result = data
                 for (let Acid in data) {
                     const AccId = {
                         accountId: Acid,
                         Contacts: [],
                         Opportunitys: []
                     };
                     if (data[Acid]['Contacts']) {
                         AccId.Contacts = data[Acid]['Contacts'].map(c => ({
                             Id: c.Id,
                             Name: c.Name,
                             Department: c.Department
                         }));
                     }
                     if (data[Acid]['Opportunitys']) {
                         AccId.Opportunitys = data[Acid]['Opportunitys'].map(o => ({
                             Id: o.Id,
                             Name: o.Name,
                             StageName: o.StageName
                         }));
                     }
                     tempResult.push(AccId);
                 }
                 this.Result = tempResult;
             })
             .catch(err => {
                 this.Result = [];
                 this.Errors = err.body ? err.body.message : err.message;
             });
     }*/
}