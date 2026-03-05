import { api, LightningElement, wire } from 'lwc';
import GetProductDetail from '@salesforce/apex/GetProductDetails.GetProduct';

export default class ProductCatalog extends LightningElement {
    columns = [
        { label: 'Product Name', fieldName: 'name' },
        { label: 'Price', fieldName: 'price', type: 'currency' },
        {
            type: 'action', // Use 'action' for a dropdown menu
            typeAttributes: {
                rowActions: [
                    { label: 'Remove', name: 'RMV' }
                ]
            }
        }
    ];

    @api allProducts = [];
    removeProductId;
    allSelectedProduct = [];
    isShow = false;
    totalAmount;
    @wire(GetProductDetail)
    productList({ data, error }) {
        if (data) {
            let tempArray = [];
            if (data && data.length > 0) {
                for (let item of data) {

                    let unitPrice = 0;
                    if (item.PricebookEntries && item.PricebookEntries.length > 0) {
                        unitPrice = item.PricebookEntries[0].UnitPrice;
                    }

                    tempArray.push({
                        id: item.Id,
                        name: item.Name,
                        price: unitPrice
                    });
                }
            }
            this.allProducts = tempArray;
        } else if (error) {
            console.error('Error:', error);
        }
    }

    handelCalculateData(event) {
        if (this.allSelectedProduct.length <= 0) {
            this.isShow = false;
            this.totalAmount = 0;
        }
        this.allSelectedProduct = JSON.parse(JSON.stringify(event.detail.totalSelectedProduct));
        this.isShow = true;
        //console.log('this.allSelectedProduct>>>', this.allSelectedProduct);
        if (this.allSelectedProduct.length > 0) {
            let onePro = 0;
            for (let item of this.allSelectedProduct) {
                onePro += Number(item.price) || 0;
            }
            this.totalAmount = onePro;

        }
    }
    handelRemoveProduct(event) {

        let action = JSON.parse(JSON.stringify(event.detail.action));
        let row = JSON.parse(JSON.stringify(event.detail.row));
        // console.log('rowID>>>', row);
        if (action.name === 'RMV') {
            this.allSelectedProduct = this.allSelectedProduct.filter(item => item.id !== row.id);
            this.handelCalculateData({ detail: { totalSelectedProduct: this.allSelectedProduct } });
        }
        this.removeProductId = row.id;
        //console.log('this.removeProductId>>>', this.removeProductId);
    }
}