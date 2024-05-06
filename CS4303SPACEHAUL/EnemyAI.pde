class EnemyAI extends Body { //Similar to Player except follows steering algorithms for movement. Vulnerable to hazards and follows player once found.
  private final float MAX_SPEED = 30;
  private final float PROJECTILE_PROPULSION = 2;
  private final float MAX_PROJECTILES = 20;
  
  private float orientation = 0.0;
  private final float SLOW_DOWN = 0.7; //drag
  private final float radius = 4;  
  private color colour = color(250, 96, 0);  


  private final float maxAcc = 0.2; //defined in proportion to speed. 

  private final int PATROL_STATE = 1;
  private final int ATTACK_METEORS_STATE = 2;
  private final int ATTACK_PLAYER_1_STATE = 3;
  private final int ATTACK_PLAYER_2_STATE = 4;
  private final int INIT_STATE = 0;
  
  private int currState = 0;
  
  private Planet patrollingPlanet = null;
  private Player targetPlayer = null;
  
  private ArrayList<Projectile> projectilesFired = new ArrayList<Projectile>();
  
  private float visibilityRadius = radius*20;
  
  private Timer cooldownTimer = null;
  
  public EnemyAI(PVector start) {
    super(start, new PVector(0,0), 0.01);
    changeState(PATROL_STATE);  //by default enter patrol state from init.
  }
  
  private void changeState(int newState){
    if(newState == INIT_STATE){
      currState = INIT_STATE;
    } else if(newState == PATROL_STATE){
      //logic
      determineNewPatrolTarget();
      targetPlayer = null;
      currState = newState;
    } else if(newState == ATTACK_METEORS_STATE){
      //logic
      patrollingPlanet = null;
      targetPlayer = null;
      currState = newState;
    } else if(newState == ATTACK_PLAYER_1_STATE){
      //logic
      patrollingPlanet = null;
      currState = newState;
    } else if(newState == ATTACK_PLAYER_2_STATE){
      //logic
      patrollingPlanet = null;
      currState = newState;
    }
  }
  
  private void determineNewPatrolTarget(){
    int maxSize =  CS4303SPACEHAUL.map.planets.size();
    int randomSelect = floor(random(0,maxSize));
    patrollingPlanet =  CS4303SPACEHAUL.map.planets.get(randomSelect);
  }
  
  private void patrolStateLogic(){
    if(currState != PATROL_STATE){
      return;
    }
    //check if within acceptiability radius of planet, if so, pick another one
    if(getPosition().dist(patrollingPlanet.getPosition()) > patrollingPlanet.getDiameter()*1.5){
      fleeOrSeek(patrollingPlanet.getPosition().copy(), 1);
      avoidPlanets();
    } else {
      determineNewPatrolTarget();
    }
    
    
    //if player(s) are within range, fire at them
    
    //if meteor is within range, fire at it
  }
  
  private void fireAtMeteorsStateLogic(){
    if(currState != ATTACK_METEORS_STATE){
      return;
    }
    
    //if player(s) / meteor are within range, fire at them
    
    //if destroyed
  }
  
  private void fireAtPlayer1StateLogic(){
    if(currState != ATTACK_PLAYER_1_STATE){
      return;
    }
    if(cooldownTimer != null){
      return;
    }
    float currentSpeed = velocity.mag();
    PVector velocityOfProjectile = position.copy().sub(targetPlayer.getPosition()).mult(-1).normalize();
    
    projectilesFired.add(new Projectile(position.copy(), velocityOfProjectile.mult(PROJECTILE_PROPULSION).copy(), 5, 10));
    cooldownTimer = new Timer(500, null, 0);
    //projectilesFired.add(new Projectile(position, new PVector(10,10), 5, 10));
    
    //if player(s) / meteor are within range, fire at them
    
    //if destroyed
  }
  
  private void fireAtPlayer2StateLogic(){
    if(currState != ATTACK_PLAYER_2_STATE){
      return;
    }
    //check if within acceptiability radius of planet, if so, pick another one
    
    //if player(s) / meteor are within range, fire at them
    
    //if destroyed
  }
  
  
  PVector fleeOrSeek(PVector pointOfInterest, int fleeOrSeek){
    //fleeOrSeek == -1 if flee, 1 if seek.
    PVector pointingToTarget = new PVector(pointOfInterest.x - position.x, pointOfInterest.y - position.y);
    pointingToTarget.normalize().mult(fleeOrSeek * maxAcc);
    velocity.x += pointingToTarget.x;
    velocity.y += pointingToTarget.y;
    return pointingToTarget;
  }
  
  //To avoid crashing into planets, AI flies around the planet to get to target.
  public void avoidPlanets(){
    for(Planet planet : CS4303SPACEHAUL.map.planets){
      if(planet.getPosition().dist(position) < ((planet.getDiameter())+radius)*1.5){
        velocity.add(position.copy().sub(planet.getPosition()).normalize().mult(maxAcc/1.5)); 
      } 
    }
    if(CS4303SPACEHAUL.map.planets.get(0).getPosition().dist(position) < ((CS4303SPACEHAUL.map.planets.get(0).getDiameter())+radius)*1.5){
      velocity.add(position.copy().sub(CS4303SPACEHAUL.map.planets.get(0).getPosition()).normalize().mult(maxAcc/1.5)); 
    } 
  }
  

  

  public void integrate() {
    //LOGIC:
    //  CHECK IF PLAYER IS IN SIGHT
    //  IF SO, FIRE AT THEM
    //  CHECK IF ARRIVED AT PLANET IN PATROL
    //  if so, randomly pick next patrol.
    for(Projectile projectile : projectilesFired){
      projectile.integrate();
    }
    patrolStateLogic();
    fireAtMeteorsStateLogic();
    fireAtPlayer1StateLogic();
    fireAtPlayer2StateLogic();
    
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
    velocity.mult(SLOW_DOWN);
  }
  


  
  public void draw() {
    CS4303SPACEHAUL.offScreenBuffer.noStroke();
    CS4303SPACEHAUL.offScreenBuffer.pushMatrix();
    CS4303SPACEHAUL.offScreenBuffer.translate(position.x, position.y);
    CS4303SPACEHAUL.offScreenBuffer.fill(colour);
    CS4303SPACEHAUL.offScreenBuffer.rotate(-orientation+HALF_PI);
    CS4303SPACEHAUL.offScreenBuffer.triangle(-radius, -radius, -radius, radius, radius*2, 0);
    CS4303SPACEHAUL.offScreenBuffer.popMatrix();
    for(Projectile projectile : projectilesFired){
      projectile.draw();
    }
  }
  


  public float getRadius(){
    return radius;
  }
    
  public float getVisibilityRadius(){
    return visibilityRadius;
  }
  
  public void updateProjectilesAndTimers(Player player1, Player player2, ArrayList<Meteor> meteors){
    if(cooldownTimer != null){
      cooldownTimer.updateTimer();
      if(cooldownTimer.outOfTime()){
        cooldownTimer = null;
      }
    }
    for(int i = 0; i < projectilesFired.size(); i++){
      projectilesFired.get(i).updateTimer();
      if(projectilesFired.get(i).timeToDespawn()){
        projectilesFired.remove(i);
        i--;
        continue;
      } else if(projectilesFired.get(i).getPosition().copy().dist(player1.getPosition()) < projectilesFired.get(i).getRadiusX() + player1.getRadius()){ //check if hit player 1
        projectilesFired.remove(i);
        i--;
        continue;
      } else if(projectilesFired.get(i).getPosition().copy().dist(player1.getPosition()) < projectilesFired.get(i).getRadiusX() + player2.getRadius()){ //check if hit player 2
        projectilesFired.remove(i);
        i--;
        continue;
      } 
      //check if hit meteors
      for(Meteor meteor : meteors){
        if(projectilesFired.get(i).getPosition().copy().dist(meteor.getPosition()) < projectilesFired.get(i).getRadiusX() + meteor.getWidth()){
          meteor.toggleToRemove();
          projectilesFired.remove(i);
          i--;
          break;
        }
      }
    }
  }
  
  public void checkPlayer1IsInRange(Player player){
    if((currState != ATTACK_PLAYER_1_STATE || currState != ATTACK_PLAYER_2_STATE) && lineOfSight(player)){
      targetPlayer = player;
      changeState(ATTACK_PLAYER_1_STATE);
      println("TARGETED PLAYER");
    } else if(currState == ATTACK_PLAYER_1_STATE && !lineOfSight(player)) {
      //if the player is no longer in line of sight, abandon targeting. revert to patrol.
      changeState(PATROL_STATE);
      println("LOST PLAYER");
    }
  }
  
  public void checkPlayer2IsInRange(Player player){
    if((currState != ATTACK_PLAYER_1_STATE || currState != ATTACK_PLAYER_2_STATE) && lineOfSight(player)){
      targetPlayer = player;
      changeState(ATTACK_PLAYER_2_STATE);
    } else if(currState == ATTACK_PLAYER_2_STATE && !lineOfSight(player)) {
      //if the player is no longer in line of sight, abandon targeting . revert to patrol.
      changeState(PATROL_STATE);
    }
  }
  
  public boolean lineOfSight(Player player){
    PVector lineToPlayer = player.getPosition().copy().sub(getPosition()).normalize();
    while(lineToPlayer.mag() < visibilityRadius){
      float oldMag = lineToPlayer.mag();
      lineToPlayer.normalize().mult(oldMag + radius*0.01); //incrementally raise ray of sight until we hit our target.
      for(Planet planet : map.planets){
        if(lineToPlayer.dist(planet.getPosition()) < planet.getDiameter()/2){
          println("FAILURE1");
          return false; //planet in the way of line of sight.
        }
      }
      if(lineToPlayer.dist(player.getPosition()) < player.getRadius()*2){
        return true; //found player
      }
    }
    println("FAILURE2");
    return false; //if here then line drawn was beyond visibility radius, failed.
  }
  
}
