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

include "e_commerce_handler_service/automatic_service/public/interfaces/includes.iol"
include "e_commerce_handler_service/locations.iol"
include "console.iol"

outputPort Test {
  Location: e_commerce
  Protocol: sodep
  Interfaces: userInterface, orderInterface, productInterface
}

main{

  removeuser@Test()();
  removeproduct@Test()();
  removeorder@Test()();

  // Insert of table user

  createuserRequest.fiscalcode = "1";
  createuserRequest.name = "John";
  createuserRequest.surname = "Silver";
  createuserRequest.email = "john.silver@mail.com";
  createuser@Test(createuserRequest)();

  undef( createuserRequest );
  createuserRequest.fiscalcode = "3";
  createuserRequest.name = "Rick";
  createuserRequest.surname = "Grimes";
  createuserRequest.email = "rick.grimes@mail.com";
  createuser@Test(createuserRequest)();

  undef( createuserRequest );
  createuserRequest.fiscalcode = "2";
  createuserRequest.name = "Walter";
  createuserRequest.surname = "White";
  createuserRequest.email = "walter.white@mail.com";
  createuser@Test(createuserRequest)();

  undef( createuserRequest );
  createuserRequest.fiscalcode = "4";
  createuserRequest.name = "Rustin";
  createuserRequest.surname = "Cohle";
  createuserRequest.email = "rustin.cohle@mail.com";
  createuser@Test(createuserRequest)();

  getuserRequest.filter.column_name = "name";
  getuserRequest.filter.column_value = "Rick";
  getuserRequest.filter.expression.eq = true;
  getuser@Test(getuserRequest)( response );
  println@Console( response.row.name )();

//Insert of rows inside the table "prodotto"
  createproductRequest.product_name = "Cover Iphone 5s";
  createproductRequest.quantity = 40;
  createproduct@Test(createproductRequest)();

  undef( createproductRequest );
  createproductRequest.description = "I7 Processor, RAM 8GB and Video Card Nvdia GTX 950";
  createproductRequest.product_name = "Computer Asus";
  createproductRequest.quantity = 12;
  createproduct@Test(createproductRequest)();

  undef( createproductRequest );
  createproductRequest.product_name = "Chicken";
  createproductRequest.quantity = 12;
  createproduct@Test(createproductRequest)();

  // Insert of table ordine

  createorderRequest.id_product = 1;
  createorderRequest.id_user = "1";
  createorderRequest.quantity = 3;
  createorder@Test(createorderRequest)();

  undef( createorderRequest );
  createorderRequest.id_product = 2;
  createorderRequest.id_user = "4";
  createorderRequest.quantity = 1;
  createorder@Test(createorderRequest)();

  updateuserRequest.surname = "Smith";
  updateuserRequest.filter.column_name = "surname";
  updateuserRequest.filter.column_value = "Silver";
  updateuserRequest.filter.expression.eq = true;
  updateuser@Test(updateuserRequest)();

  updateproductRequest.product_name = "Fried Chicken";
  updateproductRequest.quantity = 20;
  updateproductRequest.filter.column_name = "product_name";
  updateproductRequest.filter.column_value = "Chicken";
  updateproductRequest.filter.expression.eq = true;
  updateproduct@Test(updateproductRequest)();

  // Select of table prodotto

  getproduct@Test(getproductRequest)(response);
  for (i = 0, i < #response.row, i++ ) {
    println@Console( "\n" + response.row[i].fiscalcode )()
  };

  undef( getproductRequest );
  undef( response );
  getproductRequest.filter.column_name = "product_name";
  getproductRequest.filter.column_value = "Fried Chicken";
  getproductRequest.filter.expression.eq = true;
  getproductRequest.filter.and_operator = true;
  getproductRequest.filter[1].column_name = "quantity";
  getproductRequest.filter[1].column_value = 10;
  getproductRequest.filter[1].expression.gteq = true;
  getproduct@Test(getproductRequest)( response );
  println@Console( "\n" + response.row.id_product )()

}
