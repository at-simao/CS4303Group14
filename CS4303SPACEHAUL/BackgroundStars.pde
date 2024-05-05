class BackgroundStars { //Maintains background stars of level.
  
  private int MAX_ATTEMPT_AT_PLACING = 100;
  private int MAX_STARS = 100;
  
  private float radiusOfSpawn = 300;
  
  private ArrayList<Star> stars;

  BackgroundStars() {
    stars = new ArrayList<Star>();
  }

  //Determines if it is is appropriate to spawn a new meteor.
  public void generate(Player player1, Player player2, int whichPlayerIsCentre) { 
    if(stars.size() > MAX_STARS){
      return; // do not place
    }
    //random chance to generate meteor
    if(stars.size() == 0){
      //game just started
      Star newStar;
      for(int i = 0; i < MAX_ATTEMPT_AT_PLACING; i++){
        newStar = new Star(new PVector(player1.getPosition().x + random(-radiusOfSpawn, radiusOfSpawn), player1.getPosition().y + random(-radiusOfSpawn, radiusOfSpawn)), 2);
        int currSize = stars.size();
        if(currSize == 0){
          stars.add(newStar);
        }
        for(int j = 0; j < currSize; j++){
          //check not on top of other stars
          if(newStar.getPosition().dist(stars.get(j).getPosition()) <= newStar.getRadius() + stars.get(j).getRadius()){
            stars.add(newStar);
          }
        }
      }
      return;
    }
    PVector potentialSpawnPosition = null;
    //If here then game is already in-play. Add stars in direction of player movement.
    if(whichPlayerIsCentre == 1){
      if(player1.getVelocity().mag() == 0){
        return; //game just started, or player is still, do not spawn yet.
      }
      PVector playerDirection = null;
      playerDirection = player1.getVelocity().copy().normalize();
      playerDirection.rotate(random(-PI/2, PI/2)); //random span of placement for dynamic feel.
      potentialSpawnPosition = playerDirection.copy().mult(radiusOfSpawn).add(player1.getPosition());
      if(potentialSpawnPosition.copy().sub(player2.getPosition()).mag() < radiusOfSpawn){ //do not spawn in front of other player (2), only off-screen.
        return;
      }
      
    } else {
      if(player2.getVelocity().mag() == 0){
        return; //game just started, or player is still, do not spawn yet.
      }
      PVector playerDirection = null;
      playerDirection = player2.getVelocity().copy().normalize();
      playerDirection.rotate(random(-PI/2, PI/2)); //random span of placement for dynamic feel.
      potentialSpawnPosition = playerDirection.copy().mult(radiusOfSpawn).add(player2.getPosition());
      if(potentialSpawnPosition.copy().sub(player1.getPosition()).mag() < radiusOfSpawn){ //do not spawn in front of other player (2), only off-screen.
        return;
      }
    }
    
    for(Star star : stars){
      if(potentialSpawnPosition.copy().dist(star.getPosition()) < star.getRadius()*4){ //do not spawn too close to other stars.
        return;
      }
    }
    
    //passed all tests, add
    
    stars.add(new Star(potentialSpawnPosition, 2));
    
  }

  //Despawns stars if both players are sufficiently far away.
  public void deleteStar(Player player1, Player player2){
    PVector currentPosition = null;
    for (int i = 0; i < stars.size(); i++) {
      currentPosition = stars.get(i).getPosition();
      if(currentPosition.copy().dist(player1.getPosition()) > radiusOfSpawn &&
          currentPosition.copy().dist(player2.getPosition()) > radiusOfSpawn){
        stars.remove(i);
        i--;  
      }
    }
  }
  
  public void draw() {
    println(stars.size());
    for (Star star : stars) {
      star.draw();
    }
  }
  
  public void clear(){
    stars.clear();
  }
}
