import LightningDatatable from 'lightning/datatable';
import buttonColumn from './buttonColumns.html';
export default class CustomDataType extends LightningDatatable {
    static customTypes = {
        buttonColumns: {
            template: buttonColumn,
            typeAttributes: ['recordId']
        }
    }
}