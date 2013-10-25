<?php
	session_start();
	if( !empty($_SESSION['loggedin']) ){
		$db = new mysqli("ip", "user", "password", "table") or die("Can't connect to db");
		$sql = "DELETE FROM reports";
		$db->query($sql);

		header( "Location: /admin.php" );
	} else {
		header( "Location: /" );
	}
?>
