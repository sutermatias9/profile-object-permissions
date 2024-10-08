import { LightningElement, api } from 'lwc';

export default class ObjectPermissionsToggles extends LightningElement {
    @api permissions;
    @api disabled;

    @api getPermissions() {
        const togglesInfo = {};

        this.template.querySelectorAll('lightning-input').forEach((input) => {
            togglesInfo[input.label] = input.checked;
        });

        return togglesInfo;
    }

    handlePermissionChange(event) {
        const { label: permission, checked } = event.currentTarget;

        if (checked) {
            this.check('Read');

            if (permission === 'Delete' || permission === 'ModifyAll') {
                this.check('Edit');

                if (permission === 'ModifyAll') {
                    this.check('Delete');
                    this.check('ViewAll');
                }
            }
        } else {
            if (permission !== 'Create') {
                this.uncheck('ModifyAll');

                if (permission === 'Edit') {
                    this.uncheck('Delete');
                } else if (permission === 'Read') {
                    this.uncheckAll();
                }
            }
        }
    }

    check(label) {
        this.template.querySelector(`lightning-input[data-label="${label}"]`).checked = true;
    }

    uncheck(label) {
        this.template.querySelector(`lightning-input[data-label="${label}"]`).checked = false;
    }

    uncheckAll() {
        this.template.querySelectorAll('lightning-input').forEach((input) => {
            input.checked = false;
        });
    }
}
