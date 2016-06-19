<?php

for($i = 0; $i < 40; $i++) {
	$filename = "x_monstre_$i.swf";
	$url = "http://transformice.com/images/x_deadmeat/x_monstres/$filename";
	$code = checkExternalFile($url);
	if($code == 200 || $code == 300) {
		file_put_contents($filename, fopen($url, 'r'));
	}
}
echo "Update Successful! Redirecting...";
echo '<script>window.setTimeout(function(){ window.location = "../"; },1000);</script>';

function checkExternalFile($url)
{
	$ch = curl_init($url);
	curl_setopt($ch, CURLOPT_NOBODY, true);
	curl_exec($ch);
	$retCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
	curl_close($ch);

	return $retCode;
}
?>