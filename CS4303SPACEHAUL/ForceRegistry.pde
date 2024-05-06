import java.util.*;

public class ForceRegistry {

    private HashMap<Body, Set<ForceGenerator>> registry = new HashMap<>();

    /**
     * Register the given force to apply to the given body.
     */
    public void add(Body body, ForceGenerator fg) {
        registry.computeIfAbsent(body, k -> new HashSet<>()).add(fg);
    }

    /**
     * Remove all force generators associated with a specific body.
     */
    public void remove(Body body) {
        Set<ForceGenerator> forceGs = registry.remove(body);
        if (forceGs != null) println("Removed body");
        Gravity gravity = new Gravity(body);

        for (HashMap.Entry<Body, Set<ForceGenerator>> entry : registry.entrySet()) {
            Set<ForceGenerator> fgs = entry.getValue();
            boolean removed = fgs.removeIf(fg -> fg instanceof Gravity && ((Gravity) fg).gravitationalBody.equals(gravity));
            println("Removed forceGenerator");
        }
    }

    /**
     * Clear all registrations from the registry.
     */
    public void clear() {
        registry.clear();
    }

    /**
     * Calls all force generators to update the forces of their corresponding bodies.
     */
    public void updateForces() {
        for (HashMap.Entry<Body, Set<ForceGenerator>> entry : registry.entrySet()) {
            for (ForceGenerator fg : entry.getValue()) {
                fg.updateForce(entry.getKey());
            }
        }
    }
}
