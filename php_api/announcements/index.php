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
    $attachments = db_fetch_all($stmt->get_result());
    normalize_attachment_urls($attachments);
    foreach ($attachments as $attachment) {
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

function ensure_announcement_faculties_table($conn) {
    $conn->query(
        "CREATE TABLE IF NOT EXISTS announcement_faculties (
            announcement_id INT(11) NOT NULL,
            faculty_id INT(11) NOT NULL,
            PRIMARY KEY (announcement_id, faculty_id),
            KEY idx_announcement_faculties_faculty (faculty_id),
            CONSTRAINT fk_announcement_faculties_announcement
                FOREIGN KEY (announcement_id) REFERENCES announcements(id) ON DELETE CASCADE,
            CONSTRAINT fk_announcement_faculties_faculty
                FOREIGN KEY (faculty_id) REFERENCES faculties(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci"
    );
}

function normalize_faculty_ids($data, $target_type, $target_faculty_id) {
    if ($target_type !== "faculty" && $target_type !== "teacher") {
        return [];
    }

    $ids = [];
    if (isset($data["target_faculty_ids"]) && is_array($data["target_faculty_ids"])) {
        foreach ($data["target_faculty_ids"] as $faculty_id) {
            $faculty_id = (int)$faculty_id;
            if ($faculty_id > 0 && !in_array($faculty_id, $ids, true)) {
                $ids[] = $faculty_id;
            }
        }
    }

    if (empty($ids) && $target_faculty_id) {
        $ids[] = (int)$target_faculty_id;
    }

    return $ids;
}

function sync_announcement_faculties($conn, $announcement_id, $faculty_ids) {
    $delete_stmt = $conn->prepare("DELETE FROM announcement_faculties WHERE announcement_id = ?");
    $delete_stmt->bind_param("i", $announcement_id);
    $delete_stmt->execute();

    if (empty($faculty_ids)) {
        return;
    }

    $insert_stmt = $conn->prepare(
        "INSERT IGNORE INTO announcement_faculties (announcement_id, faculty_id)
         VALUES (?, ?)"
    );
    foreach ($faculty_ids as $faculty_id) {
        $insert_stmt->bind_param("ii", $announcement_id, $faculty_id);
        $insert_stmt->execute();
    }
}

function attach_announcement_faculties($conn, &$announcements) {
    if (empty($announcements)) {
        return;
    }

    $ids = array_map(function ($row) {
        return (int)$row["id"];
    }, $announcements);
    $placeholders = implode(",", array_fill(0, count($ids), "?"));
    $types = str_repeat("i", count($ids));

    $stmt = $conn->prepare(
        "SELECT af.announcement_id, f.id AS faculty_id, f.name AS faculty_name
         FROM announcement_faculties af
         INNER JOIN faculties f ON f.id = af.faculty_id
         WHERE af.announcement_id IN ($placeholders)
         ORDER BY f.id ASC"
    );
    $stmt->bind_param($types, ...$ids);
    $stmt->execute();

    $faculties_by_announcement = [];
    foreach (db_fetch_all($stmt->get_result()) as $row) {
        $announcement_id = (int)$row["announcement_id"];
        if (!isset($faculties_by_announcement[$announcement_id])) {
            $faculties_by_announcement[$announcement_id] = [
                "ids" => [],
                "names" => []
            ];
        }
        $faculties_by_announcement[$announcement_id]["ids"][] = (int)$row["faculty_id"];
        $faculties_by_announcement[$announcement_id]["names"][] = $row["faculty_name"];
    }

    foreach ($announcements as &$announcement) {
        $announcement_id = (int)$announcement["id"];
        $faculty_data = $faculties_by_announcement[$announcement_id] ?? null;
        if (!$faculty_data && !empty($announcement["target_faculty_id"])) {
            $faculty_data = [
                "ids" => [(int)$announcement["target_faculty_id"]],
                "names" => empty($announcement["target_faculty_name"])
                    ? []
                    : [$announcement["target_faculty_name"]]
            ];
        }

        $announcement["target_faculty_ids"] = $faculty_data["ids"] ?? [];
        $announcement["target_faculty_names"] = $faculty_data["names"] ?? [];
        if (!empty($announcement["target_faculty_names"])) {
            $announcement["target_faculty_name"] = implode(", ", $announcement["target_faculty_names"]);
        }
    }
}

ensure_announcement_faculties_table($conn);

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
        normalize_attachment_urls($announcement["attachments"]);
        $announcement_list = [$announcement];
        attach_announcement_faculties($conn, $announcement_list);
        $announcement = $announcement_list[0];

        send_json(["status" => "success", "data" => $announcement]);
    }

    $status = $_GET["status"] ?? null;
    $target_faculty_id = get_query_int("target_faculty_id");
    $visible_faculty_id = get_query_int("visible_faculty_id");
    $visible_role = isset($_GET["visible_role"]) ? strtolower(trim($_GET["visible_role"])) : null;
    if ($visible_role === "staff") {
        $visible_role = "employee";
    }

    $sql =
        "SELECT a.*, u.name AS creator_name, f.name AS target_faculty_name
         FROM announcements a
         LEFT JOIN users u ON u.id = a.created_by
         LEFT JOIN faculties f ON f.id = a.target_faculty_id
         WHERE (? IS NULL OR a.status = ?)
           AND (
             ? IS NULL
             OR a.target_faculty_id = ?
             OR EXISTS (
                SELECT 1 FROM announcement_faculties taf
                WHERE taf.announcement_id = a.id AND taf.faculty_id = ?
             )
           )
           AND (
             ? IS NULL
             OR a.target_type = 'all'
             OR (a.target_type IS NULL AND a.target_faculty_id IS NULL)
             OR (? = 'employee' AND a.target_type = 'employee')
             OR (
                ? = 'teacher'
                AND a.target_type = 'teacher'
                AND (
                    a.target_faculty_id = ?
                    OR EXISTS (
                        SELECT 1 FROM announcement_faculties tvaf
                        WHERE tvaf.announcement_id = a.id AND tvaf.faculty_id = ?
                    )
                )
             )
             OR (
                ? <> 'employee'
                AND (a.target_type = 'faculty' OR a.target_type IS NULL)
                AND (
                    a.target_faculty_id = ?
                    OR EXISTS (
                        SELECT 1 FROM announcement_faculties vaf
                        WHERE vaf.announcement_id = a.id AND vaf.faculty_id = ?
                    )
                )
             )
           )
         ORDER BY a.created_at DESC";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param(
        "ssiiisssiisii",
        $status,
        $status,
        $target_faculty_id,
        $target_faculty_id,
        $target_faculty_id,
        $visible_role,
        $visible_role,
        $visible_role,
        $visible_faculty_id,
        $visible_faculty_id,
        $visible_role,
        $visible_faculty_id,
        $visible_faculty_id
    );
    $stmt->execute();

    $announcements = db_fetch_all($stmt->get_result());
    attach_announcement_faculties($conn, $announcements);
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
    $target_faculty_ids = normalize_faculty_ids($data, $target_type, $target_faculty_id);
    $target_faculty_id = empty($target_faculty_ids) ? null : $target_faculty_ids[0];
    $published_at = $data["published_at"] ?? null;
    $expired_at = $data["expired_at"] ?? null;

    if ($title === "") {
        send_json(["status" => "error", "message" => "Missing announcement title"], 400);
    }
    if (($target_type === "faculty" || $target_type === "teacher") && empty($target_faculty_ids)) {
        send_json(["status" => "error", "message" => "Select at least one faculty"], 400);
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

    $announcement_id = $stmt->insert_id;
    sync_announcement_faculties($conn, $announcement_id, $target_faculty_ids);

    send_json(["status" => "success", "id" => $announcement_id], 201);
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
    $target_faculty_ids = normalize_faculty_ids($data, $target_type, $target_faculty_id);
    $target_faculty_id = empty($target_faculty_ids) ? null : $target_faculty_ids[0];
    $published_at = $data["published_at"] ?? null;
    $expired_at = $data["expired_at"] ?? null;

    if ($title === "") {
        send_json(["status" => "error", "message" => "Missing announcement title"], 400);
    }
    if (($target_type === "faculty" || $target_type === "teacher") && empty($target_faculty_ids)) {
        send_json(["status" => "error", "message" => "Select at least one faculty"], 400);
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

    sync_announcement_faculties($conn, $id, $target_faculty_ids);

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
