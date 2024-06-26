import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/ldsUtils';

import getObjectPermissions from '@salesforce/apex/ObjectPermissionsHandler.getObjectPermissions';
import getFieldPermissions from '@salesforce/apex/FieldPermissionsHandler.getFieldPermissions';
import setObjectPermissions from '@salesforce/apex/ObjectPermissionsHandler.setPermissions';
import setFieldPermissions from '@salesforce/apex/FieldPermissionsHandler.setPermissions';

export default class PermissionsEditor extends LightningElement {
    @api profiles;
    @api sobjects;
    profileSelected;
    sobjectSelected;
    areTogglesDisplayed = false;

    objectPermissions;
    fieldPermissions;

    isSaved = false;

    handleObjectChange(event) {
        this.sobjectSelected = event.detail.value;
    }

    handleProfileChange(event) {
        this.profileSelected = event.detail.value;
    }

    async handleGetPermissionsClick() {
        this.areTogglesDisplayed = true;

        if (this.sobjectSelected && this.profileSelected) {
            const options = { sobjectName: this.sobjectSelected, profileId: this.profileSelected };

            const [objPermissions, fldPermissions] = await Promise.all([
                getObjectPermissions(options),
                getFieldPermissions(options)
            ]);

            this.isSaved = false;

            this.objectPermissions = Object.entries(objPermissions).map(([name, value]) => {
                return { name, value };
            });

            this.fieldPermissions = Object.entries(fldPermissions).map(([fieldName, permissions]) => {
                return { name: fieldName, permissions };
            });
        }
    }
    // ! VER CUANDO ES STANDARD PROFILE
    handleSaveClick() {
        const options = { profileId: this.profileSelected, sobjectName: this.sobjectSelected };

        const objTogglesValuesJSON = JSON.stringify(this.getTogglesValues('object'));
        const fieldTogglesValuesJSON = JSON.stringify(this.getTogglesValues('field'));

        Promise.all([
            setObjectPermissions({ ...options, permissionsJSON: objTogglesValuesJSON }),
            setFieldPermissions({ ...options, permissionsJSON: fieldTogglesValuesJSON })
        ])
            .then(() => {
                this.showNotification('Permissions sucessfully updated!');
                this.isSaved = true;
            })
            .catch((error) => {
                this.showNotification('An error ocurred...', reduceErrors(error)[0], 'error');
            });
    }

    getTogglesValues(type) {
        return this.template.querySelector(`c-${type}-permissions-toggles`).getPermissions();
    }

    showNotification(title, message, variant = 'success') {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });

        this.dispatchEvent(event);
    }
}
