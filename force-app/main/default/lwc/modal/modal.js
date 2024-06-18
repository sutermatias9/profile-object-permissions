import { LightningElement } from 'lwc';

export default class Modal extends LightningElement {
    connectedCallback() {
        this.template.addEventListener('keydown', (event) => {
            if (event.key === 'Escape') this.closeModal();
        });
    }

    disconnectedCallback() {
        this.template.removeEventListener('keydown');
    }

    handleCloseClick() {
        this.closeModal();
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}
