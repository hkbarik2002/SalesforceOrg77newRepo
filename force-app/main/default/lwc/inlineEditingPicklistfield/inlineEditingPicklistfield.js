import { LightningElement, track, wire } from 'lwc';
import getProjectTaskData from '@salesforce/apex/InlineEditingPicklistfieldController.getProjectTaskData';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import PROJECTTASK_OBJECT from '@salesforce/schema/Project_Task__c';
import STATUS_FIELD from '@salesforce/schema/Project_Task__c.Status__c';

const columns = [
    { label: 'Name', fieldName: 'Name__c', type: 'text' },
    { label: 'Due date', fieldName: 'Due_Date__c', type: 'date' },
    {
        label: 'Status',
        fieldName: 'Status__c',
        type: 'customPickList',
        wrapText: true,
        typeAttributes: {
            options: { fieldName: 'statusPicklistOptions' },
            value: { fieldName: 'Status__c' },
            placeholder: 'Choose status'
        }
    }
];

export default class InlineEditingPicklistfield extends LightningElement {
    columns = columns;
    @track taskData = [];
    @track ptStatus = [];
    @track draftValues = [];

    @wire(getObjectInfo, { objectApiName: PROJECTTASK_OBJECT })
    ptObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$ptObjectInfo.data.defaultRecordTypeId',
        fieldApiName: STATUS_FIELD
    })
    ptStatusPicklist({ data, error }) {
        if (data) {
            //console.log('>>>>>PT', JSON.stringify(data));
            this.ptStatus = data.values.map(opt => ({
                label: opt.label,
                value: opt.value
            }));
            //console.log('>>>>>PS', JSON.stringify(this.ptStatus));
            this.fetchPTdata();
        } else if (error) {
            console.error('Picklist fetch error', error);
        }
    }

    fetchPTdata() {
        getProjectTaskData()
            .then(result => {
                this.taskData = result.map(record => {
                    return {
                        ...record,
                        'statusPicklistOptions': this.ptStatus   // ✅ attach options here
                    };
                });
                // console.log('Final Data => ', JSON.stringify(this.taskData));
            })
            .catch(error => {
                console.error('Task fetch error', error);
            });
    }
    handleCellChange(event) {
        this.draftValues = event.detail.draftValues;

    }
    handelSave() {
        console.log('>>>>cc', JSON.stringify(this.draftValues));
    }
}