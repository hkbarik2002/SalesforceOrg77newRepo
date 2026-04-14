import { LightningElement, track } from 'lwc';

export default class ParentComponent extends LightningElement {
    @track selectedOption = '';

    options = [
        { label: 'Show Input 1', value: 'name' },
        { label: 'Show Input 2', value: 'phone' },
        { label: 'Show Input 3', value: 'email' }
    ];

    handleChange(event) {
        this.selectedOption = event.detail.value;
        console.log('this.selectedOption>>>>>', this.selectedOption);
    }
}