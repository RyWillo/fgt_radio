<?php
if(!defined("FgtFunctions")){ die(""); }

/* This 'library' is for handling new media.
   Garrysmod bass only can play hotlinked media so this file will convert youtube/soundcloud/dropbox links to that.
   As it stands this file just checks if a user is (incorrectly) linking to dropbox or youtube. (I've had alot of people try it).
*/

function mediaCheck( $url ) {
	if( !preg_match("/^[[:alpha:]]{1,5}:\/\//", $url) ){ //Check if url has a valid (http[s]/ftp):// beginning.
		error_log("Attempted to enter an invalid url. (missing protocol header): " . $url );
		die("Please enter a valid url. (Needs the http://)");
	}

	if( preg_match("/.*youtube\.com\/watch.*/", $url) ){
		error_log("Attempted to enter an invalid url. (youtube): " . $url );
		die("This player can not play youtube urls, yet.");
	}

	if( preg_match("/.*dropbox\.com\/s\/.*/", $url) ){
		error_log("Attempted to enter an invalid url. (non-public dropbox): " . $url );
		die("This dropbox link is not in your public folder");
	}
}

?>
