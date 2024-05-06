import java.util.ArrayList;

class MissionManager {
  ArrayList<Mission> activeMissions;

  MissionManager() {
    activeMissions = new ArrayList<Mission>();
  }

  // Method to update all missions
  public void updateMissions() {
    Iterator<Mission> it = activeMissions.iterator();
    while (it.hasNext()) {
      Mission mission = it.next();
      mission.update();
        if (mission.isCompleted()) {
          if(!mission.getType()){
            score += floor(mission.getScore()* (float(((EscortMission)mission).getNumThatMadeIt())/float(((EscortMission)mission).getMaxAI())));
          } else{
            score += mission.getScore();
          }
          
          it.remove(); // Remove the mission if it's completed
        }
      }
  }

  public ArrayList<Mission> getActiveMissions() {
    return new ArrayList<>(activeMissions);  // Return a copy to prevent modification 
  }
  public void attemptAction(Player player) {
    Iterator<Mission> it = activeMissions.iterator();
    while (it.hasNext()) {  
      Mission mission = it.next();
      if(mission.attemptAction(player)){ System.out.println("EAA10");return;};
    }
  }

  // Method to add a new mission
  public void addMission(Mission mission) {
    activeMissions.add(mission);

  }

  public void updatePickupZone(Planet planet, boolean startOrEndPoint) {
    for(Mission mission : activeMissions) {
      if(mission.containsPlanet(planet)){
        return;
      }
    }
    if(startOrEndPoint){
      planet.setMissionEndPlanet(false);
    } else {
      planet.setMissionStartPlanet(false);
    }
  }

  // Could be called every game tick or based on certain events
  public boolean checkForNewMission() {
    return (activeMissions.isEmpty() || (activeMissions.size() < 3 && random(0,1) < 0.02));
  }
}
