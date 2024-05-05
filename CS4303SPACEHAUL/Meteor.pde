class Meteor extends Body{ //small bodies that attract one another and collide with eachother, players, and AI.
  private float meteorWidth = 5;
  private float meteorHeight = 5;
  private float orientation = 0;
  private float angularMomentum = 0;
  private float ANGULAR_DRAG = 0.97;
  private boolean toRemove = false;
  private float minimumDistanceForGravity = 200;
  private boolean isDestroyed = false;
  
  
  Meteor(float radius, float invM, PVector pos){
    super(pos, new PVector(0,0), invM);
    this.meteorWidth = radius;
    meteorHeight = random(0.5, 1) * meteorWidth;
    orientation = random(0, TWO_PI);
  }
  
  //Meteors are attracted to all moving bodies, including other meteors. Must calculate respective pull from n^2 combinations.
  public void integratePerMeteor(ArrayList<Meteor> meteors){
    for (Meteor meteor : meteors) {
      if(position.dist(meteor.getPosition()) < minimumDistanceForGravity){
        gravitationalPull(meteor);
      }
    }
  }
  
  public void integrate(){
    // update position
    this.position.y += velocity.y;
    this.position.x += velocity.x;
    orientation += angularMomentum;
    angularMomentum *= ANGULAR_DRAG;
  }

  public void draw() {
    //orientation
    CS4303SPACEHAUL.offScreenBuffer.pushMatrix();
    CS4303SPACEHAUL.offScreenBuffer.noStroke();
    CS4303SPACEHAUL.offScreenBuffer.translate(position.x, position.y);
    CS4303SPACEHAUL.offScreenBuffer.rotate(orientation);
    CS4303SPACEHAUL.offScreenBuffer.fill(175, 80, 0);
    CS4303SPACEHAUL.offScreenBuffer.ellipse(0, 0, meteorWidth, meteorHeight); //elliptical meteors. 
    CS4303SPACEHAUL.offScreenBuffer.popMatrix();
  }
  
  public float getWidth(){
    return meteorWidth;
  }
  
  public void toggleToRemove(){
    toRemove = true;
  }
  
  public boolean getToRemove(){
    return toRemove;
  }
  
  public void changeAngularMomentum(float angularMomentum){
    this.angularMomentum += angularMomentum;
  }
  
  public boolean isDestroyed(){
    return isDestroyed;
  }
  
  public void setDestroyed(){
    isDestroyed = true;
  }
}
