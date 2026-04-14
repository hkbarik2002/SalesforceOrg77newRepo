import { LightningElement, api } from 'lwc';

export default class customActionCells extends LightningElement {
    @api recordId;

    fireRowAction(actionName) {
        this.dispatchEvent(
            new CustomEvent('lightning-datatable__rowaction', {
                detail: {
                    action: { name: actionName },
                    row: { Id: this.recordId }
                },
                bubbles: true,
                composed: true
            })
        );
    }

    handleEdit() {
        this.fireRowAction('edit');
    }

    // handleDelete() {
    //     this.dispatchEvent(new CustomEvent('action', { detail: { name: 'delete', recordId: this.recordId } }));
    // }

    // handleView() {
    //     this.dispatchEvent(new CustomEvent('action', { bubbles: true, composed: true, detail: { name: 'view', recordId: this.recordId } }));
    // }
}