<?php
include("../config/db.php");

$sql = "SELECT id, name, email, role, faculty_id, created_at 
        FROM users 
        ORDER BY id DESC";

$result = $conn->query($sql);

$data = [];

while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode([
    "status" => "success",
    "data" => $data
]);

$conn->close();
?>