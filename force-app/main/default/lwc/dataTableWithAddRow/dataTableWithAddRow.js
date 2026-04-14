import { LightningElement, track } from 'lwc';

export default class DataTableWithAddRow extends LightningElement {
    @track data = [];
    //  saveDraftValues;
    columns = [
        { label: 'Name', fieldName: 'name', editable: true },
        { label: 'Email', fieldName: 'email', editable: true }
    ];

    handleAddRow() {
        const newRow = {
            id: Date.now().toString(), // unique key
            name: '',
            email: ''
        };

        this.data = [...this.data, newRow]; // important (immutability)
        // console.log('data----->', this.data);
    }
    handleSave(event) {
        const draftValues = event.detail.draftValues;

        // Merge draft values into existing data
        const updatedData = this.data.map(row => {
            const draft = draftValues.find(d => d.id === row.id);
            console.log('row---->', JSON.stringify(...row), 'draft---->', JSON.stringify(...draft));
            return draft ? { ...row, ...draft } : row;
        });

        this.data = updatedData;

        console.log('Updated data ---->', this.data);
    }

    handleCancel() {
        // Option 1: Just clear draft values (recommended)
        this.draftValues = [];

        // Option 2 (only if needed): reset full data
        // this.data = [];
    }
}