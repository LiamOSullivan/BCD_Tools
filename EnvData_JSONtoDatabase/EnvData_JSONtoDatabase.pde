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
 ***TODO: ignore files of szie 0KB with no entries and/or JSON markup
 
 */


import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.Path;
import java.io.File;
import org.apache.commons.io.FilenameUtils; //added to code folder
import java.text.SimpleDateFormat;
import java.util.Date;
import java.text.DateFormat;
import java.util.Locale;
import java.text.ParseException;

boolean debugPrintDebug = true; //toggle debug print messages to console

String emptyPath = "//data//empty//";
String addPath = "//data//ambientSound14//";
String fullPath = "C://Users//Liam//Google Drive//NCG//Tasks//System Architecture//Code//DashboardPartialCopy//public_html//ambientSound1";
String searchPath; 

JSONObject json;
JSONArray dates, times, levels; //Keys for Environmental Sound Monitoring 

void setup() {
  searchPath = sketchPath()+addPath;
  //searchPath = emptyPath;
  File[] directoryFiles = loadFileList(searchPath); //***TODO: only load .php or .json
  if (directoryFiles.length > 1) {
    debugPrintln("Start file parsing... could be a while!");
    for (int i=0; i<directoryFiles.length; i+=1) {
      loadJSONData(directoryFiles[i]);
      Path p = Paths.get(directoryFiles[i].toString());
      String filename = p.getFileName().toString();
      debugPrintln("filename: "+filename);
      //check filename timestamp against dates
      if (verifyFilenameTimestamp(filename)) {
        debugPrintln("Filename timestamp matches dates in JSON data");
      } else {
        debugPrintln("Filename timestamp does not match dates in JSON data, exiting");
        exit();
      }
    }
    debugPrintln("Finished file parsing.");
  } else {
    debugPrintln("No files to parse in directory");
  }
  //***TODO: write to SQL DB

  exit();
}


//loadFileList method
//load all .php files from a directory
//extract site id from file name
//extract timestamp from filename
File[] loadFileList(String sp_) {
  debugPrintln("Looking in "+searchPath);
  File dir = new File(sp_);
  File[] dirList = dir.listFiles();
  if (dirList != null) {
    debugPrintln("dirList length is: "+ dirList.length);

    return dirList;
  } else {
    dirList = new File[1];
    //dirList[0] = new File("Directory_File_List_Null"); //***TODO: Test this.
    return dirList;
  }
}

void loadJSONData(File f_) {
  // Load JSON file
  //***TODO: check for empty file, Null values.
  //***TODO: validate timestamp against dates, times
  debugPrintln("Load JSON from: "+f_);
  json = loadJSONObject(f_);
  //debugPrintln(json); 

  //************************
  //Environmental Sound Data
  //************************
  //Get 'entries' key
  int entries = -1;
  if (!json.isNull("entries")) {
    entries = json.getInt("entries");
    debugPrintln("Entries: "+entries);
  } else {
    debugPrintln("'Entries' key was not found");
  }

  //Get Arrays by keys
  dates = getJSONArrayInFile("dates", json);
  times = getJSONArrayInFile("times", json);
  levels = getJSONArrayInFile("aleq", json);

  //TODO:Verify entries = #dates = #times = #levels
  debugPrintln("Entries = "+entries+"\tJSON Array lengths: "+ dates.size()+"\t"+ times.size()+"\t"+ levels.size());
  if (entries == dates.size() && entries == times.size() && entries == levels.size()) {
    debugPrintln("JSON data entries count verified");
  }
  debugPrintln("JSON data loaded");
}

JSONArray getJSONArrayInFile(String s_, JSONObject j_) {
  JSONArray jsonArray = new JSONArray();
  if (!j_.isNull(s_)) {
    jsonArray = j_.getJSONArray(s_);
  } else {
    debugPrintln("Key "+s_+" not found in file");
  }
  return jsonArray;
}

boolean verifyFilenameTimestamp(String f_) {
  //filenames contain "site" follow by a site_id (1 or 2 chars, 1 to 14) followed by UNIX timestamp 10 digits for period

  //String [] parsed = {"-1", "-1", "-1"}; 
  //if ((f_.endsWith(".php")) || (f_.endsWith(".PHP")) ) {
  //  //what to do?
  //} else if ((f_.endsWith(".json")) || (f_.endsWith(".JSON")) ) {
  ////what to do?
  //}

  String base = FilenameUtils.getBaseName(f_);
  debugPrint("Filename (no ext): "+base);
  debugPrintln("\t# characters: "+base.length());
  String epochString = null;

  //TODO: make this more robust e.g. for all possible site-ids, dates combos
  if (base.length()==15) {
    epochString = base.substring(5, 15); //will assume e.g. site#**********
  } else if (base.length()==16) {
    epochString = base.substring(6, 16); //will assume e.g. site##**********
  }
  debugPrint("Unix epoch: "+epochString);
  //Unix epoch time stamp range: 
  //999999999 (9 digits) = Sunday, September 9, 2001 1:46:39 AM
  //9999999999 (10 digits) = Saturday, November 20, 2286 5:46:39 PM
  //2000000000 (10) = Wednesday, May 18, 2033 3:33:20 AM
  long epochLong = Long.parseLong(epochString);
  Date date = new Date(epochLong * 1000L);
  SimpleDateFormat format = new SimpleDateFormat("dd/MM/yyyy");
  String dateString = format.format(date);
  debugPrintln("\tHuman readable: "+dateString);

  String startDateString = dates.getString(0);
  String endDateString = dates.getString(dates.size()-1);
  debugPrintln("Start date string in JSON data: "+startDateString);
  debugPrintln("End date string in JSON data: "+endDateString);
  Date startDate, endDate;
  String newDateString;
  try {
    startDate = format.parse(startDateString);
    endDate = format.parse(endDateString);
    newDateString = format.format(startDate);
    endDateString = format.format(endDate);
    debugPrintln("\t Start/end dates in JSON data: "+newDateString+" | "+endDateString);
    if (newDateString.equals(endDateString)&&newDateString.equals(dateString)) {
      return true;
    } else {
      return false;
    }
  } 
  catch (ParseException e) {
    //e.debugPrintStackTrace();
    debugPrintln("Error parsing date string from JSON data, and JSON data spans one day");
  }
  return false;
}


/* Java 8 directory lookup code */
//
//long count = -1; //# files in dir
//try {
//  debugPrintln("Files: "+ Files.list(Paths.get(sp_)));
//  count = Files.list(Paths.get(sp_)).count();
//  debugPrintln("# files in directory is "+ count);
//}
//catch(IOException e) {
//  debugPrintln("IOE counting files");
//}

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