import { LightningElement, track } from 'lwc';
import courseRelatedEnrolment from '@salesforce/apex/courseEnrollmentController.courseRelatedEnrolment';

export default class CourseEnrollmentViewer extends LightningElement {
    columns = [
        { label: 'Student Name', fieldName: 'Name', type: 'text' },
        { label: 'Status', fieldName: 'Status', type: 'text' }
    ];

    course = '';          // reactive by default
    enrolmentData = [];   // initialized as empty array

    handleCourseChange(event) {
        this.course = event.target.value;
    }

    async fetchEnrollments() {
        try {
            const result = await courseRelatedEnrolment({ courseEn: this.course });

            // Flatten result into array
            this.enrolmentData = Object.values(result).flatMap(value =>
                value.map(enrolment => ({ ...enrolment }))
            );

            console.log('Enrolment Data:', JSON.stringify(this.enrolmentData));
        } catch (error) {
            console.error('Error fetching enrolments:', error);
        }
    }
}