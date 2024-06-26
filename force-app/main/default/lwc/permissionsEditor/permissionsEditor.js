import { LightningElement, api } from 'lwc';
import getObjectPermissions from '@salesforce/apex/ObjectPermissionsHandler.getObjectPermissions';
import getFieldPermissions from '@salesforce/apex/FieldPermissionsHandler.getFieldPermissions';
import setObjectPermissions from '@salesforce/apex/ObjectPermissionsHandler.setPermissions';
import setFieldPermissions from '@salesforce/apex/FieldPermissionsHandler.setPermissions';

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

    handleSaveClick() {
        const options = { profileId: this.profileSelected, sobjectName: this.sobjectSelected };
        console.log('save');

        const objTogglesValues = this.getTogglesValues('object');
        const fieldTogglesValues = this.getTogglesValues('field');
        console.log(JSON.stringify(objTogglesValues));
        console.log(JSON.stringify(fieldTogglesValues));
        setObjectPermissions({ ...options, permissionsJSON: JSON.stringify(objTogglesValues) }); //devuelve promise
        setFieldPermissions({ ...options, permissionsJSON: JSON.stringify(fieldTogglesValues) }).then(() =>
            console.log('success')
        );
    }

    getTogglesValues(type) {
        return this.template.querySelector(`c-${type}-permissions-toggles`).getPermissions();
    }
}
