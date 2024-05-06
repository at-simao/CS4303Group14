public static class CollisionUtil {

    // Helper method to check if a point is inside a circle
    private static boolean pointInsideCircle(PVector point, PVector circleCenter, float radius) {
        return PVector.dist(point, circleCenter) < radius;
    }

    // Method to check if the center of a circle is inside a triangle
    private static boolean circleInsideTriangle(PVector circleCenter, PVector[] triangle) {
        // Using barycentric coordinates to check if point is inside triangle
        PVector v0 = PVector.sub(triangle[2], triangle[0]);
        PVector v1 = PVector.sub(triangle[1], triangle[0]);
        PVector v2 = PVector.sub(circleCenter, triangle[0]);

        float d00 = v0.dot(v0);
        float d01 = v0.dot(v1);
        float d11 = v1.dot(v1);
        float d20 = v2.dot(v0);
        float d21 = v2.dot(v1);

        float denom = d00 * d11 - d01 * d01;
        float v = (d11 * d20 - d01 * d21) / denom;
        float w = (d00 * d21 - d01 * d20) / denom;
        float u = 1.0f - v - w;

        return (u >= 0) && (v >= 0) && (w >= 0);
    }

    // Method to check if a triangle edge intersects with a circle
    private static boolean edgeIntersectsCircle(PVector A, PVector B, PVector center, float radius) {
        PVector edge = PVector.sub(B, A);
        PVector centerToA = PVector.sub(center, A);
        float a = edge.dot(edge);
        float b = 2 * centerToA.dot(edge);
        float c = centerToA.dot(centerToA) - radius * radius;
        float delta = b * b - 4 * a * c;

        if (delta < 0) {
            return false; // No intersection
        }

        float t1 = (-b - sqrt(delta)) / (2 * a);
        float t2 = (-b + sqrt(delta)) / (2 * a);

        return (t1 >= 0 && t1 <= 1) || (t2 >= 0 && t2 <= 1);
    }

    // Main method to check all types of collision between the player's triangle and the planet's circle
    public static boolean checkCollision(Player player, Planet planet) {
        float radius = planet.getRadius();
        PVector[] vertices = new PVector[3];
        float angle = player.orientation + HALF_PI;
        PVector basePos = player.position;

        // Calculate triangle vertices in world coordinates
        vertices[0] = new PVector(-player.radius, -player.radius).rotate(angle).add(basePos);
        vertices[1] = new PVector(-player.radius, player.radius).rotate(angle).add(basePos);
        vertices[2] = new PVector(player.radius*2, 0).rotate(angle).add(basePos);

        // Check for each type of collision
        for (PVector vertex : vertices) {
            if (pointInsideCircle(vertex, planet.position, radius)) {
                println("Vertex is inside planet");
                return true;
            }
        }

        if (circleInsideTriangle(planet.position, vertices)) {
            println("Planet is inside player");
            return true;
        }

        for (int i = 0; i < vertices.length; i++) {
            int next = (i + 1) % vertices.length;
            if (edgeIntersectsCircle(vertices[i], vertices[next], planet.position, radius)) {
                println("Edge intersects with planet.");
                return true;
            }
        }

        return false; // No collision detected
    }

    public static void handleCollision(Player player, Body planet) {
        // Calculate the normal vector from the planet to the player
        PVector collisionNormal = PVector.sub(player.position, planet.position);
        collisionNormal.normalize();

        PVector relativeVelocity = PVector.sub(player.velocity, planet.velocity);
        float velocityAlongNormal = relativeVelocity.dot(collisionNormal);

        // Calculate the force needed to stop the player
        PVector stoppingForce = PVector.mult(collisionNormal, -velocityAlongNormal * player.getMass());

        // Apply an additional force to push the player away, ensuring they don't penetrate the barrier
        // This can be adjusted based on how hard you want the barrier to feel
        float restitutionCoefficient = 0.2f;  // This makes the collision slightly bouncy
        PVector additionalForce = PVector.mult(collisionNormal, restitutionCoefficient * velocityAlongNormal);

        //println("Velocity along normal: " + velocityAlongNormal);
        PVector counterForce = PVector.add(stoppingForce, additionalForce);
        PVector resultingAcceleration = counterForce.copy();
        resultingAcceleration.mult(player.getInvMass());
        float counterVelocityAlongNormal = resultingAcceleration.dot(collisionNormal);
        //println("Velocity enacted by counter force: " + counterVelocityAlongNormal);

        // Add both forces to the force accumulator
        player.addForce(PVector.add(stoppingForce, additionalForce));
    }
}
