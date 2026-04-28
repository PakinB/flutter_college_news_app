<?php
include("../config/db.php");

$data = json_decode(file_get_contents("php://input"), true);

$title = $data['title'];
$content = $data['content'];
$summary = $data['summary'];
$target_faculty_id = $data['faculty_id'];
$created_by = $data['created_by'];

$sql = "INSERT INTO announcements (title, content, summary, target_faculty_id, created_by, priority, status, )
        VALUES ('$title', '$content', '$summary', '$target_faculty_id', '$created_by', 'normal', 'draft')";

if ($conn->query($sql)) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error"]);
}
?>