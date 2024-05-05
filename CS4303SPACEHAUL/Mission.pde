static int lastMissionId = 0;

abstract class Mission {
    protected boolean isCompleted = false;
    protected ArrayList<Planet> pickupPlanets;
    protected Planet destinationPlanet;
    // Method to update mission status
    private int score;
    private boolean type;
    private int id;
   
    public Mission(ArrayList<Planet> originPlanets, Planet targetPlanet, boolean missionType) {
      destinationPlanet = targetPlanet;
      pickupPlanets = originPlanets;
      destinationPlanet.setMissionPlanet(true);
      this.id = ++lastMissionId;
      type = missionType;
      for(Planet planet : pickupPlanets) {
        planet.setMissionPlanet(true);
      }
    }
    
    public int getId() {
      return id;
    }
    
    public boolean getType() {
      return type;
    }
    
    public void update(){
      for(Planet planet : pickupPlanets) {
        if (player1.getPosition().dist(planet.getPosition()) < planet.getDiameter()) {
          promptInteraction(player1);
        }
        if (player2.getPosition().dist(planet.getPosition()) < planet.getDiameter()) {
          promptInteraction(player2);
        }
       }  
     }

    public ArrayList<Planet> getPickupPlanets() {
      return pickupPlanets;
    }
    
    public Planet getDestinationPlanet() {
      return destinationPlanet;
    }

    protected void promptInteraction(Player player) {
      textSize(30);
      stroke(0,0,0);
      textAlign(CENTER, CENTER);
      fill(0);
      text("Press "+(player == player1 ? "E" : "1") + " to interact", player == player1 ? width/4 : width/4*3, height / 4 * 3); // Position above the player
    }

    // Handle player interaction
    abstract boolean attemptAction(Player player);

    // Check if the mission is completed
    public boolean isCompleted() {
        return isCompleted;
    }
    
    public int getScore() {
      return score;
    }
        
    
    protected void calculateScore(boolean isCargoMission) {
        int distance = 0;
        if(isCargoMission) {
          for (Planet planet : pickupPlanets) {
            distance += map.planets.indexOf(planet);
          }
        }
        else {
          distance = map.planets.indexOf(pickupPlanets.get(0));
        }
        float missionMulti = isCargoMission ? 1 : 1.25; 
        int scorePerPlanet = 100; // Score per planet involved
        int planetScore = isCargoMission ? scorePerPlanet * pickupPlanets.size() : scorePerPlanet;
        int distanceScore = (int)(distance * 50); 
    
        int totalScore = (int)(100 + planetScore + distanceScore * missionMulti);
        
        score= totalScore;
    }
}