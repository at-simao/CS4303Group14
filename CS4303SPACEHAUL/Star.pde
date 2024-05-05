class Star {
  PVector position;
  float radius = 1.5;
  
  Star(PVector position, float radius){
    this.position = position;
    //this.radius = radius;
  }
  
  public void draw(){
    CS4303SPACEHAUL.offScreenBuffer.fill(255);
    CS4303SPACEHAUL.offScreenBuffer.circle(position.x, position.y, radius);
  }
  
  public PVector getPosition(){
    return position;
  }
  
  public float getRadius(){
    return radius;
  }
}
