import { LightningElement, api } from 'lwc';

export default class FieldPermissionsToggles extends LightningElement {
    @api permissions;

    handlePermissionChange(event) {
        const { label: permission, checked } = event.currentTarget;
        const field = event.currentTarget.dataset.field;
        const [readToggle, editToggle] = this.template.querySelectorAll(`lightning-input[data-field="${field}"]`);
        console.log(readToggle);
        console.log(editToggle);

        if (permission === 'Read' && !checked) {
            editToggle.checked = false;
        } else if (permission === 'Edit' && checked) {
            readToggle.checked = true;
        }
    }
}
