<?php
require_once __DIR__ . "/cors.php";

$host = "localhost";
$user = "root";
$pass = "";
$db   = "college_news";

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die(json_encode([
        "status" => "error",
        "message" => "Connection failed"
    ]));
}
?>
