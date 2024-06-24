import { LightningElement, api } from 'lwc';
import getObjectPermissions from '@salesforce/apex/ObjectPermissionsHandler.getObjectPermissions';
import getFieldPermissions from '@salesforce/apex/FieldPermissionsHandler.getFieldPermissions';

export default class PermissionsEditor extends LightningElement {
    @api profiles;
    @api sobjects;
    profileSelected;
    sobjectSelected;

    objectPermissions;
    fieldPermissions;

    handleObjectChange(event) {
        this.sobjectSelected = event.detail.value;
    }

    handleProfileChange(event) {
        this.profileSelected = event.detail.value;
    }

    async handleGetPermissionsClick() {
        if (this.sobjectSelected && this.profileSelected) {
            const options = { sobjectName: this.sobjectSelected, profileId: this.profileSelected };

            const [objPermissions, fldPermissions] = await Promise.all([
                getObjectPermissions(options),
                getFieldPermissions(options)
            ]);

            this.objectPermissions = Object.entries(objPermissions).map(([name, value]) => {
                return { name, value };
            });

            this.fieldPermissions = Object.entries(fldPermissions).map(([fieldName, permissions]) => {
                return { name: fieldName, permissions };
            });
        }
    }
}
