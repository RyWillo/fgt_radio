<?php
	if( !empty($_POST["id"]) ){
		session_start();

		$db = new mysqli("ip", "user", "password", "table") or die("Can't connect to db");
		$client_ip = $_SERVER["REMOTE_ADDR"];
		$sessionid = session_id();
		$id = $_POST["id"];

		if( preg_match("/[^0-9]/", $id) ){
			die("Invalid ID.");
		}

		$sql = $db->prepare("INSERT INTO sessions values( INET_ATON(?), ? ) ON DUPLICATE KEY UPDATE phpsessid=phpsessid") or die("Can't prepare");
		$sql->bind_param("ss", $client_ip, $sessionid) or die("Can't bind");
		$sql->execute() or die("Can't execute");

		$sql = $db->prepare("INSERT INTO reports values( INET_ATON(?), ? ) ON DUPLICATE KEY UPDATE song_id=song_id") or die("Can't prepare");
		$sql->bind_param("sd", $client_ip, $id) or die("Can't bind");
		$sql->execute() or die("Can't execute " . $id);
		error_log("Report recieved: " . $id);

		header( "Location: /" );
	} else {
		header( "Location: /" );
	}
?>
