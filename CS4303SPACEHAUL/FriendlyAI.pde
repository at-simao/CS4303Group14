class FriendlyAI extends Body { //Similar to Player except follows steering algorithms for movement. Vulnerable to hazards and follows player once found.
  private final float MAX_SPEED = 30;
  
  private float health = 100;
  private final float MAX_HEALTH = 100;
  private float orientation = 0.0;
  private final float SLOW_DOWN = 0.7; //drag
  private final float radius = 4;  
  private color colour;  
  Player target = null;
  private final float maxAcc = 3; //defined in proportion to speed. 
  private PVector wanderTarget;
  private boolean isLost = false;
  private Planet targetPlanet;
  private boolean arrived;
  private float visibilityRadius = radius*8;
  public FriendlyAI(PVector start, color planetColour) {
    super(start, new PVector(0,0), 0.01);
    colour = planetColour;
  }
  
  //Establishes player as target to trail behind.
  public void setTarget(Player player){
    target = player;
    isLost = false;
  }
  
  public color getColour() {
    return colour;
  }
  
  PVector fleeOrSeek(PVector pointOfInterest, int fleeOrSeek){
    //fleeOrSeek == -1 if flee, 1 if seek.
    PVector pointingToTarget = new PVector(pointOfInterest.x - position.x, pointOfInterest.y - position.y);
    pointingToTarget.normalize().mult(fleeOrSeek * maxAcc);
    //if(fleeOrSeek == 1){
    //  pointingToTarget.normalize().mult(maxAcc);
    //}
    //else if(fleeOrSeek == 2){
    //  pointingToTarget.normalize().mult(-maxAcc/pow(position.dist(pointOfInterest)/600,1)); //attenuation function, planet avoidence should be low unless close to planet.
    //}
    velocity.x += pointingToTarget.x;
    velocity.y += pointingToTarget.y;
    return pointingToTarget;
  }
  
  //To avoid crashing into planets, AI flies around the planet to get to target.
  public void avoidPlanets(){
    for(Planet planet : CS4303SPACEHAUL.map.planets){
      if(planet.getPosition().dist(position) < ((planet.getDiameter()/2)+radius)*1.5){
        velocity.add(position.copy().sub(planet.getPosition()).normalize().mult(maxAcc/1.5)); 
      } 
    }
  }
  
  // simple lost movement temp
  private void wander() {
    velocity.mult(0);
    if(position.dist(wanderTarget) < 10) {
      float angle = random(TWO_PI);
      wanderTarget.set(this.position.x + 100 * cos(angle), this.position.y + 100 * sin(angle));
    }
    fleeOrSeek(wanderTarget, 1);
  }
  
  
  //An adapted for of steering, the AI seeks and accelerates towards the player's trail. The AI also smoothly follows player once velocity matches.
  public void tailBehind(){ //adapted from: https://studres.cs.st-andrews.ac.uk/CS4303/Lectures/L9/PursueSketch/PursueSketch.pde
    //Instead of targetting where player is going, we target where player was. Ensures we are never in the way of the player, which may be needed if player is trying to avoid obstacles for this friendly AI.
    if(target == null){
      velocity.mult(SLOW_DOWN);
      return;
    }
        
    PVector tail = target.getVelocity().copy().normalize();
    tail.mult(-(target.getRadius()*4)) ; //directly behind player.
    tail.add(target.getPosition()) ;
    if(position.dist(target.getPosition()) > target.getRadius()*6){ //satisfiability radius
      fleeOrSeek(tail, 1);
    } else if(position.dist(target.getPosition()) > target.getRadius()*4 && target.getVelocity().mag() > 0.5){ //condition only relevant if player is moving, as the AI must pursue as very dynamicaly moving target (player).
      fleeOrSeek(tail, 1);
      velocity.setMag(target.getVelocity().mag());
      return; //no slow down, should be smooth movement when this close.
    }
    velocity.mult(SLOW_DOWN);
  }
  public boolean arrived() {
    return arrived;
  }
  public void setTargetPlanet(Planet planet) {
    this.targetPlanet = planet;
  }
  public Planet getTargetPlanet() {
    return targetPlanet;
  }
  public void integrate() {
    if(health == 0){
      //DESPAWN WHEN HEALTH IS 0, RESET.
    }
  
    if(targetPlanet!=null) {
      moveToSurface();
    }
    else {
      if(position.dist(player1.getPosition()) < 500 && isLost) {
        setTarget(player1);
        isLost = false;
      }
      if(position.dist(player2.getPosition()) < 500 && isLost) {
        setTarget(player2);
        isLost = false;
      }
      if(position.dist(target.getPosition()) > 500) {
        if(!isLost) {
          isLost = true;
          wanderTarget = target.getPosition().copy();
        }
        wander();
      }
      else {
        tailBehind(); //first establish direction to find player.
      }
      avoidPlanets(); //then determine net direction that does not fly into a planet.
    }
    //if(velocity.mag() > MAX_SPEED){
    //  //velocity.mult(MAX_SPEED/velocity.mag());
    //}
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
  
  public void moveToSurface() {
    if(position.dist(targetPlanet.getPosition()) - targetPlanet.getDiameter() /2 < 5) {arrived = true;}
    PVector toPlanetCenter = PVector.sub(targetPlanet.getPosition(), position);
    toPlanetCenter.setMag(targetPlanet.getDiameter() / 2 + 5); // Move to just outside the planet's surface
    PVector targetPosition = PVector.add(targetPlanet.getPosition(), toPlanetCenter);
    fleeOrSeek(targetPosition, 1); // Seek towards the calculated position on the surface
    velocity.mult(SLOW_DOWN);
  }
  
  public void draw() {
    CS4303SPACEHAUL.offScreenBuffer.noStroke();
    drawHealthBar();
    CS4303SPACEHAUL.offScreenBuffer.translate(position.x, position.y);
    CS4303SPACEHAUL.offScreenBuffer.fill(colour);
    CS4303SPACEHAUL.offScreenBuffer.rotate(-orientation+HALF_PI);
    CS4303SPACEHAUL.offScreenBuffer.triangle(-radius, -radius, -radius, radius, radius*2, 0);
    CS4303SPACEHAUL.offScreenBuffer.fill(colour);    
    CS4303SPACEHAUL.offScreenBuffer.rotate((orientation-HALF_PI));
    CS4303SPACEHAUL.offScreenBuffer.translate(-position.x, -position.y);
  }
  
  public void drawHealthBar(){
    CS4303SPACEHAUL.offScreenBuffer.translate(position.x, position.y);
    CS4303SPACEHAUL.offScreenBuffer.fill(0);
    CS4303SPACEHAUL.offScreenBuffer.noStroke();
    CS4303SPACEHAUL.offScreenBuffer.rect(-radius*1.5, radius*2.5, radius*3, radius/2);
    CS4303SPACEHAUL.offScreenBuffer.fill(0,180,0);
    CS4303SPACEHAUL.offScreenBuffer.rect(-radius*1.5, radius*2.5, ((radius*3)*health)/MAX_HEALTH, radius/2);
    CS4303SPACEHAUL.offScreenBuffer.translate(-position.x, -position.y);
  }
  
  public void changeHealthBy(float increment){
    health += increment;
    health = min(health, MAX_HEALTH);
  }
  
  public float getHealth(){
    return health;
  }
  
  public float getRadius(){
    return radius;
  }
    
  public float getVisibilityRadius(){
    return visibilityRadius;
  }
  
  public boolean hasATarget(){
    return (target != null);
  }
}
