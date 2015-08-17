include "db_connector_iface.iol"
include "ini_utils.iol"
include "console.iol"
include "string_utils.iol"

outputPort DBConnector {
Interfaces: DBConnectorIface
}

/*
Remember to set config.ini for defining db connection.
Put the following files into the lib folder:
- DB Driver jar file.
- db-connector.jar obtained after compiling the project
- c3p0-0.9.5.1.jar from lib folder in the root folder of the project
- mchange-commons-java-0.2.10.jar from lib folder in the root folder of the project
*/

embedded {
Java:
	"joliex.db.DBConnector" in DBConnector
}

main {
	if ( #args == 0 ) {
		println@Console("Usage: jolie test.ol table_name")()
	} else {
		parseIniFile@IniUtils( "config.ini" )( config );
    	connect@DBConnector( config.db_config )();
    	println@Console("connected with " + connectionInfo.host )();
		q = "SELECT * FROM " + args[0];
		query@DBConnector( q )( result );
		valueToPrettyString@StringUtils( result )( s );
		println@Console( s )()
	}
}
