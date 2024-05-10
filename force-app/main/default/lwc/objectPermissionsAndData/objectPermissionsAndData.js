import { LightningElement, wire } from 'lwc';
import { getFieldApiName } from 'c/ldsUtils';
import getProfiles from '@salesforce/apex/ProfileHandler.getProfiles';
import getSObjects from '@salesforce/apex/SObjectHandler.getSObjects';
import getFieldPermissions from '@salesforce/apex/ProfileHandler.getFieldPermissions';

const COLUMNS = [
    { label: 'Field', fieldName: 'field' },
    { label: 'Readable', fieldName: 'readable' },
    { label: 'Editable', fieldName: 'edit' }
];

// const DATA = [{ create: 'True', edit: 'True' }];

export default class ObjectPermissionsAndData extends LightningElement {
    profileOptions;
    mainProfile = null;
    compareProfile = null;
    isCompareComboboxDisabled = true;

    sObjectOptions;
    sObjectSelected;

    columns = COLUMNS;
    mainProfileData;

    get areOptionsSelected() {
        return this.mainProfile !== null && this.sObjectSelected !== null;
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
            console.log('entranding');
            const mainProfilePermissions = await this.getProfilePermissions(this.mainProfile);
            console.log('profilePermi', mainProfilePermissions);
            console.log(JSON.stringify(Object.entries(mainProfilePermissions)));
            // let compareProfilePermissions;

            // necesito tabla aparte para compare
            // if (!this.isCompareComboboxDisabled && this.compareProfile) {
            //     compareProfilePermissions = await this.getProfilePermissions(this.compareProfile);
            // }

            // hacer tablita
            this.mainProfileData = Object.entries(mainProfilePermissions).map(([objectField, permissions]) => {
                console.log(getFieldApiName(objectField));
                return {
                    field: getFieldApiName(objectField),
                    readable: permissions.Readable,
                    edit: permissions.Editable
                };
            });
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

    // TODO Compare permissions with 2nd profile
}
