class EnemyAI extends Body { //Similar to Player except follows steering algorithms for movement. Vulnerable to hazards and follows player once found.
  private final float MAX_SPEED = 30;
  private final float PROJECTILE_PROPULSION = 9;
  private final float MAX_PROJECTILES = 20;
  
  private float orientation = 0.0;
  private final float SLOW_DOWN = 0.9; //drag
  private final float radius = 4;  
  private color colour = color(250, 96, 0);  


  private final float maxAcc = 0.4; //defined in proportion to speed. 

  private final int PATROL_STATE = 1;
  private final int ATTACK_PLAYER_1_STATE = 2;
  private final int ATTACK_PLAYER_2_STATE = 3;
  private final int SEARCH_LAST_LOCATION_STATE = 4;
  private final int INIT_STATE = 0;
  
  private int currState = 0;
  private PVector lastKnownPlayerPosition = null;
  private Planet patrollingPlanet = null;
  private Player targetPlayer = null;
  
  private ArrayList<Projectile> projectilesFired = new ArrayList<Projectile>();
  
  private float visibilityRadius = radius*90;
  
  private Timer cooldownTimer = null;
  
  public EnemyAI(PVector start) {
    super(start, new PVector(0,0), 0.01);
    changeState(PATROL_STATE);  //by default enter patrol state from init.
  }
  
  // change state of enemy ai
  private void changeState(int newState) {
    switch (newState) {
      case INIT_STATE:
        currState = INIT_STATE;
        break;
      case PATROL_STATE:
        determineNewPatrolTarget();
        targetPlayer = null;
        break;
      case ATTACK_PLAYER_1_STATE:
        patrollingPlanet = null;
        break;
      case ATTACK_PLAYER_2_STATE:
        patrollingPlanet = null;
        break;
      case SEARCH_LAST_LOCATION_STATE:
        patrollingPlanet = null;
        break;        
      default:
        throw new IllegalStateException("Unknown state: " + newState);
     }
    currState = newState;
  }
  
  // get random planet to patrol
  private void determineNewPatrolTarget() {
    int maxSize = CS4303SPACEHAUL.map.planets.size();
    int randomSelect = floor(random(0, maxSize));
    patrollingPlanet = CS4303SPACEHAUL.map.planets.get(randomSelect);
  }
  
  // moves ai towards patrol planet
  private void patrolStateLogic() {
    if (getPosition().dist(patrollingPlanet.getPosition()) > patrollingPlanet.getDiameter() * 1.5) {
      fleeOrSeek(patrollingPlanet.getPosition().copy(), 1);
      avoidPlanets();
    } 
    else {
      determineNewPatrolTarget();  // find new target planet
    }
  }

  // fire at and move towards player
  private void fireAtPlayerStateLogic() {
    if(targetPlayer.getDead()) {  // if target is dead then patrol
      changeState(PATROL_STATE);
      return;
    }
    PVector toPlayer = PVector.sub(targetPlayer.getPosition(), getPosition());
    float distance = toPlayer.mag();
    toPlayer.normalize();
    if (distance < 150) {  // slow down as approaching closer to player
      velocity.mult(SLOW_DOWN);
    }
      if (distance < 50) {  // start to orbit around player
        PVector orbitDirection = new PVector(-toPlayer.y, toPlayer.x);
        velocity = orbitDirection;
        if (distance > 30) {
          fleeOrSeek(targetPlayer.getPosition(), 1);
          } else if (distance < 20) {  // dont get too close
              fleeOrSeek(targetPlayer.getPosition(), -1);
         }
      } else {
          fleeOrSeek(targetPlayer.getPosition(), 1);
      }
      if (cooldownTimer == null) {  // create new projectile to fire at player
        PVector velocityOfProjectile = position.copy().sub(targetPlayer.getPosition()).mult(-1).normalize();
        projectilesFired.add(new Projectile(position.copy(), velocityOfProjectile.mult(PROJECTILE_PROPULSION).copy(), 5, 10));
        cooldownTimer = new Timer(1600, null, 0);
      }
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
    for(Projectile projectile : projectilesFired){  // update projectiles
      projectile.integrate();
    }
    switch (currState) {
      case PATROL_STATE:
        patrolStateLogic();
        break;
      case ATTACK_PLAYER_1_STATE:
        fireAtPlayerStateLogic();
        break;
      case ATTACK_PLAYER_2_STATE:
        fireAtPlayerStateLogic();
        break;
      case SEARCH_LAST_LOCATION_STATE:
        searchLastLocationLogic();
        break;
      default:
    }
    updateOrientation();
    updatePosition();
  }
  
  // update orientation towards target
  private void updateOrientation() {
    if (velocity.mag() != 0) {
      float targetOrientation = atan2(velocity.x, velocity.y);
      if (orientation > PI) orientation -= 2 * PI;
      else if (orientation < -PI) orientation += 2 * PI;
      float orIncrement = PI / 16;
      if (abs(targetOrientation - orientation) <= orIncrement) {
        orientation = targetOrientation;
      } else {
      if (targetOrientation < orientation) {
        if (orientation - targetOrientation <= PI) orientation -= orIncrement;
        else orientation += orIncrement;} else {
        if (targetOrientation - orientation <= PI) orientation += orIncrement;
        else orientation -= orIncrement;
        }
      }
    }
  }
  
  // update pos of ai
  private void updatePosition() {
    position.y += velocity.y;
    position.x += velocity.x;
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
    outerLoop:
    for(int i = 0; i < projectilesFired.size(); i++){
      if(i > 10) {projectilesFired.remove(i); continue;}
      projectilesFired.get(i).updateTimer();
      if(projectilesFired.get(i).timeToDespawn()){
        projectilesFired.remove(i);
        i--;
        continue;
      } else if(projectilesFired.get(i).getPosition().copy().dist(player1.getPosition()) < projectilesFired.get(i).getRadiusX() + player1.getRadius()){ //check if hit player 1
        projectilesFired.remove(i);
        i--;
        player1.changeHealthBy(-20);
        continue;
      } else if(projectilesFired.get(i).getPosition().copy().dist(player2.getPosition()) < projectilesFired.get(i).getRadiusX() + player2.getRadius()){ //check if hit player 2
        projectilesFired.remove(i);
        i--;
        player2.changeHealthBy(-20);
        continue;
      } else 
      for(int j = 0; j < aiList.size(); j++) {
        if(projectilesFired.get(i).getPosition().copy().dist(aiList.get(j).getPosition()) < projectilesFired.get(i).getRadiusX() + aiList.get(j).getRadius()){ //check if hit player 2
          projectilesFired.remove(i);
          i--;
          aiList.get(j).changeHealthBy(-50);
          continue outerLoop; // continue outerloop
        } 
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
    } else if(currState == ATTACK_PLAYER_1_STATE && !lineOfSight(player)) {
      //if the player is no longer in line of sight, abandon targeting. revert to patrol.
      changeState(SEARCH_LAST_LOCATION_STATE);
    }
  }
  
  public void checkPlayer2IsInRange(Player player){
    if((currState != ATTACK_PLAYER_1_STATE || currState != ATTACK_PLAYER_2_STATE) && lineOfSight(player)){
      targetPlayer = player;
      changeState(ATTACK_PLAYER_2_STATE);
    } else if(currState == ATTACK_PLAYER_2_STATE && !lineOfSight(player)) {
      //if the player is no longer in line of sight, abandon targeting . revert to patrol.
      changeState(SEARCH_LAST_LOCATION_STATE);
    }
  }
  
  private void searchLastLocationLogic() {
    if (lastKnownPlayerPosition == null) {
      changeState(PATROL_STATE); // No last known position revert to patrol
      return;
    }
    PVector toLastKnown = PVector.sub(lastKnownPlayerPosition, position);
    float distance = toLastKnown.mag();

    if (distance > 30) { // Check if AI is close to the last known position
      fleeOrSeek(lastKnownPlayerPosition, 1); // Move towards the last known position
    } else {
      lastKnownPlayerPosition = null; // Clear last known position
      changeState(PATROL_STATE); // Start patrolling again if the player is still not in sight
    }
  }

  public boolean lineOfSight(Player player){
    if(player.getDead()){
      return false;
    }
    PVector lineToPlayer = PVector.sub(player.getPosition(), getPosition());
    float distanceToPlayer = lineToPlayer.mag();
    lineToPlayer.normalize(); // Normalize to get direction vector

    float maxSightDistance = visibilityRadius;
    float effectiveDistance = Math.min(distanceToPlayer, maxSightDistance);

    for (float d = 0; d < effectiveDistance; d += getRadius() * 0.1) { // Increment by 10% of AI radius
        PVector checkPoint = PVector.add(getPosition(), PVector.mult(lineToPlayer, d));
        for (Planet planet : CS4303SPACEHAUL.map.planets) {
            float distanceToPlanet = PVector.dist(checkPoint, planet.getPosition());
            if (distanceToPlanet < planet.getDiameter() / 2) {
                return false; // Planet is blocking the line of sight
            }
        }
    }
    if (maxSightDistance >= distanceToPlayer) {  // if can see player update last seen location
      lastKnownPlayerPosition = player.getPosition().copy();
      return true;
    }
    return false;
  }

  

  
}
