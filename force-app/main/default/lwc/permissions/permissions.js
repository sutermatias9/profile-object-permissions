import { LightningElement, wire } from 'lwc';

import getSObjects from '@salesforce/apex/SObjectHandler.getSObjects';
import getProfiles from '@salesforce/apex/ProfileHandler.getProfiles';

export default class Permissions extends LightningElement {
    profiles;
    sobjects;

    @wire(getProfiles)
    wiredProfiles({ data, error }) {
        if (data) {
            this.profiles = Object.entries(data).map(([Id, Name]) => {
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

            this.sobjects = apiNames.map((apiName) => {
                return { label: sObjects[apiName], value: apiName };
            });
        } else if (error) {
            console.error(error);
        }
    }
}
