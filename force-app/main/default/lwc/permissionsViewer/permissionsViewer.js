import { LightningElement, api } from 'lwc';
// import cellColors from '@salesforce/resourceUrl/cellColors';

export default class PermissionsViewer extends LightningElement {
    @api profiles;
    @api sobjects;
    @api mainPermissions;
    @api comparePermissions;

    viewSelected = 'object';
    sObjectSelected = null;
    mainProfile = null;
    compareProfile = null;

    columns;

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

    handleObjectChange(event) {
        this.sObjectSelected = event.detail.value;

        if (this.mainProfile) {
            this.buildTable();
        }
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

        if (this.mainProfile) {
            this.buildTable();
        }
    }

    handleViewChange(event) {
        this.sObjectSelected = null;
        this.mainProfile = null;
        this.compareProfile = null;
        this.viewSelected = event.detail.value;
    }

    buildTable() {
        const detail = {
            isFieldView: this.isFieldView,
            sobject: this.sObjectSelected,
            profile: this.mainProfile,
            type: 'main'
        };

        this.dispatchEvent(new CustomEvent('profileselect', { detail }));

        if (this.compareProfile) {
            detail.profile = this.compareProfile;
            detail.type = 'compare';
            this.dispatchEvent(new CustomEvent('profileselect', { detail }));
        }
    }
}
