// package com.sheridan.group33.find_care.find_care;

// import com.sheridan.group33.find_care.find_care.Model.Node;
// import com.sheridan.group33.find_care.find_care.Model.Edge;
// import com.sheridan.group33.find_care.find_care.service.AStarPathFinding;
// import org.junit.jupiter.api.BeforeEach;
// import org.junit.jupiter.api.Test;
// import static org.junit.jupiter.api.Assertions.*;

// import java.util.*;

// class AStarPathFindingTest {

//     private AStarPathFinding pathfinding;
//     private Map<Node, List<Edge>> graph;

//     @BeforeEach
//     void setUp() {
//         // Initialize A* algorithm
//         pathfinding = new AStarPathFinding();

//         // Create a test graph
//         graph = new HashMap<>();

//         Node entrance = new Node("Entrance", 0, 0, 1);
//         Node hallwayA = new Node("HallwayA", 10, 5, 1);
//         Node room101 = new Node("Room101", 20, 10, 1);
//         Node room102 = new Node("Room102", 25, 10, 1);

//         // Create connections
//         graph.put(entrance, Arrays.asList(new Edge(entrance, hallwayA, 10)));
//         graph.put(hallwayA, Arrays.asList(new Edge(hallwayA, room101, 10), new Edge(hallwayA, room102, 5)));
//         graph.put(room101, Collections.emptyList());
//         graph.put(room102, Collections.emptyList());

//         // Load graph into the algorithm
//         pathfinding.setGraph(graph);
//     }

//     @Test
//     void testFindShortestPath_ValidPath() {
//         Node start = new Node("Entrance", 0, 0, 1);
//         Node goal = new Node("Room102", 25, 10, 1);

//         List<Node> path = pathfinding.findPath(start, goal);

//         assertNotNull(path, "Path should not be null");
//         assertEquals(3, path.size(), "Path should contain 3 nodes (Entrance -> HallwayA -> Room102)");
//         assertEquals("Entrance", path.get(0).getId());
//         assertEquals("HallwayA", path.get(1).getId());
//         assertEquals("Room102", path.get(2).getId());
//     }

//     @Test
//     void testFindShortestPath_NoPath() {
//         Node start = new Node("Room101", 20, 10, 1);
//         Node goal = new Node("Entrance", 0, 0, 1);

//         List<Node> path = pathfinding.findPath(start, goal);

//         assertTrue(path.isEmpty(), "No path should be found");
//     }
// }
