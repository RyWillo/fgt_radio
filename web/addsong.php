<?php
	if( !empty($_POST["title"]) && !empty($_POST["artist"]) && !empty($_POST["genre"]) && !empty($_POST["url"]) ){
		define("FgtFunctions", TRUE);
		include("media_handlers.php");

		$db = new mysqli("ip", "user", "password", "table") or die("Can't connect to db");
		$title = $_POST["title"];
		$artist = $_POST["artist"];
		$genre = $_POST["genre"];
		$url = $_POST["url"];

		if( @preg_match( $title . $artist . $genre . $url, "/[[:cntrl:]]/" ) ){ // @ Is to hide the delimter warning. If any \n or \t gets into the database the list.php will break.
			error_log("Attempted to addsong with invalid characters.");
			die("Invalid characters.");
		}

		mediaCheck( $url );

		$sql = $db->prepare("SELECT id FROM songs WHERE url=?") or die("Can' prepare");
		$sql->bind_param("s", $url) or die("Can't bind_param");
		$sql->execute() or die("Can't execute");
		$res = $sql->get_result() or die("Can't get_result");
		if( $res->num_rows ){
			die("URL already exists.");
		}

		$sql = $db->prepare("INSERT INTO songs VALUES (0, ?, ?, ?, ?, INET_ATON(?))") or die("Can't prepare");
		$sql->bind_param("sssss", $title, $artist, $genre, $url, $_SERVER["REMOTE_ADDR"]) or die("Can't bind");
		$sql->execute() or die("Can't execute");
		header( "Location: /" );

	} else {
		header( "Location: /" );
	}
?>
