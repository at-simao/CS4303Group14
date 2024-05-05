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

    //Method for determining strength of gravitational pull from one body to another.
    // PVector calculateGravityByBody(PVector body1Pos, PVector body2Pos){
    //     PVector gravity = new PVector(body2Pos.x - body1Pos.x, body2Pos.y - body1Pos.y);
    //     float distance = gravity.mag();
    //     if(distance == 0) {
    //         gravity.mult(0); //prevent divide by 0 error
    //     } else {
    //         gravity.mult(1/pow(distance, 2.25));
    //     }
    //     return gravity.copy();
    // }

    // update velocity based on gravitational pull.
    // void gravitationalPull(Body otherBody) {
    //     if(position.x == otherBody.getPosition().x && position.y == otherBody.getPosition().y){
    //     return; //if both objects are on top of each other, gravity is infinitely large, so do not calculate.
    //     }
    //     PVector gravity = calculateGravityByBody(getPosition(), otherBody.getPosition()); //body1 == this body, body2 == otherBody.
    //     // If infinite mass, we don't integrate
    //     if (invMass <= 0f) return;
        
    //     PVector acceleration = gravity.copy() ;
    //     acceleration.mult(invMass);
        
    //     // update velocity
    //     velocity.add(acceleration);
    // }

    /**
     * Adds the effect of gravity from the planet onto the body. Gravitational force is calculated
     * using Newton's Law of Gravitation: F = G ⋅ (m_1 ⋅ m_2) / r^2
     */
    public void updateForce(Body body) {
        // println("Updating Force");
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
        // println("Distance: " + distance);
        // println("Resulting Force Magnitude: " + forceMagnitude);

        PVector resultingForce = direction.copy();
        resultingForce.mult(forceMagnitude); // Scale the direction by the force magnitude
        resultingForce.mult(body.getMass());

        // println("Resulting Force: " + resultingForce);
        body.addForce(resultingForce);
    }
}