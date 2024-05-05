import java.util.Iterator;

class EscortMission extends Mission {
  private ArrayList<FriendlyAI> escortAIs = new ArrayList<>();
  private HashMap<FriendlyAI, Boolean> aiSpawned = new HashMap<>();
  private HashMap<FriendlyAI, Player> escortPlayers = new HashMap<>();

  public EscortMission(ArrayList<Planet> origin, Planet destination) {
    super(origin,destination, false);
    calculateScore(false);
  }
    
  public boolean attemptAction(Player player) {
    Iterator<Planet> planetIterator = pickupPlanets.iterator();
    while (planetIterator.hasNext()) {
      Planet origin = planetIterator.next();
      if (!aiSpawned.containsKey(origin) && player.getPosition().dist(origin.getPosition()) < origin.getDiameter()) {
        FriendlyAI newAI = new FriendlyAI(origin.getPosition(), origin.getColour());
        aiList.add(newAI);
        newAI.setTarget(player);
        escortAIs.add(newAI);
        aiSpawned.put(newAI, true);
        escortPlayers.put(newAI, player);
        planetIterator.remove(); // Remove planet from pickup list after AI is spawned
        if(!pickupPlanets.contains(origin)) {origin.setMissionPlanet(false);}
        return true;
      }
    }
    for(FriendlyAI ai: escortAIs) {
      if(escortPlayers.get(ai) == player && ai.getPosition().dist(destinationPlanet.getPosition()) < destinationPlanet.getDiameter()) {
        ai.setTargetPlanet(destinationPlanet);
      }
    }
    return false;
  }
    
  @Override
  void update() {
    super.update();
    Iterator<FriendlyAI> iterator = escortAIs.iterator();
    while (iterator.hasNext()) {
      FriendlyAI ai = iterator.next();
      if (ai.arrived()) {
        completeMission(ai, iterator); // Pass the iterator to the completeMission method
        continue;
      }
      if (aiSpawned.get(ai) && ai.getPosition().dist(destinationPlanet.getPosition()) < destinationPlanet.getDiameter()) {
        if (player1.getPosition().dist(destinationPlanet.getPosition()) < destinationPlanet.getDiameter()) {
          promptInteraction(player1);
        }
        else {
          if (player2.getPosition().dist(destinationPlanet.getPosition()) < destinationPlanet.getDiameter()) {
            promptInteraction(player2);
          }
        }
      }
    }
    if (pickupPlanets.isEmpty() && escortAIs.isEmpty()) {
      isCompleted = true; // Ensure all conditions are met before marking as complete
      destinationPlanet.setMissionPlanet(false); // Remove drop-off indicator
    }
  }
  private void completeMission(FriendlyAI ai, Iterator<FriendlyAI> iterator) {
    ui.updateCargo(ai.getColour());
    iterator.remove(); // Remove AI from the list using the iterator
    aiSpawned.remove(ai);
    aiList.remove(ai);
    escortPlayers.remove(ai);
  }
}
