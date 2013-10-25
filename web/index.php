<html>
<head>
<title>Fgt Radio - Playlist</title>
<?php
	$db = new mysqli("ip", "user", "password", "table") or die("Failed to connect to db!");
	$sql = "SELECT title, artist, genre FROM songs ORDER BY id DESC LIMIT 40";
	$res = $db->query($sql) or die("Can't query");
?>
</head>
<body>

<div id="divAddsong">
<form name="formAddsong" id="formAddsong" method="post" action="addsong.php">
        Title: <input name="title" type="text" id="artist"><br>
        Artist: <input name="artist" type="text" id="artist"><br>
	Genre: <input name="genre" type="text" id="genre"><br>
	URL: <input name="url" type="text" id="url"><br>
        <input type="submit" value="Submit">
</form>
</div>

<div id="recentSongsHeader"> Recently Added: </div>
<ul id="recentSongs">
<?php
	while( $row = $res->fetch_assoc() ){
		printf("\t<li>%s by %s (Genre: %s)</li>\n", $row["title"], $row["artist"], $row["genre"]);
	}
?>
</ul>

</body>
</html>
