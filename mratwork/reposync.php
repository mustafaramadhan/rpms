<?php

	$source = gethostbynamel('rpms.mratwork.com');

	$sender = $_SERVER['REMOTE_ADDR'];

	$accept = false;

	foreach ($source as &$val) {
		if ($val === $sender) {
			$accept = true;
		}
	}

	if ($accept) {
		file_put_contents('ready_sync', 'ok');
		print("- Set to 'ready_sync'");
	} else {
		print("- Wrong from original source (rpms.mratwork.com)");
	}