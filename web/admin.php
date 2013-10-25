<html>
<head>
<title>Fgt Radio - Admin</title>
<?php session_start(); ?>
</head>
<body>
<?php
	if(!empty($_SESSION['loggedin'])){
		$db = new mysqli("ip", "user", "password", "table") or die("Can't connect to db");
		$sql = "SELECT id, INET_NTOA(uploader), title, artist, genre, url, count(reports.ip_address) FROM songs LEFT JOIN reports ON reports.song_id=songs.id GROUP BY id ORDER BY count(reports.ip_address) DESC, id";
		$res = $db->query($sql) or die("Can't query");
?>
<form style="display: inline;" action="delsong.php" method="post">
<table id="songs" width="80%" border="1">
        <caption><h1>All Songs</h1></caption>
        <thead><tr>
		<th scope="col">ID</th>
		<th scope="col">IP</th>
                <th scope="col">Title</th>
                <th scope="col">Artist</th>
                <th scope="col">Genre</th>
		<th scope="col">URL</th>
		<th scope="col">Votes</th>
        </tr></thead>
        <tbody>
<?php
		while( $row = $res->fetch_assoc() ){
			//die( print_r( $row ) );
			echo "\t<tr>\n";
				printf("\t\t<td><input type=\"checkbox\" name=\"delSongs[]\" value=\"%d\">%d</td>\n", $row["id"], $row["id"]);
				printf("\t\t<td>%s</td>\n", $row["INET_NTOA(uploader)"]);
				printf("\t\t<td>%s</td>\n", $row["title"]);
				printf("\t\t<td>%s</td>\n", $row["artist"]);
				printf("\t\t<td>%s</td>\n", $row["genre"]);
				printf("\t\t<td><a href=\"%s\">%s</td>\n", $row["url"], substr($row["url"], 0, 100));
				printf("\t\t<td>%d</td>\n", $row["count(reports.ip_address)"]);
			echo "\t</tr>\n";
		}
?>
        </tbody>
</table>
<input type="submit" value="Delete Songs">
</form>
<form style="display: inline;" action="clearreports.php" method="post">
<input type="submit" value="Clear Votes">
</form>


<?php
	} else { // Opening brace for if loggedin check.
?>

<form method="post" action="login.php">
	Username: <input name="username" type="text" id="username"><br>
	Password: <input name="password" type="password" id="password"><br>
	<input type="submit" value="Login"><br>
</form>
	<?php } // Closing brace for if loggedin check. ?>

</body>
</html>
