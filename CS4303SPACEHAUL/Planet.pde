class Planet {
  private float angle;
  private float orbit;
  private float period;

  private float diameter;
  public color colour;
  private boolean missionPlanet = false;

  public Planet(float radius, float orbit, float period, color colour) {
    this.angle = random(TWO_PI);
    this.orbit = orbit;
    this.period = period;

    this.diameter = 2 * radius;
    this.colour = colour;
  }

  public void setMissionPlanet(boolean newMissionPlanet) {
    missionPlanet = newMissionPlanet;
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
  
  public float getDiameter(){
    return diameter;
  }

  public color getColour() {
    return colour;
  }

  public void draw() {
    CS4303SPACEHAUL.offScreenBuffer.pushMatrix(); // Save the current state of the coordinate system
    CS4303SPACEHAUL.offScreenBuffer.rotate(angle); // Rotate the coordinate system by the current angle
    CS4303SPACEHAUL.offScreenBuffer.translate(orbit, 0); // Move to the correct position in the orbit
    CS4303SPACEHAUL.offScreenBuffer.fill(colour); // Set the color for the planet
    CS4303SPACEHAUL.offScreenBuffer.noStroke(); // No border for the planet
    //CS4303SPACEHAUL.offScreenBuffer.ellipse(0, 0, diameter, diameter); // Draw the planet as a circle
    if(this != CS4303SPACEHAUL.map.star){
      CS4303SPACEHAUL.offScreenBuffer.arc(0,0,diameter,diameter,HALF_PI, HALF_PI*3);
      CS4303SPACEHAUL.offScreenBuffer.fill(lerpColor(color(0,0,0), colour, 0.5)); // Set the color for the planet
      CS4303SPACEHAUL.offScreenBuffer.rotate(PI); // Rotate the coordinate system by the current angle
      CS4303SPACEHAUL.offScreenBuffer.arc(0,0,diameter,diameter,HALF_PI, HALF_PI*3);
      CS4303SPACEHAUL.offScreenBuffer.rotate(-PI); // Rotate the coordinate system by the current angle
    } else {
      CS4303SPACEHAUL.offScreenBuffer.ellipse(0, 0, diameter, diameter); // Draw the planet as a circle
    }


    if(missionPlanet) {
      drawPickup();
    }
    
    CS4303SPACEHAUL.offScreenBuffer.popMatrix(); // Restore the original state of the coordinate system
  }
  
  private void drawPickup() {
        CS4303SPACEHAUL.offScreenBuffer.stroke(255, 255, 255); // Yellow color for visibility
        CS4303SPACEHAUL.offScreenBuffer.noFill();
        float radius = diameter;  // Slightly larger than the planet's diameter
        float angleStep = TWO_PI / 60;
        for (float angle = 0; angle < TWO_PI; angle += angleStep) {
            float x = cos(angle) * radius;
            float y = sin(angle) * radius;
            CS4303SPACEHAUL.offScreenBuffer.point(x, y);
        }
    }
  
  
}
