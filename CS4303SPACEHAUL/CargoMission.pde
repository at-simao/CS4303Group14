class CargoMission extends Mission {
    private ArrayList<Planet> cargoToDeliver;

  //Setting mission planets

    public CargoMission(ArrayList<Planet> pickup, ArrayList<Planet> delivery) {
      super(pickup, delivery, true);
      cargoToDeliver = new ArrayList<>();
      calculateScore(true);
    }
    
    public boolean attemptAction(Player player) {
      if (!player.hasCargo()) {
        for(Planet pickupPlanet : pickupPlanets) {
          if (player.getPosition().dist(pickupPlanet.getPosition()) < pickupPlanet.getDiameter()) {
            player.setCargo(pickupPlanet);
            pickupPlanets.remove(pickupPlanet);
            updateUi(pickupPlanet.getColour());
            cargoToDeliver.add(pickupPlanet);
            if(!pickupPlanets.contains(pickupPlanet)){
              missionManager.updatePickupZone(pickupPlanet);
            }
            return true;
          }
        }
      }
      else{
        if (player.getPosition().dist(destinationPlanets.get(0).getPosition()) < destinationPlanets.get(0).getDiameter()) {
          updateUi(getFadedColour(player.getCargo().getColour()));
          cargoToDeliver.remove(player.getCargo());
          player.setCargo(null);
          checkComplete();
        }      
      }
      return false;
    }
    
    void checkComplete() {
      if(pickupPlanets.isEmpty() && cargoToDeliver.isEmpty()){
        isCompleted = true; 
        missionManager.updatePickupZone(destinationPlanets.get(0));
        // other stuff
      }
      
    }
    
    @Override
    void update() {
      // Update planet missions
      if (!player1.hasCargo()) {
        super.update();
      }
      if (player1.hasCargo() && player1.getPosition().dist(destinationPlanets.get(0).getPosition()) < destinationPlanets.get(0).getDiameter()) {
        promptInteraction(player1);  
      }
      if (player2.hasCargo() && player2.getPosition().dist(destinationPlanets.get(0).getPosition()) < destinationPlanets.get(0).getDiameter()) {
        promptInteraction(player2);
      }           //<>//
    }

}
