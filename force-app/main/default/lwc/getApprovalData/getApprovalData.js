import { LightningElement, track } from 'lwc';
import getApprovedData from '@salesforce/apex/ApprovalTabController.getApprovalData';
import ApexToGetCaseData from '@salesforce/apex/ApprovalTabController.ApexToGetCaseData';
import ApexToGetOpportunityData from '@salesforce/apex/ApprovalTabController.ApexToGetOpportunityData';
export default class GetApprovalData extends LightningElement {

    oppColumns = [
        {
            label: 'Opportunity Name', fieldName: 'recordUrl', type: 'url',
            typeAttributes: {
                label: { fieldName: 'Name' },
                target: '_blank'
            }
        },
        { label: 'Stage', fieldName: 'StageName' },
        { label: 'Amount', fieldName: 'Amount', type: 'currency' },
        { label: 'Type', fieldName: 'Type' },
        { label: 'Status', fieldName: 'ApprovalStatus' } // Virtual field
    ];

    accColumns = [
        {
            label: 'Account Name', fieldName: 'recordUrl', type: 'url',
            typeAttributes: {
                label: { fieldName: 'Name' },
                target: '_blank'
            }
        },
        { label: 'Billing City', fieldName: 'BillingCity' },
        { label: 'Status', fieldName: 'ApprovalStatus' }
    ];

    caseColumns = [
        { label: 'Subject', fieldName: 'Subject' },
        {
            label: 'Related Account', fieldName: 'aRecordUrl', type: 'url',
            typeAttributes: {
                label: { fieldName: 'RelatedAccount' },
                target: '_blank'
            }
        },
        {
            label: 'Owner', fieldName: 'oRecordUrl', type: 'url',
            typeAttributes: {
                label: { fieldName: 'OwnerName' },
                target: '_blank'
            }
        },
        { label: 'Status', fieldName: 'ApprovalStatus' }
    ];

    accData;
    oppData;
    caseData;
    isOppFilter = false;
    isFilteredOpp = false;
    isFilter = false;
    isFilterCase = false;
    @track inputMinFilterAmount;
    @track inputMaxFilterAmount;
    @track newFilCasData;
    @track newFilOppData;
    @track inputFilterData;

    connectedCallback() {
        console.log('LWC Component -> GetApprovalData');
        this.callGetApprovedData();
    }
    callGetApprovedData() {
        getApprovedData()
            .then((result) => {
                if (result && result.AccList) {
                    //console.log('Result received:', result);
                    this.accData = result.AccList.map(ac => {
                        // 2. Spread the account object and add the virtual 'Pending' status
                        return { ...ac, ApprovalStatus: 'Pending', recordUrl: `/lightning/r/Case/${ac.Id}/view` };
                    });
                    //console.log(' this.accData>>>', this.accData);
                }
                if (result && result.OppList) {
                    // console.log('Result received:', result);
                    this.oppData = result.OppList.map(ac => {
                        return { ...ac, ApprovalStatus: 'Pending', recordUrl: `/lightning/r/Case/${ac.Id}/view` };
                    });
                }
                if (result && result.CaseList) {
                    this.caseData = result.CaseList.map(ac => {
                        return {
                            ...ac,
                            RelatedAccount: ac.Account ? ac.Account.Name : '',
                            OwnerName: ac.Owner ? ac.Owner.Name : '',
                            oRecordUrl: `/lightning/r/Case/${ac.Owner.Id}/view`,
                            aRecordUrl: `/lightning/r/Case/${ac.Account.Id}/view`,
                            ApprovalStatus: 'Pending'
                        };
                    });
                    // console.log(' this.caseData>>>', this.caseData);
                }
            }).catch(error => {
                console.log('error>>>', error);
            })
    }
    handleDownloadOpportunityCSV() {
        this.downloadCSV(this.oppData, 'Pending_Opportunity_Approvals.csv');
    }
    handleDownloadAccountCSV() {
        this.downloadCSV(this.accData, 'Pending_Account_Approvals.csv');
    }
    handleDownloadCaseCSV() {
        this.downloadCSV(this.caseData, 'Pending_Case_Approvals.csv');
    }
    downloadCSV(data, fileName) {
        try {
            if (!Array.isArray(data) || data.length === 0) {
                console.error('No data available');
                return;
            }

            if (!fileName) {
                fileName = 'download.csv';
            }

            const headers = Object.keys(data[0]);
            const csvRows = [];
            csvRows.push(headers.join(','));

            data.forEach(row => {
                const values = headers.map(header => {
                    let val = row[header] ?? '';
                    val = val.toString().replace(/"/g, '""');
                    return `"${val}"`;
                });
                csvRows.push(values.join(','));
            });

            const csvContent = csvRows.join('\n');
            const encodedUri =
                'data:text/csv;charset=utf-8,' +
                encodeURIComponent(csvContent);

            const link = document.createElement('a');
            link.setAttribute('href', encodedUri);
            link.setAttribute('download', fileName);
            link.style.display = 'none';

            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);

        } catch (error) {
            console.error('CSV Error:', error.message, error.stack);
        }
    }
    handelFilterClick() {
        this.isFilter = true;
    }
    handleAccountChance(event) {
        //console.log('event>>>>>', event);
        this.inputFilterData = event.detail.value;
        //console.log('this.inputFilterData >>>>', this.inputFilterData);
    }
    handelApply() {
        //try {
        if (this.caseData) {
            const uniqueAccountIds = new Set();
            for (let ca of this.caseData) {
                if (ca.Account.Name === this.inputFilterData) {
                    uniqueAccountIds.add(ca.Account.Id);
                }
            }
            const accountIdList = [...uniqueAccountIds];
            this.callApexToGetCaseData(accountIdList);
            this.isFilter = false;
            this.isFilterCase = true;

        }
        /*} catch (error) {
            console.error('handelApply>>>:', error.message, error.stack);
        }*/

    }

    callApexToGetCaseData(accIdList) {
        ApexToGetCaseData({ AccLId: accIdList })
            .then(data => {
                const datas = data.map(da => {
                    return {
                        ...da,
                        RelatedAccount: da.Account ? da.Account.Name : '',
                        OwnerName: da.Owner ? da.Owner.Name : '',
                        oRecordUrl: da.Owner ? `/lightning/r/User/${da.Owner.Id}/view` : '',
                        aRecordUrl: da.Account ? `/lightning/r/Account/${da.Account.Id}/view` : '',
                        ApprovalStatus: 'Pending'
                    };
                });

                // remove Proxy (optional)
                this.newFilCasData = JSON.parse(JSON.stringify(datas));
            })
            .catch(error => {
                console.log('error>>>>', error.message);
            })
    }

    handelBack() {
        this.isFilterCase = false;
        this.isFilteredOpp = false;
    }

    handelOppFilterClick() {
        this.isOppFilter = true;
    }
    handleMinAmountChance(event) {
        this.inputMinFilterAmount = event.detail.value;
    }
    handleMaxAmountChance(event) {
        this.inputMaxFilterAmount = event.detail.value;
    }
    handelOppApply() {
        if (this.oppData) {
            const uniqueopportunityIds = new Set();
            for (let op of this.oppData) {
                if (op.Amount > this.inputMinFilterAmount && op.Amount < this.inputMaxFilterAmount) {
                    uniqueopportunityIds.add(op.Id);
                }
            }
            const opportunityIdList = [...uniqueopportunityIds];
            this.callApexToGetOpportunityData(opportunityIdList);
            this.isOppFilter = false;

        }
    }

    callApexToGetOpportunityData(opporId) {
        ApexToGetOpportunityData({ OppLIds: opporId })
            .then(data => {
                console.log('data>>>', data);
                const oppData = data.map(opd => {
                    return { ...opd, ApprovalStatus: 'Pending', recordUrl: `/lightning/r/Case/${opd.Id}/view` };
                });
                this.newFilOppData = JSON.parse(JSON.stringify(oppData));
                this.isFilteredOpp = true
            })
            .catch(error => {

            })
    }

}