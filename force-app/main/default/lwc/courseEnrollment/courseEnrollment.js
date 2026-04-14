import { LightningElement, track, wire } from 'lwc';
import getCourse from '@salesforce/apex/courseEnrollmentController.getCourse';
import getCourseRelatedData from '@salesforce/apex/courseEnrollmentController.getCourseRelatedData';
import getEnrollmentRelatedData from '@salesforce/apex/courseEnrollmentController.getEnrollmentRelatedData';
import updateToApprove from '@salesforce/apex/courseEnrollmentController.updateToApprove';
import updateToReject from '@salesforce/apex/courseEnrollmentController.updateToReject';
import getStudentData from '@salesforce/apex/courseEnrollmentController.getStudentData';
import creatEnrolmentRecord from '@salesforce/apex/courseEnrollmentController.creatEnrolmentRecord';
import insertContact from '@salesforce/apex/courseEnrollmentController.insertContact';
import getListStatus from '@salesforce/apex/courseEnrollmentController.getListStatus';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class CourseEnrollment extends LightningElement {
    courseOptions = [];
    listoFStudent = [];
    listOfStatus = [];
    selectedStudent;
    selectedStatus;
    @track selectedCourseId;
    @track selectedCourse;
    @track notSeatAvailable = false;
    @track isAdmin = false;
    @track pendingEnrollments = [];
    @track enrolmentVisible = false;
    @track contactData = {};
    @track ShowPopup = false;

    connectedCallback() {
        this.callgetStudentData();
    }
    callgetStudentData() {
        getStudentData()
            .then(data => {
                this.listoFStudent = data.map(da => ({ label: da.Name, value: da.Id }));
                // console.log('sd>>> ', JSON.stringify(this.listoFStudent));
                return getListStatus()
            }).then(data => {
                this.listOfStatus = data.map(da => ({ label: da, value: da }));
                //console.log('sd>>> ', JSON.stringify(this.listOfStatus));
            })
    }

    @wire(getCourse)
    getAllCourse({ data, error }) {
        if (data) {
            this.courseOptions = data.map(cs => ({
                label: cs.Name,
                value: cs.Id
            }));
        } else if (error) {
            console.error('Error found when data loaded', error);
        }
        //console.log('>>C ', JSON.stringify(this.courseOptions));
    }

    handleCourseChange(event) {
        this.selectedCourseId = event.detail.value;
        //console.log('>>C ', JSON.stringify(this.selectedCourseId));
        this.callgetCourseRelatedData();
        this.callgetEnrollmentRelatedData();
        //this.selectedCourse = true;
    }

    handleRequestEnrollment() {
        this.isAdmin = true;
        this.enrolmentVisible = true;
    }
    handleBack() {
        this.enrolmentVisible = false;
    }

    callgetCourseRelatedData() {
        getCourseRelatedData({ courseId: this.selectedCourseId })
            .then(result => {
                //console.log('>>D ', JSON.stringify(result));
                this.selectedCourse = result;
                //console.log('>>S ', JSON.stringify(this.selectedCourse.Available_Seats));
                if (this.selectedCourse.Available_Seats <= 0) {
                    this.notSeatAvailable = true;
                }
            })
            .catch(error => {
                console.error('Error found: ', error);
            });
    }
    callgetEnrollmentRelatedData() {
        getEnrollmentRelatedData({ courseId: this.selectedCourseId })
            .then(data => {
                //console.log('CD>>>> ', JSON.stringify(data));
                this.isAdmin = true;
                this.pendingEnrollments = data;
            })
            .catch(error => {
                console.error('Error found: ', error);
            });
    }
    handleApprove(event) {
        const enrollmentId = event.target.dataset.id;
        // console.log('Selected Enrollment Id: ', enrollmentId);
        updateToApprove({ enoId: enrollmentId })
            .then(data => {
                // console.log('UT >>>> ', JSON.stringify(data));
                this.showToast('Success', data, 'success');
                this.callgetEnrollmentRelatedData();
            })
            .catch(error => {
                console.error('Error found: ', error);
            });

    }

    handleReject(event) {
        const enrollmentId = event.target.dataset.id;
        updateToReject({ enoId: enrollmentId })
            .then(data => {
                // console.log('UT >>>> ', JSON.stringify(data));
                this.showToast('Success', data, 'success');
                this.callgetEnrollmentRelatedData();
            })
            .catch(error => {
                console.error('Error found: ', error);
            });
    }

    handleSaveEnrollment() {
        // console.log('INFO>>>>', JSON.stringify(this.selectedStudent), JSON.stringify(this.selectedCourseId), JSON.stringify(this.selectedStatus));
        creatEnrolmentRecord({ sId: this.selectedStudent, cId: this.selectedCourseId, status: this.selectedStatus })
            .then(result => {
                if (result == 'Sucess') {
                    this.selectedStudent = ' ';
                    this.selectedStatus = ' ';
                    this.showToast('Success', 'Enrolment record creat sucessfully', 'success');
                    this.enrolmentVisible = false;
                    this.callgetEnrollmentRelatedData();
                    this.callgetCourseRelatedData();
                } else this.showToast('Success', result, 'success');
            })
            .catch(error => {
                console.error('Error found: ', error);
            });
    }

    clickToSaveContact() {
        // console.log('Cda>>>> ', JSON.stringify(this.contactData));
        insertContact({ con: this.contactData })
            .then(result => {
                this.showToast('Success', result, 'success');
                //console.log('Cda>>>> ', JSON.stringify(result));
                this.selectedStudent = result.Id;
                //console.log('Cda>>>> ', JSON.stringify(this.selectedStudent));
                this.callgetStudentData();
                this.ShowPopup = false;
            })
            .catch(error => {
                console.error('Error found: ', error);
            });
    }

    handleAddNew() {
        this.ShowPopup = true;
    }
    handlepopupClose() {
        this.ShowPopup = false;
    }
    handelContactdata(event) {
        const field = event.target.name;
        const value = event.target.value;
        this.contactData[field] = value;
        // console.log('Cd>>>> ', JSON.stringify(this.contactData));
    }
    handleStudentChange(event) {
        this.selectedStudent = event.detail.value;
    }
    handelCourceChange(event) {
        this.selectedCourseId = event.detail.value;
    }
    handelSelectedStatus(event) {
        this.selectedStatus = event.detail.value;
    }
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    disconnectedCallback() {
        console.log('Component disconnect sucessfully')
    }
}