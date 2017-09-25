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

void insertFilesIntoTable(MySQL db_, String tn_, boolean append_) {
  //TODO: check for existing entry for timestamp, verify match for reading and skip if appropriate


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