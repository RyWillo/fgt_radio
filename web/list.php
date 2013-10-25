<?php
	$db = new mysqli("ip", "user", "password", "table");
	$sql = "SELECT id, title, artist, genre, url FROM songs";

	if( $res = $db->query($sql) ){
		while( $row = $res->fetch_assoc() ){
			// id, title, artist, genre, url
			printf("%d\t%s\t%s\t%s\t%s\n", $row["id"], $row["title"], $row["artist"], $row["genre"], $row["url"]);
		}
	}

?>
