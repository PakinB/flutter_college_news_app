<?php
include("../config/db.php");

$id = $_GET['id'];

$sql = "SELECT * FROM announcements WHERE id=$id";
$result = $conn->query($sql);

echo json_encode($result->fetch_assoc());
?>