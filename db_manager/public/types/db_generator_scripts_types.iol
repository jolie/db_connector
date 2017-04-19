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
type NativeType: void {
      .isstring?: bool
      .isint?: bool
      .isdouble?: bool
      .isvoid?: bool
      .isbool?: bool
      .islong?: bool
      .israw?: bool
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
