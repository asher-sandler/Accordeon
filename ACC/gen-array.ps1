Param(
[Parameter(Mandatory=$FALSE,Position=1)]
[string]$DirectoryName = ""
)

function getD($dir)
{
	$items = get-childitem $dir 

	$url =  "https://cbrportal.cbr.ru/gucfo/Kaluga/"
	$crlf = [char][int]13+[char][int]10

	$out = ""
	$a = 1;
	$b = 1;
	
	foreach($item in $items)
	{
			if ($item.PSIsContainer)
			{
			    
			   $out += $crlf+"A"+$a.tostring()+":"+$item.Name.Substring(1)+":spravka"+$crlf
			   $out += getD $item.FullName
			   $b = 1;
			   $global:isDir = $true
			}
			else
			{
				$out += "B"+$b.tostring()+":"+$item.BaseName+$crlf
				$urldir = $($dir.ToLower().Replace($item.PSDrive.ToString().ToLower()+":\",$url)).replace("\","/")
				$cout = $("C"+$b.tostring()+":"+$urldir+$item.Name+"?Web=1").Replace(" ","%20")
				
				$out +=$cout+$crlf
			}
		$a++
		$b++
	}

return $out

}

if ([String]::IsNullOrEmpty($DirectoryName)){
	
	write-host
	write-host "This script generate " -nonewline
	write-host "text file for Accordeon filling"  -foreground yellow 
	
	write-host  

	
	write-host "Usage : .\gen-array.ps1 - DirectoryName <dir with files>" -foreground yellow
	
	

}
else
{

	$crlf = [char][int]13+[char][int]10
	
	if (!(Test-Path -Path $DirectoryName))
	{
		write-host  "Directory "+$DirectoryName+" does not exists!" -foreground yellow 
	}
	else
	{	
	 
		$global:isDir = $false
		$dir = $(get-item $DirectoryName).FullName+"\"
		write-host $("Processing directory " +$dir)  -foreground yellow 
		$out+= getD $dir
		if (!$global:isDir)
		{
			$out = "A1:Документы:spravka"+$crlf+$out
		}
		$out |  out-file   -filepath "accordeon.txt"  -Force	-Encoding UTF8
	}
}

