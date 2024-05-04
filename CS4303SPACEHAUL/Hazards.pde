class Hazards { //Maintains all hazards on map and handles collision logic for each, including collision between two meteors, meteor & player, and meteor & AI.
  
  private float ELASTICITY = 0.5; //how much kinetic energy remains in colliding meteor, and how much is transferred to hit meteor (1-ELASTICITY).
  
  private int MAX_METEORS = 100;
  
  private float chanceOfNewMeteor = 0.96; //note that this probability is twice as high as current value, as attempt to generate meteors twice per frame.
  
  private float distanceOfSpawn = 600;
  
  private ArrayList<Meteor> meteors;

  Hazards() {
    meteors = new ArrayList<Meteor>();
  }

  //Determines if it is is approprriate to spawn a new meteor.
  public void generate(Player player1, Player player2, int whichPlayerIsCentre) { 
    //random chance to generate meteor
    if(meteors.size() < MAX_METEORS && random(0,1) > chanceOfNewMeteor){
      //generated given player heading (should gen just ahead so as to not make procedural pop-in obvious).
      //Placing just ahead limits useless work, we need to sell illusion only when player is likely to see it.
      PVector playerPosition = null;
      PVector playerDirection = null;
      PVector potentialSpawnPosition = null;
      if(whichPlayerIsCentre == 1){
        if(player1.getVelocity().mag() == 0){
          return; //game just started, or player is still, do not spawn yet.
        }
        playerPosition = player1.getPosition();
        playerDirection = player1.getVelocity().copy().normalize();
        playerDirection.rotate(random(-PI/6, PI/6)); //random span of placement for dynamic feel.
        potentialSpawnPosition = playerDirection.copy().mult(distanceOfSpawn).add(playerPosition);
        if(potentialSpawnPosition.copy().sub(player2.getPosition()).mag() < distanceOfSpawn){ //do not spawn in front of other player (2), only off-screen.
          return;
        }
      } else { // == 2
        if(player2.getVelocity().mag() == 0){
          return; //game just started, or player is still, do not spawn yet.
        }
        playerPosition = player2.getPosition();
        playerDirection = player2.getVelocity().copy().normalize();
        playerDirection.rotate(random(-PI/6, PI/6)); //random span of placement
        potentialSpawnPosition = playerDirection.copy().mult(distanceOfSpawn).add(playerPosition);
        if(potentialSpawnPosition.copy().sub(player1.getPosition()).mag() < distanceOfSpawn){ //do not spawn in front of other player (1), only off-screen.
          return;
        }
      }
      
      Meteor newMeteor = new Meteor(10, 0.05, potentialSpawnPosition);
      
      
      //check not spawning on top of planet
      ArrayList<Planet> planets = CS4303SPACEHAUL.map.planets;
      PVector distanceFromMeteor = potentialSpawnPosition.copy();
      for(Planet planet : planets){
        if(distanceFromMeteor.copy().sub(planet.getPosition()).mag() < 200 + newMeteor.getWidth()*2){ //max radius of planet is 200, 
          return; //do not spawn meteor on top of a planet
        }
      }
      
      //check not spawning on top of current meteors
      
      for(Meteor meteor : meteors){
        if(distanceFromMeteor.copy().sub(meteor.getPosition()).mag() < newMeteor.getWidth()+meteor.getWidth()){
          return; //do not spawn on top of another meteor
        }
      }
      
      //passed all checks, add to array list
      
      meteors.add(newMeteor);
      
    }
  }

  //Performs all logic for hazards, including collision detection.
  public void integrate(Player player1, Player player2, ArrayList<FriendlyAI> escortAI) {
    for (int i = 0; i < meteors.size(); i++) {
      //gravity from other meteors
      meteors.get(i).integratePerMeteor(meteors);
      meteorCollisions(meteors.get(i));
      playerMeteorCollisions(meteors.get(i), player1, player2);
      for(FriendlyAI friend : escortAI){
        escortAIMeteorCollisions(meteors.get(i), friend);
      }
      if(meteors.get(i).getToRemove()){
        meteors.remove(i);
      } else {
        meteors.get(i).integrate();
      }
    }
  }
  
  //Detects collision between two meteors.
  public void meteorCollisions(Meteor meteor){
    PVector meteorPosition = meteor.getPosition().copy();
    PVector meteor2Position = null;
    for(Meteor meteor2 : meteors){
      meteor2Position = meteor2.getPosition().copy();
      if(meteorPosition.x != meteor2Position.x && meteorPosition.y != meteor2Position.y){ //i.e. not the same meteor colliding with itself
        if(meteorPosition.copy().sub(meteor2Position).mag() < (meteor.getWidth() + meteor2.getWidth())/2.0){
          meteor2.getPosition().x -= meteor2.getVelocity().x;
          meteor2.getPosition().y -= meteor2.getVelocity().y;
          //determine position of collision, then call handler. It is called twice to handle both frames of reference, when one is incident on the other, and vice-versa.
          handleCollision(meteor, meteor2, meteor2Position.copy().sub(meteorPosition).normalize());
        }
      }
    }
  }
  
  private void escortAIMeteorCollisions(Meteor meteor, FriendlyAI friend){
    PVector meteorPosition = meteor.getPosition().copy();
    PVector aiPosition = friend.getPosition();
    if(meteorPosition.copy().sub(aiPosition).mag() <= (meteor.getWidth())/2.0 + friend.getRadius()){
      friend.changeHealthBy(-25);
      meteor.toggleToRemove();
    }
  }
  
  private void playerMeteorCollisions(Meteor meteor, Player player1, Player player2){
    PVector meteorPosition = meteor.getPosition().copy();
    PVector player1Position = player1.getPosition();
    PVector player2Position = player2.getPosition();
    if(meteorPosition.copy().sub(player1Position).mag() <= (meteor.getWidth())/2.0 + player1.getRadius()){
      hurtPlayer(player1, meteor);  
    } else if(meteorPosition.copy().sub(player2Position).mag() <= (meteor.getWidth())/2.0 + player1.getRadius()){
      hurtPlayer(player2, meteor);  
    }
  }
  
  private void hurtPlayer(Player player, Meteor meteor){
    player.changeHealthBy(-25);
    meteor.toggleToRemove();
  }
  
  //Despawns meteors if both players are sufficiently far away.
  public void deleteHazard(Player player1, Player player2){
    PVector currentPosition = null;
    for (int i = 0; i < meteors.size(); i++) {
      currentPosition = meteors.get(i).getPosition();
      if(currentPosition.copy().sub(player1.getPosition()).mag() > distanceOfSpawn*2 &&
          currentPosition.copy().sub(player2.getPosition()).mag() > distanceOfSpawn*2){
        meteors.remove(i);
        i--;  
      }
    }
  }
  
  public void draw() {
    for (Meteor meteor : meteors) {
      meteor.draw();
    }
  }
  
  public float getProbabilityOfSpawn(){
    return chanceOfNewMeteor;
  }
  
  public void setProbabilityOfSpawn(float probability){
    chanceOfNewMeteor = probability;
  }
  
  //We simulate kinetic energy transfer between two moving objects, and change in direction in movement for both.
  private void handleCollision(Meteor m1, Meteor m2, PVector normalOfCollision){
    //from m1's perspective as stationary and m2 as incident on it.
    PVector incidentVelocity = m2.getVelocity().copy().normalize();
    float oldSpeedM2 = m2.getVelocity().mag();
    PVector m2Reflection = returnReflectionVector(incidentVelocity, normalOfCollision);
    //when m2 is stationary
    incidentVelocity = m1.getVelocity().copy().normalize();
    float oldSpeedM1 = m1.getVelocity().mag();
    PVector m1Reflection = returnReflectionVector(incidentVelocity, normalOfCollision.mult(-1));
    m1Reflection.mult(oldSpeedM1*ELASTICITY); //perfect reflection of m1's movement
    m2Reflection.mult(oldSpeedM2*ELASTICITY); //perfect reflection of m2's movement
    
    PVector transferredEnergyFromM2 = normalOfCollision.copy().mult(oldSpeedM2*(1-ELASTICITY));
    PVector transferredEnergyFromM1 = normalOfCollision.mult(-1).mult(oldSpeedM1*(1-ELASTICITY));
    
    
    m1Reflection.x += transferredEnergyFromM2.x;
    m1Reflection.y += transferredEnergyFromM2.y; //(1-elasticity) of m1's energy goes to m2, making reflection imperfect. 
    m2Reflection.x += transferredEnergyFromM1.x;
    m2Reflection.y += transferredEnergyFromM1.y; //(1-elasticity) of m1's energy goes to m2, making reflection imperfect.
    
    m1.setVelocity(m1Reflection.copy());
    m2.setVelocity(m2Reflection.copy());
  }
  
  private PVector returnReflectionVector(PVector incidence, PVector normal){
    float angleOfIncidence = normal.dot(incidence);
    return normal.mult(2*angleOfIncidence).sub(incidence).normalize().copy();
  }
}
