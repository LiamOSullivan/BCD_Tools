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
import java.util.Locale;

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
    println("Start file parsing... could be a while!");
    for (int i=0; i<directoryFiles.length; i+=1) {
      loadJSONData(directoryFiles[i]);
      Path p = Paths.get(directoryFiles[i].toString());
      String filename = p.getFileName().toString();
      println("filename: "+filename);
      verifyFilenameTimestamp(filename);  //check filename timestamp against dates
    }
    println("Finished file parsing.");
  } else {
    println("No files to parse in directory");
  }
  //***TODO: write to SQL DB

  exit();
}


//loadFileList method
//load all .php files from a directory
//extract site id from file name
//extract timestamp from filename
File[] loadFileList(String sp_) {
  println("Looking in "+searchPath);
  File dir = new File(sp_);
  File[] dirList = dir.listFiles();
  if (dirList != null) {
    println("dirList length is: "+ dirList.length);

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
  println("Load JSON from: "+f_);
  json = loadJSONObject(f_);
  //println(json); 

  //************************
  //Environmental Sound Data
  //************************
  //Get 'entries' key
  int entries = -1;
  if (!json.isNull("entries")) {
    entries = json.getInt("entries");
    println("Entries: "+entries);
  } else {
    println("'Entries' key was not found");
  }

  //Get Arrays by keys
  dates = getJSONArrayInFile("dates", json);
  times = getJSONArrayInFile("times", json);
  levels = getJSONArrayInFile("aleq", json);

  //TODO:Verify entries = #dates = #times = #levels
  println("Entries = "+entries+"\tJSON Array lengths: "+ dates.size()+"\t"+ times.size()+"\t"+ levels.size());
  println("JSON data loaded");
}

JSONArray getJSONArrayInFile(String s_, JSONObject j_) {
  JSONArray jsonArray = new JSONArray();
  if (!j_.isNull(s_)) {
    jsonArray = j_.getJSONArray(s_);
  } else {
    println("Key "+s_+" not found in file");
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
  print("Filename (no ext): "+base);
  println("\t# characters: "+base.length());
  String epochString = null;

  //TODO: make this more robust e.g. for all possible site-ids dates combos
  if (base.length()==15) {
    epochString = base.substring(5, 15); //will assume e.g. site#**********
  } else if (base.length()==16) {
    epochString = base.substring(6, 16); //will assume e.g. site##**********
  }
  print("Unix epoch: "+epochString);
  //Unix epoch time stamp range: 
  //999999999 (9 digits) = Sunday, September 9, 2001 1:46:39 AM
  //9999999999 (10 digits) = Saturday, November 20, 2286 5:46:39 PM
  //2000000000 (10) = Wednesday, May 18, 2033 3:33:20 AM
  long epochLong = Long.parseLong(epochString);
  Date date = new Date(epochLong * 1000L);
  SimpleDateFormat format = new SimpleDateFormat("dd/MM/yyyy");
  println("\tHuman readable: "+format.format(date));
  String firstDate = dates.getString(0);
  String lastDate = dates.getString(dates.size()-1);
  print("First date in JSON data: "+firstDate);
  println("\tlast date in JSON data: "+lastDate);
  if (firstDate.equals(lastDate) && lastDate.equals(format)) {  
    return true;
  } else {
    return false;
  }
}


/* Java 8 directory lookup code */
//
//long count = -1; //# files in dir
//try {
//  println("Files: "+ Files.list(Paths.get(sp_)));
//  count = Files.list(Paths.get(sp_)).count();
//  println("# files in directory is "+ count);
//}
//catch(IOException e) {
//  println("IOE counting files");
//}