<?php
include("../config/db.php");

$data = json_decode(file_get_contents("php://input"), true);

$name = $data['name'];
$email = $data['email'];
$password = password_hash($data['password'], PASSWORD_DEFAULT);
$role = $data['role'] ?? 'student';
if ($role === 'user') {
    $role = 'student';
}
$faculty_id = $data['faculty_id'];

$sql = "INSERT INTO users (name, email, password, role, faculty_id)
        VALUES ('$name', '$email', '$password', '$role', '$faculty_id')";

$check = $conn->query("SELECT id FROM users WHERE email='$email'");
if ($check->num_rows > 0) {
    echo json_encode(["status"=>"error","message"=>"Email already exists"]);
    exit;
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
