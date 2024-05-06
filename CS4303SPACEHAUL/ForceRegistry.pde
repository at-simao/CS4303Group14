import java.util.Iterator ;

/**
 * Holds all the force generators and the particles they apply to
 */
public class ForceRegistry {
  
    /**
     * Keeps track of one force generator and the particle it applies to.
     */
    private class ForceRegistration {
        public final Body body;
        public final ForceGenerator forceGenerator;

        ForceRegistration (Body body, ForceGenerator fg) {
            this.body = body;
            this.forceGenerator = fg;
        }
    }
  
    // Holds the list of registrations
    ArrayList<ForceRegistration> registrations = new ArrayList();
    
    /**
     * Register the given force to apply to the given particle
     */
    void add(Body body, ForceGenerator fg) {
        registrations.add(new ForceRegistration(body, fg));
    }
  
    /**
     * Remove the given registered pair from the registry. If the
     * pair is not registered, this method will have no effect.
     */
    // This is going to be very inefficient with an AL. Suspect a
    // Hashmap with generator as key and value as list of particles
    // would be better.

    /**
     * Clear all registrations from the registry
     */
    void clear() {
        registrations.clear(); 
    }
  
    /**
     * Calls all force generators to update the forces of their corresponding particles.
     */
    void updateForces() {
        Iterator<ForceRegistration> iterator = registrations.iterator();

        while (iterator.hasNext()) {
            ForceRegistration fr = iterator.next();
            if(fr.body instanceof Player){
              if(((Player)fr.body).getRespawnTimer() != null){
                continue;
              }
            }
            fr.forceGenerator.updateForce(fr.body);
        }
    }
}
