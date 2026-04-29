<?php
require_once "../config/db.php";
require_once "../config/helpers.php";

$method = $_SERVER["REQUEST_METHOD"];
$id = get_query_int("id");
$announcement_id = get_query_int("announcement_id");

function public_image_url($file_name) {
    $scheme = (!empty($_SERVER["HTTPS"]) && $_SERVER["HTTPS"] !== "off") ? "https" : "http";
    $host = $_SERVER["HTTP_HOST"];
    $base_path = rtrim(dirname(dirname($_SERVER["SCRIPT_NAME"])), "/\\");
    return "$scheme://$host$base_path/images/$file_name";
}

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
    if (!empty($_FILES["file"])) {
        $announcement_id = isset($_POST["announcement_id"]) ? (int)$_POST["announcement_id"] : null;
        $replace_existing = ($_POST["replace_existing"] ?? "0") === "1";

        if (!$announcement_id) {
            send_json(["status" => "error", "message" => "Missing announcement id"], 400);
        }

        if ($_FILES["file"]["error"] !== UPLOAD_ERR_OK) {
            send_json(["status" => "error", "message" => "Image upload failed"], 400);
        }

        $tmp_path = $_FILES["file"]["tmp_name"];
        $file_type = mime_content_type($tmp_path);
        $allowed_types = [
            "image/jpeg" => "jpg",
            "image/png" => "png",
            "image/gif" => "gif",
            "image/webp" => "webp",
        ];

        if (!isset($allowed_types[$file_type])) {
            send_json(["status" => "error", "message" => "Only image files are allowed"], 400);
        }

        $image_dir = __DIR__ . "/../images";
        if (!is_dir($image_dir)) {
            mkdir($image_dir, 0755, true);
        }

        if ($replace_existing) {
            delete_announcement_image_files($conn, $announcement_id);
        }

        $file_name = "announcement_" . $announcement_id . "_" . bin2hex(random_bytes(8)) . "." . $allowed_types[$file_type];
        $target_path = $image_dir . "/" . $file_name;

        if (!move_uploaded_file($tmp_path, $target_path)) {
            send_json(["status" => "error", "message" => "Could not save uploaded image"], 500);
        }

        $file_url = public_image_url($file_name);
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
            "file_url" => $file_url
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
