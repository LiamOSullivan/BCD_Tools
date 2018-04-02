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
import java.io.FilenameFilter;
import java.nio.file.Paths;
import java.nio.file.Path;
import java.io.File;
import org.apache.commons.io.FilenameUtils; //added to code folder
import java.text.SimpleDateFormat;
import java.util.Date;
import java.time.DateTimeException;
import java.time.format.DateTimeFormatter;
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
String fullPath = "E://NCG//DashboardPartialCopy//public_html//ambientSound1";
String searchPath = "C://Users//Liam//Downloads//ambientSound1"; 
JSONObject json;
JSONArray dates, times, levels; //Keys for Environmental Sound Monitoring 
int entries;
long timestampLong = -1; //timestampLong encoded in file name string

//Database access
String user     = "root";
String pass     = ""; //"qlDh6KXnANo938ju";
//String database = "test_mysql";
String database = "soundmonitoringdb";

void setup() {
  // connect to database of server "localhost"
  db = new MySQL( this, "localhost", database, user, pass );
  if ( db.connect() )
  {
    println( "Successful Connection to DB!" );
    printDBInfo(db);

    //searchPath = sketchPath()+addPath;
    //searchPath = emptyPath;
    //searchPath = fullPath;
    File[] directoryFiles = loadFileList(searchPath); //***TODO: only load .php or .json
    if (directoryFiles.length > 1) { //***TODO: hardcoded must be replaced
      debugPrintln("***Start file parsing of <"+directoryFiles.length+"> files... this could take a while!");
      long start = millis();
      for (int i=0; i<directoryFiles.length; i+=1) {
        //debugPrintln(".....................................");
        if (loadJSONData(directoryFiles[i])) { //loads arrays with data from JSON fields in file e.g. dates, times, levels

          //for each file in dir, get a String for the date contained in filename
          Path p = Paths.get(directoryFiles[i].toString());
          String filename = p.getFileName().toString();
          //debugPrint("filename: "+filename);

          int fid = getFilenameSiteId(filename);
          //debugPrintln("\tsite ID is: "+fid);

          timestampLong = getFilenameTimestamp(filename); //get the long int for the timestampLong
          SimpleDateFormat fd = new SimpleDateFormat("dd/MM/yyyy");
          String dateString = getDateStringFromTimestamp(timestampLong, fd); //format as date string
          SimpleDateFormat ft = new SimpleDateFormat("HH:mm");
          //String timeString = getDateStringFromTimestamp(timestampLong, ft); //format as time string
          //debugPrintln("Date String: "+dateString+"\tTime String: "+timeString);

          //check filename timestampLong string against dates in JSON
          if (verifyJSONDates(dates, dateString)) {
            
            
            /*TODO...******************************/
            //Build an array of readings for each date. Only send to DB if not a duplicate-
            //will require storage of dates prevously processed
            /**************************************/
            
            //debugPrintln("Filename timestampLong matches dates in JSON data");
            //We'd expect 288 readings per day, but in actuality we get less. 
            //Tweak this lower if there are holes in the database
            if (entries>=250) { 
              //insertFilesIntoTable(db, "sound_monitoring_readings", true); // database, table, toggle append
              debugPrintln("----> Found file at end of day <----"); 
              debugPrintln("----> "+filename+" <----");
            }
          } else {
            debugPrintln("Filename timestamp does not match dates in JSON data, SKIPPING");
            debugPrintln("******Skip file: "+filename+" ******");
          }

          //

          long delta = millis()-start;
          //debugPrintln("Elapsed time for database update "+delta);
        }
      }//////////////////////////////////////////////////////////////////////////////////End for-loop
      debugPrintln(".....................................");
      debugPrintln("***Finished file parsing.");
    } else {
      debugPrintln(".....................................");
      debugPrintln("***No files to parse in directory");
    }

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
    debugPrintln( "Connection to DB failed" );
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