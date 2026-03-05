import { LightningElement } from 'lwc';

export default class ItemsContainer extends LightningElement {

    items = [
        { id: '1', name: 'Apple', count: 2 },
        { id: '2', name: 'Banana', count: 5 },
        { id: '3', name: 'Mango', count: 1 }
    ];

    handleIncrement(event) {
        const itemId = event.detail;
        this.items = this.items.map(item => (
            item.id === itemId ? { ...item, count: item.count + 1 } : item
        ));
        // Optional: keep console for debugging
        console.log('items>>>>', this.items);
    }
}