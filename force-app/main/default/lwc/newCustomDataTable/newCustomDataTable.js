import lightningDatatable from 'lightning/datatable';
import customActionCell from './customActionCells.html';
export default class newCustomDataTable extends lightningDatatable {
    static customTypes = {
        horizontalActions: {
            template: customActionCell,
            standardCellLayout: true,
            typeAttributes: ['recordId']
        }
    };
}