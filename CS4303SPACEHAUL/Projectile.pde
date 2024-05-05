class Projectile{
  PVector position;
  PVector velocity;
  float radiusX;
  float radiusY;
  float orientation;
  
  Timer timeToDespawn = new Timer(10000, null, 0);
  
  Projectile(PVector position, PVector velocity, float radiusX, float radiusY){
    this.position = position;
    this.velocity = velocity;
    this.radiusX = radiusX;
    this.radiusY = radiusY;
    orientation = atan2(velocity.x, velocity.y);
  }
  
  public void integrate(){
    //gravity of planets + sun - TODO
    
    //gravity of meteors - ??
    
    if(velocity.mag() != 0){ //if 0, no need to update orientation, keep facing same direction from before standing-still.
      float targetOrientation = atan2(velocity.x, velocity.y); //we want character to face movement
      
      if (orientation > PI) orientation -= 2*PI ;
      else if (orientation < -PI) orientation += 2*PI ;
      
      //move a bit towards velocity:
      // turn vel into orientation
      
      // Will take a frame extra at the PI boundary
      float orIncrement = PI/16;
      if (abs(targetOrientation - orientation) <= orIncrement) {
        orientation = targetOrientation ;
      } else {
         // if it's less than me, then how much if up to PI less, decrease otherwise increase
      if (targetOrientation < orientation) {
        if (orientation - targetOrientation <= PI) orientation -= orIncrement  ;
          else orientation += orIncrement ;
        }
        else {
         if (targetOrientation - orientation <= PI) orientation += orIncrement ;
         else orientation -= orIncrement ; 
        }
      }
      //END OF COPIED CODE
    }
        
    //// update position
    this.position.y += velocity.y;
    this.position.x += velocity.x;
  }
  
  public void updateTimer(){
    timeToDespawn.updateTimer();
  }
  
  public boolean timeToDespawn(){
    return timeToDespawn.outOfTime();
  }
  
  public void draw(){
    CS4303SPACEHAUL.offScreenBuffer.pushMatrix();
    CS4303SPACEHAUL.offScreenBuffer.translate(position.x, position.y);
    CS4303SPACEHAUL.offScreenBuffer.rotate(-orientation);
    CS4303SPACEHAUL.offScreenBuffer.fill(255);
    CS4303SPACEHAUL.offScreenBuffer.ellipse(0, 0,radiusX,radiusY);
    CS4303SPACEHAUL.offScreenBuffer.popMatrix();
  }
  
  public PVector getPosition(){
    return position;
  }
  
  public float getRadiusX(){
    return radiusX;
  }
}
