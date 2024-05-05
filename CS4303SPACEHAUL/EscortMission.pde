import java.util.Iterator;

class EscortMission extends Mission {
  private ArrayList<FriendlyAI> escortAIs = new ArrayList<>();
  private HashMap<FriendlyAI, Boolean> aiSpawned = new HashMap<>();
  private HashMap<FriendlyAI, Player> escortPlayers = new HashMap<>();
  
  public EscortMission(ArrayList<Planet> origin, ArrayList<Planet> destination) {
    super(origin,destination, false);
    calculateScore(false);
  }
    
  public boolean attemptAction(Player player) { //<>//
    Iterator<Planet> planetIterator = pickupPlanets.iterator();
    Iterator<Planet> destinationIterator = destinationPlanets.iterator();
        System.out.println("EAA");
    // Change
    for(FriendlyAI ai: escortAIs) {
      if(escortPlayers.get(ai) == player && ai.getPosition().dist(ai.getDestination().getPosition()) < ai.getDestination().getDiameter()) {
        ai.seekPlanet();  // Set seek true instead
        player.decreaseAIs();
        System.out.println("EAA2");
        return true; //<>//
      }
    }
    
    while (planetIterator.hasNext()) {
      Planet origin = planetIterator.next();
      Planet destination = destinationIterator.next();
      System.out.println("EAA3");
     // if (!aiSpawned.containsKey(origin) && player.getPosition().dist(origin.getPosition()) < origin.getDiameter()) {
      if (player.getPosition().dist(origin.getPosition()) < origin.getDiameter()) {
        System.out.println("EAA4");
        if(player.getAIs() > 1) {break;}
        System.out.println("EAA5");
        FriendlyAI newAI = new FriendlyAI(origin.getPosition(), destination);System.out.println("EAA51");
        aiList.add(newAI);System.out.println("EAA52");
        newAI.setTarget(player); System.out.println("EAA53"); // move to constructor
        escortAIs.add(newAI);System.out.println("EAA54");
        aiSpawned.put(newAI, true);System.out.println("EAA55");
        escortPlayers.put(newAI, player);System.out.println("EAA56");
        updateUi(origin.getColour());System.out.println("EAA57");
        planetIterator.remove(); System.out.println("EAA58");// Remove planet from pickup list after AI is spawned
        destinationIterator.remove();System.out.println("EAA59");
        player.increaseAIs();
        System.out.println("EAA6");
        if(!pickupPlanets.contains(origin)) {missionManager.updatePickupZone(origin);}
        System.out.println("EAA7");
        return true;
      }
    }
    System.out.println("EAA8");
    return false;
  }
    
  @Override
  void update() {
    super.update();
    Iterator<FriendlyAI> iterator = escortAIs.iterator();
    while (iterator.hasNext()) {
      FriendlyAI ai = iterator.next();
      if (ai.arrived()) {
        //Update drop off planets
        updateUi(getFadedColour(ai.getDestination().getColour()));
        completeMission(ai, iterator); // Pass the iterator to the completeMission method
        continue;
      }
      if (aiSpawned.get(ai) && ai.getPosition().dist(ai.getDestination().getPosition()) < ai.getDestination().getDiameter()) {
        promptInteraction(escortPlayers.get(ai));
      }
    }
    if (pickupPlanets.isEmpty() && escortAIs.isEmpty()) {
      isCompleted = true; // Ensure all conditions are met before marking as complete
     // missionManager.updatePickupZone(destinationPlanets);
    }
  }
  private void completeMission(FriendlyAI ai, Iterator<FriendlyAI> iterator) {
    iterator.remove(); // Remove AI from the list using the iterator
    aiSpawned.remove(ai);
    aiList.remove(ai);
    escortPlayers.remove(ai);
  }
}
