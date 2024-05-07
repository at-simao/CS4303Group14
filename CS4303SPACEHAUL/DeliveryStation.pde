public class DeliveryStation extends Body {
    private static final float k = 15;

    private float angle;
    private float orbit;
    private float period;

    public DeliveryStation(float orbit, float angle, float period) {
        super(new PVector(orbit * cos(angle), orbit * sin(angle)), new PVector(0,0), 0.01);

        this.angle = angle;
        this.orbit = orbit;
        this.period = period;
    }

    public PVector getPosition() {
        return position;
    }
    private void drawPickup() {
      CS4303SPACEHAUL.offScreenBuffer.stroke(255, 255, 255); // Yellow color for visibility
      CS4303SPACEHAUL.offScreenBuffer.noFill();
      float radius = 200;  // Slightly larger than the planet's diameter
      float angleStep = TWO_PI / 60;
      for (float angle = 0; angle < TWO_PI; angle += angleStep) {
        float x = cos(angle) * radius;
        float y = sin(angle) * radius;
        CS4303SPACEHAUL.offScreenBuffer.point(x, y);
      }
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
        int size = 40;

        CS4303SPACEHAUL.offScreenBuffer.pushMatrix();
        CS4303SPACEHAUL.offScreenBuffer.rotate(this.angle);
        CS4303SPACEHAUL.offScreenBuffer.translate(this.orbit, 0);
        CS4303SPACEHAUL.offScreenBuffer.fill(200);
        CS4303SPACEHAUL.offScreenBuffer.noStroke();
        CS4303SPACEHAUL.offScreenBuffer.ellipse(0, 0, size, size * 2); // Drawing a sphere
        CS4303SPACEHAUL.offScreenBuffer.stroke(200);
        CS4303SPACEHAUL.offScreenBuffer.strokeWeight(10);
        CS4303SPACEHAUL.offScreenBuffer.line(0, -size * 2, 0, size * 2); // Extend from both sides of the sphere
        CS4303SPACEHAUL.offScreenBuffer.strokeWeight(1);
        CS4303SPACEHAUL.offScreenBuffer.fill(#2B3B92); // Blue panels
        CS4303SPACEHAUL.offScreenBuffer.rect(-size, size * 2, size * 2, 5); // Right outer panel
        CS4303SPACEHAUL.offScreenBuffer.rect(-size, - size * 2 - 5, size * 2, 5); // Left outer panel
        CS4303SPACEHAUL.offScreenBuffer.rect(-size, size * 2 - 10, size * 2, 5);  // Right inner panel
        CS4303SPACEHAUL.offScreenBuffer.rect(-size, - size * 2 + 5, size * 2, 5);  // Left inner panel
        drawPickup();
        CS4303SPACEHAUL.offScreenBuffer.popMatrix();
    }
}
