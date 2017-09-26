/* Environmental Data: JSON To Database
 
 Script to parse the individual JSON files from the Environmental Data on the Dublin Dashboard site 
 and enter data into a (mySQL) database */

/**************************
 Environmental Sound Data
 ***
 Database:soundmonitoringdb
 
 Table: sound_monitoring_readings
 Columns:
 read_id INT
 date_time DATETIME
 read_level FLOAT
 site_id INT
 
 Table: sound_monitoring_sites
 tbc
 ***************************/

/*
 ***TODO: ignore files of size 0KB with no entries and/or JSON markup
 
 */


import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.Path;
import java.io.File;
import org.apache.commons.io.FilenameUtils; //added to code folder
import java.text.SimpleDateFormat;
import java.util.Date;
import java.text.DateFormat;
import java.time.LocalTime;
import java.time.LocalDate;
import java.util.Locale;
import java.text.ParseException;
import de.bezier.data.sql.*;
import java.sql.Timestamp;

MySQL db;
boolean debugPrintDebug = true; //toggle debug print messages to console

//JSON files
String emptyPath = "//data//empty//";
String addPath = "//data//ambientSound14//";
String fullPath = "C://Users//Liam//Google Drive//NCG//Tasks//System Architecture//Code//DashboardPartialCopy//public_html//ambientSound1";
String searchPath; 
JSONObject json;
JSONArray dates, times, levels; //Keys for Environmental Sound Monitoring 

//Database access
String user     = "root";
String pass     = "qlDh6KXnANo938ju";
//String database = "test_mysql";
String database = "soundmonitoringdb";

void setup() {
  searchPath = sketchPath()+addPath;
  //searchPath = emptyPath;
  File[] directoryFiles = loadFileList(searchPath); //***TODO: only load .php or .json
  if (directoryFiles.length > 1) { //***TODO: hardcoded must be replaced
    debugPrintln("Start file parsing... could be a while!");
    for (int i=0; i<directoryFiles.length; i+=1) {
      debugPrintln(".....................................");
      loadJSONData(directoryFiles[i]); //loads arrays with data from JSON fields in file e.g. dates, times, levels

      //for each file in dir, get a String for the date contained in filename
      Path p = Paths.get(directoryFiles[i].toString());
      String filename = p.getFileName().toString();
      debugPrint("filename: "+filename);

      int fid = getFilenameSiteId(filename);
      debugPrintln("\tsite ID is: "+fid);

      long epoch = getFilenameTimestamp(filename); //get the long int for the timestamp
      SimpleDateFormat f = new SimpleDateFormat("dd/MM/yyyy");
      String dateString = getDateStringFromTimestamp(epoch, f); //format as date string
      debugPrintln("\tgetDateStringFromTimestamp: "+dateString);
      
      //check filename timestamp string against dates in JSON
      if (verifyJSONDates(dates, dateString)) {
        debugPrintln("Filename timestamp matches dates in JSON data");
      } else {
        debugPrintln("Filename timestamp does not match dates in JSON data, exiting");
        debugPrintln("******Exit at file: "+filename+"******");
        exit();
      }
    }
    debugPrintln(".....................................");
    debugPrintln("Finished file parsing.");
  } else {
    debugPrintln(".....................................");
    debugPrintln("No files to parse in directory");
  }

  // connect to database of server "localhost"
  db = new MySQL( this, "localhost", database, user, pass );
  if ( db.connect() )
  {
    println( "Successful Connection to DB!" );
    printDBInfo(db);
    long start = millis();
    insertFilesIntoTable(db, "sound_monitoring_readings", true); // database, table, toggle append
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

//***TODO: write to log file on error
void debugPrint(String s_) {
  if (debugPrintDebug) {
    print(s_);
  }
}
void debugPrintln(String s_) {
  if (debugPrintDebug) {
    println(s_);
  }
}