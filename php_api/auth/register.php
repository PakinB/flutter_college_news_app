<?php
include("../config/db.php");


error_reporting(0);
ini_set('display_errors', 0);


header('Content-Type: application/json');


$data = json_decode(file_get_contents("php://input"), true);

if (!$data) {
    echo json_encode(["status" => "error", "message" => "No input data"]);
    exit;
}

$name = $data['name'] ?? '';
$email = $data['email'] ?? '';
$password_raw = $data['password'] ?? '';

if (!$name || !$email || !$password_raw) {
    echo json_encode(["status" => "error", "message" => "Missing fields"]);
    exit;
}


$password = password_hash($password_raw, PASSWORD_DEFAULT);


$stmt = $conn->prepare("INSERT INTO users (name, email, password) VALUES (?, ?, ?)");
$stmt->bind_param("sss", $name, $email, $password);

if ($stmt->execute()) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "message" => $stmt->error]);
}

$stmt->close();
$conn->close();
?>