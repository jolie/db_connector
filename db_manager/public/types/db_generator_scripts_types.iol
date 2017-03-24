type NativeType: void {
      .isstring?: bool
      .isint?: bool
      .isdouble?: bool
      .isvoid?: bool
      .isbool?: bool
      .islong?: bool
      .is_filter_type?: bool
      .is_custom_type?: string
}

type TableColumnDescriptor: void {
      .name: string
      .value_type: NativeType
      .is_serial: bool
      .must_be_unique?: int
      .is_nullable: bool
      .has_default_value: bool
      .is_identity: bool
}

type TableDescriptor: void {
      .table_name: string
      .table_columns*: TableColumnDescriptor
      .is_view:bool
      .create_operation_name?: string
      .update_operation_name?: string
      .remove_operation_name?: string
      .get_operation_name?: string
}
