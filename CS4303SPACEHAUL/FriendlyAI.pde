static int gaiID = 0;
class FriendlyAI extends Body { // Similar to Player except follows steering algorithms for movement. Vulnerable to hazards and follows player once found.
  private final float MAX_SPEED = 30;

  private float health = 100;
  private final float MAX_HEALTH = 100;
  private float orientation = 0.0;
  private final float SLOW_DOWN = 0.7; //drag
  
  private final float radius = 4;
  private int aiID;
  private color colour;
  
  Player target = null;
  FriendlyAI aiBehind = null;
  FriendlyAI aiInFront = null;
  private final float maxAcc = 3; //defined in proportion to speed. 
  private PVector wanderTarget;
  private boolean isLost = false;
 // private Planet targetPlanet;  //rework
  private boolean seekPlanet = false;
  private Planet destination;
  private boolean arrived;
  private float visibilityRadius = radius*8;
  
  public FriendlyAI(PVector start, Planet goal) {
    super(start, new PVector(0,0), 0.01);
    colour = goal.getColour();
    destination = goal;
    aiID = ++gaiID;
  }
  
  public Planet getDestination() {
    return destination;
  }
   public int getID() {
    return aiID;
  }
  //Establishes player as target to trail behind.
  public void setTarget(Player player){
    FriendlyAI otherAI = player.getAIBehindPlayer(); 
    if(otherAI != null){
      //follow trail of AI behind player.
      //println("IN WHILE LOOP" + frameCount);
      while(true){
        if(otherAI.getAIBehind() != null){
          otherAI = otherAI.getAIBehind();
          continue;
        }
        //otherwise, it means we reached the end of the trailing line. Add self to end of line.
        otherAI.setAIBehind(this); 
        target = player; 
        setAIInFront(otherAI);
        break;//end of loop
      }
      //println("ESCAPE WHILE LOOP");
    } else {
      target = player; 
      player.setAIFollowing(this);
    }
    isLost = false;
  }
    public boolean isLost() {
    return isLost;
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
    //Instead of targetting where player/ai in front is going, we target where target was. Ensures we are never in the way of the player, which may be needed if player is trying to avoid obstacles for this friendly AI.
    if(target == null && aiInFront == null){
      velocity.mult(SLOW_DOWN);
      return;
    }
      
    PVector tail;
    PVector targetPosition;
    PVector targetVelocity;
    float targetRadius;
    if(aiInFront != null){
      tail = aiInFront.getVelocity().copy().normalize();
      targetPosition = aiInFront.getPosition();
      targetRadius = aiInFront.getRadius();
      targetVelocity = aiInFront.getVelocity();
    } else { //if no ai in front, means player is in front.
      tail = target.getVelocity().copy().normalize();
      targetPosition = target.getPosition();
      targetRadius = target.getRadius();
      targetVelocity = target.getVelocity();
    }
    tail.mult(-(targetRadius*4)) ; //directly behind player.
    tail.add(targetPosition) ;
    if(position.dist(targetPosition) > targetRadius*6){ //satisfiability radius
      fleeOrSeek(tail, 1);
    } else if(position.dist(targetPosition) > targetRadius*4 && targetVelocity.mag() > 0.5){ //condition only relevant if player is moving, as the AI must pursue as very dynamicaly moving target (player).
      fleeOrSeek(tail, 1);
      velocity.setMag(targetVelocity.mag());
      return; //no slow down, should be smooth movement when this close.
    }
    velocity.mult(SLOW_DOWN);
  }
  public boolean arrived() {
    return arrived;
  }
  public void seekPlanet() {
    if(aiInFront == null){ //leading the trail
      target.setAIFollowing(aiBehind);
      if(aiBehind != null){
        aiBehind.setAIInFront(null);
      }
    } else { //all other ai in the queue
      if(aiBehind != null){
        aiBehind.setAIInFront(aiInFront);
      }
      aiInFront.setAIBehind(aiBehind);
    }
    //ai.loseRecursively(ai);
    this.seekPlanet = true;
  }
  
  public boolean isSeeking() {
    return seekPlanet;
  }

  public void integrate() {
    if(health == 0){
      //DESPAWN WHEN HEALTH IS 0, RESET.
      if(aiInFront == null){ //leading the trail
        target.setAIFollowing(aiBehind);
        if(aiBehind != null){
          aiBehind.setAIInFront(null);
        }
      } else { //all other ai in the queue
        if(aiBehind != null){
          aiBehind.setAIInFront(aiInFront);
        }
        aiInFront.setAIBehind(aiBehind);
      }
      
    }
    if (aiInFront != null && (aiInFront.isSeeking())) {
      setTarget(target);
    }
    if(seekPlanet) {
      moveToSurface();
    }
    else {
      if(position.dist(player1.getPosition()) < 500 && isLost) {
        setTarget(player1); ///////////////////////
        isLost = false;
      }
      if(position.dist(player2.getPosition()) < 500 && isLost) {
        setTarget(player2);
        isLost = false;
      }
      if(position.dist(target.getPosition()) > 500) {
        if(!isLost) {
          isLost = true;
          loseRecursively(this);
          if(target.getAIBehindPlayer() == this){
            target.setAIFollowing(null);
          }
          wanderTarget = target.getPosition().copy();
        }
        wander();
      }
      else {
        tailBehind(); //first establish direction to find player.
      }
      //avoidPlanets(); //then determine net direction that does not fly into a planet.
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
  
  private void loseRecursively(FriendlyAI otherAI){
    FriendlyAI temp;
    while(otherAI != null){
      otherAI.setAIInFront(null);
      temp = otherAI.getAIBehind();
      otherAI.setAIBehind(null);
      otherAI = temp;
    }
  }
  
  
  public void moveToSurface() {
    if(position.dist(destination.getPosition()) - destination.getDiameter() /2 < 5) {
      arrived = true;
    }
    PVector toPlanetCenter = PVector.sub(destination.getPosition(), position);
    toPlanetCenter.setMag(destination.getDiameter() / 2 + 5); // Move to just outside the planet's surface
    PVector targetPosition = PVector.add(destination.getPosition(), toPlanetCenter);
    fleeOrSeek(targetPosition, 1); // Seek towards the calculated position on the surface
    velocity.mult(SLOW_DOWN);
  }
  
  public void draw() {
    CS4303SPACEHAUL.offScreenBuffer.noStroke();
    CS4303SPACEHAUL.offScreenBuffer.pushMatrix();
    drawHealthBar();
    CS4303SPACEHAUL.offScreenBuffer.translate(position.x, position.y);
    CS4303SPACEHAUL.offScreenBuffer.fill(colour);
    CS4303SPACEHAUL.offScreenBuffer.rotate(-orientation+HALF_PI);
    CS4303SPACEHAUL.offScreenBuffer.triangle(-radius, -radius, -radius, radius, radius*2, 0);
    CS4303SPACEHAUL.offScreenBuffer.popMatrix();
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
  
  public Player getTarget(){
    return target;
  }
  
  public FriendlyAI getAIBehind(){
    return aiBehind;
  }
  
  public FriendlyAI getAIInFront(){
    return aiInFront;
  }
  
  public void setAIBehind(FriendlyAI ai){
    aiBehind = ai;
  }
  
  public void setAIInFront(FriendlyAI ai){
    aiInFront = ai;
  }
  
  public void kill(){
    health = 0;
  }
}
