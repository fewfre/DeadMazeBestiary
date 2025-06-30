<?php
require_once 'utils.php';
define('URL_TO_CHECK_IF_SCRIPT_HAS_ACCESS_TO_ASSETS', "http://www.transformice.com/images/x_deadmeat/x_monstres/x_monstre_1.swf");

setProgress('starting');

// Check if Atelier801 server can be accessed
$isA801ServerOnline = fetchHeadersOnly(URL_TO_CHECK_IF_SCRIPT_HAS_ACCESS_TO_ASSETS);
if(!$isA801ServerOnline['exists']) {
	setProgress('error', [ 'message' => "Update script cannot currently access the Atelier 801 servers - it may either be down, or script might be blocked/timed out" ]);
	exit;
}

////////////////////////////////////
// Core Logic
////////////////////////////////////

// Basic Resources

list($resourcesBasic, $externalBasic) = updateBasicResources();

setProgress('updating');
$json = getConfigJson();
$json["packs"]["monsters"] = $resourcesBasic;
$json["packs_external"] = $externalBasic;
saveConfigJson($json);

// Finished

setProgress('completed');
echo "Update Successful!";

sleep(10);
setProgress('idle');

////////////////////////////////////
// Update Functions
////////////////////////////////////

function updateBasicResources() {
	$resources = array();
	$external = array();

	//
	// Multi-item pack Loading
	//
	$max = 65;
	for($i = 0; $i < $max; $i++) {
		setProgress('updating', [ 'message'=>"Updating monster", 'value'=>$i+1, 'max'=>$max ]);
		$filename = "x_monstre_$i.swf";
		$url = "http://transformice.com/images/x_deadmeat/x_monstres/$filename";
		$file = "../$filename";
		downloadFileIfNewer($url, $file);
		
		// Check local file so that if there's a load issue the update script still uses the current saved version
		if(file_exists($file)) {
			$resources[] = $filename;
			$external[] = $url;
		}
	}
	
	return [$resources, $external];
}