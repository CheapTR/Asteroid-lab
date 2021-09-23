class Text extends GraphicObject {
  int displayNumber=0;
  
  Text( float xloc, float yloc)
  {
    instanciate( xloc, yloc);
  }
  
  void instanciate( float xloc, float yloc)
  {
    location = new PVector(xloc, yloc);
  }
  
  void display(String text, int disp) {
    
        textSize(28);
    fill(0, 408, 612);
    text(text + disp, location.x/1.07, location.y+40);
  }
  
}
