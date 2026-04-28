<?php
include("../config/cors.php");

include("../config/db.php");

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode([
        "status" => "error",
        "message" => "Please send login data with POST JSON"
    ]);
    exit;
}

$data = json_decode(file_get_contents("php://input"), true);

if (!$data) {
    echo json_encode(["status" => "error", "message" => "No input data"]);
    exit;
}

$email = $data['email'] ?? '';
$password = $data['password'] ?? '';

if (!$email || !$password) {
    echo json_encode(["status" => "error", "message" => "Missing email or password"]);
    exit;
}

$stmt = $conn->prepare("SELECT * FROM users WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(["status" => "error", "message" => "User not found"]);
    exit;
}

$user = $result->fetch_assoc();

if (password_verify($password, $user['password'])) {
    unset($user['password']);
    echo json_encode([
        "status" => "success",
        "user" => $user
    ]);
} else {
    echo json_encode(["status" => "error", "message" => "Wrong password"]);
}
?>
