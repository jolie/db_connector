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
type createproductRequest:void {
	.id_product?:int
	.product_name:string
	.description?:string
	.quantity:long
}

type createproductResponse:void

type updateproductRequest:void {
	.id_product?:int
	.product_name?:string
	.description?:string
	.quantity?:long
	.filter*:FilterType
}

type updateproductResponse:void

type removeproductRequest:void {
	.filter*:FilterType
}

type removeproductResponse:void

type getproductRequest:void {
	.filter*:FilterType
}

type getproductRowType:void {
	.id_product:int
	.product_name:string
	.description:string
	.quantity:long
}

type getproductResponse:void {
	.row*:getproductRowType
}

interface productInterface {
	RequestResponse:
		createproduct( createproductRequest )( createproductResponse ) throws SQLException SQLServerException,
		updateproduct( updateproductRequest )( updateproductResponse ) throws SQLException SQLServerException,
		removeproduct( removeproductRequest )( removeproductResponse ) throws SQLException SQLServerException,
		getproduct( getproductRequest )( getproductResponse ) throws SQLException SQLServerException
}
