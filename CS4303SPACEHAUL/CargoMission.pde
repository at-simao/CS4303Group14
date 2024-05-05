class CargoMission extends Mission {
    private ArrayList<Planet> cargoToDeliver;

  //Setting mission planets

    public CargoMission(ArrayList<Planet> pickup, Planet delivery) {
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
            cargoToDeliver.add(pickupPlanet);
            if(!pickupPlanets.contains(pickupPlanet)){
              pickupPlanet.setMissionPlanet(false);
              // death will need to reset
            }
            return true;
          }
        }
      }
      else{
        if (player.getPosition().dist(destinationPlanet.getPosition()) < destinationPlanet.getDiameter()) {
          ui.updateCargo(player.getCargo().getColour());
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
        destinationPlanet.setMissionPlanet(false);  
        // other stuff
      }
      
    }
    
    @Override
    void update() {
      // Update planet missions
      if (!player1.hasCargo()) {
        super.update();
      }
      if (player1.hasCargo() && player1.getPosition().dist(destinationPlanet.getPosition()) < destinationPlanet.getDiameter()) {
        promptInteraction(player1);  
      }
      if (player2.hasCargo() && player2.getPosition().dist(destinationPlanet.getPosition()) < destinationPlanet.getDiameter()) {
        promptInteraction(player2);
      }           //<>//
    }

}
