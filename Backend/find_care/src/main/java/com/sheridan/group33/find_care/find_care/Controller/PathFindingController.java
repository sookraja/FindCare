package com.sheridan.group33.find_care.find_care.Controller;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.sheridan.group33.find_care.find_care.Model.Node;
import com.sheridan.group33.find_care.find_care.Repository.NodeRepository;
import com.sheridan.group33.find_care.find_care.service.AStarPathFinding;

@RestController
@RequestMapping("/api/pathfinding")
public class PathFindingController {

    @Autowired
    private AStarPathFinding aStarPathFinding;
    
    private final NodeRepository nodeRepository;


    public PathFindingController(NodeRepository nodeRepository) {
        this.nodeRepository = nodeRepository;
    }

    @GetMapping("/find")
    public ResponseEntity<List<Node>> findPath(
            @RequestParam String startNodeId,
            @RequestParam String goalNodeId) {
        
        // In a real implementation, you would get these nodes from your repository
        Optional<Node> startNode = nodeRepository.findById(startNodeId);
        Optional<Node> goalNode = nodeRepository.findById(goalNodeId);
                
        // In a real implementation, you would do something like this:
        if (startNode.isPresent() && goalNode.isPresent()) {
            List<Node> path = aStarPathFinding.findPath(startNode.get(), goalNode.get());
            if (path.isEmpty()) {
                return ResponseEntity.noContent().build();
                // logger.log(Level.INFO ,"Path is empty");
            }
            return ResponseEntity.ok(path);
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}