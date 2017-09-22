class mySQLTable
{
    int id;
    public String fieldOne;
    public int fieldTwo;
    
    public String toString ()
    {
        return String.format("id: %d, fieldOne: %s fieldTwo: %d", id, fieldOne, fieldTwo);
    }
    
    public void setId ( int id ) {
        this.id = id;
    }
    
    public int getId () {
        return id;
    }
}