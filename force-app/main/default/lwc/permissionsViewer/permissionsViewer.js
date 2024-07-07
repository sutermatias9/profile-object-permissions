import { LightningElement, api } from 'lwc';
import getAllObjectPermissions from '@salesforce/apex/ObjectPermissionsHandler.getAllObjectPermissions';
import getFieldPermissions from '@salesforce/apex/FieldPermissionsHandler.getFieldPermissions';
// import cellColors from '@salesforce/resourceUrl/cellColors';

export default class PermissionsViewer extends LightningElement {
    @api profiles;
    @api sobjects;

    mainPermissions;
    comparePermissions;

    view = 'object';
    sobject = null;
    mainProfile = null;
    compareProfile = null;

    showTables = false;

    get viewOptions() {
        return [
            { label: 'Object Permissions', value: 'object' },
            { label: 'Field Permissions', value: 'field' }
        ];
    }

    get isFieldView() {
        return this.view === 'field';
    }

    get isMainNull() {
        return this.mainProfile === null;
    }

    handleGetPermissionsClick() {
        this.template.querySelector('.main-input').reportValidity();

        if (this.isFieldView) {
            this.template.querySelector('.object-input').reportValidity();

            if (this.sobject && this.mainProfile) {
                this.buildTable();
            }
        } else if (this.mainProfile) {
            this.buildTable();
        }
    }

    handleObjectChange(event) {
        this.sobject = event.detail.value;
    }

    handleProfileChange(event) {
        const profileType = event.currentTarget.name;
        const profileId = event.detail.value;

        if (profileType === 'main') {
            this.mainProfile = profileId;
        } else {
            this.compareProfile = profileId;
        }
    }

    handleViewChange(event) {
        this.view = event.detail.value;
        this.resetVariables();
    }

    resetVariables() {
        this.sobject = null;
        this.mainProfile = null;
        this.compareProfile = null;
        this.mainPermissions = null;
        this.comparePermissions = null;
        this.showTables = false;
    }

    async buildTable() {
        this.mainPermissions = await this.getProfilePermissions(this.mainProfile, this.sobject);

        if (this.compareProfile) {
            this.comparePermissions = await this.getProfilePermissions(this.compareProfile, this.sobject);
        }

        this.showTables = true;
    }

    async getProfilePermissions(profileId, sobjectName) {
        try {
            let result;

            if (this.isFieldView) {
                result = await getFieldPermissions({ sobjectName, profileId });
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
