<?php
include("../config/db.php");

$id = $_GET['id'];

$sql = "DELETE FROM announcements WHERE id=$id";

if ($conn->query($sql)) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error"]);
}
?>