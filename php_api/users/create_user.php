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
if ($role === 'staff') {
    $role = 'employee';
}
$allowed_roles = ['admin', 'pr', 'teacher', 'student', 'employee'];
if (!in_array($role, $allowed_roles, true)) {
    $role = 'student';
}
$faculty_id = isset($data['faculty_id']) && $data['faculty_id'] !== ''
    ? (int)$data['faculty_id']
    : null;

$sql = "INSERT INTO users (name, email, password, role, faculty_id)
        VALUES ('$name', '$email', '$password', '$role', " . ($faculty_id === null ? "NULL" : "'$faculty_id'") . ")";

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
