class SoundReading
{
  /******
   Table: sound_monitoring_readings
   Columns:
   read_id INT
   time_stamp TIMESTAMP (seconds since epoch)
   read_level FLOAT
   site_id INT
   *********/
  //BezierSQL looks for fields with the following name pattern...
  public int readId;
  public Timestamp readTimestamp;
  public float readLevel;
  public int siteId;

  SoundReading(int id_) {
    this.readId = id_;
    long ts = 1494135001; //need to specify in millis from epoch so use long
    ts*=1000;
    this.readTimestamp = new Timestamp(ts);
    this.readLevel = random(150);
    this.siteId = int(random(1, 15));
  }

  public String toString ()
  {
    return String.format("id: %d, time_stamp: %s, read_level: %f, site_id: %d", 
      readId, readTimestamp, readLevel, siteId);
  }
  //naming using this pattern ensures BezierSQL can find the field if it isn't public
  public void setReadId ( int id ) {
    this.readId = id;
  }

  public int getReadId () {
    return readId;
  }
}