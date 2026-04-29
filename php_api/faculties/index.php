<?php
require_once "../config/db.php";
require_once "../config/helpers.php";

$method = $_SERVER["REQUEST_METHOD"];
$id = get_query_int("id");

if ($method === "GET") {
    if ($id) {
        $stmt = $conn->prepare("SELECT id, name, description, created_at FROM faculties WHERE id = ?");
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $faculty = $stmt->get_result()->fetch_assoc();

        if (!$faculty) {
            send_json(["status" => "error", "message" => "Faculty not found"], 404);
        }

        send_json(["status" => "success", "data" => $faculty]);
    }

    $result = $conn->query("SELECT id, name, description, created_at FROM faculties ORDER BY id ASC");
    send_json(["status" => "success", "data" => db_fetch_all($result)]);
}

if ($method === "POST") {
    $data = read_json_body();
    $name = trim($data["name"] ?? "");
    $description = trim($data["description"] ?? "");

    if ($name === "") {
        send_json(["status" => "error", "message" => "Missing faculty name"], 400);
    }

    $stmt = $conn->prepare("INSERT INTO faculties (name, description) VALUES (?, ?)");
    $stmt->bind_param("ss", $name, $description);

    if (!$stmt->execute()) {
        send_json(["status" => "error", "message" => $stmt->error], 500);
    }

    send_json(["status" => "success", "id" => $stmt->insert_id], 201);
}

if ($method === "PUT" || $method === "PATCH") {
    if (!$id) {
        send_json(["status" => "error", "message" => "Missing faculty id"], 400);
    }

    $data = read_json_body();
    $name = trim($data["name"] ?? "");
    $description = trim($data["description"] ?? "");

    if ($name === "") {
        send_json(["status" => "error", "message" => "Missing faculty name"], 400);
    }

    $stmt = $conn->prepare("UPDATE faculties SET name = ?, description = ? WHERE id = ?");
    $stmt->bind_param("ssi", $name, $description, $id);

    if (!$stmt->execute()) {
        send_json(["status" => "error", "message" => $stmt->error], 500);
    }

    send_json(["status" => "success"]);
}

if ($method === "DELETE") {
    if (!$id) {
        send_json(["status" => "error", "message" => "Missing faculty id"], 400);
    }

    $stmt = $conn->prepare("DELETE FROM faculties WHERE id = ?");
    $stmt->bind_param("i", $id);

    if (!$stmt->execute()) {
        send_json(["status" => "error", "message" => $stmt->error], 500);
    }

    send_json(["status" => "success"]);
}

send_json(["status" => "error", "message" => "Method not allowed"], 405);
?>
