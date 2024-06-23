import { LightningElement, api } from 'lwc';

export default class ObjectPermissionsToggles extends LightningElement {
    @api permissions;

    handlePermissionChange(event) {
        const toggle = event.currentTarget;
        const permission = toggle.label;
        const checked = toggle.checked;

        if (permission === 'Read' && !checked) {
            this.uncheckAll();
        } else if (permission === 'Create' && checked) {
            this.check('Read');
        } else if (permission === 'Edit') {
            if (checked) {
                this.check('Read');
            } else {
                this.uncheck('Delete');
                this.uncheck('ModifyAll');
            }
        } else if (permission === 'Delete') {
            if (checked) {
                this.check('Read');
                this.check('Edit');
            } else {
                this.uncheck('ModifyAll');
            }
        } else if (permission === 'ViewAll') {
            if (checked) {
                this.check('Read');
            } else {
                this.uncheck('ModifyAll');
            }
        } else if (permission === 'ModifyAll') {
            if (checked) {
                this.check('Read');
                this.check('Edit');
                this.check('Delete');
                this.check('ViewAll');
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
