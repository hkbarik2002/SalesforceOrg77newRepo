import { LightningElement, track, wire } from 'lwc';
import { gql, executeMutation, graphql } from "lightning/graphql";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const colum = [
    { label: 'Id', fieldName: 'Id' },
    { label: 'Name', fieldName: 'Name' },
    { label: 'Email', fieldName: 'Email' },
]

export default class CreateRecordQuery_Gql extends LightningElement {
    contactColumns = colum;
    isCreatButton = false;
    firstName = '';
    lastName = '';
    contactId;
    errors;
    isUpdateButton = false;
    searchInputValue = '';
    latestCotactData = [];
    latestConRefresh
    /**                                             Get 10 latest contact record  */
    @wire(graphql, {
        query: gql`
            query{
                uiapi{
                    query{
                    Contact(orderBy:{CreatedDate :{order:DESC }} first: 10 ){
                        edges{
                        node{
                            Id
                            Name{
                            value
                            }
                        }
                        }
                    }
                }
            }
        }`,
    })
    wiredContacts({ data, errors, refresh }) {
        if (data) {
            this.latestConRefresh = refresh;
            //console.log('latestConRefresh>>>>:', this.latestConRefresh);
            this.latestCotactData = data.uiapi.query.Contact?.edges?.map(edg => {
                return {
                    label: edg.node?.Name?.value,
                    value: edg.node?.Id
                }
            })
            // console.log('latestCotactData>>>>:', this.latestCotactData);
        }
        else if (errors) {
            console.log('errors wire>>>>:', errors.message);
        }
    }




    /**                                      Creat record section  */

    getCreateQuery({ fn, ln }) {
        return gql`
            mutation CreateAccount {
                uiapi {
                    ContactCreate(input: { Contact: { FirstName: "${fn}" ,LastName: "${ln}"  } }) {
                        Record {
                            Id
                            Name {
                                value
                            }
                        }
                    }
                }
            }
        `;
    }
    async handleCreateContact() {
        //console.log('async>>>');
        if (!this.lastName && !this.firstName) {
            this.errors = ['please enter both first and last name'];
            return;
        }

        // this.isLoading = true;
        this.errors = undefined;
        this.contactId = undefined;

        try {
            const result = await executeMutation({
                query: this.getCreateQuery({ fn: this.firstName, ln: this.lastName })
            });

            if (result.errors) {
                console.log('error>>>>', JSON.stringify(result.errors));
                this.errors = result.errors;
            } else {
                // console.log('result>>>>', JSON.stringify(result.data));
                this.contactId = result.data.uiapi.ContactCreate.Record.Id;
                this.showToast('Success', this.firstName + ' ' + this.lastName + ' Records creat successfully..', 'success');
                this.firstName = '';
                this.lastName = '';
                return this.latestConRefresh();
            }
        } catch (error) {
            this.errors = error;
            console.log('Insert error>>', error.message, error.stack);
        }
    }
    openCreatSection() {
        this.isCreatButton = true;
        this.isUpdateButton = false;
        this.openContactDatas = false;
        this.isDeleteButton = false;
        this.contactId = '';
    }
    handelFirstNameChange(event) {
        event.preventDefault();
        this.firstName = event.target.value;
    }
    handelLastNameChange(event) {
        event.preventDefault();
        this.lastName = event.target.value;
    }
    handelContactSave() {
        this.handleCreateContact();
    }
    handelContactCancel() {
        this.isCreatButton = false;
    }

    /**                                        Update record Section  */

    @track conId = '';
    @track contactData;
    isUpdateSearchButton = false;
    afters = null;
    openContactDatas = false;
    @track contaData = {};
    originalData = {};
    _refresh;

    getContactQuery = gql`
        query GetContact($conId: ID) {
            uiapi {
                query {
                    Contact(where: { Id: { eq: $conId } }) {
                        pageInfo{
                            hasNextPage
                            hasPreviousPage
                            endCursor
                            startCursor
                            }
                        edges {
                            node {
                                Id
                                FirstName { value }
                                LastName { value }
                                Email { value }
                            }
                        }
                    }
                }
            }
        }
    `;

    @wire(graphql, {
        query: '$getContactQuery',
        variables: '$variables'
    })
    wiredContact({ data, errors, refresh }) {
        try {
            if (data) {
                this._refresh = refresh;
                //console.log('_refresh>>>', this._refresh);
                const edges = data.uiapi.query.Contact.edges;
                //console.log('data from wire:', data);
                if (edges.length > 0) {
                    const record = edges[0].node;

                    this.contactData = {
                        Id: record.Id,
                        FirstName: record?.FirstName?.value,
                        LastName: record?.LastName?.value,
                        Email: record?.Email?.value
                    };
                    this.originalData = { ...this.contactData };
                }

                else {
                    this.contactData = {};
                }

                //  this.isUpdateSearchButton = true;
                //console.log('contactData:', this.contactData);
                this.openContactDatas = !!this.contactData?.Id;

                //console.log('openContactDatas:', this.openContactDatas);
            }

            if (errors) {
                this.errors = errors;
                console.error('GraphQL Errors:', JSON.stringify(errors));
            }
        } catch (error) {
            this.errors = error;
            console.error('Update Wire error:', error.message, error.stack);
        }
    }

    // dynamic variables getter
    get variables() {
        return {
            conId: this.conId,
            //after: this.afters
        };
    }

    handleContactOptionChange(event) {
        event.preventDefault();
        this.conId = event.target.value;
        //console.log('handleContactOptionChange conId>>>', this.conId);
        if (this.conId === '') {
            this.openContactDatas = false;
        }
        else {
            this.openContactDatas = true;
        }
    }

    openUpdateSection(event) {
        event.preventDefault();
        this.isUpdateButton = true;
        this.isCreatButton = false;
        this.isDeleteButton = false;
    }
    handelUpdateCancel(event) {
        this.conId = '';
        this.openContactDatas = false;
        if (this.conId == '') {
            return this._refresh();
        }
        //this.contactData = undefined;
        //this.originalData = undefined;
    }
    handleInputChange(event) {
        const { name, value } = event.target;

        this.contactData = {
            ...this.contactData,
            [name]: value
        };
    }
    finalData = {};
    handelUpdateSave() {
        this.finalData = {
            FirstName: this.contactData.FirstName || this.originalData.FirstName,
            LastName: this.contactData.LastName || this.originalData.LastName,
            Email: this.contactData.Email || this.originalData.Email
        };
        this.handleUpdateContact();

    }


    get updateMutation() {
        return gql`
        mutation updatContactRecord($input: ContactUpdateInput!){
            uiapi{
                    ContactUpdate(input: $input) {
                            success
                    }
                }
            }
    `;
    }
    async handleUpdateContact() {
        //console.log("Updating contact with data:", this.finalData);
        const result = await executeMutation({
            query: this.updateMutation,
            variables: {
                input: {
                    Id: this.conId,
                    Contact: {
                        FirstName: this.finalData.FirstName,
                        LastName: this.finalData.LastName,
                        Email: this.finalData.Email,
                    },
                },
            },
        });
        // console.log("Update result>>>", result.data.uiapi?.ContactUpdate?.success);
        if (result.data.uiapi?.ContactUpdate?.success) {
            this.showToast('Success', this.finalData.FirstName + ' ' + this.finalData.LastName + ' Records update successfully..', 'success');
            return this._refresh();
        }
    }
    catch(error) {
        console.error("Error creating contact", error);
    }

    /**                                                     Delete Record Section     */

    isDeleteButton = false;
    contactDeleteId = '';

    openDeleteSection() {
        this.isDeleteButton = true;
        this.isCreatButton = false;
        this.isUpdateButton = false;
        this.openContactDatas = false;
    }
    handleDeleteSearch(event) {
        this.contactDeleteId = event.target.value;
    }
    handleDeleteButton() {
        // console.log('contactDeleteId>>', this.contactDeleteId);
        this.handleDeleteContact();
    }
    get deleteMutation() {
        return gql`
      mutation ContactDeleteExample($input:RecordDeleteInput!) {
        uiapi {
          ContactDelete(input: $input) {
            Id
          }
        }
      }
    `;
    }

    async handleDeleteContact() {
        try {
            const promises = this.selectedContactIds.map(coId => {
                return executeMutation({
                    query: this.deleteMutation,
                    variables: {
                        input: { Id: coId }
                    }
                });
            });

            const results = await Promise.all(promises);

            // console.log('All results:', results);

            this.showToast(
                'Success',
                'Records deleted successfully',
                'success'
            );

            this.selectedContactIds = [];

            return this._refresh();

        } catch (error) {
            console.error("Error deleting contact", error);
        }
    }

    selectedContactIds = [];

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;

        // extract only Ids
        this.selectedContactIds = selectedRows.map(row => row.Id);

        console.log('Selected Ids:', this.selectedContactIds);
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    /**                                                               GrapgQl Contact data table     */

    endCursors = null;
    limits = 5;
    listOfAllContactData = [];
    pageInfo;
    get accVeriable() {
        return {
            after: this.endCursors,
            first: this.limits
        }
    }

    @wire(graphql, {
        query: gql`
            query getAllContact($after: String ,$first:Int){
                uiapi{
                     query{
                            Contact(where:{Email:{ne:null}} orderBy:{CreatedDate :{order:DESC }}, after: $after , first: $first){
                                pageInfo{
                                    hasNextPage
                                    endCursor
                                }
                                edges{
                                    node{
                                        Id
                                        Name{value}
                                        Email{value}
                                    }
                                }
                            }
                        }
                    }
                }`,
        variables: "$accVeriable"
    })
    wireGetContactAllData({ data, errors, refresh }) {
        try {
            if (data) {
                // console.log('wireGetContactAllData>>>>>>', data);
                // console.log('refresh>>>', refresh);
                this.pageInfo = data.uiapi.query.Contact?.pageInfo;
                let wireConData = data.uiapi.query.Contact?.edges?.map(edg => ({
                    Id: edg.node?.Id,
                    Name: edg.node?.Name?.value,
                    Email: edg.node?.Email?.value
                }));
                this.listOfAllContactData = [
                    ...this.listOfAllContactData,
                    ...wireConData
                ];
                // console.log('wirelistOfAllContactData>>>>>>', this.listOfAllContactData);
            }
        } catch (error) {
            console.error('wireGetContactAll error>>>:', error.message, error.stack);
        }
    }
    handleLoadMore() {
        if (this.pageInfo?.hasNextPage) {
            this.endCursors = this.pageInfo?.endCursor;
            //console.log('handleLoadMore called, endCursor:', this.endCursors);
        }
    }
}