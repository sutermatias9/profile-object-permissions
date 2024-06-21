import { LightningElement, wire } from 'lwc';

import getSObjects from '@salesforce/apex/SObjectHandler.getSObjects';
import getProfiles from '@salesforce/apex/ProfileHandler.getProfiles';
import getAllObjectPermissions from '@salesforce/apex/ProfileHandler.getAllObjectPermissions';
import getFieldPermissions from '@salesforce/apex/ProfileHandler.getFieldPermissions';

export default class Permissions extends LightningElement {
    profiles;
    sobjects;
    mainPermissions;
    comparePermissions;

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

    async handleProfileSelect(event) {
        const { isFieldView, sobject, profile, type } = event.detail;

        if (type === 'main') {
            this.mainPermissions = await this.getProfilePermissions(profile, isFieldView, sobject);
        } else {
            this.comparePermissions = await this.getProfilePermissions(profile, isFieldView, sobject);
        }

        console.log(JSON.stringify(this.mainPermissions));
        console.log(JSON.stringify(this.comparePermissions));
    }

    async getProfilePermissions(profileId, isFieldView, sObjectName) {
        try {
            let result;

            if (isFieldView) {
                result = await getFieldPermissions({ sObjectName, profileId });
            } else {
                result = await getAllObjectPermissions({ profileId });
            }

            return result;
        } catch (e) {
            console.error('error', e);
            throw e;
        }
    }
}
