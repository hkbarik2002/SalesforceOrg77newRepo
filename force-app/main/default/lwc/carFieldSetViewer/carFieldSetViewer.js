import { LightningElement, wire } from 'lwc';
import getFieldSetFields from '@salesforce/apex/CarFieldSetController.getFieldSetFields';
export default class CarFieldSetViewer extends LightningElement {

    fsColumn = [];
    fsData;
    allDatafetch = false;
    @wire(getFieldSetFields, {
        objectName: 'Rexo2026__Car__c',
        fieldSetName: 'Rexo2026__Car_Field_Set'
    })
    wiredFields({ data, error }) {
        if (data) {
            //console.log('data>>', data);
            this.fsColumn = data.fsString.map(fsd => {
                return {
                    label: fsd.replace(/^[^_]+__/, '').replace(/__c$/, '').replace(/([A-Z])/g, ' $1').trim(),
                    fieldName: fsd
                }
            })
            this.fsData = data.CarsList;
            if (this.fsData && this.fsColumn) {
                this.allDatafetch = true;
                //console.log('fsData>>
            }
            //console.log('fsColumn>>>', this.fsData);
        }
    }
}