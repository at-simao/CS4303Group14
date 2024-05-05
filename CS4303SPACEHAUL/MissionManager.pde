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
          score += mission.getScore();
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
      if(mission.attemptAction(player)){return;};
    }
  }

  // Method to add a new mission
  public void addMission(Mission mission) {
    activeMissions.add(mission);

  }

  // Could be called every game tick or based on certain events
  public boolean checkForNewMission() {
    return (activeMissions.isEmpty() || (activeMissions.size() < 3 && random(0,1) < 0.02));
  }
}
