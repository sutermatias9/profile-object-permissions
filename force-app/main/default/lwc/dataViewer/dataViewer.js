import { LightningElement, wire } from 'lwc';
import getProfiles from '@salesforce/apex/ProfileHandler.getProfiles';
import getSObjects from '@salesforce/apex/SObjectHandler.getSObjects';

export default class DataViewer extends LightningElement {
    profileOptions;
    profileSelected;

    // TODO Get profiles
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

            this.sObjectOptions = apiNames.map((apiName) => {
                return { label: sObjects[apiName], value: apiName };
            });
        } else if (error) {
            console.error(error);
        }
    }

    handleProfileChange(event) {
        this.profileSelected = event.detail.value;
    }

    handleSObjectChange() {}
}
