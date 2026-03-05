import { LightningElement, track, wire } from 'lwc';
import getReview from '@salesforce/apex/ReviewControler.getReview';

export default class AutoRefreshApex extends LightningElement {

    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Email', fieldName: 'Email__c' },
        { label: 'Ratings', fieldName: 'Ratings__c' }
    ];
    @track Reviews;

    connectedCallback() {
        this.fetchReviews();
    }
    fetchReviews() {
       // console.log('fetchReviews call------>');
        getReview()
            .then(result => {
                this.Reviews = result;
                //console.log('Reviews fetched:', result);
            })
            .catch(error => {
               // console.error('Error fetching reviews:', error);
            });
    }

    handleRefreshClick() {
       // console.log('refresh call------>');
        this.fetchReviews();
    }

}