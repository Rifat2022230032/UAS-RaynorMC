<?php
$host = 'teknologi22.xyz';
$username = 'teky6584_api_raynor';
$password = '644841Cpa';
$database = 'teky6584_api_raynor';

$conn = new mysqli($host, $username, $password, $database);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>
