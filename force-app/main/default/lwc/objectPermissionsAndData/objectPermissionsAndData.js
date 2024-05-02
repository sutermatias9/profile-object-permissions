import { LightningElement, wire } from 'lwc';
import getProfiles from '@salesforce/apex/ProfileHandler.getProfiles';
import getSObjects from '@salesforce/apex/SObjectHandler.getSObjects';

export default class ObjectPermissionsAndData extends LightningElement {
    profileOptions;
    mainProfile;
    compareProfile;
    isCompareComboboxDisabled = true;

    sObjectOptions;
    sObjectSelected;

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
    }

    handleSObjectChange(event) {
        console.log(event.detail.value);
        this.sObjectSelected = event.detail.value;
    }

    handleCheckboxChange(event) {
        this.isCompareComboboxDisabled = !event.detail.checked;
    }

    // TODO Make table
    // TODO Show fields when button click
    // TODO Compare permissions with 2nd profile
}
