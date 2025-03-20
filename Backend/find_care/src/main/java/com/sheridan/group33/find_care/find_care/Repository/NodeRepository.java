package com.sheridan.group33.find_care.find_care.Repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.sheridan.group33.find_care.find_care.Model.Node;

public interface NodeRepository extends JpaRepository<Node, String> {
    
    @Query("SELECT n FROM Node n WHERE n.id = :id")
    Optional<Node> findNodeById(@Param("id") String id);
}