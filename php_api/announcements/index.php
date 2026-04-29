<?php
require_once "../config/db.php";
require_once "../config/helpers.php";

$method = $_SERVER["REQUEST_METHOD"];
$id = get_query_int("id");

function attach_announcement_files($conn, &$announcements) {
    if (empty($announcements)) {
        return;
    }

    $ids = array_map(function ($row) {
        return (int)$row["id"];
    }, $announcements);
    $placeholders = implode(",", array_fill(0, count($ids), "?"));
    $types = str_repeat("i", count($ids));

    $stmt = $conn->prepare(
        "SELECT id, announcement_id, file_url, file_type, uploaded_at
         FROM attachments
         WHERE announcement_id IN ($placeholders)
         ORDER BY id ASC"
    );
    $stmt->bind_param($types, ...$ids);
    $stmt->execute();

    $attachments_by_announcement = [];
    foreach (db_fetch_all($stmt->get_result()) as $attachment) {
        $announcement_id = (int)$attachment["announcement_id"];
        if (!isset($attachments_by_announcement[$announcement_id])) {
            $attachments_by_announcement[$announcement_id] = [];
        }
        $attachments_by_announcement[$announcement_id][] = $attachment;
    }

    foreach ($announcements as &$announcement) {
        $announcement_id = (int)$announcement["id"];
        $announcement["attachments"] = $attachments_by_announcement[$announcement_id] ?? [];
    }
}

if ($method === "GET") {
    if ($id) {
        $stmt = $conn->prepare(
            "SELECT a.*, u.name AS creator_name, f.name AS target_faculty_name
             FROM announcements a
             LEFT JOIN users u ON u.id = a.created_by
             LEFT JOIN faculties f ON f.id = a.target_faculty_id
             WHERE a.id = ?"
        );
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $announcement = $stmt->get_result()->fetch_assoc();

        if (!$announcement) {
            send_json(["status" => "error", "message" => "Announcement not found"], 404);
        }

        $attachments_stmt = $conn->prepare(
            "SELECT id, announcement_id, file_url, file_type, uploaded_at
             FROM attachments
             WHERE announcement_id = ?
             ORDER BY id ASC"
        );
        $attachments_stmt->bind_param("i", $id);
        $attachments_stmt->execute();
        $announcement["attachments"] = db_fetch_all($attachments_stmt->get_result());

        send_json(["status" => "success", "data" => $announcement]);
    }

    $status = $_GET["status"] ?? null;
    $target_faculty_id = get_query_int("target_faculty_id");
    $visible_faculty_id = get_query_int("visible_faculty_id");

    $sql =
        "SELECT a.*, u.name AS creator_name, f.name AS target_faculty_name
         FROM announcements a
         LEFT JOIN users u ON u.id = a.created_by
         LEFT JOIN faculties f ON f.id = a.target_faculty_id
         WHERE (? IS NULL OR a.status = ?)
           AND (? IS NULL OR a.target_faculty_id = ?)
           AND (? IS NULL OR a.target_type = 'all' OR a.target_faculty_id = ?)
         ORDER BY a.created_at DESC";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ssiiii", $status, $status, $target_faculty_id, $target_faculty_id, $visible_faculty_id, $visible_faculty_id);
    $stmt->execute();

    $announcements = db_fetch_all($stmt->get_result());
    attach_announcement_files($conn, $announcements);

    send_json(["status" => "success", "data" => $announcements]);
}

if ($method === "POST") {
    $data = read_json_body();

    $title = trim($data["title"] ?? "");
    $content = trim($data["content"] ?? "");
    $summary = trim($data["summary"] ?? "");
    $created_by = isset($data["created_by"]) ? (int)$data["created_by"] : null;
    $status = $data["status"] ?? "draft";
    $priority = $data["priority"] ?? "normal";
    $target_type = $data["target_type"] ?? "all";
    $target_faculty_id = isset($data["target_faculty_id"]) && $data["target_faculty_id"] !== ""
        ? (int)$data["target_faculty_id"]
        : null;
    $published_at = $data["published_at"] ?? null;
    $expired_at = $data["expired_at"] ?? null;

    if ($title === "") {
        send_json(["status" => "error", "message" => "Missing announcement title"], 400);
    }

    $stmt = $conn->prepare(
        "INSERT INTO announcements
         (title, content, summary, created_by, status, priority, target_type, target_faculty_id, published_at, expired_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
    );
    $stmt->bind_param(
        "sssisssiss",
        $title,
        $content,
        $summary,
        $created_by,
        $status,
        $priority,
        $target_type,
        $target_faculty_id,
        $published_at,
        $expired_at
    );

    if (!$stmt->execute()) {
        send_json(["status" => "error", "message" => $stmt->error], 500);
    }

    send_json(["status" => "success", "id" => $stmt->insert_id], 201);
}

if ($method === "PUT" || $method === "PATCH") {
    if (!$id) {
        send_json(["status" => "error", "message" => "Missing announcement id"], 400);
    }

    $data = read_json_body();
    $title = trim($data["title"] ?? "");
    $content = trim($data["content"] ?? "");
    $summary = trim($data["summary"] ?? "");
    $status = $data["status"] ?? "draft";
    $priority = $data["priority"] ?? "normal";
    $target_type = $data["target_type"] ?? "all";
    $target_faculty_id = isset($data["target_faculty_id"]) && $data["target_faculty_id"] !== ""
        ? (int)$data["target_faculty_id"]
        : null;
    $published_at = $data["published_at"] ?? null;
    $expired_at = $data["expired_at"] ?? null;

    if ($title === "") {
        send_json(["status" => "error", "message" => "Missing announcement title"], 400);
    }

    $stmt = $conn->prepare(
        "UPDATE announcements
         SET title = ?, content = ?, summary = ?, status = ?, priority = ?, target_type = ?,
             target_faculty_id = ?, published_at = ?, expired_at = ?
         WHERE id = ?"
    );
    $stmt->bind_param(
        "ssssssissi",
        $title,
        $content,
        $summary,
        $status,
        $priority,
        $target_type,
        $target_faculty_id,
        $published_at,
        $expired_at,
        $id
    );

    if (!$stmt->execute()) {
        send_json(["status" => "error", "message" => $stmt->error], 500);
    }

    send_json(["status" => "success"]);
}

if ($method === "DELETE") {
    if (!$id) {
        send_json(["status" => "error", "message" => "Missing announcement id"], 400);
    }

    $stmt = $conn->prepare("DELETE FROM announcements WHERE id = ?");
    $stmt->bind_param("i", $id);

    if (!$stmt->execute()) {
        send_json(["status" => "error", "message" => $stmt->error], 500);
    }

    send_json(["status" => "success"]);
}

send_json(["status" => "error", "message" => "Method not allowed"], 405);
?>
