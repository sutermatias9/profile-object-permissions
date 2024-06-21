import { LightningElement, api } from 'lwc';
import getObjectPermissions from '@salesforce/apex/ProfileHandler.getObjectPermissions';

export default class PermissionsEditor extends LightningElement {
    @api profiles;
    @api sobjects;
    profileSelected;
    sobjectSelected;

    handleObjectChange(event) {
        this.sobjectSelected = event.detail.value;
    }

    handleProfileChange(event) {
        this.profileSelected = event.detail.value;
    }

    async handleGetPermissionsClick() {
        if (this.sobjectSelected && this.profileSelected) {
            const objectPermissions = await getObjectPermissions({
                sobjectName: this.sobjectSelected,
                profileId: this.profileSelected
            });
            console.log(objectPermissions);
        }
    }
}
