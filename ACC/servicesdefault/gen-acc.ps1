
function ReadObj($name)
{
	$objxmlFileName =$name + ".json"

	
	if (!(Test-Path -Path $objxmlFileName))
	{
		return $false
	}
	
	$content = Get-Content -raw $objxmlFileName
	$oDbp=$content | ConvertFrom-Json

	return $oDbp
    
}



$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
 
# . "..\..\Script\Utils.ps1"
. "$dp0\Accordeon.ps1"


$templ = "Заявки"

$json = ReadObj($templ)



	$html = create-Accordeon-From-Template $json

	

	$fileName = $("act-rendered.html")
	# write-host $test
	# write-host $scriptName
	$html | out-file  -filepath $fileName -encoding UTF8 -Force
	# $test | out-file  -filepath $("..\Gen\webroot\js\test.js") -encoding UTF8 -Force

	$fl = get-item $fileName



	write-host $("html script was generated: ") 
	write-host $fl.FullName -ForeGround Green

