package com.sheridan.group33.find_care.find_care.service;

import com.sheridan.group33.find_care.find_care.Model.Node;
import com.sheridan.group33.find_care.find_care.Model.Edge;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class AStarPathFinding {

    // Default constructor
    public AStarPathFinding() {
    }

    // Heuristic function: Uses Euclidean distance
    private double heuristic(Node a, Node b) {
        return Math.sqrt(Math.pow(a.getX() - b.getX(), 2) + Math.pow(a.getY() - b.getY(), 2));
    }

    public List<Node> findPath(Node start, Node goal) {
        Map<Node, Double> fScore = new HashMap<>(); // Declare fScore map here
        PriorityQueue<Node> openSet = new PriorityQueue<>(Comparator.comparingDouble(n -> fScore.getOrDefault(n, Double.MAX_VALUE)));
        Map<Node, Node> cameFrom = new HashMap<>();
        Map<Node, Double> gScore = new HashMap<>();

        gScore.put(start, 0.0);
        fScore.put(start, heuristic(start, goal));
        openSet.add(start);

        while (!openSet.isEmpty()) {
            Node current = openSet.poll();
            if (current.equals(goal)) return reconstructPath(cameFrom, current);

            for (Edge edge : current.getEdges()) {
                Node neighbor = edge.getToNode();
                double tentativeGScore = gScore.getOrDefault(current, Double.MAX_VALUE) + edge.getWeight();

                if (tentativeGScore < gScore.getOrDefault(neighbor, Double.MAX_VALUE)) {
                    cameFrom.put(neighbor, current);
                    gScore.put(neighbor, tentativeGScore);
                    fScore.put(neighbor, tentativeGScore + heuristic(neighbor, goal));
                    openSet.add(neighbor);
                }
            }
        }
        return Collections.emptyList(); // No path found
    }

    private List<Node> reconstructPath(Map<Node, Node> cameFrom, Node current) {
        List<Node> path = new ArrayList<>();
        while (current != null) {
            path.add(current);
            current = cameFrom.get(current);
        }
        Collections.reverse(path);
        return path;
    }
}