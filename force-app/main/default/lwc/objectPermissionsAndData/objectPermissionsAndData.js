import { LightningElement, wire } from 'lwc';
import getProfiles from '@salesforce/apex/ProfileHandler.getProfiles';

export default class ObjectPermissionsAndData extends LightningElement {
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

    handleProfileChange(event) {
        this.profileSelected = event.detail.value;
        console.log(JSON.stringify(this.profileSelected));
    }

    // TODO Get objects
    // TODO Make table
    // TODO Show fields when button click
    // TODO Compare permissions with 2nd profile
}
