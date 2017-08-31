<?php
$validMonsters = array();
for($i = 0; $i < 65; $i++) {
	$filename = "x_monstre_$i.swf";
	$url = "http://transformice.com/images/x_deadmeat/x_monstres/$filename";
	$code = checkExternalFile($url);
	if($code == 200 || $code == 300) {
		file_put_contents($filename, fopen($url, 'r'));
		$validMonsters[] = $filename;
	}
}

$json = json_decode(file_get_contents("config.json"), true);
$json["packs"]["monsters"] = $validMonsters;
file_put_contents("config.json", json_encode($json));//, JSON_PRETTY_PRINT

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
