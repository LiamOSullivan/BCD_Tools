/**
 *    MySQL local
 *
 *    Based on https://github.com/fjenett/sql-library-processing
 */

import de.bezier.data.sql.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.text.DateFormat;
MySQL db;

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

    //query tables
    String[] tableNames = db.getTableNames();
    String [] cols = {"null"};
    for (int i=0; i<tableNames.length; i+=1) {
      println( "Table #"+i+" is named " + tableNames[i] );

      //  //query rows
      db.query( "SELECT COUNT(*) FROM %s", tableNames[i] );
      db.next(); //Check if more results (rows) are available. This needs to be called before any results can be retrieved.
      println( "This table has " + db.getInt(1) + " rows" ); //first (second?) int contains # rows?

      //  //query columns
      db.query( "SELECT * FROM %s", tableNames[i] );
      cols = db.getColumnNames(); //Returns an array with the column names of the last request.
      for (int p=0; p<cols.length; p+=1) {
        println("Column name:"+cols[p]);
        while (db.next())
        {
          int n = db.getInt(cols[p]);  //search for column name (not case sensitive)
          String s = db.getString(cols[p]);
          println("int: "+n+"\tString: "+s);
        }
        println("--------");
      }
    }

    //SomeObject newData = new SomeObject (int(random(100)));
    db.query( "SELECT * FROM %s", tableNames[0] );
    println("SELECT * FROM "+tableNames[0]);
    cols = db.getColumnNames();
    print("Columns in table: " );
    print(cols);
    println();
    db.query( "SELECT * FROM %s", tableNames[0] );
    long start = millis();
    for (int i=0; i<10; i+=1) {
      //SomeObject newData = new SomeObject(int(random(100)));
      SoundReading newData = new SoundReading(i);
      newData.setReadId(i);
      db.saveToDatabase(tableNames[0], newData); //update values in database.
      db.query( "SELECT * FROM %s", tableNames[0] ); //required to reopen results set
    }
    //long delta = millis()-start;
    //println("Elapsed time for database update "+delta);
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


class SomeObject {
  public int id;
  public int randomNumber1;
  public int randomNumber2;

  SomeObject(int n_) {

    this.randomNumber1 = n_;
    this.randomNumber2 = 2*n_;
  }

  public void setId ( int id_ ) {
    this.id = id_;
  }

  public int getId () {
    return this.id;
  }
}