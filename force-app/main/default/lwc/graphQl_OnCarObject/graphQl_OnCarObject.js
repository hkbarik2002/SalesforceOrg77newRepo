import { LightningElement, wire } from 'lwc';
import { gql, graphql } from "lightning/graphql";

const column = [
    { label: 'Car Name', fieldName: 'carName', type: 'text' },
    { label: 'Status', fieldName: 'status', type: 'text' },
    { label: 'Category', fieldName: 'category', type: 'text' },
    { label: 'Daily Rent', fieldName: 'dailyRent', type: 'currency' },
    { label: 'Total Amount', fieldName: 'totalAmount', type: 'currency' },
    { label: 'Customer Name', fieldName: 'customerName', type: 'text' },
    { label: 'Total Days', fieldName: 'totalDays', type: 'Number' }
]
export default class GraphQl_OnCarObject extends LightningElement {
    columns = column;
    inputSvelue = '';
    caraDetails = [];
    isSpinerLoading = false;
    pageInfos;
    totalRecords;
    afters = null;
    pageNumber = 1;
    limits = 4;


    connectedCallback() {
        this.isSpinerLoading = true;
    }

    get disableNextButton() {
        return this.pageInfos && !this.pageInfos?.hasNextPage;
    }

    get totalPages() {
        return Math.ceil(this.totalRecords / this.limits);
    }

    get gqlInputdata() {
        return {
            carName: '%' + this.inputSvelue + '%',
            limits: this.limits,
            after: this.afters
        }
    }

    @wire(graphql, {
        query: gql`query getCarIds ($carName:String, $limits:Int, $after:String){
            uiapi {
                query {
                Rexo2026__VehicleBooking__c(
                    where: {
                    and:[
                        {Rexo2026__Car__c: { ne: null }},
                        {Rexo2026__Car__r:{
                        Rexo2026__Name__c:{like:$carName}
                        }}
                    ]
                    
                    }
                    first : $limits after : $after
                ) {
                    totalCount
                    pageInfo{
                    hasNextPage
                    hasPreviousPage
                    endCursor
                    startCursor
                    }
                    edges {
                    node {
                        Id
                        Rexo2026__CustomerName__c{
                        value
                        }
                        Rexo2026__TotalDays__c{
                        value
                        }
                        Rexo2026__TotalAmount__c{
                        value
                        displayValue
                        }
                        Rexo2026__Car__r{
                            Rexo2026__Name__c{
                                value
                            }
                            Rexo2026__Status__c{
                                value
                            }
                            Rexo2026__Category__c{
                                value
                            }
                            Rexo2026__DailyRent__c{
                                value
                                displayValue
                            }
                        }
                    }
                    }
                }
                }
            }
        }`,
        variables: "$gqlInputdata"
    })
    getCarDeatails({ data, errors }) {
        if (data) {
            // console.log('data>>>', data);
            this.totalRecords = data.uiapi.query?.Rexo2026__VehicleBooking__c?.totalCount;
            this.pageInfos = data.uiapi.query?.Rexo2026__VehicleBooking__c?.pageInfo;
            this.caraDetails = data.uiapi.query?.Rexo2026__VehicleBooking__c?.edges?.map((car) => {
                return {
                    Id: car.node.Id,
                    carName: car.node.Rexo2026__Car__r?.Rexo2026__Name__c?.value,
                    status: car.node.Rexo2026__Car__r?.Rexo2026__Status__c?.value,
                    category: car.node.Rexo2026__Car__r?.Rexo2026__Category__c?.value,
                    dailyRent: car.node.Rexo2026__Car__r?.Rexo2026__DailyRent__c?.value,
                    totalAmount: car.node.Rexo2026__TotalAmount__c?.value,
                    customerName: car.node.Rexo2026__CustomerName__c?.value,
                    totalDays: car.node.Rexo2026__TotalDays__c?.value
                }
            })
            this.isSpinerLoading = false;
            //console.log('caraDetails>>>', this.caraDetails);
        }
        else if (errors) {
            console.log('errors>>', JSON.stringify(errors));
            this.isSpinerLoading = false;
        }
    }

    handelInputChange(event) {
        event.preventDefault();
        this.inputSvelue = event.target.value;
        this.afters = null;
        this.pageNumber = 1;
        // console.log('this.afters>>>', this.afters);
    }

    handelNext(event) {
        event.preventDefault();
        this.isSpinerLoading = true;
        if (this.pageInfos && this.pageInfos.hasNextPage) {
            this.afters = this.pageInfos.endCursor;
            this.pageNumber++;
        }
        else {
            this.afters = null;
            this.pageNumber = 1;
        }
        console.log('isSpinerLoading>>>', this.isSpinerLoading);
    }
    handleReset(event) {
        event.preventDefault();
        this.afters = null;
        this.inputSvelue = '';
        this.pageNumber = 1;

    }
}