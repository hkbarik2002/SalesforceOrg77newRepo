import { LightningElement, wire } from 'lwc';
import { gql, graphql } from "lightning/graphql";

const column = [
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Department', fieldName: 'Department', type: 'text' },
    { label: 'Phone', fieldName: 'Phone', type: 'phone' },
    { label: 'Email', fieldName: 'Email', type: 'email' },
    { label: 'AccountName', fieldName: 'AccountName', type: 'text' },
    { label: 'AnnualRevenue', fieldName: 'AnnualRevenue', type: 'currency' }
]
export default class GraphQlComponent extends LightningElement {
    columns = column;
    condata = [];
    errors;
    inputName = '';
    limits = 5;
    afters = null;
    pageInfo;
    totalRecordCount;
    pageNumber = 1;
    isLoading = false;

    connectedCallback() {
        this.isLoading = true;
    }
    get variables() {
        return {
            conName: '%' + this.inputName + '%',
            qlimits: this.limits,
            after: this.afters

        }
    }
    @wire(graphql, {
        query: gql
            `
            query getAccoutRecord($conName:String,$qlimits:Int , $after:String){
                        uiapi{
                                query{
                                    Contact(where:{Name:{like:$conName}} first: $qlimits after : $after ){
                                     totalCount
                                        pageInfo{
                                            hasNextPage
                                            hasPreviousPage
                                            startCursor
                                            endCursor
                                        }
                                        edges{
                                            node{
                                                Id
                                                Name{
                                                value
                                                }
                                                Department{
                                                value
                                                }
                                                Phone{
                                                value
                                                }
                                                Email{
                                                value
                                                }
                                                Account{
                                                    Name{
                                                        value
                                                    }
                                                    AnnualRevenue{
                                                        value
                                                        displayValue
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                    }
        `,
        variables: "$variables"
    })
    graphqlQueryResult({ data, errors }) {
        if (data) {
            //console.log('data>>', data);
            this.pageInfo = data.uiapi.query?.Contact?.pageInfo;
            this.totalRecordCount = data.uiapi.query?.Contact?.totalCount;
            // console.log('this.pageInfo>>', this.pageInfo);
            this.condata = data.uiapi.query?.Contact?.edges?.map((edge) => {
                // console.log('edge>>', edge);
                return {
                    Id: edge.node.Id,
                    Name: edge.node?.Name?.value,
                    Department: edge.node.Department?.value,
                    Phone: edge.node.Phone?.value,
                    Email: edge.node.Email?.value,
                    AccountName: edge.node.Account?.Name?.value,
                    AnnualRevenue: edge.node.Account?.AnnualRevenue?.value
                }
            });
            this.isLoading = false;
        }
        else if (errors) {
            console.log('errors>>', JSON.stringify(errors));
            this.isLoading = false;
        }

    }
    get totalPages() {
        return Math.ceil(this.totalRecordCount / this.limits);
    }
    get disableNestButton() {
        return !this.pageInfo?.hasNextPage;
    }
    handleReset(event) {
        event.preventDefault();
        console.log('isloading >> ', this.isLoading);
        this.isLoading = true;
        this.afters = null;
        if (this.pageNumber === 1) {
            //this.isLoading = false;
            this.inputName = '';
        } else {
            this.pageNumber = 1;
            // this.isLoading = false;
        }
    }
    handleNextClick(event) {

        event.preventDefault();
        console.log('isloading >> ', this.isLoading);
        //this.isLoading = this.isLoading ? false : true;
        this.isLoading = true;
        if (this.pageInfo && this.pageInfo.hasNextPage) {
            this.afters = this.pageInfo.endCursor;
            this.pageNumber++;

        } else {
            this.afters = null;
            this.pageNumber = 1;
        }

    }
    handelInputChange(event) {
        event.preventDefault();
        this.inputName = event.target.value;
        this.pageNumber = 1;
        this.afters = null;
        // console.log('this.inputName>>', this.inputName);
    }
}