import { LightningElement, track } from 'lwc';
import FatchProjectData from '@salesforce/apex/ProjectObjectDashboardController.FatchProjectData';
import FatchProjectTaskData from '@salesforce/apex/ProjectObjectDashboardController.FatchProjectTaskData';
import getUserDetail from '@salesforce/apex/ProjectObjectDashboardController.getUserDetail';
import creatNewProjectTask from '@salesforce/apex/ProjectObjectDashboardController.creatNewProjectTask';
import updateProTaskRecord from '@salesforce/apex/ProjectObjectDashboardController.updateProTaskRecord';
import deleteProject from '@salesforce/apex/ProjectObjectDashboardController.deleteProject';

export default class ProjectObjectDashboard extends LightningElement {
    statusOptions = [
        { label: 'Planned', value: 'Planned' },
        { label: 'In Progress', value: 'In Progress' },
        { label: 'On Hold', value: 'On Hold' },
        { label: 'Completed', value: 'Completed' },
    ];
    taskStatusOptions = [
        { label: 'Not Started', value: 'Not Started' },
        { label: 'In Progress', value: 'In Progress' },
        { label: 'Completed', value: 'Completed' },
    ];
    projectColumns = [
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'Project Manager Name', fieldName: 'pmName', type: 'text' },
        { label: 'Budget', fieldName: 'budget', type: 'currency' },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'View', name: 'view' },
                    { label: 'Edit', name: 'edit' },
                    { label: 'Delete', name: 'delete' }
                ]
            }
        }
    ];

    @track checkEditable = false;
    @track taskColumns = [];
    refreshColumns() {
        this.taskColumns = [
            { label: 'Name', fieldName: 'Name', type: 'text' },
            { label: 'Project Manager Name', fieldName: 'pmName', type: 'text' },
            { label: 'Status', fieldName: 'status', type: 'text', editable: this.checkEditable },
            { label: 'Assigned To', fieldName: 'AuName', type: 'text' },
        ];
    }
    @track taskList = [];
    @track selectedStatus;
    @track projectList = [];
    @track showTasks = false;
    @track isModalOpen = false;
    @track allUser = [];
    @track newTaskName;
    @track newUserSelect;
    @track newTaskStatus;
    @track projectId;

    handleStatusChange(event) {
        this.selectedStatus = event.detail.value;
        this.showTasks = false;
        //console.log('>>>', JSON.stringify(this.selectedStatus));
        this.FatchProjectsData();
    }
    async FatchProjectsData() {
        const result = await FatchProjectData({ selectedStatus: this.selectedStatus })
        this.projectList = result.map(item => ({
            Id: item.ids,
            Name: item.Name,
            pmName: item.pmName,
            budget: item.budget
        }));
        // console.log('>>>', JSON.stringify(this.projectList));

    }
    handleProjectRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        this.projectId = row.Id;
        //console.log('>>>', JSON.stringify(projectId),'>>>>',JSON.stringify(actionName));
        this.getProjectTaskData();
        // console.log('>>>', JSON.stringify(actionName));
        switch (actionName) {
            case 'edit':
                this.checkEditable = true;
                this.refreshColumns();
                break;
            case 'view':
                this.checkEditable = false;
                this.refreshColumns();
                break;
            case 'delete':
                this.deleteProjects();
                break;
        }
        this.showTasks = true;

    }

    async deleteProjects() {
        try {
            //console.log('>>>>', JSON.stringify(this.projectId));
            await deleteProject({ pId: this.projectId });
            this.showTasks = false;
            await this.FatchProjectsData();
        } catch {
            console.error('Error while updating', error);
        }
    }

    async getProjectTaskData() {
        try {
            const result = await FatchProjectTaskData({ pId: this.projectId });

            this.taskList = result.map(res => ({
                Id: res.ids,
                Name: res.Name,
                pmName: res.pmName,
                status: res.status,
                AuName: res.AuName

                //console.log('>>>', JSON.stringify(this.taskList));
            }));
        } catch {
            console.error('Error while updating', error);
        }
    }
    async handleSaveTasks(event) {
        const editadRecords = event.detail.draftValues;
        const editadRecord = editadRecords.map(res => ({
            Id: res.Id,
            Status__c: res.status
        }));
        const result = await updateProTaskRecord({ listPTask: editadRecord });
        if (result === 'Sucess') {
            // console.log('here am i>>>>>');
            this.refreshColumns();
            await this.getProjectTaskData();
        }

    }

    openNewTaskModal() {
        this.isModalOpen = true;
        getUserDetail()
            .then(result => {
                //console.log('>>>>', JSON.stringify(result));
                this.allUser = result.map(res => ({ label: res.Name, value: res.Id }));

            })
            .catch(error => {
                console.error('Error fetching projects', error);
            });
        // console.log('>>>>this.allUser', JSON.stringify(this.allUser));
    }
    closeModal() {
        this.isModalOpen = false;
    }

    handleTaskNameChange(event) {
        this.newTaskName = event.detail.value;
    }
    handlePTUserChange(event) {
        this.newUserSelect = event.detail.value;
    }
    handleTaskStatusChange(event) {
        this.newTaskStatus = event.detail.value;
    }
    async saveNewTask() {
        try {
            await creatNewProjectTask({ proId: this.projectId, ptname: this.newTaskName, ptuser: this.newUserSelect, ptStatus: this.newTaskStatus });
            this.isModalOpen = false;
            await this.getProjectTaskData();

        } catch (error) {
            console.error('Error while updating', error);
        }
    }
}