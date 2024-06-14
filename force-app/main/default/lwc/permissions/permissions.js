import { LightningElement, wire } from 'lwc';
import cellColors from '@salesforce/resourceUrl/cellColors';

import getProfiles from '@salesforce/apex/ProfileHandler.getProfiles';
import getSObjects from '@salesforce/apex/SObjectHandler.getSObjects';

export default class Permissions extends LightningElement {
    profiles;
    sObjects;
    tableColors = cellColors;

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

            apiNames.sort(); // ? ver

            this.sObjects = apiNames.map((apiName) => {
                return { label: sObjects[apiName], value: apiName };
            });
        } else if (error) {
            console.error(error);
        }
    }
}
