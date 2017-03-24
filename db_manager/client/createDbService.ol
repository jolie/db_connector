include "../public/interfaces/TableGeneratorInterface.iol"
include "../config/config.iol"
include "runtime.iol"
include "console.iol"
include "ui/swing_ui.iol"

outputPort Test {
Location: TableGeneratorLocation
Protocol: sodep
Interfaces: TableGeneratorInterface
}

main {
  install( ConnectionError=>
		showMessageDialog@SwingUI( "I dati inseriti sono errati!" )();
    println@Console( main.ConnectionError )()
	);

  with( request ) {
    .host = "localhost";
    .driver = "postgresql";
    .port = 5432;
    .database = "store";
    .table_schema = "public";
    .username = "postgres";
    .password = "postgres"
  };
  createDbService@Test( request )( response )
}
