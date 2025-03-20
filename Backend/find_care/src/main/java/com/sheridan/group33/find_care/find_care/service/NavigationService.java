package com.sheridan.group33.find_care.find_care.service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sheridan.group33.find_care.find_care.Model.Node;
import com.sheridan.group33.find_care.find_care.Repository.NodeRepository;

@Service
public class NavigationService {

    @Autowired
    private NodeRepository nodeRepository;

    @Autowired
    private AStarPathFinding aStarPathfinding;

    public List<Node> getShortestPath(String startId, String endId) {
        Optional<Node> start = nodeRepository.findById(startId);
        Optional<Node> end = nodeRepository.findById(endId);

        if (start.isPresent() && end.isPresent()) {
            return aStarPathfinding.findPath(start.get(), end.get());
        }
        return List.of();
    }
}
