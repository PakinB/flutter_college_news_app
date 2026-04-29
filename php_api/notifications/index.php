<?php
require_once "../config/db.php";
require_once "../config/helpers.php";

$method = $_SERVER["REQUEST_METHOD"];
$id = get_query_int("id");
$user_id = get_query_int("user_id");

if ($method === "GET") {
    if ($id) {
        $stmt = $conn->prepare(
            "SELECT n.*, a.title AS announcement_title
             FROM notifications n
             LEFT JOIN announcements a ON a.id = n.announcement_id
             WHERE n.id = ?"
        );
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $notification = $stmt->get_result()->fetch_assoc();

        if (!$notification) {
            send_json(["status" => "error", "message" => "Notification not found"], 404);
        }

        send_json(["status" => "success", "data" => $notification]);
    }

    if (!$user_id) {
        send_json(["status" => "error", "message" => "Missing user_id"], 400);
    }

    $stmt = $conn->prepare(
        "SELECT n.*, a.title AS announcement_title
         FROM notifications n
         LEFT JOIN announcements a ON a.id = n.announcement_id
         WHERE n.user_id = ?
         ORDER BY n.sent_at DESC"
    );
    $stmt->bind_param("i", $user_id);
    $stmt->execute();

    send_json(["status" => "success", "data" => db_fetch_all($stmt->get_result())]);
}

if ($method === "POST") {
    $data = read_json_body();
    $user_id = isset($data["user_id"]) ? (int)$data["user_id"] : null;
    $announcement_id = isset($data["announcement_id"]) ? (int)$data["announcement_id"] : null;
    $is_read = isset($data["is_read"]) ? (int)(bool)$data["is_read"] : 0;

    if (!$user_id || !$announcement_id) {
        send_json(["status" => "error", "message" => "Missing notification fields"], 400);
    }

    $stmt = $conn->prepare(
        "INSERT INTO notifications (user_id, announcement_id, is_read)
         VALUES (?, ?, ?)"
    );
    $stmt->bind_param("iii", $user_id, $announcement_id, $is_read);

    if (!$stmt->execute()) {
        send_json(["status" => "error", "message" => $stmt->error], 500);
    }

    send_json(["status" => "success", "id" => $stmt->insert_id], 201);
}

if ($method === "PATCH" || $method === "PUT") {
    if (!$id) {
        send_json(["status" => "error", "message" => "Missing notification id"], 400);
    }

    $data = read_json_body();
    $is_read = isset($data["is_read"]) ? (int)(bool)$data["is_read"] : 1;

    $stmt = $conn->prepare("UPDATE notifications SET is_read = ? WHERE id = ?");
    $stmt->bind_param("ii", $is_read, $id);

    if (!$stmt->execute()) {
        send_json(["status" => "error", "message" => $stmt->error], 500);
    }

    send_json(["status" => "success"]);
}

if ($method === "DELETE") {
    if (!$id) {
        send_json(["status" => "error", "message" => "Missing notification id"], 400);
    }

    $stmt = $conn->prepare("DELETE FROM notifications WHERE id = ?");
    $stmt->bind_param("i", $id);

    if (!$stmt->execute()) {
        send_json(["status" => "error", "message" => $stmt->error], 500);
    }

    send_json(["status" => "success"]);
}

send_json(["status" => "error", "message" => "Method not allowed"], 405);
?>
