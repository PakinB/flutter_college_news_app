<?php
require_once "../config/db.php";
require_once "../config/helpers.php";

$method = $_SERVER["REQUEST_METHOD"];
$id = get_query_int("id");
$announcement_id = get_query_int("announcement_id");

if ($method === "GET") {
    if ($id) {
        $stmt = $conn->prepare(
            "SELECT id, announcement_id, file_url, file_type, uploaded_at
             FROM attachments
             WHERE id = ?"
        );
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $attachment = $stmt->get_result()->fetch_assoc();

        if (!$attachment) {
            send_json(["status" => "error", "message" => "Attachment not found"], 404);
        }

        send_json(["status" => "success", "data" => $attachment]);
    }

    if ($announcement_id) {
        $stmt = $conn->prepare(
            "SELECT id, announcement_id, file_url, file_type, uploaded_at
             FROM attachments
             WHERE announcement_id = ?
             ORDER BY id ASC"
        );
        $stmt->bind_param("i", $announcement_id);
        $stmt->execute();
        send_json(["status" => "success", "data" => db_fetch_all($stmt->get_result())]);
    }

    $result = $conn->query(
        "SELECT id, announcement_id, file_url, file_type, uploaded_at
         FROM attachments
         ORDER BY uploaded_at DESC"
    );
    send_json(["status" => "success", "data" => db_fetch_all($result)]);
}

if ($method === "POST") {
    $data = read_json_body();
    $announcement_id = isset($data["announcement_id"]) ? (int)$data["announcement_id"] : null;
    $file_url = trim($data["file_url"] ?? "");
    $file_type = trim($data["file_type"] ?? "");

    if (!$announcement_id || $file_url === "" || $file_type === "") {
        send_json(["status" => "error", "message" => "Missing attachment fields"], 400);
    }

    $stmt = $conn->prepare(
        "INSERT INTO attachments (announcement_id, file_url, file_type)
         VALUES (?, ?, ?)"
    );
    $stmt->bind_param("iss", $announcement_id, $file_url, $file_type);

    if (!$stmt->execute()) {
        send_json(["status" => "error", "message" => $stmt->error], 500);
    }

    send_json(["status" => "success", "id" => $stmt->insert_id], 201);
}

if ($method === "DELETE") {
    if (!$id) {
        send_json(["status" => "error", "message" => "Missing attachment id"], 400);
    }

    $stmt = $conn->prepare("DELETE FROM attachments WHERE id = ?");
    $stmt->bind_param("i", $id);

    if (!$stmt->execute()) {
        send_json(["status" => "error", "message" => $stmt->error], 500);
    }

    send_json(["status" => "success"]);
}

send_json(["status" => "error", "message" => "Method not allowed"], 405);
?>
