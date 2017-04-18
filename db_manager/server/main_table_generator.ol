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
include "../public/interfaces/TableGeneratorInterface.iol"
include "../config/config.iol"
include "runtime.iol"
include "console.iol"
include "database.iol"
include "string_utils.iol"
include "file.iol"

execution{ concurrent }

inputPort TableGenerator {
  Location: TableGeneratorLocation
  Protocol: sodep
  Interfaces: TableGeneratorInterface
}

outputPort MySelf {
  Location: "local"
  Protocol: sodep
  Interfaces: TableGeneratorInterface
}

inputPort MySelfIP {
  Location: "local"
  Protocol: sodep
  Interfaces: TableGeneratorInterface
}

// In the init scope the interface DatabaseCommonTypes and the where filter are created

init {
  // The FILTER_TYPE define the type of where clause
  FILTER_TYPE =
  "/***************************************************************************
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
   type ExpressionFilterType: void {
      .eq?: bool
      .gt?: bool
      .lt?: bool
      .gteq?: bool
      .lteq?: bool
      .noteq?: bool
    }

    type FilterType: void {
      //.parentesis: bool
      .column_name: string
      .column_value: any
      .expression: ExpressionFilterType
      .and_operator?:  bool
      .or_operator?: bool
    }
";
// WHERE_FILTER create the string of where clause using the type of interface DatabaseCommonTypes
  WHERE_FILTER = "where = \"\";
        if ( is_defined( request.filter ) ) {
          where = \" WHERE \";
          for(i = 0, i < #request.filter, i++){
            if( is_defined( request.filter[i].expression.eq ) ) {
              where +=  \"\\\"\" + request.filter[i].column_name + \"\\\" = \" + \"'\" + request.filter[i].column_value + \"'\"
            };
            if( is_defined( request.filter[i].expression.gt ) ) {
              where += \"\\\"\" + request.filter[i].column_name + \"\\\" > \" + \"'\" + request.filter[i].column_value + \"'\"
            };
            if( is_defined( request.filter[i].expression.lt ) ) {
              where += \"\\\"\" + request.filter[i].column_name + \"\\\" < \" + \"'\" + request.filter[i].column_value + \"'\"
            };
            if( is_defined( request.filter[i].expression.gteq ) ) {
              where += \"\\\"\" + request.filter[i].column_name + \"\\\" >= \" + \"'\" + request.filter[i].column_value + \"'\"
            };
            if( is_defined( request.filter[i].expression.lteq ) ) {
              where += \"\\\"\" + request.filter[i].column_name + \"\\\" <= \" + \"'\" +request.filter[i].column_value + \"'\"
            };
            if( is_defined( request.filter[i].expression.noteq ) ) {
              where += \"\\\"\" + request.filter[i].column_name + \"\\\" != \"+ \"'\" + request.filter[i].column_value + \"'\"
            };
            if( is_defined( request.filter[i].and_operator ) == false
            && is_defined( request.filter[i].or_operator ) == false) {
              where += \";\"
            }
            else{
              if( is_defined( request.filter[i].and_operator ) ){
                where += \" AND \"
              }
              else{
                where += \" OR \"
              }
            }
          }}\n";

  getLocalLocation@Runtime( )( MySelf.location );
  _main_init = "main {\n";
  _main_end = "}\n";
  println@Console("Running...")()
}

define _operation_init {
  response.behaviour += "\t[ " + operation_name + "( request )( response ) {\n"
}

define _operation_end {
  response.behaviour += "\n\t} ]{ nullProcess }\n\n\n"
}

main {
  // This service is used to create the service of Database
  [ createDbService( request )( response ) {
        // connect to the database
        tableName = "";

        driver = request.driver;

        scope( connection_scope ) {
            install( ConnectionError => valueToPrettyString@StringUtils( connection_scope.ConnectionError )( s );
                                        println@Console( s )();
                                        exit
            );
            // connection with Database using the informaton of request
            with( connectionInfo ) {
                  .host = request.host;
                  .driver = request.driver;
                  .port = request.port;
                  .database = request.database;
                  .username = request.username;
                  .password = request.password;
                  .toLowerCase = true
            };
            connect@Database( connectionInfo )()
        }
        ;
        // The driver of Database are checked
        if ( driver == "sqlserver") {
            scope( query ) {
                q = "select * from INFORMATION_SCHEMA.TABLES";
                query@Database( q )( tables )
            };
            /* for each table retrieve meta data of columns */
            undef( q );
            for( i = 0, i < #tables.row, i++ ) {
                q.statement[ i ] = "SELECT syscol.is_identity, *  from INFORMATION_SCHEMA.COLUMNS icol
                                    JOIN sys.columns syscol ON
                                    object_id( icol.TABLE_CATALOG + '.' + icol.TABLE_SCHEMA + '.' + icol.TABLE_NAME ) = syscol.object_id
                                    AND syscol.name=icol.COLUMN_NAME
                                    WHERE icol.TABLE_NAME=:table_name";
                q.statement[ i ].table_name = tables.row[ i ].table_name
            };
            executeTransaction@Database( q )( columns )

      } else if ( driver == "postgresql" )  {
        // If the database is postgres the metadata of tables are pulled out
            scope( query ) {
                q = "SELECT table_name FROM information_schema.tables where table_schema=:table_schema";
                q.table_schema = request.table_schema;
                query@Database( q )( tables )
            };
            /* for each table retrieve meta data of columns */
            undef( q );
            for( i = 0, i < #tables.row, i++ ) {
                q.statement[ i ] = "SELECT * from information_schema.columns where table_schema=:table_schema AND table_name=:table_name";
                q.statement[ i ].table_schema = request.table_schema;
                q.statement[ i ].table_name = tables.row[ i ].table_name
            };
            executeTransaction@Database( q )( columns );
            // Serial fields of the tables are searched
            que.statement = "SELECT c.relname FROM pg_class c WHERE c.relkind = :seriale";
            que.statement.seriale = "S";
            executeTransaction@Database( que )( serial );
            que.statement[1] = "SELECT table_name, column_name FROM information_schema.columns WHERE table_schema = :table_schema AND table_catalog = :table_catalog";
            que.statement[1].table_schema = request.table_schema;
            que.statement[1].table_catalog = request.database;
            executeTransaction@Database( que )( fields );
            y=0;
            //The information are saved inside the variable serialFields
            for ( i=0, i<#serial.result.row, i++ ) {
              for ( j=0, j<#fields.result[1].row, j++ ) {

                containsRequest = serial.result.row[ i ].relname;
                containsRequest.substring = fields.result[1].row[ j ].column_name;
                contains@StringUtils(containsRequest)(containsResponse);

                containsRequestTable = serial.result.row[ i ].relname;
                containsRequestTable.substring = fields.result[1].row[ j ].table_name;
                contains@StringUtils(containsRequestTable)(containsResponseTable);

                if( containsResponse && containsResponseTable) {
                  serialFields.campo[y] = fields.result[1].row[ j ].column_name;
                  serialFields.campo[y].table = fields.result[1].row[ j ].table_name
                }
              }
            }
      };

      // the folder of the Database service are created with its folder automatic_service
      token = "../db_services/" + request.database + "_handler_service/automatic_service";
      mkdir@File( token )();
      // the lib folder are created
      mkdir@File( "../db_services/" + request.database + "_handler_service/lib" )();
      undef( file );
      file.filename = "lib/autoconf1_0_0.jar";
      file.format = "binary";
      readFile@File( file )( autoconf );
      file.filename = "../db_services/" + request.database + "_handler_service/lib/autoconf1_0_0.jar";
      file.content -> autoconf;
      writeFile@File( file )();

      // The folder public with subfolder interfaces and types are created
      mkdir@File( token + "/public" )();
      mkdir@File( token + "/public/interfaces" )();
      mkdir@File( token + "/public/types" )();
      undef( file );
      // Inside the folder typer the DatabaseCommonTypes interface is created
      file.filename = token + "/public/types/" + request.database + "DatabaseCommonTypes.iol";
      // The content of this interface is the FILTER_TYPE
      file.content = FILTER_TYPE;
      writeFile@File( file )();

      // generate config.ini file
      // The file config.ini is the file of configuration used to connect with the database
      undef( file );
      file.filename = "../db_services/" + request.database + "_handler_service/config.ini";
      file.content =
      "; **************************************************************************
       ;   Copyright (C) 2016-2017 by Danilo Sorano <soranod@gmail.com>           *
       ;   Copyright (C) 2016 by Claudio Guidi <guidiclaudio@gmail.com>           *
       ;                                                                          *
       ;    This program is free software; you can redistribute it and/or modify  *
       ;    it under the terms of the GNU Library General Public License as       *
       ;    published by the Free Software Foundation; either version 2 of the    *
       ;    License, or (at your option) any later version.                       *
       ;                                                                          *
       ;    This program is distributed in the hope that it will be useful,       *
       ;    but WITHOUT ANY WARRANTY; without even the implied warranty of        *
       ;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
       ;    GNU General Public License for more details.                          *
       ;                                                                          *
       ;    You should have received a copy of the GNU Library General Public     *
       ;    License along with this program; if not, write to the                 *
       ;    Free Software Foundation, Inc.,                                       *
       ;    59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
       ;                                                                          *
       ;    For details about the authors of this software, see the AUTHORS file. *
       ; **************************************************************************
       [db_connection]
       HOST=" + request.host + "\n"
                      + "DRIVER=" + request.driver + "\n"
                      + "PORT=" + request.port + "\n"
                      + "DATABASE=" + request.database + "\n"
                      + "USERNAME=" + request.username + "\n"
                      + "PASSWORD=" + request.password;
      writeFile@File( file )();

      // generate locations.ini
      // The file locations contains the constant variable of the location
      undef( file );
      file.filename = "../db_services/" + request.database + "_handler_service/locations.iol";
      file.content =
      "/***************************************************************************
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
       constants{\n"
                        + "\t" + request.database + "=\"socket://localhost:9100\"\n"
                        + "}";
      writeFile@File( file )();

      //Inside the folder lib the driver file are pasted
      if ( request.driver == "sqlserver") {
          undef( file );
          file.filename = "lib/jdbc-sqlserver.jar";
          file.format = "binary";
          readFile@File( file )( driverfile );
          file.filename = "../db_services/" + request.database + "_handler_service/lib/jdbc-sqlserver.jar";
          file.content -> driverfile;
          writeFile@File( file )()
      } else if ( request.driver == "postgresql" ) {
          undef( file );
          file.filename = "lib/jdbc-postgresql.jar";
          file.format = "binary";
          readFile@File( file )( driverfile );
          file.filename = "../db_services/" + request.database + "_handler_service/lib/jdbc-postgresql.jar";
          file.content -> driverfile;
          writeFile@File( file )()
      } else {
          throw( DatabaseNotSupported )
      };

      //The init_behaviour contains the WHERE_FILTER and init of the main_automatic
      // In this part of code the connection with the database is initializzed
      init_behaviour =
      "define __where {\n" + WHERE_FILTER + "}\n"+
      "init {
        parseIniFile@IniUtils( \"config.ini\" )( config );
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
        println@Console(\"Running...\")()
        }\n";

//The header of main_automatic contains all the necessary include
//and the inputPort of our automatic service
      behaviour_header =
      "/***************************************************************************
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
       include \"public/types/" + request.database + "DatabaseCommonTypes.iol\"
       include \"public/interfaces/includes.iol\"
       include \"database.iol\"
       include \"ini_utils.iol\"
       include \"console.iol\"
       include \"string_utils.iol\"
       include \"locations.iol\"
       execution{ concurrent }
       inputPort " + request.database + "{
         Location: \"local\"
         Protocol: sodep
         Interfaces:";

    // For eaxh table the service are created and information are passed
    // with the variable create_req.
      for( i = 0, i < #tables.row, i++ ) {
          undef( create_req );
          create_req.database = request.database;
          with( create_req.table ) {
              .table_name = tables.row[ i ].table_name;
              //Check if a table is a view or not
              if( tables.row[ i ].table_type == "VIEW" ) {
                    .is_view = true
              } else {
                    .is_view = false
              };
              for( c = 0, c < #columns.result[ i ].row, c++ ) {
                    with ( .table_columns[ c ] ) {
                        column -> columns.result[ i ].row[ c ];
                        .name = column.column_name;
                        //Check if a table contains serial fields
                        for ( j=0, j<#serialFields.campo, j++ ) {
                          if(serialFields.campo[j] == .name && serialFields.campo[j].table == tables.row[i].table_name)
                          {
                            .is_serial = true;
                            j=#serialFields.campo
                          }
                        };
                        if(!is_defined( .is_serial )){
                          .is_serial = false
                        };
                        // Check the type of fields of a table
                        if ( column.data_type == "integer") {
                            .value_type.isint = true
                        } else if ( column.data_type == "smallint") {
                            .value_type.isint = true
                        } else if ( column.data_type == "bigint") {
                            .value_type.islong = true
                        } else if ( column.data_type == "real") {
                            .value_type.isdouble = true
                        } else if ( column.data_type == "numeric") {
                            .value_type.isdouble = true
                        } else if ( column.data_type == "doubleprecision") {
                            .value_type.isdouble = true
                        } else if ( column.data_type == "long") {
                            .value_type.islong = true
                        } else if(column.data_type == "boolean"){
                          .value_type.isbool = true
                        } else if ( column.data_type == "varchar") {
                            .value_type.isdouble = true
                        } else if ( column.data_type == "text") {
                            .value_type.isdouble = true
                        } else if ( column.data_type == "char") {
                            .value_type.isdouble = true
                        } else if ( column.data_type == "bytea") {
                            .value_type.israw = true
                        } else if ( column.data_type == "char") {
                            .value_type.isdouble = true
                        } else {
                            .value_type.isstring = true
                        };
                        // Check other properties of fields
                        if ( column.column_default == "") {
                            .has_default_value = false
                        } else {
                            .has_default_value = true
                        };
                        if ( column.is_nullable == "YES" ) {
                            .is_nullable = true
                        } else {
                            .is_nullable = false
                        };
                        if ( column.is_identity == 1 || column.is_identity == "YES") {
                            .is_identity = true
                        } else {
                            .is_identity = false
                        }
                    }
              }
        };
        println@Console( "Processing table " + create_req.table.table_name )();
        // This service create the service(Insert, Update, Remove and Select) of database tables
        createService4Table@MySelf( create_req )( create_res );
        undef( file );
        // Creation of the interfaces of each table
        file.filename = token + "/public/interfaces/" + create_req.table.table_name + "Interface.iol";
        file.content -> create_res.interface;
        writeFile@File( file )();

        // The interface of the inputPort are added to Interfaces clause
        if ( i > 0 ) {
              behaviour_header += ",\n\t\t\t"
        };
        behaviour_header += create_req.table.table_name + "Interface";

        behaviour += "// " + create_req.table.table_name + "\n";
        behaviour += create_res.behaviour + "\n\n";
        println@Console("Done.")();
        tableName[i] = create_req.table.table_name
    };

    undef( file );
    // Creationt of the file includes.iol, that contains all the interfaces for the table
    file.filename = token + "/public/interfaces/includes.iol";
    content =
    "/***************************************************************************
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
     ***************************************************************************/\n";
     for ( y=0, y < #tableName, y++ ) {
       content += "include \"" + tableName[y] + "Interface.iol\"\n"
     };
    file.content = content;
    writeFile@File( file )();

    // The main_automatic with is content is created
    undef( file );
    file.filename = token + "/main_automatic_" + request.database  + ".ol";
    behaviour += "\n}\n\n";
    file.content = behaviour_header + "\n}\n\n" + init_behaviour + "\n\nmain {\n" + behaviour;
    writeFile@File( file )();
    println@Console("Database table generation is finished with SUCCESS")();

    // In this part the custom_service is generated
    dirPathCustom = "../db_services/" + request.database + "_handler_service/custom_service";
    exists@File( dirPathCustom )( exist );
    dirPath = "../db_services/" + request.database + "_handler_service";
    // Check if the custom_service folder exist
    if( !exist ){
      mkdir@File( dirPathCustom )();
      undef( file );
      // Creation of the main_custom with is content
      // This main contains a defaultService
      file.filename = dirPath + "/custom_service/main_custom_" + request.database + ".ol";
      file.content =
      "/***************************************************************************
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
      include \"public/interfaces/custom_interface_" + request.database + ".iol\"
      inputPort customService {
        Location: \"local\"
        Protocol: sodep
        Interfaces: interfaceCustom
      }
      main{
        defaultService()( response ){
          response = \"This is a default service of custom part!\"
        }
      }";
      writeFile@File( file )();
      undef( file );
      // Generation the interface of custom_service
      file.filename = dirPath + "/custom_service/public/interfaces/custom_interface_" + request.database + ".iol";
      mkdir@File(dirPath + "/custom_service/public" )();
      mkdir@File(dirPath + "/custom_service/public/interfaces" )();
      file.content =
      "/***************************************************************************
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
       interface interfaceCustom {
        RequestResponse: defaultService( void )( string )
        }";
      writeFile@File( file )();
      undef( file );
      // Generation of the principal main
      file.filename = dirPath + "/main_" + request.database + ".ol";
      interfaces = "";
      for( j = 0, j < #tables.row, j++){
        if(j == #tables.row -1){
          interfaces = interfaces + tables.row[ j ].table_name + "Interface"
        }
        else{
          interfaces = interfaces + tables.row[ j ].table_name + "Interface, "
        }
      };
      // The main embed the main_custom and the main_automatic and define the inpuPort of the service
      file.content =
      "/***************************************************************************
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
      include \"automatic_service/public/interfaces/includes.iol\"
      include \"custom_service/public/interfaces/custom_interface_" + request.database + ".iol\"
      include \"locations.iol\"
      include \"console.iol\"

      outputPort customService {
        Interfaces: interfaceCustom
      }

      outputPort automaticService {
        Interfaces: " + interfaces + "
      }

      inputPort clientService {
        Location: " + request.database + "
        Protocol:sodep
        Aggregates: customService, automaticService
      }

      embedded {
        Jolie: \"automatic_service/main_automatic_" + request.database + ".ol\" in automaticService,
                \"custom_service/main_custom_" + request.database + ".ol\" in customService
      }

      main {
        println@Console( \"Server in attesa...\" )();
        linkIn( dummy )
      }";
      writeFile@File( file )()
    };

    response = "Il servizio e stato creato con successo."
  }] { nullProcess }

  // This service create the principals oeration of the database
  [ createService4Table( request )( response ) {

        response.interface =
        "/***************************************************************************
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
        include \"../types/" + request.database + "DatabaseCommonTypes.iol\"\n";
        // Creation of the operation name for each operation
        if ( !request.table.is_view ) {
              if ( is_defined( request.table.create_operation_name ) ) {
              create_operation_name = request.table.create_operation_name
              } else {
                    create_operation_name = "create" + request.table.table_name
              };
              create_operation_name_request = create_operation_name + "Request";
              create_operation_name_response = create_operation_name + "Response";
              if ( is_defined( request.table.update_operation_name ) ) {
                    update_operation_name = request.table.update_operation_name
              } else {
                    update_operation_name =  "update" + request.table.table_name
              };
              update_operation_name_request = update_operation_name + "Request";
              update_operation_name_response = update_operation_name + "Response";

              if ( is_defined( request.table.remove_operation_name ) ) {
                remove_operation_name = request.table.remove_operation_name
              } else {
                remove_operation_name =  "remove" + request.table.table_name
              };
              remove_operation_name_request = remove_operation_name + "Request";
              remove_operation_name_response = remove_operation_name + "Response";
              // Creation of the type for each operation
              creation_type_request.type_name = create_operation_name_request;
              creation_type_request.root_native_type.isvoid = true;
              field_index = 0;

              /*
               Creation of the create operation
              */
              for( x = 0, x < #request.table.table_columns, x++ ) {
                    current_column << request.table.table_columns[x];
                    if ( !current_column.is_identity ) {
                      // Check if a field is serial or not
                      if(current_column.is_serial == false)
                      {
                          creation_type_request.fields[ field_index ].name = current_column.name;
                          creation_type_request.fields[ field_index ].native_type << current_column.value_type;
                          if( current_column.has_default_value || current_column.is_nullable ) {
                                  creation_type_request.fields[ field_index ].is_optional = true
                          } else {
                                  creation_type_request.fields[ field_index ].is_optional = false
                          };
                          field_index++
                      }
                    }
              };
              // Invokation of the service createType for the create operation
              createType@MySelf( creation_type_request )( creation_type_response );
              response.interface += creation_type_response + "\n\n";
              creation_type_request_response.type_name = create_operation_name_response;
              creation_type_request_response.root_native_type.isvoid = true;
              // response type is void
              createType@MySelf( creation_type_request_response )( creation_type_response );
              response.interface += creation_type_response + "\n\n";

              /*
               Creation of the update operation
              */
              update_type_request.type_name = update_operation_name_request;
              update_type_request.root_native_type.isvoid = true;
              field_index = 0;
              //Check if there are some serial fields
              for( x = 0, x < #request.table.table_columns, x++ ) {
                    current_column -> request.table.table_columns[x];
                    if ( !current_column.is_identity ) {
                      if(current_column.is_serial == false){
                        update_type_request.fields[ field_index ].name = request.table.table_columns[x].name;
                        update_type_request.fields[ field_index ].native_type << request.table.table_columns[x].value_type;
                        update_type_request.fields[ field_index ].is_optional = true;
                        field_index++
                      }
                    }
              };
              // The update operation has the filter for where clause
              update_type_request.fields[ field_index ].name = "filter*";
              update_type_request.fields[ field_index ].native_type.is_filter_type = true;
              update_type_request.fields[ field_index ].is_optional = false;
              // Creation of type for update operation
              createType@MySelf( update_type_request )( update_type_response );
              response.interface += update_type_response + "\n\n";
              update_type_request_response.type_name = update_operation_name_response;
              update_type_request_response.root_native_type.isvoid = true;
              createType@MySelf( update_type_request_response )( update_type_response );
              response.interface += update_type_response + "\n\n";

              /*
                Creation of remove operation
              */
              remove_type_request.type_name = remove_operation_name_request;
              remove_type_request.root_native_type.isvoid = true;
              field_index = 0;
              // The field 'filter' is added to remove operation
              remove_type_request.fields[ 0 ].name = "filter*";
              remove_type_request.fields[ 0 ].native_type.is_filter_type = true;
              remove_type_request.fields[ 0 ].is_optional = false;
              // The service createType is launched to create the type for remove operation
              createType@MySelf( remove_type_request )( remove_type_response );
              response.interface += remove_type_response + "\n\n";
              remove_type_request_response.type_name = remove_operation_name_response;
              remove_type_request_response.root_native_type.isvoid = true;
              createType@MySelf( remove_type_request_response )( remove_type_response );
              response.interface += remove_type_response + "\n\n";

              /*
                Creation of the implementation server side of ddtabase operation
              */
              operation_name = create_operation_name;
              _operation_init;
              response.behaviour += "\n";
              _offset = "\t\t\t";
              undef( optional_fields );
              undef( not_optional_fields );
              // Setting of the variable optional_fields and not_optional_fields with the fields corresponding
              for( x = 0, x < #request.table.table_columns, x++ ) {
                    current_column -> request.table.table_columns[x];
                    if( !current_column.is_identity ) {
                          if( current_column.has_default_value || current_column.is_nullable  ) {
                                  optional_fields[ #optional_fields ] = current_column.name
                          } else {
                                  not_optional_fields[ #not_optional_fields ] = current_column.name
                          }
                    }
              }
              ;
              // Prepare check for optional values
              response.behaviour += _offset + "optional_fields=\"\";value_fields=\"\";at_least_one_optional_field=false;\n";
              for( o = 0, o < #optional_fields, o++ ) {
                      response.behaviour += _offset + "if ( is_defined( request." + optional_fields[ o ] + " ) ) {\n";
                      response.behaviour += _offset + "if ( at_least_one_optional_field ) { optional_fields += \",\";value_fields += \",\" };\n";
                      response.behaviour += _offset + "\toptional_fields += \"" + "\\\"" + optional_fields[ o ] + "\\\"" +"\";\n";
                      response.behaviour += _offset + "\tvalue_fields += \":" + optional_fields[ o ] + "\";\n";
                      response.behaviour += _offset + "\tat_least_one_optional_field=true\n";
                      response.behaviour += _offset + "};\n"
              };

              /*
                Setting of the insert query with the value of the table
              */

              response.behaviour += _offset +
              "if(optional_fields != \"\"){
                q = \"INSERT INTO \\\"" + request.table.table_name + "\\\" ( \" + optional_fields  + \" ";
              if ( #not_optional_fields > 0 ) { response.behaviour += "," };
              column = "";
              values = "";
              col_index = 0; // used for inserting commas correctly
              for( x = 0, x < #not_optional_fields, x++ ) {

                    column += "\\\"" + not_optional_fields[x] + "\\\"";
                    values += ":" + not_optional_fields[ x ];
                    col_index++;

                    if ( col_index > 0 && x < ( #not_optional_fields - 1 ) ) {
                          column += ", ";
                          values += ", "
                    }
              };
              response.behaviour += column + " ) VALUES ( \" + value_fields + \"";
              if ( #not_optional_fields > 0 ) { response.behaviour += "," };
              response.behaviour += values + " )\"\n";
              response.behaviour +=
              "} else {
                q = \"INSERT INTO \\\"" + request.table.table_name + "\\\" ( " + column + " ) VALUES ( " + values + " )\"
                };\n";
              for( x = 0, x < #request.table.table_columns, x++ ) {
                   current_column -> request.table.table_columns[x];
                   if ( !current_column.is_identity ) {
                          response.behaviour += _offset + "q." + current_column.name + " = request." + current_column.name + ";\n"
                   }
              };
              response.behaviour += _offset + "update@Database( q )( result )";
              _operation_end
              ;

              /*
                Implementation server side of update operation
              */
              operation_name = update_operation_name;
              _operation_init;
              response.behaviour += "\n";
              _offset = "\t\t\t";
              response.behaviour += _offset + "__where;\n";
              undef( optional_fields );
              undef( not_optional_fields );
              for( x = 0, x < #request.table.table_columns, x++ ) {
                    current_column -> request.table.table_columns[x];
                    if( !current_column.is_identity ) {
                          optional_fields[ #optional_fields ] = current_column.name
                    }
              }
              ;
              // prepare check for optional values
              response.behaviour += _offset + "optional_fields=\"\";at_least_one_optional_field=false;\n";
              for( o = 0, o < #optional_fields, o++ ) {
                      response.behaviour += _offset + "if ( is_defined( request." + optional_fields[ o ] + " ) ) {\n";
                      response.behaviour += _offset + "if ( at_least_one_optional_field ) { optional_fields += \",\" };\n";
                      response.behaviour += _offset + "\toptional_fields += \"\\\"" + optional_fields[ o ] + "\\\"=:" + optional_fields[ o ] + "\";\n";
                      response.behaviour += _offset + "\tat_least_one_optional_field=true\n";
                      response.behaviour += _offset + "};\n"
              };

              response.behaviour += _offset + "q = \"UPDATE \\\"" + request.table.table_name + "\\\" SET \" + optional_fields + \"";
              response.behaviour += "\" + where;\n";

              for( x = 0, x < #request.table.table_columns, x++ ) {
                    response.behaviour += _offset + "q." + request.table.table_columns[x].name
                            + " = request." + request.table.table_columns[x].name + ";\n"
              };
              response.behaviour += _offset + "update@Database( q )( result )\n";
              _operation_end;

              // generate remove operation
              operation_name = remove_operation_name;
              _operation_init;
              response.behaviour += "\n";
              _offset = "\t\t\t";
              response.behaviour += _offset + "__where;\n";
              for( x = 0, x < #request.table.table_columns, x++ ) {
                    if ( is_defined( request.table.table_columns[x].is_primary_key ) ) {
                      primary_key = request.table.table_columns[x].name
                    }
              };
              response.behaviour += _offset + "q = \"DELETE FROM \\\"" + request.table.table_name + "\\\"\" + where;\n";
              response.behaviour += _offset + "update@Database( q )( result )\n";
              _operation_end
        };

        /*
          Creation and implementation of select operation of table
        */

        if ( is_defined( request.table.get_operation_name ) ) {
              get_operation_name = request.table.get_operation_name
        } else {
              get_operation_name =  "get" + request.table.table_name
        };
        get_operation_name_request = get_operation_name + "Request";
        get_operation_name_response = get_operation_name + "Response";

        // creation of get type
        undef( get_type_request );
        get_type_request.type_name = get_operation_name + "Request";
        get_type_request.root_native_type.isvoid = true;
        get_type_request.fields[ 0 ].name = "filter*";
        get_type_request.fields[ 0 ].native_type.is_filter_type = true;
        get_type_request.fields[ 0 ].is_optional = false;
        createType@MySelf( get_type_request )( get_type_response );
        response.interface += get_type_response + "\n\n";
        get_type_request_response.type_name = get_operation_name + "RowType";
        get_type_request_response.root_native_type.isvoid = true;
        field_index = 0;
        for( x = 0, x < #request.table.table_columns, x++ ) {
              current_column -> request.table.table_columns[x];
              get_type_request_response.fields[ field_index ].name = current_column.name;
              get_type_request_response.fields[ field_index ].native_type << current_column.value_type;
              get_type_request_response.fields[ field_index ].is_optional = false;
              field_index++
        };
        createType@MySelf( get_type_request_response )( get_type_response );
        response.interface += get_type_response + "\n\n";

        // Generation of type response of get operation
        undef( get_type_request_response );
        get_type_request_response.type_name = get_operation_name_response;
        get_type_request_response.root_native_type.isvoid = true;
        get_type_request_response.fields[ 0 ].name = "row*";
        get_type_request_response.fields[ 0 ].native_type.is_custom_type = get_operation_name + "RowType";
        get_type_request_response.fields[ 0 ].is_optional = false;
        createType@MySelf( get_type_request_response )( get_type_response );
        response.interface += get_type_response + "\n\n";

        // Creation of table interface
        response.interface += "interface " + request.table.table_name + "Interface {\n" ;
        response.interface += "\tRequestResponse:\n";

        if ( !request.table.is_view ) {
          	  operation_name = create_operation_name;
          	  operation_name_request_type = create_operation_name_request;
          	  operation_name_response_type = create_operation_name_response;

              response.interface += "\t\t" + operation_name + "( "
                 + operation_name_request_type + " )( "
                 + operation_name_response_type + " ) throws SQLException SQLServerException,\n";

              operation_name = update_operation_name;
              operation_name_request_type = update_operation_name_request;
              operation_name_response_type = update_operation_name_response;

              response.interface += "\t\t" + operation_name + "( "
                 + operation_name_request_type + " )( "
                 + operation_name_response_type + " ) throws SQLException SQLServerException,\n";

              operation_name = remove_operation_name;
              operation_name_request_type = remove_operation_name_request;
              operation_name_response_type = remove_operation_name_response;

              response.interface += "\t\t" + operation_name + "( "
                 + operation_name_request_type + " )( "
                 + operation_name_response_type + " ) throws SQLException SQLServerException,\n"

        };
      	operation_name = get_operation_name;
      	operation_name_request_type = get_operation_name_request;
      	operation_name_response_type = get_operation_name_response;

        response.interface += "\t\t" + operation_name + "( "
                 + operation_name_request_type + " )( "
                 + operation_name_response_type + " ) throws SQLException SQLServerException";

        response.interface += "\n";

        response.interface += "}\n";

        // Implementation server side of get operation
        operation_name = get_operation_name;
        _operation_init;
        response.behaviour += "\n";
        _offset = "\t\t\t";
        response.behaviour += _offset + "__where;\n";
        response.behaviour += _offset + "q = \"SELECT ";
        column = "";
        values = "";
        col_index = 0; // used for inserting commas correctly
        for( x = 0, x < #request.table.table_columns, x++ ) {
            	column +="\\\"" + request.table.table_columns[x].name + "\\\"";
            	col_index++;
            	if ( col_index > 0 && x < ( #request.table.table_columns - 1 ) ) {
                	  column += ", "
      	      }
        };
        response.behaviour += column + " FROM \\\"" + request.table.table_name + "\\\"\" + where;\n";
        response.behaviour += _offset + "query@Database( q )( response )\n";
        _operation_end
  }] { nullProcess }

  /*
    This service create type for each operation is launched on createService4Table
  */
  [ createType( request )( response ) {

        response = "type " + request.type_name + ":";
        get_native_type_request.native_type -> request.root_native_type;
        getNativeType@MySelf( get_native_type_request )( root_native_type );
        response += root_native_type;
        //This service check the fields of table and create the type
        if ( #request.fields > 0 ) {
              response += " {\n";
              for( x = 0, x < #request.fields, x++ ) {
                    response += "\t." + request.fields[x].name;
                    if ( request.fields[ x ].is_optional ) {
                      response += "?"
                    };
                    response += ":";
                    // For each field the service get native check the type of the field is passed in input
                    get_native_type_request.native_type -> request.fields[x].native_type;
                    getNativeType@MySelf( get_native_type_request )( native_type );
                    response += native_type + "\n"
              };
              response += "}"
        }
  }] { nullProcess }

  // This service check the bative type of the fields table
  [ getNativeType( request )( response ) {
        if ( is_defined( request.native_type.isstring ) ) {
          response = "string"
        } else if ( is_defined( request.native_type.isint ) ) {
          response = "int"
        } else if ( is_defined( request.native_type.isdouble ) ) {
          response = "double"
        } else if ( is_defined( request.native_type.isvoid ) ) {
          response = "void"
        } else if ( is_defined( request.native_type.islong ) ) {
          response = "long"
        } else if ( is_defined( request.native_type.is_filter_type ) ) {
          response = "FilterType"
        } else if ( is_defined( request.native_type.isbool ) ) {
          response = "bool"
        } else if ( is_defined( request.native_type.is_custom_type ) ) {
          response = request.native_type.is_custom_type
        }
  }] { nullProcess }
}
