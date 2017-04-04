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
        include "../types/e_commerceDatabaseCommonTypes.iol"
type createuserRequest:void {
	.fiscalcode:string
	.name:string
	.surname:string
	.email:string
}

type createuserResponse:void

type updateuserRequest:void {
	.fiscalcode?:string
	.name?:string
	.surname?:string
	.email?:string
	.filter*:FilterType
}

type updateuserResponse:void

type removeuserRequest:void {
	.filter*:FilterType
}

type removeuserResponse:void

type getuserRequest:void {
	.filter*:FilterType
}

type getuserRowType:void {
	.fiscalcode:string
	.name:string
	.surname:string
	.email:string
}

type getuserResponse:void {
	.row*:getuserRowType
}

interface userInterface {
	RequestResponse:
		createuser( createuserRequest )( createuserResponse ) throws SQLException SQLServerException,
		updateuser( updateuserRequest )( updateuserResponse ) throws SQLException SQLServerException,
		removeuser( removeuserRequest )( removeuserResponse ) throws SQLException SQLServerException,
		getuser( getuserRequest )( getuserResponse ) throws SQLException SQLServerException
}
