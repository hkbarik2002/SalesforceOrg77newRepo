// yourParentComponent.js
import { LightningElement, track } from 'lwc';

const columns = [
    { label: 'Name', fieldName: 'name' },
    { label: 'Type', fieldName: 'type' },
    {
        label: 'Dynamic Button', fieldName: 'id', type: 'buttonColumn', typeAttributes: {
            recordId: { fieldName: 'id' }
        }
    },
];

export default class YourParentComponent extends LightningElement {
    columns = columns;
    @track data = [
        { id: 1, name: 'Ankit', type: 'CS' },
        { id: 2, name: 'Rijwan', type: 'EC' },
        { id: 3, name: 'Himanshu', type: 'MEC' },
        { id: 4, name: 'Anil', type: 'CS' },
        { id: 5, name: 'Sachin', type: 'MSC' },
    ];

    // handleButtonMethod(event) {
    //     console.log('Name>>>>:::', event.detail.buttonName);
    //     console.log('Id:::::>>', event.detail.recordId);
    // }
}