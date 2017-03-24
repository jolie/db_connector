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
       include "public/types/DBDatabaseCommonTypes.iol"
       include "public/interfaces/includes.iol"
       include "database.iol"
       include "ini_utils.iol"
       include "console.iol"
       include "string_utils.iol"
       include "locations.iol"
       execution{ concurrent }
       inputPort DB{
         Location: "local"
         Protocol: sodep
         Interfaces:tabellaInterface
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
// tabella
	[ createtabella( request )( response ) {

			optional_fields="";value_fields="";at_least_one_optional_field=false;
			if ( is_defined( request.CampoProva ) ) {
			if ( at_least_one_optional_field ) { optional_fields += ",";value_fields += "," };
				optional_fields += "\"CampoProva\"";
				value_fields += ":CampoProva";
				at_least_one_optional_field=true
			};
			if(#optional_fields != 0){
                q = "INSERT INTO \"tabella\" ( " + optional_fields  + "  ) VALUES ( " + value_fields + " )"
} else {
                q = "INSERT INTO \"tabella\" (  ) VALUES (  )"
                };
			q.CampoProva = request.CampoProva;
			update@Database( q )( result )
	} ]{ nullProcess }


	[ updatetabella( request )( response ) {

			__where;
			optional_fields="";at_least_one_optional_field=false;
			if ( is_defined( request.CampoProva ) ) {
			if ( at_least_one_optional_field ) { optional_fields += "," };
				optional_fields += "\"CampoProva\"=:CampoProva";
				at_least_one_optional_field=true
			};
			q = "UPDATE \"tabella\" SET " + optional_fields + "" + where;
			q.CampoProva = request.CampoProva;
			update@Database( q )( result )

	} ]{ nullProcess }


	[ removetabella( request )( response ) {

			__where;
			q = "DELETE FROM \"tabella\"" + where;
			update@Database( q )( result )

	} ]{ nullProcess }


	[ gettabella( request )( response ) {

			__where;
			q = "SELECT \"CampoProva\" FROM \"tabella\"" + where;
			query@Database( q )( response )

	} ]{ nullProcess }





}

