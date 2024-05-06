/**
 * A force generator that applies a gravitational force.
 * One instance can be used for multiple particles.
 */
public final class Gravity extends ForceGenerator {
    private static final float G = 0.1;
    private Planet planet;
    
    // Constructs the generator with the given acceleration
    public Gravity(Planet planet) {
        this.planet = planet;
    }

    /**
     * Adds the effect of gravity from the planet onto the body. Gravitational force is calculated
     * using Newton's Law of Gravitation: F = G ⋅ (m_1 ⋅ m_2) / r^2
     */
    public void updateForce(Body body) {
        // println("Updating Force");
        //println("Player position: " + body.position);
        //println("Planet position: " + planet.position);
        if(body instanceof Player){
          if(((Player)body).getRespawnTimer() != null){
            return;
          }
        }
        PVector direction = PVector.sub(planet.position, body.position);
        float distance = floor(direction.mag());
        direction.normalize();

        // Prevents dividing by 0 and prevents calculation if masses are infinite.
        if (distance == 0f) {
            // println("Distance is 0.");
            return;
        };
        if (body.getInvMass() <= 0f) {
            // println("Ship has infinite mass.");
            return;
        }
        if (planet.getInvMass() <= 0f) {
            // println("Planet has infinite mass.");
            return;
        }

        float forceMagnitude = G * (body.getMass() * planet.getMass()) / (distance * distance);
        // println("Ship Mass: " + body.getMass());
        // println("Planet Mass: " + planet.getMass());
        //println("Distance: " + distance);
        // println("Resulting Force Magnitude: " + forceMagnitude);

        PVector resultingForce = direction.copy();
        resultingForce.mult(forceMagnitude); // Scale the direction by the force magnitude
        resultingForce.mult(body.getMass());

        // println("Resulting Force: " + resultingForce);
        body.addForce(resultingForce);
    }
}
