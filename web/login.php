<?php
	if( !empty($_POST["username"]) && !empty($_POST["password"]) ){
		session_start();
		$db = new mysqli("ip", "user", "password", "table") or die("Can't connect to db");
		$user = $_POST["username"];
		$pass = $_POST["password"];
		$sql = $db->prepare("SELECT id FROM admins WHERE username=? AND password=SHA2( ?, 256 )") or die("Failed to prepare statement"); // I would reccomend using a salted hash.
		$sql->bind_param("ss", $user, $pass) or die("Failed to bind_param");
		$sql->execute() or die("Failed to execute sql");
		$res = $sql->get_result();

		if($res->num_rows) {
			$_SESSION['loggedin'] = 'true';
		}

		header( "Location: /admin.php" );

	} else {
		header( "Location: /" );
	}
?>
