import { LightningElement, api } from 'lwc';

export default class ObjectPermissions extends LightningElement {
    @api profiles;
    @api sobjects;
}
