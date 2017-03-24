/***************************************************************************
 *   Copyright (C) 2016-2017 by Danilo Sorano <soranod@gmail.com>     *
 *   Copyright (C) 2016 by Claudio Guidi <guidiclaudio@gmail.com>     *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU Library General Public License as       *
 *   published by the Free Software Foundation; either version 2 of the    *
 *   License, or (at your option) any later version.                       *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU Library General Public     *
 *   License along with this program; if not, write to the                 *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 *                                                                         *
 *   For details about the authors of this software, see the AUTHORS file. *
 ***************************************************************************/
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
