<?php
	session_start();
	if( !empty($_POST["delSongs"]) && !empty($_SESSION['loggedin']) ){
		$db = new mysqli("ip", "user", "password", "table") or die("Can't connect to db");
		$songs = $_POST["delSongs"];
		$id = -1;

		for( $i = 0; $i < count($songs); $i++ ){
			if( preg_match("/[^0-9]/", $songs[$i]) ){
				die("Invalid ID: ". $songs[$i]);
			}
		}

		$sql = $db->prepare("DELETE FROM songs WHERE id=?") or die("Can't prepare");
		$sql->bind_param("d", $id) or die("Can't bind");

		for( $i = 0; $i < count($songs); $i++ ){ // Delete all the checked songs.
			$id = $songs[$i];
			$sql->execute() or die("Can't execute " . $id);
			$sql->reset();
		}

		header( "Location: /admin.php" );

	} else {
		header( "Location: /" );
	}
?>
