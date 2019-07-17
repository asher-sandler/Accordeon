function New-AccContent()
{

$content = "" | Select Name,URI

return $content

}

function New-AccObj()
{

$acc = "" | Select Name, Image, Contents

$acc.Name = ""
$acc.Image =""
$acc.Contents = @()



return $acc

}

function get-accArr($name)
{

$fileName = $name+".txt"

$file = get-content $fileName  -Encoding UTF8

$AccObj = @()

    $accExists = $false 
	
	$acc = New-AccObj 
	$contExist = $false
	
	foreach($line in $file)
	{
		if (![string]::IsNullOrEmpty($line.Trim()))
		{
			
			$arr = $line.Split(":")
			# $arr[0].Substring(0,2)
			$fw = $arr[0].Substring(0,1).ToUpper()
			if ($fw -eq "A")
			{
				if (!$accExists)
				{
					$accExists = $true
					
					
					
					
				}
				else
				{
				    if ($contExist)
					{
						 $acc.Contents +=$Content
					}
				    
					$AccObj += $acc 
				
				}
				
				
				$acc = New-AccObj 
				$acc.Name = $arr[1]
				$acc.Image = $arr[2]
				$contExist = $false
				
				
				
				
			}
			elseif (($fw -eq "B") )
			{
				if ($contExist)
				{
				   $acc.Contents +=$Content
				   
				   
				}
				else
				{
					
				}
				$content = New-AccContent 
				
				$content.Name = $line.Substring(3).replace(".docx","").replace(".doc","").replace(".xlsx","").replace(".xls","")
				$contExist = $true
			
			}
			elseif (($fw -eq "C") )
			{
			
				$content.URI = $line.Substring(3)
			}
		}

	}
	$acc.Contents +=$Content
	$AccObj += $acc 
	
	
    $AccObj |ConvertTo-Json -Depth 100 | out-file $($name+".json")


}

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

$templ = "Заявки"
get-accArr $templ




