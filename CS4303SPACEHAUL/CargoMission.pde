class CargoMission extends Mission {
    private ArrayList<Planet> cargoToDeliver;

    public CargoMission(ArrayList<Planet> pickup) {
      super(pickup, true);
      cargoToDeliver = new ArrayList<>();
      //cargoCarriers = new HashMap<>();
      calculateScore(true);
    }
    
    // attempt interaciton with planet
    public boolean attemptAction(Player player) {
      if (!player.hasCargo()) {  // if dont have cargo attempt pickup of cargo
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
          if (player.getPosition().dist(map.deliveryStation.getPosition()) < 200) { // attempt drop off of cargo
            if(!cargoToDeliver.contains(player.getCargo())) return false;  // if cargo doesn't match return
            updateUi(getFadedColour(player.getCargo().getColour()),true);
            cargoToDeliver.remove(player.getCargo());
            player.setCargo(null);
            checkComplete();
          }  
        }
      }
      return false;
    }
    
    // check mission is completed
    void checkComplete() {
      if(pickupPlanets.isEmpty() && cargoToDeliver.isEmpty()){
        isCompleted = true;
        if(deliveryStation) {
          return;
        }
        missionManager.updatePickupZone(destinationPlanets.get(0), true);
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
