import { api, LightningElement, track } from 'lwc';

export default class ProductTile extends LightningElement {

    @track _allProduct = [];
    _removeData;
    selectedProduce = [];
    @api get removeData() {
        return this._removeData;
    }

    set removeData(value) {
        //console.log('removeData received in setter >>>', value);
        this._removeData = value;
        if (value) {
            this.handleUnselectProduct(value);
        }
    }
    handleUnselectProduct(value) {
        this._allProduct = this._allProduct.map(item => {
            if (item.id === value) {
                return {
                    ...item,
                    rowLabel: 'Add To Cart',
                    buttonVariant: 'brand',
                    isAdded: false
                }
            }
            return item;
        });
    }
    get columns() {
        return [
            { label: 'Product Name', fieldName: 'name' },
            { label: 'Price', fieldName: 'price', type: 'currency' },
            {
                type: 'button',
                typeAttributes: {
                    label: { fieldName: 'rowLabel' },
                    name: 'ATC',
                    variant: { fieldName: 'buttonVariant' },
                    disabled: { fieldName: 'isAdded' }
                }
            }
        ];
    }
    @api
    get allProduct() {
        return this._internalList;
    }
    set allProduct(value) {
        if (value) {
            this._allProduct = value.map(item => ({
                ...item,
                rowLabel: item.rowLabel || 'Add To Cart',
                buttonVariant: item.buttonVariant || 'brand',
                isAdded: item.isAdded || false
            }));
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        this.selectedProduce = [...this.selectedProduce, {
            id: row.id,
            name: row.name,
            price: row.price
        }];
        if (actionName === 'ATC') {
            console.log('Clicked:', row.name);
            this._allProduct = this._allProduct.map(item => {
                if (item.id === row.id) {
                    return {
                        ...item,
                        rowLabel: 'Added',
                        buttonVariant: 'success',
                        isAdded: true
                    };
                }
                return item;
            });

        }
    }

    handleCalculation() {
        console.log('this.selectedProduce>>', this.selectedProduce);
        this.dispatchEvent(new CustomEvent('cartupdate', {
            detail: { totalSelectedProduct: this.selectedProduce }
        }));
        this.selectedProduce = [];
    }
}