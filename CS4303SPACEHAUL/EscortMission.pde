import java.util.Iterator;

class EscortMission extends Mission {
  private ArrayList<FriendlyAI> escortAIs = new ArrayList<>();
  private HashMap<Integer, Boolean> aiSpawned = new HashMap<>();
  private HashMap<Integer, Player> escortPlayers = new HashMap<>();
  private int numOfAIThatMadeIt = 0;
  private int numOfDeadAI = 0;
  private int maxAI = 0;
  private int maxFollowingAI = 5;
  
  public EscortMission(ArrayList<Planet> origin, ArrayList<Planet> destination) {
    super(origin,destination, false);
    calculateScore(false);
    maxAI = destination.size();
  }
    
    // attempt interaction with player
  public boolean attemptAction(Player player) { //<>//
    Iterator<Planet> planetIterator = pickupPlanets.iterator();
    Iterator<Planet> destinationIterator = destinationPlanets.iterator();
    // Change  
    for(FriendlyAI ai: escortAIs) {  // attempt AI drop off first
      if(escortPlayers.get(ai.getID()) == player && ai.getPosition().dist(ai.getDestination().getPosition()) < ai.getDestination().getDiameter()) {
        ai.seekPlanet();  // Set seek true instead
        player.decreaseAIs();
        updateUi(ai.getColour(),false);
        return true;  //<>//
      }
    }
    
    while (planetIterator.hasNext()) {
      Planet origin = planetIterator.next();
      Planet destination = destinationIterator.next();
      if (player.getPosition().dist(origin.getPosition()) < origin.getDiameter()) {
        if(player.getAIs() > maxFollowingAI) {break;}  // limit following ai total
        FriendlyAI newAI = new FriendlyAI(origin.getPosition(), destination);
        aiList.add(newAI);
        newAI.setTarget(player);  // 
        escortAIs.add(newAI);
        aiSpawned.put(newAI.getID(), true);
        escortPlayers.put(newAI.getID(), player); //<>//
        updateUi(origin.getColour(), true);
        planetIterator.remove(); // Remove planet from pickup list after AI is spawned
        destinationIterator.remove();
        player.increaseAIs();
        if(!pickupPlanets.contains(origin)) {missionManager.updatePickupZone(origin, false);}
        return true;
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
        //Update drop off planets
        numOfAIThatMadeIt++;
        completeMission(ai, iterator); // Pass the iterator to the completeMission method
        continue;
      }
      if(ai.getHealth() <= 0){
        iterator.remove(); // Remove AI from the list using the iterator
        aiSpawned.remove(ai.getID());
        aiList.remove(ai);
        escortPlayers.remove(ai.getID());
        numOfDeadAI++;
        continue;
      }
      if (aiSpawned.get(ai.getID()) && ai.getPosition().dist(ai.getDestination().getPosition()) < ai.getDestination().getDiameter()) {
        promptInteraction(escortPlayers.get(ai.getID()));
      }
    }
    if (pickupPlanets.isEmpty() && (numOfDeadAI + numOfAIThatMadeIt) == maxAI) {
      isCompleted = true; // Ensure all conditions are met before marking as complete
    }
  }
  private void completeMission(FriendlyAI ai, Iterator<FriendlyAI> iterator) {
    iterator.remove(); // Remove AI from the list using the iterator
    aiSpawned.remove(ai.getID());
    aiList.remove(ai);
    escortPlayers.remove(ai.getID());
  }
  
  public int getNumThatMadeIt(){
    return numOfAIThatMadeIt;
  }
  
  public int getMaxAI(){
    return maxAI;
  }
}
