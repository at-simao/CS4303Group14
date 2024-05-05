class Planet extends Body {
    private static final float k = 20;

    private float angle;
    private float orbit;
    private float period;

    private float diameter;
    public color colour;

    public Planet(float radius, float orbit, float angle, float period, color colour) {
        super(new PVector(orbit * cos(angle), orbit * sin(angle)), new PVector(0,0));

        this.invMass = k / (radius * radius);

        this.angle = angle;
        this.orbit = orbit;
        this.period = period;

        this.diameter = 2f * radius;
        this.colour = colour;
    }

    public PVector getPosition() {
        return position;
    }

    public float getRadius() {
        return diameter / 2f;
    }
    
    public float getDiameter() {
        return diameter;
    }

    public void integrate() {
        this.angle += TWO_PI / period;
        this.angle %= TWO_PI;

        this.position.x = orbit * cos(angle);
        this.position.y = orbit * sin(angle);

        float orbitalSpeed = 2 * PI * orbit / period;
        this.velocity.x = -orbitalSpeed * sin(angle); // Cosine term for x-component of tangential velocity
        this.velocity.y = orbitalSpeed * cos(angle);  // Sine term for y-component of tangential velocity
    }

    public void draw() {
        CS4303SPACEHAUL.offScreenBuffer.pushMatrix(); // Save the current state of the coordinate system
        CS4303SPACEHAUL.offScreenBuffer.rotate(angle); // Rotate the coordinate system by the current angle
        CS4303SPACEHAUL.offScreenBuffer.translate(orbit, 0); // Move to the correct position in the orbit
        CS4303SPACEHAUL.offScreenBuffer.fill(colour); // Set the color for the planet
        CS4303SPACEHAUL.offScreenBuffer.noStroke(); // No border for the planet
        CS4303SPACEHAUL.offScreenBuffer.ellipse(0, 0, diameter, diameter); // Draw the planet as a circle
        CS4303SPACEHAUL.offScreenBuffer.popMatrix(); // Restore the original state of the coordinate system
    }
}
