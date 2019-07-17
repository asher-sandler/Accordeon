Param(

[Parameter(Mandatory=$TRUE)]
[string]$TemplateName
)

$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
 
. "$dp0\Utils.ps1"

    #write-host $outPath
	$tmpl = Open-Template($TemplateName)

	# $tmpl
	#read-host
	$source = Render-Template($tmpl)



	$fileout = $outPath+$TemplateName+".ps1"
	$source | out-file   -filepath $fileout  -Force	-Encoding UTF8

	$fl = get-item $fileout

	$firtString = $(get-content $fl -Encoding UTF8)[0]


	write-host $("PS script was generated: ") 
	write-host 
	write-host $fl.FullName -ForeGround Yellow
	write-host 
	write-host ("In this file :" + $firtString) -ForeGround Yellow
	write-host 


	<#
	$source | out-file   -filepath $($fileout+"-unknown")  -Force	-Encoding unknown
	$source | out-file   -filepath $($fileout+"-string")  -Force	-Encoding string
	$source | out-file   -filepath $($fileout+"-unicode")  -Force	-Encoding unicode
	$source | out-file   -filepath $($fileout+"-bigendianunicode")  -Force	-Encoding bigendianunicode
	$source | out-file   -filepath $($fileout+"-utf8")  -Force	-Encoding utf8
	$source | out-file   -filepath $($fileout+"-utf7")  -Force	-Encoding utf7
	$source | out-file   -filepath $($fileout+"-utf32")  -Force	-Encoding utf32
	$source | out-file   -filepath $($fileout+"-ascii")  -Force	-Encoding ascii
	$source | out-file   -filepath $($fileout+"-default")  -Force	-Encoding default
	$source | out-file   -filepath $($fileout+"-oem")  -Force	-Encoding oem
	#>

