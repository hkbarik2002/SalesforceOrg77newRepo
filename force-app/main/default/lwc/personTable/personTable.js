import { api, LightningElement } from 'lwc';

export default class PersonTable extends LightningElement {

    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Phone', fieldName: 'Phone' },
        { label: 'Country', fieldName: 'Country' }
    ];
    @api dfData;

}