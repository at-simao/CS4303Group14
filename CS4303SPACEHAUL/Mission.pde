static int lastMissionId = 0;

abstract class Mission {
  protected boolean isCompleted = false;
  protected ArrayList<Planet> pickupPlanets;
  protected ArrayList<Planet> destinationPlanets;
  protected ArrayList<Integer> uiPlanets;
  protected ArrayList<Integer> uiDPlanets;
    // Method to update mission status
  private int score;
  private boolean type;
  private int id;
   
  public Mission(ArrayList<Planet> originPlanets, ArrayList<Planet> targetPlanets, boolean missionType) {
    destinationPlanets = targetPlanets;
    pickupPlanets = originPlanets;
    uiPlanets = new ArrayList<Integer>();
    uiDPlanets = new ArrayList<Integer>();
    for(Planet planet : destinationPlanets) {
      planet.setMissionPlanet(true);
      uiDPlanets.add(planet.getColour());
    }
    this.id = ++lastMissionId;
    type = missionType;
    for(Planet planet : pickupPlanets) {
      planet.setMissionPlanet(true);
      uiPlanets.add(planet.getColour());
    }
  }
    
  protected void updateUi(color colour) {
    for(int i = 0;i < uiPlanets.size(); i++) {  
      if(uiPlanets.get(i) == colour) {
        uiPlanets.set(i, getFadedColour(colour));
        return;
      }
    }
  }
    
  protected color getFadedColour(color originalColour) {
    float r = red(originalColour) * 0.65;
    float g = green(originalColour) * 0.65;
    float b = blue(originalColour) * 0.65;
    return color(r, g, b);
  }  
    
    public boolean containsPlanet(Planet planet) {
      return pickupPlanets.contains(planet) || destinationPlanets.contains(planet);
    }
    
    public int getId() {
      return id;
    }
    
    public boolean getType() {
      return type;
    }
    
    public ArrayList<Integer> getUiPlanets() {
      return uiPlanets;
    }
     public ArrayList<Integer> getUiDPlanets() {
      return uiDPlanets;
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
    
    public ArrayList<Planet> getDestinationPlanets() {
      return destinationPlanets;
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
      for(int i = 0; i < pickupPlanets.size(); i++) {
        distance += abs(map.planets.indexOf(pickupPlanets.get(i)) - map.planets.indexOf(destinationPlanets.get(i)));
      }
    }
    float missionMulti = isCargoMission ? 1 : 1; 
    int scorePerPlanet = 100; // Score per planet involved
    int planetScore = scorePerPlanet * pickupPlanets.size();
    int distanceScore = (int)(distance * 50); 
    
    int totalScore = (int)(100 + planetScore + distanceScore * missionMulti);
        
    score= floor(CS4303SPACEHAUL.scoreMultiplier(totalScore));
  }
}
