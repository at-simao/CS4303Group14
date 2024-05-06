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
<<<<<<< HEAD
        // println("Updating Force");
        //println("Player position: " + body.position);
        //println("Planet position: " + planet.position);
        if(body instanceof Player){
          if(((Player)body).getRespawnTimer() != null){
            return;
          }
        }
=======
>>>>>>> 08c50e4 (tidied up gravity forcegenerator code)
        PVector direction = PVector.sub(planet.position, body.position);
        float distance = floor(direction.mag());
        direction.normalize();

        // Prevents dividing by 0 and prevents calculation if masses are infinite.
        if (distance == 0f) return;
        if (body.getInvMass() <= 0f) return;
        if (planet.getInvMass() <= 0f) return;

        float forceMagnitude = G * (body.getMass() * planet.getMass()) / (distance * distance);

        PVector resultingForce = direction.copy();
        resultingForce.mult(forceMagnitude); // Scale the direction by the force magnitude
        resultingForce.mult(body.getMass());

        body.addForce(resultingForce);
    }
}
