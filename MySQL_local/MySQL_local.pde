/**
 *    MySQL local
 *
 *    Based on https://github.com/fjenett/sql-library-processing
 */

import de.bezier.data.sql.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.text.DateFormat;
import java.net.SocketException;
import java.sql.Timestamp;
MySQL db;

//boolean FORCE_APPEND = true; //starts inserting after current highest index found in DB

void setup()
{
  size( 100, 100 );
  // mysql login:
  String user     = "root";
  String pass     = "qlDh6KXnANo938ju";

  // name of the database to use
  //String database = "test_mysql";
  String database = "soundmonitoringdb";
  // add additional parameters like this:
  // sql_library_test_db?useUnicode=true&characterEncoding=UTF-8

  // connect to database of server "localhost"
  db = new MySQL( this, "localhost", database, user, pass );
  if ( db.connect() )
  {
    println( "Successful Connection to DB!" );
    printDBInfo(db);
    long start = millis();
    insertFilesIntoTable(db, "sound_monitoring_readings", true);
    long delta = millis()-start;
    println("Elapsed time for database update "+delta);

    ////Alternatives... getting quirky results
    ////insert rows
    ////db.insertUpdateInDatabase(java.lang.String tableName, java.lang.String[] columnNames, java.lang.Object[] values) 
    ////  Insert or update a bunch of values in the database.
    ////while (db.next())
    ////{
    ////  mySQLTable t = new mySQLTable();
    ////  db.setFromRow( t ); //tries to map column names to public fields or setter methods in the given object.
    ////  println( t );
    ////}
  } else
  {
    println( "Connection to DB failed" );
  }
  db.close();
  exit();
}

void insertFilesIntoTable(MySQL db_, String tn_, boolean append_) {
  //query rows
  db_.query( "SELECT COUNT(*) FROM %s", tn_ );
  db_.next(); //Check if more results (rows) are available. This needs to be called before any results can be retrieved.
  int nRows = db_.getInt(1);
  println( "The table has " + nRows + " rows" ); //first (second?) int contains # rows?
  int offset = 0;
  if (append_) {
    offset = nRows;
  }
  for (int i=0; i<10; i+=1) {
    //SomeObject newData = new SomeObject(int(random(100)));
    SoundReading newData = new SoundReading(i);
    newData.setReadId(i+offset);
    db.saveToDatabase(tn_, newData); //update values in database.
    db.query( "SELECT * FROM %s", tn_); //required to reopen results set
  }
}


void printDBInfo(MySQL db_) {
  //query tables

  String[] tableNames = db_.getTableNames();
  String [] cols = {"null"};


  for (int i=0; i<tableNames.length; i+=1) {
    println( "-------------------");
    println( "Table #"+i+" is named " + tableNames[i] );

    //query rows
    db_.query( "SELECT COUNT(*) FROM %s", tableNames[i] );
    db_.next(); //Check if more results (rows) are available. This needs to be called before any results can be retrieved.
    println( "This table has " + db_.getInt(1) + " rows" ); //first (second?) int contains # rows?

    //query columns
    db_.query( "SELECT * FROM %s", tableNames[i] );
    String [] colNames = db_.getColumnNames(); //Returns an array with the column names of the last request.
    print("Column names: ");
    print(colNames);
    println();
    //for (int p=0; p<cols.length; p+=1) {
    //  println("Column name:"+cols[p]);
    //  //while (db.next())
    //  //{
    //  //  int n = db.getInt(cols[p]);  //search for column name (not case sensitive)
    //  //  String s = db.getString(cols[p]);
    //  //  println("int: "+n+"\tString: "+s);
    //  //}
    //}
  }
}