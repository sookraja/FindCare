package com.sheridan.group33.find_care.find_care.Controller;

import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.sheridan.group33.find_care.find_care.Model.Node;
import com.sheridan.group33.find_care.find_care.service.NavigationService;

@RestController
@RequestMapping("/api/navigation")
public class NavigationController {

    @Autowired
    private NavigationService navigationService;

    private static final Logger logger = Logger.getLogger(NavigationController.class.getName());

    @GetMapping("/route")
    public List<Node> getRoute(@RequestParam String start, @RequestParam String end, @RequestParam boolean accessibleOnly) {
        logger.log(Level.INFO, "Received request to get route from {0} to {1}", new Object[]{start, end});

        List<Node> route = navigationService.getShortestPath(start, end, accessibleOnly);
        logger.log(Level.INFO, "Route found: {0}", route);
        
        return route;
    }
}
