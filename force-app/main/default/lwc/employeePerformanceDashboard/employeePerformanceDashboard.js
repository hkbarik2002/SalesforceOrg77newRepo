import { LightningElement, track, wire } from 'lwc';
import totalEmployeePerformanceData from '@salesforce/apex/EmployeePerformanceDashboard.totalEmployeePerformanceData';
import getEmployeePerformanceData from '@salesforce/apex/EmployeePerformanceDashboard.getEmployeePerformanceData';
import updatePerformance from '@salesforce/apex/EmployeePerformanceDashboard.updatePerformance';
export default class EmployeePerformanceDashboard extends LightningElement {

    columns = [
        { label: 'Name', fieldName: 'Employee_Name__c', type: 'text' },
        { label: 'Review Date', fieldName: 'Review_Date__c', type: 'date' },
        { label: 'Dipartment', fieldName: 'Department__c', type: 'text', editable: true },
        { label: 'Rating', fieldName: 'Rating__c', type: 'number', editable: true }
    ];

    departmentOptions = [
        { label: 'Sales', value: 'Sales' },
        { label: 'HR', value: 'HR' },
        { label: 'Tech', value: 'Tech' },
        { label: 'Finance', value: 'Finance' },
    ];

    @track performanceData = [];
    @track selectedDepartment;
    @track fromDate;
    @track toDate;
    @track totalRecord = 0;
    @track pageNumber = 1;
    @track pageSize = 5;

    get totalPages() {
        return Math.ceil(this.totalRecord / this.pageSize);
    }
    get isPrevDisabled() {
        return this.pageNumber === 1;
    }
    get isNextDisabled() {
        return this.pageNumber >= this.totalPages;
    }

    handleDepartmentChange(event) {
        this.selectedDepartment = event.detail.value;
        // console.log('handleDepartmentChange>>', JSON.stringify(this.selectedDepartment));
    }
    handleFromDateChange(event) {
        this.fromDate = event.detail.value;
        //console.log('fromDate>>', JSON.stringify(this.fromDate));
    }
    handleToDateChange(event) {
        this.toDate = event.detail.value;
        //console.log('toDate>>', JSON.stringify(this.toDate));
    }
    async handleApplyFilters() {
        try {
            console.log('here i am>>>>>>>');

            // First get total record count
            this.totalRecord = await totalEmployeePerformanceData({
                department: this.selectedDepartment,
                fromDates: this.fromDate,
                toDates: this.toDate
            });
            await this.fatchDataEPD();
            // Then get paginated employee data


        } catch (error) {
            console.error('Error Found', error);
        }
    }
    async fatchDataEPD() {
        console.log('I amm>>>');
        try {
           const data = await getEmployeePerformanceData({
                department: this.selectedDepartment,
                fromDates: this.fromDate,
                toDates: this.toDate,
                pageSizes: this.pageSize,
                pageNumbers: this.pageNumber
            });
             this.performanceData = [...data];
        } catch (error) {
            console.error('Error Found', error);
        }
    }

    async handleSave(event) {
        try {
            const recordEdits = event.detail.draftValues;
            console.log('recordEdit>>', JSON.stringify(recordEdits));

            // Update records in Apex
            await updatePerformance({ employPerformance: recordEdits });

            // Clear draft values
            this.draftValues = [];

            // 🔹 Re-fetch latest data after save
            await this.fatchDataEPD();

            console.log('Data refreshed after update');

        } catch (error) {
            console.error('Error while updating', error);
        }
    }

    handlePrevious() {
        if (this.pageNumber > 1) {
            this.pageNumber--;
            this.handleApplyFilters();
        }
    }
    handleNext() {
        if (this.pageNumber < this.totalPages) {
            this.pageNumber++;
            this.handleApplyFilters();
        }
    }
}