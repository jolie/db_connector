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
       include "public/types/e_commerceDatabaseCommonTypes.iol"
       include "public/interfaces/includes.iol"
       include "database.iol"
       include "ini_utils.iol"
       include "console.iol"
       include "string_utils.iol"
       include "locations.iol"
       execution{ concurrent }
       inputPort e_commerce{
         Location: "local"
         Protocol: sodep
         Interfaces:userInterface,
			productInterface,
			orderInterface
}

define __where {
where = "";
        if ( is_defined( request.filter ) ) {
          where = " WHERE ";
          for(i = 0, i < #request.filter, i++){
            if( is_defined( request.filter[i].expression.eq ) ) {
              where +=  "\"" + request.filter[i].column_name + "\" = " + "'" + request.filter[i].column_value + "'"
            };
            if( is_defined( request.filter[i].expression.gt ) ) {
              where += "\"" + request.filter[i].column_name + "\" > " + "'" + request.filter[i].column_value + "'"
            };
            if( is_defined( request.filter[i].expression.lt ) ) {
              where += "\"" + request.filter[i].column_name + "\" < " + "'" + request.filter[i].column_value + "'"
            };
            if( is_defined( request.filter[i].expression.gteq ) ) {
              where += "\"" + request.filter[i].column_name + "\" >= " + "'" + request.filter[i].column_value + "'"
            };
            if( is_defined( request.filter[i].expression.lteq ) ) {
              where += "\"" + request.filter[i].column_name + "\" <= " + "'" +request.filter[i].column_value + "'"
            };
            if( is_defined( request.filter[i].expression.noteq ) ) {
              where += "\"" + request.filter[i].column_name + "\" != "+ "'" + request.filter[i].column_value + "'"
            };
            if( is_defined( request.filter[i].and_operator ) == false
            && is_defined( request.filter[i].or_operator ) == false) {
              where += ";"
            }
            else{
              if( is_defined( request.filter[i].and_operator ) ){
                where += " AND "
              }
              else{
                where += " OR "
              }
            }
          }}
}
init {
        parseIniFile@IniUtils( "config.ini" )( config );
        HOST = config.db_connection.HOST;
        DRIVER = config.db_connection.DRIVER;
        PORT = int( config.db_connection.PORT );
        DATABASE = config.db_connection.DATABASE;
        USERNAME = config.db_connection.USERNAME;
        PASSWORD = config.db_connection.PASSWORD;
        scope( connection_scope ) {
          install( ConnectionError => valueToPrettyString@StringUtils( connection_scope.ConnectionError )( s );
          println@Console( s )();
          exit
          );
          with( connectionInfo ) {
            .host = HOST;
            .driver = DRIVER;
            .port = PORT;
            .database = DATABASE;
            .username = USERNAME;
            .password = PASSWORD
          };
          connect@Database( connectionInfo )()
        };
        println@Console("Running...")()
        }


main {
// user
	[ createuser( request )( response ) {

			optional_fields="";value_fields="";at_least_one_optional_field=false;
			if(optional_fields != ""){
                q = "INSERT INTO \"user\" ( " + optional_fields  + " ,\"fiscalcode\", \"name\", \"surname\", \"email\" ) VALUES ( " + value_fields + ",:fiscalcode, :name, :surname, :email )"
} else {
                q = "INSERT INTO \"user\" ( \"fiscalcode\", \"name\", \"surname\", \"email\" ) VALUES ( :fiscalcode, :name, :surname, :email )"
                };
			q.fiscalcode = request.fiscalcode;
			q.name = request.name;
			q.surname = request.surname;
			q.email = request.email;
			update@Database( q )( result )
	} ]{ nullProcess }


	[ updateuser( request )( response ) {

			__where;
			optional_fields="";at_least_one_optional_field=false;
			if ( is_defined( request.fiscalcode ) ) {
			if ( at_least_one_optional_field ) { optional_fields += "," };
				optional_fields += "\"fiscalcode\"=:fiscalcode";
				at_least_one_optional_field=true
			};
			if ( is_defined( request.name ) ) {
			if ( at_least_one_optional_field ) { optional_fields += "," };
				optional_fields += "\"name\"=:name";
				at_least_one_optional_field=true
			};
			if ( is_defined( request.surname ) ) {
			if ( at_least_one_optional_field ) { optional_fields += "," };
				optional_fields += "\"surname\"=:surname";
				at_least_one_optional_field=true
			};
			if ( is_defined( request.email ) ) {
			if ( at_least_one_optional_field ) { optional_fields += "," };
				optional_fields += "\"email\"=:email";
				at_least_one_optional_field=true
			};
			q = "UPDATE \"user\" SET " + optional_fields + "" + where;
			q.fiscalcode = request.fiscalcode;
			q.name = request.name;
			q.surname = request.surname;
			q.email = request.email;
			update@Database( q )( result )

	} ]{ nullProcess }


	[ removeuser( request )( response ) {

			__where;
			q = "DELETE FROM \"user\"" + where;
			update@Database( q )( result )

	} ]{ nullProcess }


	[ getuser( request )( response ) {

			__where;
			q = "SELECT \"fiscalcode\", \"name\", \"surname\", \"email\" FROM \"user\"" + where;
			query@Database( q )( response )

	} ]{ nullProcess }




// product
	[ createproduct( request )( response ) {

			optional_fields="";value_fields="";at_least_one_optional_field=false;
			if ( is_defined( request.id_product ) ) {
			if ( at_least_one_optional_field ) { optional_fields += ",";value_fields += "," };
				optional_fields += "\"id_product\"";
				value_fields += ":id_product";
				at_least_one_optional_field=true
			};
			if ( is_defined( request.description ) ) {
			if ( at_least_one_optional_field ) { optional_fields += ",";value_fields += "," };
				optional_fields += "\"description\"";
				value_fields += ":description";
				at_least_one_optional_field=true
			};
			if(optional_fields != ""){
                q = "INSERT INTO \"product\" ( " + optional_fields  + " ,\"product_name\", \"quantity\" ) VALUES ( " + value_fields + ",:product_name, :quantity )"
} else {
                q = "INSERT INTO \"product\" ( \"product_name\", \"quantity\" ) VALUES ( :product_name, :quantity )"
                };
			q.id_product = request.id_product;
			q.product_name = request.product_name;
			q.description = request.description;
			q.quantity = request.quantity;
			update@Database( q )( result )
	} ]{ nullProcess }


	[ updateproduct( request )( response ) {

			__where;
			optional_fields="";at_least_one_optional_field=false;
			if ( is_defined( request.id_product ) ) {
			if ( at_least_one_optional_field ) { optional_fields += "," };
				optional_fields += "\"id_product\"=:id_product";
				at_least_one_optional_field=true
			};
			if ( is_defined( request.product_name ) ) {
			if ( at_least_one_optional_field ) { optional_fields += "," };
				optional_fields += "\"product_name\"=:product_name";
				at_least_one_optional_field=true
			};
			if ( is_defined( request.description ) ) {
			if ( at_least_one_optional_field ) { optional_fields += "," };
				optional_fields += "\"description\"=:description";
				at_least_one_optional_field=true
			};
			if ( is_defined( request.quantity ) ) {
			if ( at_least_one_optional_field ) { optional_fields += "," };
				optional_fields += "\"quantity\"=:quantity";
				at_least_one_optional_field=true
			};
			q = "UPDATE \"product\" SET " + optional_fields + "" + where;
			q.id_product = request.id_product;
			q.product_name = request.product_name;
			q.description = request.description;
			q.quantity = request.quantity;
			update@Database( q )( result )

	} ]{ nullProcess }


	[ removeproduct( request )( response ) {

			__where;
			q = "DELETE FROM \"product\"" + where;
			update@Database( q )( result )

	} ]{ nullProcess }


	[ getproduct( request )( response ) {

			__where;
			q = "SELECT \"id_product\", \"product_name\", \"description\", \"quantity\" FROM \"product\"" + where;
			query@Database( q )( response )

	} ]{ nullProcess }




// order
	[ createorder( request )( response ) {

			optional_fields="";value_fields="";at_least_one_optional_field=false;
			if ( is_defined( request.id_order ) ) {
			if ( at_least_one_optional_field ) { optional_fields += ",";value_fields += "," };
				optional_fields += "\"id_order\"";
				value_fields += ":id_order";
				at_least_one_optional_field=true
			};
			if ( is_defined( request.date ) ) {
			if ( at_least_one_optional_field ) { optional_fields += ",";value_fields += "," };
				optional_fields += "\"date\"";
				value_fields += ":date";
				at_least_one_optional_field=true
			};
			if(optional_fields != ""){
                q = "INSERT INTO \"order\" ( " + optional_fields  + " ,\"id_product\", \"id_user\", \"quantity\" ) VALUES ( " + value_fields + ",:id_product, :id_user, :quantity )"
} else {
                q = "INSERT INTO \"order\" ( \"id_product\", \"id_user\", \"quantity\" ) VALUES ( :id_product, :id_user, :quantity )"
                };
			q.id_order = request.id_order;
			q.id_product = request.id_product;
			q.id_user = request.id_user;
			q.quantity = request.quantity;
			q.date = request.date;
			update@Database( q )( result )
	} ]{ nullProcess }


	[ updateorder( request )( response ) {

			__where;
			optional_fields="";at_least_one_optional_field=false;
			if ( is_defined( request.id_order ) ) {
			if ( at_least_one_optional_field ) { optional_fields += "," };
				optional_fields += "\"id_order\"=:id_order";
				at_least_one_optional_field=true
			};
			if ( is_defined( request.id_product ) ) {
			if ( at_least_one_optional_field ) { optional_fields += "," };
				optional_fields += "\"id_product\"=:id_product";
				at_least_one_optional_field=true
			};
			if ( is_defined( request.id_user ) ) {
			if ( at_least_one_optional_field ) { optional_fields += "," };
				optional_fields += "\"id_user\"=:id_user";
				at_least_one_optional_field=true
			};
			if ( is_defined( request.quantity ) ) {
			if ( at_least_one_optional_field ) { optional_fields += "," };
				optional_fields += "\"quantity\"=:quantity";
				at_least_one_optional_field=true
			};
			if ( is_defined( request.date ) ) {
			if ( at_least_one_optional_field ) { optional_fields += "," };
				optional_fields += "\"date\"=:date";
				at_least_one_optional_field=true
			};
			q = "UPDATE \"order\" SET " + optional_fields + "" + where;
			q.id_order = request.id_order;
			q.id_product = request.id_product;
			q.id_user = request.id_user;
			q.quantity = request.quantity;
			q.date = request.date;
			update@Database( q )( result )

	} ]{ nullProcess }


	[ removeorder( request )( response ) {

			__where;
			q = "DELETE FROM \"order\"" + where;
			update@Database( q )( result )

	} ]{ nullProcess }


	[ getorder( request )( response ) {

			__where;
			q = "SELECT \"id_order\", \"id_product\", \"id_user\", \"quantity\", \"date\" FROM \"order\"" + where;
			query@Database( q )( response )

	} ]{ nullProcess }





}

