//loadFileList method
//load all .php files from a directory string
File[] loadFileList(String sp_) {
  debugPrintln("Looking in "+sp_);
  File dir = new File(sp_);
  //File[] dirList = dir.listFiles(".php");

  File [] dirList = dir.listFiles(new FilenameFilter() {
    @Override
      public boolean accept(File dir, String name) {
      return name.endsWith(".php");
    }
  }
  );

  if (dirList != null) {
    debugPrintln("dirList length is: "+ dirList.length);
    return dirList;
  } else {
    dirList = new File[1];
    //dirList[0] = new File("Directory_File_List_Null"); //***TODO: Test this.
    return dirList;
  }
}

boolean loadJSONData(File f_) {
  // Load JSON file
  //***TODO: check for empty file, Null values.
  //***TODO: validate timestamp against dates, times
  //debugPrintln("Loading JSON from: "+f_);

  double bytes = f_.length();
  if (bytes>0) {
    //double kilobytes = (bytes / 1024);
    json = loadJSONObject(f_);
  } else {
    //debugPrintln("Invalid JSON, skipping");
    return false;
  }
  //debugPrintln(json); 

  //************************
  //Environmental Sound Data
  //************************
  //Get 'entries' key
  entries = -1;
  if (!json.isNull("entries")) {
    entries = json.getInt("entries");
    //debugPrintln("Entries: "+entries);
  } else {
    //debugPrintln("'Entries' key was not found");
  }

  //Get Arrays by keys
  dates = getJSONArrayInFile("dates", json);
  times = getJSONArrayInFile("times", json);
  levels = getJSONArrayInFile("aleq", json);

  //TODO:Verify entries = #dates = #times = #levels
  //debugPrintln("Entries = "+entries+"\tJSON Array lengths: "+ dates.size()+"\t"+ times.size()+"\t"+ levels.size());
  if (entries == dates.size() && entries == times.size() && entries == levels.size()) {
    //debugPrintln("JSON data entries count verified");
  }
  //debugPrintln("JSON data loaded");
  return true;
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

//extract site id from file name string
int getFilenameSiteId(String f_) {
  String base = FilenameUtils.getBaseName(f_);
  String idString = "-1";
  if (base.length()==15) {
    idString = base.substring(4, 5); //will assume e.g. site#**********
  } else if (base.length()==16) {
    idString = base.substring(4, 6); //will assume e.g. site##**********
  }
  //println("substring: "+idString);
  int idInt = int(idString);
  return idInt;
}

//extract timestamp from filename string
long getFilenameTimestamp(String f_) {
  //filenames contain "site" follow by a site_id (1 or 2 chars, 1 to 14) followed by UNIX timestamp 
  //10 digits for period  
  //**********The timestamp may not align with the last, or any, reading in the JSON data**********

  //String [] parsed = {"-1", "-1", "-1"}; 
  //if ((f_.endsWith(".php")) || (f_.endsWith(".PHP")) ) {
  //  //what to do?
  //} else if ((f_.endsWith(".json")) || (f_.endsWith(".JSON")) ) {
  ////what to do?
  //}

  String base = FilenameUtils.getBaseName(f_);
  //debugPrint("Filename (no ext): "+base);
  //debugPrintln("\t# characters: "+base.length());
  String epochString = null;

  //TODO: make this more robust e.g. for all possible site-ids, dates combos
  if (base.length()==15) {
    epochString = base.substring(5, 15); //will assume e.g. site#**********
  } else if (base.length()==16) {
    epochString = base.substring(6, 16); //will assume e.g. site##**********
  }
  //debugPrint("Unix epoch: "+epochString+"\t");
  //Unix epoch time stamp range: 
  //999999999 (9 digits) = Sunday, September 9, 2001 1:46:39 AM
  //9999999999 (10 digits) = Saturday, November 20, 2286 5:46:39 PM
  //2000000000 (10) = Wednesday, May 18, 2033 3:33:20 AM
  long epochLong = Long.parseLong(epochString);
  return epochLong;
}

String getDateStringFromTimestamp(long ts_, SimpleDateFormat f_) {
  Date d = new Date(ts_ * 1000L);
  String dateStr = f_.format(d);
  return dateStr;
}

//Check that the readings occur on same date,
//(by comparing first and last dates in JSON)
//and that this matches the date in the timestamp
//used as the filename
//Must also check if the file was written to in the
//day after- this happens close to midnight

boolean verifyJSONDates(JSONArray dates_, String ds_) {
  if (dates_.size()>0) {
    String startDateString = dates_.getString(0);
    String endDateString = dates_.getString(dates_.size()-1);
    if (startDateString.equals(endDateString) && startDateString.equals(ds_)) {
      //debugPrintln("The date strings all DO match!");
      return true;
    } else {
      DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
      LocalDate ds_Minus1 = LocalDate.parse(ds_, formatter);
      ds_Minus1=ds_Minus1.minusDays(1);
      String ds_MinusString= ds_Minus1.format(formatter);
      if (startDateString.equals(endDateString)&& startDateString.equals(ds_MinusString)) {
        //debugPrintln("The JSON date strings match and the timestamp is the following day!");
        return true;
      } else {
        //debugPrintln("Start date string in JSON data: "+startDateString);
        //debugPrintln("End date string in JSON data: "+endDateString);
        //debugPrintln("Timestamp date string in filename: "+ds_);
        //debugPrintln("The date strings DON'T all match!");
        return false;
      }
    }
  }
  return false;
}


//LocalDate startDate, endDate;
//LocalDate endDateMinusOne;
//String parsedStartDateString, parsedEndDateString, parsedEndDateM1String;
//DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
//try {
//  startDate = LocalDate.parse(startDateString, formatter);
//  endDate = LocalDate.parse(endDateString, formatter);
//  endDateMinusOne = endDate.minusDays(1);
//  parsedStartDateString = startDate.format(formatter);
//  parsedEndDateString = endDate.format(formatter);
//  parsedEndDateM1String = endDateMinusOne.format(formatter);
//  debugPrintln("\t Start/end dates in JSON data: "+parsedStartDateString+" | "+parsedEndDateString);
//  if ((parsedStartDateString.equals(endDateString)&&parsedStartDateString.equals(ds_))
//  || (parsedStartDateString.equals(parsedEndDateM1String)&&parsedStartDateString.equals(ds_))) {
//    return true;
//  } else {
//    return false;
//  }
//} 
//catch (DateTimeException e) {
//  //e.debugPrintStackTrace();
//  debugPrintln("Error parsing date string from JSON data, and JSON data spans one day");
//}


//use timestamp in filename to look through JSON data and find associated reading
float getReadingForTimestamp(long ts_) {
  //***TODO;

  //use day/hour/minute only, as seconds don't match

  return -1;
}

//LocalTime getTimeFromTimeStamp(){
//  return new LocalTime(); 
//}

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