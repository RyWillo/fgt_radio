fgt_radio
=========

A media player for Garry's Mod.

I will try to keep the workshop revision and the github the same.
Feel free to learn from my code or even use it in your own. 
Just put in a comment somewhere pointing to this github.
http://steamcommunity.com/sharedfiles/filedetails/?id=177192540

The web directory has my webserver's php files as of 10/25/13 12:30.
I won't be pushing to the web directly often, if at all.
The php code in the web directory is very bare bones, to use it you will need to setup mariadb(mysql), php, and apache on your own.
I'll include the create table statements below:

```
CREATE TABLE `admins` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` text,
  `password` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB

CREATE TABLE `reports` (
  `ip_address` int(10) unsigned NOT NULL DEFAULT '0',
  `song_id` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`ip_address`,`song_id`),
  KEY `song_id` (`song_id`),
  CONSTRAINT `reports_ibfk_1` FOREIGN KEY (`ip_address`) REFERENCES `sessions` (`ip_address`) ON DELETE CASCADE,
  CONSTRAINT `reports_ibfk_2` FOREIGN KEY (`song_id`) REFERENCES `songs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB

CREATE TABLE `sessions` (
  `ip_address` int(10) unsigned NOT NULL,
  `phpsessid` text,
  PRIMARY KEY (`ip_address`)
) ENGINE=InnoDB

CREATE TABLE `songs` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` text,
  `artist` text,
  `genre` text,
  `url` longtext,
  `uploader` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB
```
