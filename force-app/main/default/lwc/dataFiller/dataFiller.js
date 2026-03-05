import { LightningElement } from 'lwc';

export default class DataFiller extends LightningElement {

    inputData = [];   // ✅ correct spelling

    passDataOnClick() {
        const inputs = this.template.querySelectorAll('lightning-input');

        let newRow = {};

        inputs.forEach(input => {
            newRow[input.label] = input.value;
        });

        // Append new row
        this.inputData = [...this.inputData, newRow];
        this.clearInputs();
        //console.log('>>>', this.inputData);
    }
    clearInputs() {
        const inputs = this.template.querySelectorAll('lightning-input');

        inputs.forEach(input => {
            input.value = '';
        });
    }

}