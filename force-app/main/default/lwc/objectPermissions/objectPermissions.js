import { LightningElement, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import cellColors from '@salesforce/resourceUrl/cellColors';

import getProfiles from '@salesforce/apex/ProfileHandler.getProfiles';
import getSObjects from '@salesforce/apex/SObjectHandler.getSObjects';
import getFieldPermissions from '@salesforce/apex/ProfileHandler.getFieldPermissions';

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
    profileOptions;
    mainProfile = null;
    compareProfile = null;
    isCompareComboboxDisabled = true;

    sObjectOptions;
    sObjectSelected = null;

    columns = COLUMNS;
    mainProfileData;
    compareProfileData;

    get areOptionsSelected() {
        return this.mainProfile !== null && this.sObjectSelected !== null;
    }

    connectedCallback() {
        console.log('Connected Callback');
        loadStyle(this, cellColors)
            .then(() => console.log('Static Resource loaded'))
            .catch((e) => console.log('Error loading cellColors ' + e));
    }

    @wire(getProfiles)
    wiredProfiles({ data, error }) {
        if (data) {
            // Profile combobox options
            this.profileOptions = Object.entries(data).map(([Id, Name]) => {
                return { label: Name, value: Id };
            });
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getSObjects)
    wiredObjects({ data, error }) {
        if (data) {
            const sObjects = data;
            const apiNames = Object.keys(sObjects);

            apiNames.sort();

            console.log(apiNames);

            this.sObjectOptions = apiNames.map((apiName) => {
                return { label: sObjects[apiName], value: apiName };
            });
        } else if (error) {
            console.error(error);
        }
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
                sObjectName: this.sObjectSelected,
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
