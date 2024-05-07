/**
 * A force generator that applies a gravitational force.
 * One instance can be used for multiple particles.
 */
public final class Gravity extends ForceGenerator {
    private static final float METEOR_MAX_DIST = 100;
    private static final float METEOR_MIN_DIST = 15;
    private static final float G = 0.1;
    public Body gravitationalBody;
    
    // Constructs the generator with the given acceleration
    public Gravity(Body gravitationalBody) {
        this.gravitationalBody = gravitationalBody;
    }

    /**
     * Adds the effect of gravity from the gravitationalBody onto the body. Gravitational force is calculated
     * using Newton's Law of Gravitation: F = G ⋅ (m_1 ⋅ m_2) / r^2
     */
    public void updateForce(Body body) {
        if (body instanceof Player) {
            if (((Player) body).getRespawnTimer() != null) {
                return;
            }
        }

        if (body instanceof Meteor) {
            if (body.position.dist(gravitationalBody.position) > METEOR_MAX_DIST || body.position.dist(gravitationalBody.position) < METEOR_MIN_DIST) return;
            // println("Updating force of meteor");
        }

        PVector direction = PVector.sub(gravitationalBody.position, body.position);
        float distance = floor(direction.mag());
        direction.normalize();

        // Prevents dividing by 0 and prevents calculation if masses are infinite.
        if (distance == 0f) return;
        if (body.getInvMass() <= 0f) return;
        if (gravitationalBody.getInvMass() <= 0f) return;

        float forceMagnitude = G * (body.getMass() * gravitationalBody.getMass()) / (distance * distance);

        PVector resultingForce = direction.copy();
        resultingForce.mult(forceMagnitude); // Scale the direction by the force magnitude
        resultingForce.mult(body.getMass());

        // println("Resulting Force: " + resultingForce);

        body.addForce(resultingForce);
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        Gravity gravity = (Gravity) obj;
        return gravitationalBody != null ? gravitationalBody.equals(gravity.gravitationalBody) : gravity.gravitationalBody == null;
    }

    @Override
    public int hashCode() {
        return (gravitationalBody != null ? gravitationalBody.hashCode() : 0);
    }
}
