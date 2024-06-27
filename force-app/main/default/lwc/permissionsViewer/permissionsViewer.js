import { LightningElement, api } from 'lwc';
import getAllObjectPermissions from '@salesforce/apex/ObjectPermissionsHandler.getAllObjectPermissions';
import getFieldPermissions from '@salesforce/apex/FieldPermissionsHandler.getFieldPermissions';
// import cellColors from '@salesforce/resourceUrl/cellColors';

export default class PermissionsViewer extends LightningElement {
    @api profiles;
    @api sobjects;

    mainPermissions;
    comparePermissions;

    viewSelected = 'object';
    sObjectSelected = null;
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
        return this.viewSelected === 'field';
    }

    get isMainNull() {
        return this.mainProfile === null;
    }

    handleGetPermissionsClick() {
        this.template.querySelector('.main-input').reportValidity();

        if (this.isFieldView) {
            this.template.querySelector('.object-input').reportValidity();

            if (this.sObjectSelected && this.mainProfile) {
                this.buildTable();
            }
        } else if (this.mainProfile) {
            this.buildTable();
        }
    }

    handleObjectChange(event) {
        this.sObjectSelected = event.detail.value;
    }

    handleProfileChange(event) {
        const profileType = event.currentTarget.name;
        const profileId = event.detail.value;

        if (profileType === 'main') {
            this.mainProfile = profileId;
        } else {
            this.compareProfile = profileId;
        }

        console.log('main: ' + this.mainProfile);
        console.log('compare: ' + this.compareProfile);
    }

    handleViewChange(event) {
        this.sObjectSelected = null;
        this.mainProfile = null;
        this.compareProfile = null;
        this.showTables = false;
        this.viewSelected = event.detail.value;
    }

    async buildTable() {
        this.mainPermissions = await this.getProfilePermissions(this.mainProfile, this.sObjectSelected);

        if (this.compareProfile) {
            this.comparePermissions = await this.getProfilePermissions(this.compareProfile, this.sObjectSelected);
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
