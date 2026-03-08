import { LightningElement, wire, track } from 'lwc';
import getAllProduct from '@salesforce/apex/ParentProductLwcController.getAllProduct';

export default class ParentProductLwc extends LightningElement {
    @track inputData = ''; // Initialize with empty string
    products = [];
    // The wire automatically re-provisions whenever '$inputData' changes
    @wire(getAllProduct, { inputData: '$inputData' })
    wireProductData(result) {
        this.products = result;
    }

    trackInputChange(event) {
        const searchKey = event.target.value;

        // Corrected .length property usage
        if (searchKey && searchKey.length > 3) {
            this.inputData = searchKey;
        } else if (searchKey === '') {
            // Optional: Reset data if search is cleared
            this.inputData = '';
        }
    }
}