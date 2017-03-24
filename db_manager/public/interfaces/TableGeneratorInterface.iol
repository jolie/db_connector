include "../types/db_generator_scripts_types.iol"

type CreateDbServiceRequest: void {
  .host: string
  .driver: string
  .port: int
  .database: string
  .username: string
  .password: string
  .table_schema?: string     //used only if driver=postgresql
}

type CreateService4TableRequest: void {
  .table: TableDescriptor
  .database: string
}

type CreateService4TableResponse: void {
  .interface: string
  .behaviour: string
  .test*:string
}

type CreateTypeRequest: void {
  .type_name: string
  .root_native_type: NativeType
  .fields*: void {
    .name: string
    .native_type: NativeType
    .is_optional: bool
  }
}

type GetNativeTypeRequest: void {
  .native_type: NativeType
}

type CreateTypeResponse: void {
}

interface TableGeneratorInterface {
RequestResponse:
    createDbService( CreateDbServiceRequest )( string )
        throws  ConnectionError DatabaseNotSupported SQLException SQLServerException,
    createService4Table( CreateService4TableRequest )( CreateService4TableResponse ),
    createMassageFromType( CreateTypeRequest )( string ),
    createType( CreateTypeRequest )( string ),
    getNativeType( GetNativeTypeRequest )( string ),
}
