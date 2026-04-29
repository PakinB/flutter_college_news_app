<?php
include("../config/cors.php");

include("../config/db.php");

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode([
        "status" => "error",
        "message" => "Please send register data with POST JSON"
    ]);
    exit;
}

$data = json_decode(file_get_contents("php://input"), true);

if (!$data) {
    echo json_encode(["status" => "error", "message" => "No input data"]);
    exit;
}

$name = $data['name'] ?? '';
$email = $data['email'] ?? '';
$password_raw = $data['password'] ?? '';
$role = $data['role'] ?? 'user';
$faculty_id = isset($data['faculty_id']) ? (int)$data['faculty_id'] : null;

if (!$name || !$email || !$password_raw || !$faculty_id) {
    echo json_encode(["status" => "error", "message" => "Missing fields"]);
    exit;
}

$check = $conn->prepare("SELECT id FROM users WHERE email = ?");
if (!$check) {
    echo json_encode(["status" => "error", "message" => $conn->error]);
    exit;
}

$check->bind_param("s", $email);
$check->execute();
$check_result = $check->get_result();

if ($check_result->num_rows > 0) {
    echo json_encode(["status" => "error", "message" => "Email already exists"]);
    exit;
}

$password = password_hash($password_raw, PASSWORD_DEFAULT);

$stmt = $conn->prepare(
    "INSERT INTO users (name, email, password, role, faculty_id) VALUES (?, ?, ?, ?, ?)"
);
if (!$stmt) {
    echo json_encode(["status" => "error", "message" => $conn->error]);
    exit;
}

$stmt->bind_param("ssssi", $name, $email, $password, $role, $faculty_id);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "user_id" => $stmt->insert_id]);
} else {
    echo json_encode(["status" => "error", "message" => $stmt->error]);
}
?>
