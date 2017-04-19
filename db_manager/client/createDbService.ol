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
include "ini_utils.iol"
include "runtime.iol"
include "console.iol"
include "database.iol"
include "string_utils.iol"
include "file.iol"

outputPort Test {
Location: TableGeneratorLocation
Protocol: sodep
Interfaces: TableGeneratorInterface
}

main {
  install( ConnectionError=>
		println@Console( "Insert data are wrong!" )();
    println@Console( main.ConnectionError )()
	);

  parseIniFile@IniUtils( "../config.ini" )( config );

  with( request ) {
    .host = config.db_connection.HOST;
    .driver = config.db_connection.DRIVER;
    .port = int(config.db_connection.PORT);
    .database = config.db_connection.DATABASE;
    .table_schema = "public";
    .username = config.db_connection.USERNAME;
    .password = config.db_connection.PASSWORD
  };
  createDbService@Test( request )( response )
}
