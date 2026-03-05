import { LightningElement, track, wire } from 'lwc';
import getPaginatedAccountsWithOpps from '@salesforce/apex/AccountDataService.getPaginatedAccountsWithOpps';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Recommendation_Firld from "@salesforce/schema/Claim_Assessment__c.Recommendation__c";
import { RECORD_TYPE_ID } from './masterRecordTypeId';
import UId from '@salesforce/user/Id';
export default class AccountList extends LightningElement {
    columns = [
        { label: 'Account Name', fieldName: 'accountName', type: 'text', editable: true },
        { label: 'Total Opportunity Amount', fieldName: 'totalOpportunityAmount', type: 'currency' },
        { label: 'Latest Opportunity Close Date', fieldName: 'latestOpportunityCloseDate', type: 'date' },
        {
            label: 'Action', type: 'buttonColumns', typeAttributes: {
                recordId: { fieldName: 'accountId' }
            }
        },
    ];

    userId = UId;

    currentPage = 1;
    pageSizes = 4;
    totalRecord = 0;
    AssRecPicData;

    totalDataRetrive = [];

    get computedOffset() {
        //console.log('this.totalRecord>>>', JSON.stringify(this.totalRecord), '>> this.pageSizes >>', JSON.stringify(this.pageSizes));
        return Math.ceil(this.totalRecord / this.pageSizes);
    }
    get lastPage() {
        return this.currentPage >= this.computedOffset;
    }
    get firstPage() {
        return this.currentPage === 1;
    }
    connectedCallback() {
        this.countTotalRecord();
    }

    // @wire(getPicklistValues, { recordTypeId: RECORD_TYPE_ID, fieldApiName: Recommendation_Firld })
    // getAssessRecommPickListData({ data, error }) {
    //     if (data) {
    //         this.AssRecPicData = data.values.map((d) => {
    //             return { label: d.label, value: d.value };
    //         });
    //         console.log('this.AssRecPicData>>>', this.AssRecPicData);
    //     }
    //     if (error) {
    //         console.error('error: >>'.error);
    //     }
    // }


    countTotalRecord() {
        getPaginatedAccountsWithOpps({ pageSize: this.pageSizes, offsets: (this.currentPage - 1) * this.pageSizes })
            .then(data => {
                //console.log('data>>>', data);
                this.totalDataRetrive = data.accountRows;
                this.totalRecord = data.totalCount;
                //console.log(' this.totalDataRetrive>>>', JSON.stringify(this.totalDataRetrive));
                //console.log(' this.totalRecord>>>', JSON.stringify(this.totalRecord));
            })
            .catch(err => {
                this.totalDataRetrive = [];
                this.Errors = err.body ? err.body.message : err.message;
            });
    }
    handelPrevious() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.countTotalRecord();
        }
    }
    handelNext() {
        if (this.currentPage < this.computedOffset) {
            this.currentPage++;
            this.countTotalRecord();
        }
    }
    handelSave(event) {
        // console.log('Name>>>>:::>>>>', event.detail.buttonName);
        // console.log('Id:::::>>', event.detail.recordId);
    }

    handleUploadFinished(event) {
        console.log('event>>>', event);
        const uploadedFiles = event.detail.files;
        console.log('uploadedFiles>>>', uploadedFiles);
    }
}