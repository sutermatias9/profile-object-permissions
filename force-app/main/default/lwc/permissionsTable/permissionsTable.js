import { LightningElement, api } from 'lwc';

const OBJECT_COLUMNS = [
    {
        label: 'Object',
        fieldName: 'object',
        hideDefaultActions: true,
        initialWidth: 150,
        cellAttributes: {
            class: { fieldName: 'fieldClass' }
        }
    },
    {
        label: 'Read',
        fieldName: 'readable',
        fixedWidth: 80,
        hideDefaultActions: true,
        cellAttributes: {
            class: { fieldName: 'readClass' },
            alignment: 'center'
        }
    },
    {
        label: 'Create',
        fieldName: 'creatable',
        fixedWidth: 80,
        hideDefaultActions: true,
        cellAttributes: {
            class: { fieldName: 'createClass' },
            alignment: 'center'
        }
    },
    {
        label: 'Edit',
        fieldName: 'editable',
        fixedWidth: 80,
        hideDefaultActions: true,
        cellAttributes: {
            class: { fieldName: 'editClass' },
            alignment: 'center'
        }
    },
    {
        label: 'Delete',
        fieldName: 'deletable',
        fixedWidth: 80,
        hideDefaultActions: true,
        cellAttributes: {
            class: { fieldName: 'deleteClass' },
            alignment: 'center'
        }
    },
    {
        label: 'View All',
        fieldName: 'viewAll',
        fixedWidth: 80,
        hideDefaultActions: true,
        cellAttributes: {
            class: { fieldName: 'viewClass' },
            alignment: 'center'
        }
    },
    {
        label: 'Modify All',
        fieldName: 'modifyAll',
        fixedWidth: 90,
        hideDefaultActions: true,
        cellAttributes: {
            class: { fieldName: 'modifyClass' },
            alignment: 'center'
        }
    }
];

const FIELD_COLUMNS = [
    {
        label: 'Field',
        fieldName: 'field',
        hideDefaultActions: true,
        initialWidth: 120,
        cellAttributes: {
            class: { fieldName: 'fieldClass' }
        }
    },
    {
        label: 'Readable',
        fieldName: 'readable',
        fixedWidth: 100,
        hideDefaultActions: true,
        cellAttributes: {
            class: { fieldName: 'readClass' },
            alignment: 'center'
        }
    },
    {
        label: 'Editable',
        fieldName: 'editable',
        fixedWidth: 100,
        hideDefaultActions: true,
        cellAttributes: {
            class: { fieldName: 'editClass' },
            alignment: 'center'
        }
    }
];

export default class ObjectPermissionsTable extends LightningElement {
    @api isFieldView;
    @api permissions;
    @api tableColors;

    get columns() {
        return this.isFieldView ? FIELD_COLUMNS : OBJECT_COLUMNS;
    }

    get data() {
        if (this.permissions) {
            if (this.isFieldView) {
                return Object.entries(this.permissions).map(([fieldName, permissions]) => {
                    const readable = permissions.Readable;
                    const editable = permissions.Editable;

                    return {
                        field: fieldName,
                        readable,
                        editable,
                        readClass: readable ? 'has-permission' : 'no-permission',
                        editClass: editable ? 'has-permission' : 'no-permission',
                        fieldClass: 'field'
                    };
                });
            }

            return Object.entries(this.permissions).map(([sobjectName, permissions]) => {
                const readable = permissions.Read;
                const creatable = permissions.Create;
                const editable = permissions.Edit;
                const deletable = permissions.Delete;
                const viewAll = permissions.ViewAll;
                const modifyAll = permissions.ModifyAll;

                return {
                    object: sobjectName,
                    readable,
                    creatable,
                    editable,
                    deletable,
                    viewAll,
                    modifyAll,
                    readClass: readable ? 'has-permission' : 'no-permission',
                    createClass: creatable ? 'has-permission' : 'no-permission',
                    editClass: editable ? 'has-permission' : 'no-permission',
                    deleteClass: deletable ? 'has-permission' : 'no-permission',
                    viewClass: viewAll ? 'has-permission' : 'no-permission',
                    modifyClass: modifyAll ? 'has-permission' : 'no-permission',
                    fieldClass: 'field'
                };
            });
        }

        return null;
    }
}
