import { LightningElement, wire } from 'lwc';
import getProfiles from '@salesforce/apex/ProfileHandler.getProfiles';
import getSObjects from '@salesforce/apex/SObjectHandler.getSObjects';

export default class ObjectPermissionsAndData extends LightningElement {
    profileOptions;
    mainProfile;
    compareProfile;

    sObjectOptions;

    @wire(getProfiles)
    wiredProfiles({ data, error }) {
        if (data) {
            // Profile combobox options
            this.profileOptions = data.map((p) => {
                return { label: p.Name, value: p.Name };
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

        if (event.currentTarget.name === 'main-profile') {
            this.mainProfile = profileSelected;
        } else {
            this.compareProfile = profileSelected;
        }
    }

    handleSObjectChange(event) {
        console.log(event.detail.value);
    }

    // TODO Checkbox functionality
    // TODO Make table
    // TODO Show fields when button click
    // TODO Compare permissions with 2nd profile
}
