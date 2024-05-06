class Map {
    private final int STAR_COLOUR = #fdf498;
    private final int[] PLANET_COLOURS = {#5c68a3, #a35c68, #e41e5f, #36e085, #f67303, #2127c8};
    private final float DELIVERY_STN_ORBIT = 150;

    public Planet star;
    public ArrayList<Planet> planets;
    public DeliveryStation deliveryStation;

    public Map() {
        planets = new ArrayList<>();
    }

    public void generate(int numPlanets) {
        planets.clear();
        planets.add(new Planet(random(300, 600), 0, random(TWO_PI), 1, STAR_COLOUR)); // Star
        deliveryStation = new DeliveryStation(planets.get(0).getRadius() + DELIVERY_STN_ORBIT, random(TWO_PI), random(2000, 5000));
        float previousOrbit = DELIVERY_STN_ORBIT;

        for (int i = 0; i < numPlanets; i++) {
            float radius = random(50, 200);
            float orbit = previousOrbit + random(800, 1500);
            previousOrbit = orbit;
            float angle = random(TWO_PI);
            float period = sq(i+1) * random(5000, 10000); // Example: Random orbital period
            planets.add(new Planet(radius, orbit, angle, period, PLANET_COLOURS[i]));
        }
    }

    public void integrate() {
        for (Planet planet : planets) {
            planet.integrate();
        }
        deliveryStation.integrate();
    }

    public void draw() {
        for (Planet planet : planets) {
            planet.draw();
        }
        deliveryStation.draw();
    }
}
