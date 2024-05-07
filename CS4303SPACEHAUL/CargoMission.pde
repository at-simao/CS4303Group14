class CargoMission extends Mission {
    private ArrayList<Planet> cargoToDeliver;

  //Setting mission planets

    //public CargoMission(ArrayList<Planet> pickup, ArrayList<Planet> delivery) {
    //  super(pickup, delivery, true);
    //  cargoToDeliver = new ArrayList<>();
    //  calculateScore(true);
    //}
    public CargoMission(ArrayList<Planet> pickup) {
      super(pickup, true);
      cargoToDeliver = new ArrayList<>();
      //cargoCarriers = new HashMap<>();
      calculateScore(true);
    }
    
    public boolean attemptAction(Player player) {
      if (!player.hasCargo()) {
        for(Planet pickupPlanet : pickupPlanets) {
          if (player.getPosition().dist(pickupPlanet.getPosition()) < pickupPlanet.getDiameter()) {
            player.setCargo(pickupPlanet);
            pickupPlanets.remove(pickupPlanet);
            updateUi(pickupPlanet.getColour(), true);
            cargoToDeliver.add(pickupPlanet);
            if(!pickupPlanets.contains(pickupPlanet)){
              missionManager.updatePickupZone(pickupPlanet, false);
            }
            return true;
          }
        }
      }
      else{
        if(deliveryStation) { 
          if (player.getPosition().dist(map.deliveryStation.getPosition()) < 200) { // 200 
            if(!cargoToDeliver.contains(player.getCargo())) return false;
            updateUi(getFadedColour(player.getCargo().getColour()),true);
            cargoToDeliver.remove(player.getCargo());
            player.setCargo(null);
            checkComplete();
          }  
        }
      }
      return false;
    }
    
    void checkComplete() {
      if(pickupPlanets.isEmpty() && cargoToDeliver.isEmpty()){
        isCompleted = true;
        if(deliveryStation) {
          return;
        }
        missionManager.updatePickupZone(destinationPlanets.get(0), true);
        // other stuff
      }
      
    }
    
    @Override
    void update() {
      // Update planet missions
      super.update();
      if (player1.hasCargo() && player1.getPosition().dist(map.deliveryStation.getPosition()) < 200) {
        promptInteraction(player1);  
      } 
      if (player2.hasCargo() && player2.getPosition().dist(map.deliveryStation.getPosition()) < 200) {
        promptInteraction(player2);  
      }     //<>//
    }

}
