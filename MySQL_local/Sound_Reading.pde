class SoundReading
{
  public int readId;
  public String dateTime;
  public float readLevel;
  public int siteId;

  SoundReading(int id_) {
    this.readId = id_;
    this.readLevel = random(150);
    this.siteId = int(random(0, 15));
  }

  public String toString ()
  {
    return String.format("id: %d, dateTime: %s, readLevel: %f, siteId: %d", 
      readId, dateTime, readLevel, siteId);
  }

  public void setReadId ( int id ) {
    this.readId = id;
  }

  public int getReadId () {
    return readId;
  }
}