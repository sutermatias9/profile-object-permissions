import { LightningElement, api } from 'lwc';

export default class FieldPermissionsToggles extends LightningElement {
    @api permissions;
    @api disabled;

    @api getPermissions() {
        const containers = Array.from(this.template.querySelectorAll('.toggles-container'));

        const permissions = containers.map((container) => {
            const [readToggle, editToggle] = this.getToggles(container);
            const field = readToggle.dataset.field;

            return { field, read: readToggle.checked, edit: editToggle.checked };
        });

        return permissions;
    }

    handlePermissionChange(event) {
        const { label: permission, checked } = event.currentTarget;
        const field = event.currentTarget.dataset.field;
        const [readToggle, editToggle] = this.template.querySelectorAll(`lightning-input[data-field="${field}"]`);

        if (permission === 'Read' && !checked) {
            editToggle.checked = false;
        } else if (permission === 'Edit' && checked) {
            readToggle.checked = true;
        }
    }

    getToggles(container) {
        if (container) {
            return container.querySelectorAll('lightning-input');
        }

        return this.template.querySelectorAll('lightning-input');
    }
}
