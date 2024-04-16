class Planet {
  private float angle;
  private float orbit;
  private float period;

  private float diameter;
  public color colour;

  public Planet(float radius, float orbit, float period, color colour) {
    this.angle = random(TWO_PI);
    this.orbit = orbit;
    this.period = period;

    this.diameter = 2 * radius;
    this.colour = colour;
  }

  PVector getPosition() {
    float x = orbit * cos(angle);
    float y = orbit * sin(angle);

    return new PVector(x, y);
  }

  public void integrate() {
    angle += TWO_PI / period;
    angle %= TWO_PI;
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