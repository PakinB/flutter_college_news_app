<?php
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
?>
