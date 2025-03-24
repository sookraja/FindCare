DROP TABLE IF EXISTS edge;
DROP TABLE IF EXISTS node;

-- Create Nodes (Waypoints)
CREATE TABLE IF NOT EXISTS node (
    id VARCHAR(50) PRIMARY KEY,  -- Unique ID like 'Room101', 'HallwayA'
    x DOUBLE NOT NULL,           -- X coordinate
    y DOUBLE NOT NULL,           -- Y coordinate
    floor INT NOT NULL           -- Floor number
);

-- Create Edges (Connections)
CREATE TABLE IF NOT EXISTS edge (
    id INT AUTO_INCREMENT PRIMARY KEY,
    from_node_id VARCHAR(50) NOT NULL,
    to_node_id VARCHAR(50) NOT NULL,
    weight DOUBLE NOT NULL,       -- Distance or time cost
    FOREIGN KEY (from_node_id) REFERENCES node(id),
    FOREIGN KEY (to_node_id) REFERENCES node(id)
);      

-- Insert sample nodes (Waypoints)
INSERT INTO node (id, x, y, floor) VALUES 
    ('Entrance', 0, 0, 1),
    ('Reception', 10, 5, 1),
    ('HallwayA', 20, 5, 1),
    ('Room101', 25, 10, 1),
    ('Room102', 30, 10, 1),
    ('Stairs', 15, 10, 1),
    ('Elevator', 15, 15, 1),
    ('Cafeteria', 35, 5, 1),
    ('HallwayB', 20, 5, 2),
    ('Room201', 25, 10, 2),
    ('Room202', 30, 10, 2);

-- Insert sample edges (Paths) - Bi-directional
INSERT INTO edge (from_node_id, to_node_id, weight) VALUES 
    ('Entrance', 'Reception', 10), ('Reception', 'Entrance', 10),
    ('Reception', 'HallwayA', 10), ('HallwayA', 'Reception', 10),
    ('HallwayA', 'Room101', 7), ('Room101', 'HallwayA', 7),
    ('HallwayA', 'Room102', 10), ('Room102', 'HallwayA', 10),
    ('HallwayA', 'Stairs', 5), ('Stairs', 'HallwayA', 5),
    ('HallwayA', 'Elevator', 10), ('Elevator', 'HallwayA', 10),
    ('Stairs', 'HallwayB', 2), ('HallwayB', 'Stairs', 2),  -- Stairs leading to Floor 2
    ('Elevator', 'HallwayB', 10), ('HallwayB', 'Elevator', 10),  -- Slower than stairs
    ('HallwayB', 'Room201', 7), ('Room201', 'HallwayB', 7),
    ('HallwayB', 'Room202', 10), ('Room202', 'HallwayB', 10),
    ('HallwayA', 'Cafeteria', 15), ('Cafeteria', 'HallwayA', 15);


