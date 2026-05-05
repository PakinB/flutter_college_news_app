<?php
require_once "../config/db.php";
require_once "../config/helpers.php";

$method = $_SERVER["REQUEST_METHOD"];
$id = get_query_int("id");
$announcement_id = get_query_int("announcement_id");

function delete_announcement_image_files($conn, $announcement_id) {
    $stmt = $conn->prepare(
        "SELECT id, file_url
         FROM attachments
         WHERE announcement_id = ? AND file_type LIKE 'image/%'"
    );
    $stmt->bind_param("i", $announcement_id);
    $stmt->execute();

    foreach (db_fetch_all($stmt->get_result()) as $attachment) {
        $file_name = basename(parse_url($attachment["file_url"], PHP_URL_PATH));
        $file_path = __DIR__ . "/../images/" . $file_name;
        if (is_file($file_path)) {
            unlink($file_path);
        }
    }

    $delete_stmt = $conn->prepare(
        "DELETE FROM attachments
         WHERE announcement_id = ? AND file_type LIKE 'image/%'"
    );
    $delete_stmt->bind_param("i", $announcement_id);
    $delete_stmt->execute();
}

function delete_announcement_non_image_files($conn, $announcement_id) {
    $stmt = $conn->prepare(
        "SELECT id, file_url
         FROM attachments
         WHERE announcement_id = ? AND file_type NOT LIKE 'image/%'"
    );
    $stmt->bind_param("i", $announcement_id);
    $stmt->execute();

    foreach (db_fetch_all($stmt->get_result()) as $attachment) {
        $file_name = basename(parse_url($attachment["file_url"], PHP_URL_PATH));
        $file_path = __DIR__ . "/../images/" . $file_name;
        if (is_file($file_path)) {
            unlink($file_path);
        }
    }

    $delete_stmt = $conn->prepare(
        "DELETE FROM attachments
         WHERE announcement_id = ? AND file_type NOT LIKE 'image/%'"
    );
    $delete_stmt->bind_param("i", $announcement_id);
    $delete_stmt->execute();
}

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

        $attachments = [$attachment];
        normalize_attachment_urls($attachments);
        send_json(["status" => "success", "data" => $attachments[0]]);
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
        $attachments = db_fetch_all($stmt->get_result());
        normalize_attachment_urls($attachments);
        send_json(["status" => "success", "data" => $attachments]);
    }

    $result = $conn->query(
        "SELECT id, announcement_id, file_url, file_type, uploaded_at
         FROM attachments
         ORDER BY uploaded_at DESC"
    );
    $attachments = db_fetch_all($result);
    normalize_attachment_urls($attachments);
    send_json(["status" => "success", "data" => $attachments]);
}

if ($method === "POST") {
    if (!empty($_FILES["file"])) {
        $announcement_id = isset($_POST["announcement_id"]) ? (int)$_POST["announcement_id"] : null;
        $replace_existing = ($_POST["replace_existing"] ?? "0") === "1";

        if (!$announcement_id) {
            send_json(["status" => "error", "message" => "Missing announcement id"], 400);
        }

        if ($_FILES["file"]["error"] !== UPLOAD_ERR_OK) {
            send_json(["status" => "error", "message" => "File upload failed"], 400);
        }

        $tmp_path = $_FILES["file"]["tmp_name"];
        $original_name = $_FILES["file"]["name"] ?? "";
        $file_type = mime_content_type($tmp_path) ?: "application/octet-stream";
        $extension = strtolower(pathinfo($original_name, PATHINFO_EXTENSION));
        $allowed_mime_types = [
            "image/jpeg" => "jpg",
            "image/png" => "png",
            "image/gif" => "gif",
            "image/webp" => "webp",
            "application/pdf" => "pdf",
            "text/plain" => "txt",
            "text/csv" => "csv",
            "application/msword" => "doc",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document" => "docx",
            "application/vnd.ms-excel" => "xls",
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" => "xlsx",
            "application/vnd.ms-powerpoint" => "ppt",
            "application/vnd.openxmlformats-officedocument.presentationml.presentation" => "pptx",
            "application/zip" => "zip",
            "application/x-zip-compressed" => "zip",
        ];
        $allowed_extensions = [
            "jpg", "jpeg", "png", "gif", "webp",
            "pdf", "txt", "csv",
            "doc", "docx", "xls", "xlsx", "ppt", "pptx",
            "zip"
        ];

        if (isset($allowed_mime_types[$file_type])) {
            $extension = $allowed_mime_types[$file_type];
        }

        if (!in_array($extension, $allowed_extensions, true)) {
            send_json(["status" => "error", "message" => "File type is not allowed"], 400);
        }

        $image_dir = __DIR__ . "/../images";
        if (!is_dir($image_dir)) {
            mkdir($image_dir, 0755, true);
        }

        if ($replace_existing) {
            delete_announcement_image_files($conn, $announcement_id);
        }

        $file_name = "announcement_" . $announcement_id . "_" . bin2hex(random_bytes(8)) . "." . $extension;
        $target_path = $image_dir . "/" . $file_name;

        if (!move_uploaded_file($tmp_path, $target_path)) {
            send_json(["status" => "error", "message" => "Could not save uploaded file"], 500);
        }

        $file_url = uploaded_file_storage_path($file_name);
        $stmt = $conn->prepare(
            "INSERT INTO attachments (announcement_id, file_url, file_type)
             VALUES (?, ?, ?)"
        );
        $stmt->bind_param("iss", $announcement_id, $file_url, $file_type);

        if (!$stmt->execute()) {
            send_json(["status" => "error", "message" => $stmt->error], 500);
        }

        send_json([
            "status" => "success",
            "id" => $stmt->insert_id,
            "file_url" => public_uploaded_file_url($file_name)
        ], 201);
    }

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
    if ($announcement_id) {
        $type = strtolower(trim($_GET["type"] ?? ""));
        if ($type === "image" || $type === "images") {
            delete_announcement_image_files($conn, $announcement_id);
            send_json(["status" => "success"]);
        }
        if ($type === "file" || $type === "files") {
            delete_announcement_non_image_files($conn, $announcement_id);
            send_json(["status" => "success"]);
        }

        $stmt = $conn->prepare("DELETE FROM attachments WHERE announcement_id = ?");
        $stmt->bind_param("i", $announcement_id);

        if (!$stmt->execute()) {
            send_json(["status" => "error", "message" => $stmt->error], 500);
        }

        send_json(["status" => "success"]);
    }

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
