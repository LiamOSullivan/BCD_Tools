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
String emptyPath = "//data//empty//";
String addPath = "//data//ambientSound1//";
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
      //String filename;
      
    }
    println("Finished file parsing.");
  } else {
    println("No files to parse in directory");
  }

  //check filename timestamp against dates
  //verifyDate();


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
  //bubbles = new Bubble[bubbleData.size()]; 
  //for (int i = 0; i < bubbleData.size(); i++) {
  //  // Get each object in the array
  //  JSONObject bubble = bubbleData.getJSONObject(i); 
  //  // Get a position object
  //  JSONObject position = bubble.getJSONObject("position");
  //  // Get x,y from position
  //  int x = position.getInt("x");
  //  int y = position.getInt("y");
  //  // Get diamter and label
  //  float diameter = bubble.getFloat("diameter");
  //  String label = bubble.getString("label");
  //  // Put object in array
  //  bubbles[i] = new Bubble(x, y, diameter, label);
  //}
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