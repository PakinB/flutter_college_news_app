<?php
require_once __DIR__ . "/app.php";

function send_json($data, $status_code = 200) {
    http_response_code($status_code);
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
}

function read_json_body() {
    $raw = file_get_contents("php://input");
    if (!$raw) {
        return [];
    }

    $data = json_decode($raw, true);
    if (!is_array($data)) {
        send_json(["status" => "error", "message" => "Invalid JSON body"], 400);
    }

    return $data;
}

function require_request_method($method) {
    if ($_SERVER["REQUEST_METHOD"] !== $method) {
        send_json([
            "status" => "error",
            "message" => "Method not allowed. Use $method"
        ], 405);
    }
}

function get_query_int($key) {
    if (!isset($_GET[$key]) || $_GET[$key] === "") {
        return null;
    }

    return (int)$_GET[$key];
}

function db_fetch_all($result) {
    $rows = [];
    while ($row = $result->fetch_assoc()) {
        $rows[] = $row;
    }
    return $rows;
}

function api_public_base_url() {
    $configured = trim(API_PUBLIC_BASE_URL);
    if ($configured === "") {
        $configured = trim(getenv("API_PUBLIC_BASE_URL") ?: "");
    }
    if ($configured !== "") {
        return rtrim($configured, "/");
    }

    $scheme = (!empty($_SERVER["HTTPS"]) && $_SERVER["HTTPS"] !== "off") ? "https" : "http";
    $host = $_SERVER["HTTP_HOST"] ?? "localhost";
    $base_path = rtrim(dirname(dirname($_SERVER["SCRIPT_NAME"] ?? "")), "/\\");
    return "$scheme://$host$base_path";
}

function public_uploaded_file_url($file_name) {
    return api_public_base_url() . "/images/" . rawurlencode($file_name);
}

function uploaded_file_storage_path($file_name) {
    return "images/" . $file_name;
}

function normalize_attachment_file_url($file_url, $file_type = "") {
    $file_url = trim($file_url ?? "");
    if ($file_url === "") {
        return $file_url;
    }

    $lower_type = strtolower($file_type ?? "");
    if ($lower_type === "link/url") {
        return $file_url;
    }

    $path = parse_url($file_url, PHP_URL_PATH);
    if (!$path) {
        return $file_url;
    }

    $file_name = basename($path);
    if ($file_name === "" || $file_name === "." || $file_name === "..") {
        return $file_url;
    }

    $host = strtolower(parse_url($file_url, PHP_URL_HOST) ?? "");
    $is_relative_url = $host === "" && !preg_match('/^[a-z][a-z0-9+.-]*:/i', $file_url);
    $is_localhost_url = in_array($host, ["localhost", "127.0.0.1", "::1"], true);
    $normalized_path = ltrim($path, "/");
    $is_upload_path = strpos($path, "/images/") !== false || substr($normalized_path, 0, 7) === "images/";

    if (($is_relative_url || $is_localhost_url) && $is_upload_path) {
        return public_uploaded_file_url($file_name);
    }

    return $file_url;
}

function normalize_attachment_urls(&$attachments) {
    foreach ($attachments as &$attachment) {
        if (isset($attachment["file_url"])) {
            $attachment["file_url"] = normalize_attachment_file_url(
                $attachment["file_url"],
                $attachment["file_type"] ?? ""
            );
        }
    }
}
?>
