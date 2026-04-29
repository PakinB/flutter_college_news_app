<?php
include("../config/db.php");

$data = json_decode(file_get_contents("php://input"), true);

$id = intval($data['id']);
$name = $data['name'];
$faculty_id = $data['faculty_id'];
$role = $data['role'] ?? null;

if (!empty($data['password'])) {

    $password = password_hash($data['password'], PASSWORD_DEFAULT);

    $roleSql = $role ? ", role='$role'" : "";
    $sql = "UPDATE users 
            SET name='$name', password='$password', faculty_id='$faculty_id' $roleSql
            WHERE id=$id";
} else {

    $roleSql = $role ? ", role='$role'" : "";
    $sql = "UPDATE users 
            SET name='$name', faculty_id='$faculty_id' $roleSql
            WHERE id=$id";
}

if ($conn->query($sql)) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => $conn->error
    ]);
}
?>
