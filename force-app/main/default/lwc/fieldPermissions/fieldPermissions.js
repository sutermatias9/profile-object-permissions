import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import getFieldPermissions from '@salesforce/apex/FieldPermissionsHandler.getFieldPermissions';

const COLUMNS = [
    {
        label: 'Field',
        fieldName: 'field',
        hideDefaultActions: true,
        initialWidth: 120,
        cellAttributes: {
            class: { fieldName: 'fieldClass' }
        }
    },
    {
        label: 'Readable',
        fieldName: 'readable',
        fixedWidth: 100,
        hideDefaultActions: true,
        cellAttributes: {
            class: { fieldName: 'readClass' },
            alignment: 'center'
        }
    },
    {
        label: 'Editable',
        fieldName: 'editable',
        fixedWidth: 100,
        hideDefaultActions: true,
        cellAttributes: {
            class: { fieldName: 'editClass' },
            alignment: 'center'
        }
    }
];

export default class ObjectPermissionsAndData extends LightningElement {
    @api profiles;
    @api sobjects;
    @api tableColors;

    mainProfile = null;
    compareProfile = null;
    isCompareComboboxDisabled = true;

    sObjectSelected = null;

    columns = COLUMNS;
    mainProfileData;
    compareProfileData;

    get areOptionsSelected() {
        return this.mainProfile !== null && this.sObjectSelected !== null;
    }

    connectedCallback() {
        console.log('Connected Callback');
        loadStyle(this, this.tableColors)
            .then(() => console.log('Static Resource loaded'))
            .catch((e) => console.log('Error loading tableColors ' + e));
    }

    handleProfileChange(event) {
        const profileSelected = event.detail.value;
        console.log(profileSelected);

        if (event.currentTarget.classList.contains('main-profile')) {
            this.mainProfile = profileSelected;
        } else {
            this.compareProfile = profileSelected;
        }

        console.log('main profile: ', JSON.stringify(this.mainProfile));
        console.log('compare profile: ', JSON.stringify(this.compareProfile));

        if (this.sObjectSelected) {
            this.buildTable();
        }
    }

    handleSObjectChange(event) {
        console.log(event.detail.value);
        this.sObjectSelected = event.detail.value;

        if (this.mainProfile) {
            this.buildTable();
        }
    }

    handleCheckboxChange(event) {
        this.isCompareComboboxDisabled = !event.detail.checked;
    }

    async buildTable() {
        try {
            const mainProfilePermissions = await this.getProfilePermissions(this.mainProfile);

            let compareProfilePermissions;

            if (!this.isCompareComboboxDisabled && this.compareProfile) {
                compareProfilePermissions = await this.getProfilePermissions(this.compareProfile);
            }

            this.mainProfileData = this.convertToTableData(mainProfilePermissions);
            this.compareProfileData = this.convertToTableData(compareProfilePermissions);
        } catch (e) {
            console.log(e.message);
        }
    }

    async getProfilePermissions(profileId) {
        try {
            const result = await getFieldPermissions({
                sobjectName: this.sObjectSelected,
                profileId
            });

            return result;
        } catch (e) {
            console.error('error', e);
            throw e;
        }
    }

    convertToTableData(profilePermissions) {
        return Object.entries(profilePermissions).map(([fieldName, permissions]) => {
            const readable = permissions.Readable;
            const editable = permissions.Editable;

            return {
                field: fieldName,
                readable,
                editable,
                readClass: readable ? 'has-permission' : 'no-permission',
                editClass: editable ? 'has-permission' : 'no-permission',
                fieldClass: 'field'
            };
        });
    }
}
