function process-dict($dict,$dictName)
{
$dbDictionary = "" | select Name, Tables
$dbDictionary.Tables=@()
# write-host $dictName
$dbDictionary.Name = $dictName.ToUpper()
$tables=@()
$tableexists = $false
$table = "" | select Name,Fields,DisplayName,FormName,FKeys,FieldOrder
$table.DisplayName = ""
$table.FormName = ""
$table.Fields=@()
$table.FKeys = @()
$table.FieldOrder = @()
$field = "" | select Name,Type,Lenght,DisplayName,Key
$foreignkey = "" | Select Table


foreach($line in $dict)
{
    $l = $line.trim()
	if ($l.length -gt 0)
	{
		 $arr=$l.split(":")
		 
		 if ($arr.count -gt 0)
		 {
				
				$fisrtw=$arr[0].trim().tolower()
				
				if ($fisrtw -eq 't')
				{
				    if (!$tableexists)
					{
					    $tableexists = $true
						
					}
					else
					{
						$tables +=$table
						$table = "" | select Name,Fields,DisplayName,FormName,FKeys,FieldOrder
						$table.DisplayName = ""
						$table.FormName = ""
						$table.Fields=@()
						$table.FKeys = @()
						$table.FieldOrder = @()
						

					}
					if ($arr.count -ge 2){
						$table.Name = $arr[1]
					}
					
					if ($arr.count -ge 3){
						$table.DisplayName = $arr[2]
					}
					
					if ($arr.count -ge 4){
						$table.FormName = $arr[3]
					}
						
						
				}
				if ($fisrtw -eq 's')
				{
					
				}
				if ($fisrtw -eq 'f')
				{
				    
					$field = "" | select Name,Type,DisplayName,Key
					$cnt = $arr.count
					$field.Name = $arr[1]
					$field.Type = $arr[2]
					$field.DisplayName=$arr[3].Substring(0,1).ToUpper()+$arr[3].Substring(1).ToLower()
					$field.Key=0
					if($cnt -gt 4)
					{
					     $field.Key=1
					}
					$table.Fields+=$field
					$table.FieldOrder+=$field.DisplayName+":"+$field.Name
					
				}
				if ($fisrtw -eq 'fk')
				{
				    
					
					$foreignkey = "" | Select Table
					
					$foreignkey.Table = $arr[1]
					#write-host $foreignkey.Table
					#read-host
					
					$table.FKeys+=$foreignkey
					$table.FieldOrder+="FK:"+$foreignkey.Table+":name"
					
					
					#write-host $table.FKeys.Count
					#write-host $table.FKeys
					
					#write-host beg
					#foreach($fk in $table.FKeys)
					#{
					
						
					#	write-host $fk.Table
						
					#}
					#write-host end
					#read-host
					
				}				
				if ($fisrtw -eq 'end')
				{
					if ($tableexists)
					{
						$tables +=$table
						#write-host $tables
						#read-host
						$table = "" | select Name,Fields,DisplayName,FormName,FKeys,FieldOrder
						$table.DisplayName = ""
						$table.FormName = ""
						$table.Fields=@()
						$table.FKeys = @()
						$table.FieldOrder = @()
						
					    $tableexists = $false
					}
				
				}
		 }
	 }

}
if ($tableexists)
{
	$tables +=$table
}
		
$dbDictionary.Tables=$tables


return $dbDictionary

}

function get-dictionary($dictName)
{
	$dictfile = $global:wpath +"Dictionary\"+ $dictName
	$file = get-item $dictfile
   $diction = get-content $dictfile
   $fname = $file.BaseName
   # write-host $fname
   $dbDict = process-dict $diction $fname
   return ($dbDict) 
}
function get-sql($dict){

	$dbName = $dict.Name
	$mark = [char][int]96
	$crlf = [char][int]13+[char][int]10
	$sql =  "CREATE DATABASE  IF NOT EXISTS "+$mark+$dbName+$mark+";"+$crlf
	$sql += "USE "+$mark+$dbName+$mark+";"+$crlf+$crlf
	
	$views = @()
	
	foreach($table in $dict.Tables)
	{
		$tableName = $table.Name
		$sql += "DROP TABLE IF EXISTS "+$mark+$tableName+$mark+";"+$crlf
		$sql += "CREATE TABLE "+$mark+$tableName+$mark+" ("+$crlf
		$sqlSelect = "id,"
		$ViewFieldNames = "id,"
		
		$sqlTableViewIndex = "DROP VIEW IF EXISTS "+$tableName+"_index;"+$crlf
		$sqlTableViewIndex += "CREATE VIEW "+$tableName+"_index AS"+$crlf
		$sqlTableViewIndex += "SELECT id,"
		$fieldidx=1
		foreach($field in $table.Fields){
			$sql += "   "+$mark+$field.Name+$mark+" "
			$sqlSelect += $field.Name 
			$ViewFieldNames += $field.DisplayName
			$sqlTableViewIndex += $field.Name 
			$type = $field.Type.Substring(0,1)
			$FieldLen=$field.Type.Remove(0,1).trim()
			
			if ($FieldLen.length -eq 0 )
			{
				$FieldLen='default'
			}
			if ($type -eq "$")
			{
				$sql += "varchar("
				if ($FieldLen -eq 'default')
				{
					$sql += "50"
				}
				else
				{
					$sql += $FieldLen
				}
				
				$sql += ") NOT NULL COMMENT '"+$field.DisplayName+"',"+$crlf
			}
			if ($fieldidx -lt $table.Fields.count)
			{
				$sqlSelect +=","
				$ViewFieldNames +=","
				$sqlTableViewIndex +=","
			}
			$fieldidx++
		}
		$isView = $false
		
		$viewTable = "" | Select TableParent, TableChild
		$viewTable.TableParent = ""
		$viewTable.TableChild  = ""
		
		#write-host  $table.FKeys.count
		
		$sqlview = ""
		$sqlproc = ""
		$parentSX = ""
		$fkidx =1;
		$selectFromView = ""
		foreach($fk in $table.FKeys)
		{
		    if ($fkidx -eq 1)
			{
				$ViewFieldNames +=","
				$sqlTableViewIndex +=","+$crlf
			}
		    $referenceFieldName = $fk.Table+"_id"
			# $sqlSelect += $referenceFieldName+","
		    $sql += "   "+$mark+$referenceFieldName+$mark+" int(10) UNSIGNED NOT NULL," +$crlf
			$sql += "   FOREIGN KEY("+$referenceFieldName+") REFERENCES "+$fk.Table+"(id),"+$crlf

			#write-host 215
			#write-host $table.Name
		    #write-host $fk.Table
			#write-host $sql
			#read-host
			$isView = $true
			$viewTable.TableParent = get-tableParent $dict $fk.Table
			$viewTable.TableChild  = $table
			$views += $viewTable
			
			
			$ViewFieldNames +=	$viewTable.TableParent.DisplayName		
			$parentSX += "(SELECT name FROM "+$mark+$viewTable.TableParent.Name+$mark
			$parentSX += " WHERE "
			$parentSX += $viewTable.TableParent.Name+".id="
			$parentSX += $viewTable.TableChild.Name +"."+$viewTable.TableParent.Name+"_id"
			$parentSX += ") as "
			$parentSX += get-viewFieldName $viewTable.TableParent.Name
			$selectFromView += get-viewFieldName $viewTable.TableParent.Name
			if ($fkidx -lt $table.FKeys.Count)
			{
			    
				$parentSX += ","
				$selectFromView +=","
				$ViewFieldNames +=","
			}
			$parentSX += $crlf
			

		
			$sqlview += get-SQLview $dict $viewTable 
		    $sqlproc += get-SQLproc $dict $viewTable.TableParent $viewTable.TableChild $fk
			$fkidx++
		}
		
		
		
		$sqlTableViewIndex += $parentSX+" FROM "+$tableName + ";"+$crlf
		$sql += "   "+$mark+"id"+$mark+" int(10) UNSIGNED NOT NULL AUTO_INCREMENT,"+$crlf
		$sql += "     PRIMARY KEY ("+$mark+"id"+$mark+")"+$crlf
		$sql += ") ENGINE=MyISAM DEFAULT CHARSET=utf8;"+$crlf+$crlf
		
        		
		
		$keyscount =0
		foreach($field in $table.Fields){
			if ($field.Key -eq 1)
			{
				$keyscount++
			}
		}
		if ($keyscount -gt 0){
			$i=0
			$sql += "ALTER TABLE "+$mark+$tableName+$mark+$crlf
			foreach($field in $table.Fields){
				if ($field.Key -eq 1)
				{
					$i++
					$sql += "  ADD KEY "+$mark+$field.Name+$mark+" ("+$mark+$field.Name+$mark+")"
					
					if ($i -ne $keyscount)
					{
						$sql += ","
					}
					else
					{
						$sql += ";"
					}
					$sql +=$crlf 
					
				}
			}
			
		}
		$sql +=$crlf +$sqlTableViewIndex +$crlf +$sqlview +$crlf + $sqlproc + $crlf
		
		if ($selectFromView.Length -gt 0)
		{
			$sqlSelect+= ","+$selectFromView
		}
		
		dbPassportViewFieldNamesSet  $dict.Name $tableName $ViewFieldNames
		dbPassportSelectSet  $dict.Name $tableName $sqlSelect
		dbPassportViewSet $dict.Name $tableName $tableName

	
	}
	return $sql
}
function get-tableParent ($dict, $TableName)
{
    $tabl = ""
   	foreach($table in $dict.Tables) 
	{
		if ($table.Name -eq $TableName)
		{
			$tabl = $table
		}
	}
	
	return $tabl;
}
function get-SQLproc ($dict, $TableParent, $TableChild, $fk) # ( $dict)
{
	$sqlstr = ""
	$mark = [char][int]96
	$crlf = [char][int]13+[char][int]10
	
	
	#write-host $TableParent.Name
	#write-host $TableChild.Name
	#read-host
	#foreach($table in $dict.Tables)
	#{
		#foreach($fo in $table.FieldOrder)
		#{
			#$arr =  $fo.split(":")
			#if ($arr[0].toupper().trim() -eq "FK"){
				$nameProc = get-sqlProcName $TableParent.Name "name"
				
				$sqlstr = "DROP PROCEDURE if exists "+$mark+$nameProc+$mark+";"+$crlf+$crlf
				$sqlstr += 'DELIMITER $$'+$crlf
				$sqlstr += 'CREATE PROCEDURE '+$mark+$nameProc+$mark+$crlf
				$sqlstr += '(IN '+$mark+'idParam'+$mark+" INT(10))"+$crlf
				$sqlstr += 'begin'+$crlf
				$sqlstr += 'select name from '+$TableParent.Name+" where "+$TableParent.Name+'.id=idParam;'+$crlf
				$sqlstr += 'end'+$crlf+'$$'+'DELIMITER ;'+$crlf
				
				#$noret= DbPassportProcNameSet $dict.Name $TableParent $TableChild  $nameProc 
				
				
			#}
		#}
	#}
	#write-host  $sqlstr
	#read-host
	return $sqlstr	

}
function get-sqlProcName($p1,$p2)
{
   $pName = 'get'
   $pName +=(Get-Culture).TextInfo.ToTitleCase($p1)
   $pName +=(Get-Culture).TextInfo.ToTitleCase($p2)
   
   return $pName
}
function get-SQLview($dict, $v)
{
	$sqlstr = ""
	$mark = [char][int]96
	$crlf = [char][int]13+[char][int]10
	
	
		
		
		
		#foreach($v in $views)
		#{
			
		    $nameView = $v.TableChild.Name+ "_"+ $v.TableParent.Name ;
			
			
			$selectParent = "SELECT "# Tchild.id AS "+$v.TableChild.Name+"_id, "
			<#
			$i = 1
			foreach($f in $v.TableParent.Fields)
			{
				$selectParent += "Tchild."+$f.Name+" AS "+$v.TableChild.Name+"_"+$f.Name+" " 
				if ($i -lt $v.TableParent.Fields.count)
				{
					$selectParent += ", "
				}
				$i++
				
			}
			#>
			
			
			$selectChild = "Tparent.id AS "+$v.TableParent.Name+"_id, "
			
			
			$i = 1
			foreach($f in $v.TableChild.Fields)
			{   if ($f.Name.tolower().trim() -eq 'name'){
				$selectChild += "Tparent."+$f.Name+" AS "+$v.TableParent.Name+"_"+$f.Name+" " 
				
				#if ($i -lt $v.TableChild.Fields.count)
				#{
			    #		$selectChild += ", "
				#}
				#$i++
				}
				
			}
			
			
			
			$sqlstr += "DROP VIEW IF EXISTS "+$nameView+";"+$crlf+$crlf
			
			$sqlstr += "CREATE VIEW "+$nameView+" AS "+$crlf
			$sqlstr += $selectParent + $crlf
			$sqlstr += $selectChild+$crlf
			$sqlstr += "FROM "+$mark+$v.TableChild.Name+$mark+" Tchild "+$crlf
			$sqlstr += "INNER JOIN "+$mark+$v.TableParent.Name+$mark+" Tparent "+$crlf
			$sqlstr += "ON "+$v.TableParent.Name+"_id=Tparent.id;"+$crlf+$crlf
			
			#write-host $sqlstr
			
			
			$dbpsql = "id,"
			$childS1 = "SELECT id,"
			$i = 1
			foreach($f in $v.TableChild.Fields)
			{
				$childS1 += $f.Name 
				$dbpsql += 	$f.Name
				if ($i -lt $v.TableChild.Fields.count)
				{
			    		$childS1 += ", "
						$dbpsql +=","
				}
				$i++
							
			}
			
			$parentS1 = ",(SELECT name FROM "+$mark+$v.TableParent.Name+$mark
			$parentS1 += " WHERE "
			$parentS1 += $v.TableParent.Name+".id="
			$parentS1 += $v.TableChild.Name +"."+$v.TableParent.Name+"_id"
			$parentS1 += ") as "
			$parentS1 += get-viewFieldName $v.TableParent.Name
			
			
			$dbpsql += ","+$v.TableParent.Name+"_name"
			
			
			
			
			$childS1 += $parentS1+ " FROM "+$mark+$v.TableChild.Name+$mark+";"
			$sqlstr += "DROP VIEW IF EXISTS "+$nameView+"_index;"+$crlf+$crlf
			
			
			
			#dbPassportSelectSet  $dict.Name $v.TableChild.Name $dbpsql
			
			dbPassportViewSet $dict.Name $v.TableChild.Name $($nameView+"_index")
			
			$sqlstr += "CREATE VIEW "+$nameView+"_index AS "+$crlf+$childS1+$crlf+$crlf
			
			
		#}
	
	
	return $sqlstr
}
function get-viewFieldName($tableName)
{
	return $($tableName+"_name")
}
function get-controller($table)
{
	$crlf = [char][int]13+[char][int]10
	$contrname = $table.Name.Substring(0,1).ToUpper()+$table.Name.Substring(1).ToLower()
    $contr = "<?php"+$crlf+$crlf+"class "+$contrname+"Controller extends Controller"+$crlf+"{"+$crlf
	$contr += '    public function __construct($data=array())'+$crlf+"    {"+$crlf
	$contr += "       parent::__construct($data);"+$crlf
	$contr += '       $this->model = new '+$contrname+'();'+$crlf+"    }"+$crlf+$crlf

	# field for check in form , if form filled
	# i.e. Surname-R001
	$fieldForCheck = $table.Fields[0].Name+"-"+$table.FormName

	
	$contr += '       public function index(){'+$crlf+$crlf
 
	
	$contr += '            if (isset($_POST["hidden-form-id-'+$table.FormName+'"])) {'+$crlf+$crlf
    $contr += '  	     	        $id = $_POST["hidden-form-id-'+$table.FormName+'"];'+$crlf+$crlf
	#### update family !!!
	$contr += '          	        if (isset($_POST["'+$fieldForCheck+'"])) {'+$crlf
    $contr += '        	             if ($id == -1) {'+$crlf
    $contr += '       	                 	$this->model->add($_POST);'+$crlf
    $contr += '          	        	     $id = $this->model->lastID();'+$crlf
    $contr += '                      } else {'+$crlf
    $contr += '                 		     $this->model->update($_POST, $id);'+$crlf
    $contr += '                      }'+$crlf+$crlf

    $contr += '                     Router::redirect("/" . Config::get('+"'site_root') . "+'"'+$table.Name.tolower()+'/datasaved/" . $id . "/1A");'+$crlf
    $contr += '              	} '+$crlf

	$contr += '			   }'+$crlf
    $contr += '            $this->data['+"'"+$table.Name.tolower()+"'"+'] = $this->model->getList();'+$crlf
	
	
	$contr += "		}"+$crlf+$crlf	


    # end index
	
	# ------------------------------------------
    # datasaved()
	
	
	$contr += "    public function datasaved()"+$crlf	
	$contr += "    {"+$crlf	
	$contr += '        $parameters = $this->getParams();'+$crlf	
	$contr += '        if (!is_null($parameters)) {'+$crlf	
	$contr += '            if (count($parameters) >= 1) {'+$crlf
	$contr += '                $id = $parameters[0];'+$crlf
	$contr += '                $this->data['+"'"+$table.Name+"'"+'] = $this->model->getById($id);'+$crlf
 	$contr += "               Session::setFlash('Информация успешно сохранена!');"+$crlf


 	$contr += "            }"+$crlf
 	$contr += "        }"+$crlf
 	$contr += "    }"+$crlf	


    # end datasaved
	# ------------------------------------------
	
	# ------------------------------------------
    # delete()
	
	
 	$contr += "    public function delete()"+$crlf
    $contr += "	{"+$crlf
    $contr += '    if ($_POST) {'+$crlf
    
	
	$contr += '        if (isset($_POST["'
	$hiddenFormID=get-hidden-formID $table 
	$contr += $hiddenFormID
	$contr +='"]))'+$crlf
	
	
    $contr +="        {"+$crlf
	
    $contr +='            $id=$_POST["'
	$contr += $hiddenFormID
	$contr += '"];'+$crlf
	

    
    $contr += '            $this->model->deleteById($id);'+$crlf

    $contr += "            Session::setFlash('Удалено!');"+$crlf

    $contr += "        }"+$crlf	
    $contr += "    }"+$crlf	+$crlf	
 	$contr += "	}"+$crlf	


    # end delete
	# ------------------------------------------
	
	
	# ------------------------------------------
    # ask_for_delete()
	
	
 	$contr += "    public function ask_for_delete()"+$crlf
 	$contr += "    {"+$crlf

 	$contr += '        if ($_POST) {'+$crlf
	$contr += '            if (isset($_POST["'+$hiddenFormID+'"]))'+$crlf
	$contr += '            {'+$crlf
	
	$contr +='         	    $id=$_POST["'
	$contr += $hiddenFormID
	$contr += '"];'+$crlf



	$contr += '                $this->data['+"'"+$table.Name+"'"+'] = $this->model->getById($id);'+$crlf
	$contr += "                Session::setFlash('Уверены, что хотите удалить?');"+$crlf

	$contr += "            }"+$crlf
	$contr += "        }"+$crlf
	$contr += "    }"+$crlf	


	
	# ------------------------------------------
    # end ask_for_delete()
	
		
	$contr += "}"+$crlf	


	return $contr
	
}
function get-model($table)
{
	$crlf = [char][int]13+[char][int]10
	$modelname = $table.Name.Substring(0,1).ToUpper()+$table.Name.Substring(1).ToLower()
    $model = "<?php"+$crlf+$crlf+"class "+$modelname+" extends model"+$crlf+"{"+$crlf
	$model += '    public function getList($value = null)'+$crlf+"    {"+$crlf
	$model += '       $sql = "select * from '+$table.Name+'";'+$crlf
	$model += '       return $this->db->query($sql);'+$crlf+"    }"+$crlf+$crlf



	# ------------------------------------------
    # update()

	$model += '    public function update($data, $id = null)'+$crlf
	$model += '    {'+$crlf


	$i=1
	$model += '      if('+$crlf	

		
	foreach($field in $table.Fields)
	{
	    $FormFieldName = get-FormFieldName $field.Name $table.FormName
		$model += '			!isset($data['
		$model += "'"+$FormFieldName+"'])"
		if ($i -lt $table.Fields.Count)
		{
			$model += "	||"
		}
		$model +=$crlf	
		$i++
	
	}
	

	$model += '        )'+$crlf		

	$model += '		{'+$crlf	
	$model += '            return false;'+$crlf	
	$model += '		}'+$crlf+$crlf		
	$model += '        $id =(int)$id;'+$crlf


	
	foreach($field in $table.Fields)
	{
	    $FormFieldName = get-FormFieldName $field.Name $table.FormName	
		$varName = '$'+$field.Name.tolower()
		
		$model += ' 	    '+ $varName + ' = $this->db->escape($data['+"'"
		$model += $FormFieldName
		$model += "']);"+$crlf		

	}

	$model +=$crlf


	$model +='        $sql = "UPDATE '+$table.Name +' SET'+$crlf


	$i=1
	foreach($field in $table.Fields)
	{
	    $FormFieldName = get-FormFieldName $field.Name $table.FormName	
		$varName = '$'+$field.Name.tolower()
		
		$model += '                    '+ $field.Name + "='{" + $varName +"}'"
		if ($i -lt $table.Fields.Count)
		{
			$model += ","
		}
		$i++		
		
		$model +=$crlf

	}

	$model +="       		        where id = '{" +'$id' +"}';"
	$model +='";'+$crlf+$crlf
	
	$model +='        return $this->db->query($sql);'+$crlf+$crlf	
	
	$model += '    }'+$crlf

	# ------------------------------------------
    # end update
	
	# ------------------------------------------
    # getById
	
	$model += '    public function getById($value=null)'+$crlf
	$model += '    {'+$crlf
	$model += '        $sql = "select * from ' + $table.Name+' ";'+$crlf
	$model += '        if (isset($value)) {'+$crlf
 	$model += '           if (is_numeric($value)) {'+$crlf
 	$model += '                $sql .= "WHERE id = '+"'"+'" . $value . "'+"'"+' ";'+$crlf
 	$model += '            }'+$crlf
 	$model += '        }'+$crlf
 	$model += '        $sql.= "  limit 1;";'+$crlf

 	$model += '        return $this->db->query($sql);'+$crlf
 	$model += '    }'+$crlf
	
	


	# ------------------------------------------
    # add()

	

	$model += '    public function add($data)'+$crlf
	$model += '    {'+$crlf


	$i=1
	$model += '      if('+$crlf	

		
	foreach($field in $table.Fields)
	{
	    $FormFieldName = get-FormFieldName $field.Name $table.FormName
		$model += '			!isset($data['
		$model += "'"+$FormFieldName+"'])"
		if ($i -lt $table.Fields.Count)
		{
			$model += "	||"
		}
		$model +=$crlf	
		$i++
	
	}
	

	$model += '        )'+$crlf		

	$model += '		{'+$crlf	
	$model += '            return false;'+$crlf	
	$model += '		}'+$crlf+$crlf		
	#$model += '        $id =(int)$id;'+$crlf


	
	foreach($field in $table.Fields)
	{
	    $FormFieldName = get-FormFieldName $field.Name $table.FormName	
		$varName = '$'+$field.Name.tolower()
		
		$model += ' 	    '+ $varName + ' = $this->db->escape($data['+"'"
		$model += $FormFieldName
		$model += "']);"+$crlf		

	}

	$model +=$crlf


	$model +='        $sql = "INSERT INTO '+$table.Name +' SET'+$crlf


	$i=1
	foreach($field in $table.Fields)
	{
	    $FormFieldName = get-FormFieldName $field.Name $table.FormName	
		$varName = '$'+$field.Name.tolower()
		
		$model += '                    '+ $field.Name + "='{" + $varName +"}'"
		if ($i -lt $table.Fields.Count)
		{
			$model += ","
		}
		$i++		
		
		$model +=$crlf

	}

	$model +=';";'+$crlf+$crlf
	
	$model +='        return $this->db->query($sql);'+$crlf+$crlf	
	
	$model += '    }'+$crlf




	# ------------------------------------------
    # end add
	$model += @'
    public function lastID()
    {
        $sql="SELECT LAST_INSERT_ID();";
        return $this->db->query($sql)[0]["LAST_INSERT_ID()"];
    }

'@	


	$model += '    public function deleteById($value=null)'+$crlf
	$model += '    {'+$crlf
	$model += '        if (isset($value))'+$crlf
 	$model += '       {'+$crlf

	$model += '            $sql = "DELETE FROM '+$table.Name+" WHERE id = '" +'" . $value . "'+"'"+'";'+$crlf

	$model += '            return $this->db->query($sql);'+$crlf
	$model += '        }'+$crlf
	$model += '    }'+$crlf
	
	
	# end class
	$model += "}"+$crlf	
	return $model	
}
function get-view($table)
{
	$crlf = [char][int]13+[char][int]10
	$viewname = $table.Name.tolower()
	$jsname = get-jsname $table.Name $table.FormName
	# write-host $jsname
	$html  ='<script src="/<?=Config::get('+"'site_root')?>js/" +$jsname+'"></script>'+$crlf
	$html +='	<div id="'+$viewname+'_index">'+$crlf
	$html +='	        <table class="table table-bordered table-striped table-hover" id="'+$viewname+'-table">'+$crlf+$crlf
	$html +='					<tr>'+$crlf
	$fieldscount=$table.Fields.count+1
	$percnt = [math]::Round((100/$fieldscount))
	$last_column_percnt = $percnt+(100-($percnt*$fieldscount))
	
	foreach($field in $table.Fields)
	{
    	$html +='		       		     <th width="'+$percnt.ToString()+'%">'+$field.DisplayName+"</th>"+$crlf	
	}
	$addbutton  = '<button class="btn btn-warning btn-lg" type="button" onclick="AddModal('
	$addbutton += "'<?=Config::get('site_root')?>')"
	$addbutton += '" data-target="#myModal" data-toggle="modal"><span class="glyphicon glyphicon-plus"></span>New</button>'
    $html +='		       		     <th width="'+$last_column_percnt.ToString()+'%">' +$addbutton+"</th>"+$crlf	
	
	
	$html +='					</tr>'+$crlf+$crlf
	$html +="					<?php foreach("+'$data'+"['"+$viewname+"']"+' as $row) {?>'+$crlf
	$html +='					<tr>'+$crlf
	foreach($field in $table.Fields){
		$html +='						 <td width="'+$percnt.ToString()+'%">'
		$html +='<?php echo $row['+"'"+$field.Name+"']; ?>"
		$html +='</td>'	+$crlf
	}
	$EditButton ='<button class="btn btn-info btn-lg" type="button" onclick="showModal('
	$EditButton+="'<?=" + '$row["id"'+"]?>',"
	
	foreach($field in $table.Fields){
		$EditButton+="'"+'<?=$row["' + $field.Name +'"'+"]?>',"
	
	}
	
	$EditButton+="'<?=Config::get('site_root')?>')"
	$EditButton+='" data-target="#myModal" data-toggle="modal">'
	$EditButton+='<span class="glyphicon glyphicon-file"></span>Open</button>'
	# write-host $EditButton 
	
	
	                        #<button class="btn btn-info btn-lg" type="button"
                            #    onclick="showModal('<?=$row["id"]?>','<?=$row["FAMILY"]?>','<?=$row["PHONE"]?>','<?=$row["ADDRESS"]?>','<?=$row["HOUSE"]?>','<?=$row["FLAT"]?>','<?=Config::get('site_root')?>')" data-target="#myModal" data-toggle="modal">
							# <span
                            #    class="glyphicon glyphicon-file"></span>Open
                        #</button>

	$html +='		       		     <td width="'+$last_column_percnt.ToString()+'%">'+$EditButton+"</td>"+$crlf	
	
	$html +='					</tr>'+$crlf
	$html +="					<?php } ?>"+$crlf+$crlf
	
	$html +='	        </table>'+$crlf
	$html +='	</div>'+$crlf
	
	
	$html += @'

	<div id="myModal" class="modal fade" role="dialog" >
	<!--div id="myModal" class="modal fade notice-success" role="dialog" -->
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">&times;</button>
					<h2 class="modal-title"></h2>
				</div>
				<!--div class="modal-body grad" -->
				<div class="modal-body" >

				</div>
				<div class="modal-title">
				</div>
				<div class="modal-footer">

					
					<button type="button" class="btb btn-default" data-dismiss="modal">Close</button>

				</div>
			</div>
		</div>
	</div>


'@
	return $html
}


function get-datasaved($table)
{
	$crlf = [char][int]13+[char][int]10
	$viewname = $table.Name.tolower()
	$jsname = get-jsname $table.Name $table.FormName
	# write-host $jsname
	$html +='<div>'+$crlf

	$html +='   <form action="/<?=Config::get('
	$html +="'site_root')?>" + $table.Name
	$html +='" method="post">'+$crlf

	$html +=@'
        <div class="row-md-8">
            <button class="btn btn-success" type="submit">Ok</button>

        </div>
        <br/>


    </form>
	
'@
	
	$html +='	<div id="'+$viewname+'_index">'+$crlf
	$html +='	        <table class="table table-bordered table-striped table-hover" id="'+$viewname+'-table">'+$crlf+$crlf
	$html +='					<tr>'+$crlf
	$fieldscount=$table.Fields.count
	$percnt = [math]::Round((100/$fieldscount))
	$last_column_percnt = $percnt+(100-($percnt*$fieldscount))
	
	foreach($field in $table.Fields)
	{
    	$html +='		       		     <th width="'+$percnt.ToString()+'%">'+$field.DisplayName+"</th>"+$crlf	
	}


	
	$html +='					</tr>'+$crlf+$crlf
	$html +="					<?php foreach("+'$data'+"['"+$viewname+"']"+' as $row) {?>'+$crlf
	$html +='					<tr>'+$crlf
	foreach($field in $table.Fields){
		$html +='						 <td width="'+$percnt.ToString()+'%">'
		$html +='<?php echo $row['+"'"+$field.Name+"']; ?>"
		$html +='</td>'	+$crlf
	}
	
	$html +='					</tr>'+$crlf
	$html +="					<?php } ?>"+$crlf+$crlf
	
	$html +='	        </table>'+$crlf
	$html +='	</div>'+$crlf	
	$html +='</div>'+$crlf
	
	

	return $html
}

function get-deleteHTML($table)
{
	$crlf = [char][int]13+[char][int]10
	$html +='   <form action="/<?=Config::get('
	$html +="'site_root')?>" + $table.Name
	$html +='" method="post">'+$crlf
	
	$html +=@'
        <div class="row-md-8">
            <button class="btn btn-success" type="submit">Ok</button>

        </div>
        <br/>


    </form>
'@
	
	return $html
}


function get-AskForDelete($table)
{
	$crlf = [char][int]13+[char][int]10
	$viewname = $table.Name.tolower()
	$jsname = get-jsname $table.Name $table.FormName
	# write-host $jsname
	$html +='<div>'+$crlf
	$html +='   <div class="row-md-8">'+$crlf


	$html +='   <form action="/<?=Config::get('
	$html +="'site_root')?>" + $table.Name
	$html +='/delete" method="post">'+$crlf

	$hiddenFormID=get-hidden-formID($table)
	
	$html +='           <input type="hidden" id="'
	$html +=$hiddenFormID
	$html +='" name="'
	$html +=$hiddenFormID
	$html +='" value="<?php echo $data['+"'"+$table.Name+"'"+'][0]["id"]; ?>">'+$crlf
	$html +='            <button  type="submit" class="btn btn-danger"><span class="glyphicon glyphicon-trash"></span>Удалить</button>'+$crlf
	
	$html +="        </form>"+$crlf
 
 
 	$html +='   <form action="/<?=Config::get('
	$html +="'site_root')?>" + $table.Name
	$html +='" method="post">'+$crlf
	
    $html +='        <button  type="submit" class="btn btn-info"><span class="glyphicon glyphicon-backward"></span>Отмена</button>'+$crlf
    $html +='    </form>'+$crlf
    $html +='</div>'+$crlf
    $html +='<br/>'+$crlf




	
	$html +='	<div id="'+$viewname+'_index">'+$crlf
	$html +='	        <table class="table table-bordered table-striped table-hover" id="'+$viewname+'-table">'+$crlf+$crlf
	$html +='					<tr>'+$crlf
	$fieldscount=$table.Fields.count
	$percnt = [math]::Round((100/$fieldscount))
	$last_column_percnt = $percnt+(100-($percnt*$fieldscount))
	
	foreach($field in $table.Fields)
	{
    	$html +='		       		     <th width="'+$percnt.ToString()+'%">'+$field.DisplayName+"</th>"+$crlf	
	}


	
	$html +='					</tr>'+$crlf+$crlf
	$html +="					<?php foreach("+'$data'+"['"+$viewname+"']"+' as $row) {?>'+$crlf
	$html +='					<tr>'+$crlf
	foreach($field in $table.Fields){
		$html +='						 <td width="'+$percnt.ToString()+'%">'
		$html +='<?php echo $row['+"'"+$field.Name+"']; ?>"
		$html +='</td>'	+$crlf
	}
	
	$html +='					</tr>'+$crlf
	$html +="					<?php } ?>"+$crlf+$crlf
	
	$html +='	        </table>'+$crlf
	$html +='	</div>'+$crlf	
	$html +='</div>'+$crlf
	
	

	return $html
}

function get-formsFromPassport($name)
{
	$crlf = [char][int]13+[char][int]10
	$gendir = "..\gen\"+$name+"\forms\"
	$dpPassp = dbPassportReadObj($name)
	              #12345678901234567890
	$formHeader = ";Database Name     : "+$dpPassp.Name+$crlf+$crlf
	
	foreach($table in $dpPassp.Tables)
	{
		$formBody  = "t:"+$table.TableName+":"+$table.FormName+$crlf
					 #12345678901234567890
		$formBody += ";Form Type         :"+$table.FormType+$crlf+$crlf+$crlf
		
		$formBody += "View:"+$table.View+$crlf+$crlf+$crlf
		
		foreach($f in $table.Fields)
		{
			$formBody += $f.DisplayName+":"+$f.Name+$crlf
		}
		
		$formDirName = "..\gen\"+$name+"\forms\"+$table.FormType+"\"
		
		if (!(Test-Path -Path $formDirName))
		{
			New-Item -ItemType Directory  -Force -Path $formDirName
		}
		$form = $formHeader +  $formBody
		
		$formname = $formDirName + $table.TableName + "-"+$table.FormName+".wnf"
		$form  | out-file  -filepath $formname -encoding Unicode -Force	
	
	}
	
	
	dbPassportSaveObj  $dpPassp ""
}
function get-form($dbname,$table,$dirview,$viewname)
{
	$crlf = [char][int]13+[char][int]10
	$wnf ="t:"+$table.Name+":"+$table.FormName+$crlf+$crlf
	$jsname = get-jsname  $table.Name $table.FormName 
	$wnf +="; database - "+$dbname+$crlf
	$wnf +="; table    - "+$table.Name+$crlf
	$wnf +=", form     - "+$table.FormName+$crlf
	$wnf +="; html     - "+$dirview+$viewname+ $crlf
	$wnf +="; js       - /webroot/js/"+$table.Name+$table.FormName+".js"+$crlf+$crlf
	
	$wnf +="; To generate js - run powershell script  [.\gen-js.ps1 -FormName "+$table.Name+"-"+$table.FormName+".wnf]"+$crlf+$crlf
	
	$wnf +=";           НЕ ПОЛЬЗУЙТЕСЬ  в  примечаниях  знаком   двоеточие"+$crlf+$crlf
	$wnf +="; следует   менять   только порядок   при   выводе  формы  или убирать поле"+$crlf
	$wnf +="; не нужно убирать или изменять params, без этого js не будет сгенерирован."+$crlf+$crlf+$crlf+$crlf+$crlf+$crlf
	
	$wnf +="params:id,"
	
	foreach($field in $table.Fields)
	{
		$wnf +=$field.Name+","
	}
	$wnf +="siteroot"+$crlf+$crlf
	
	foreach($field in $table.Fields)
	{
		$wnf +=$field.DisplayName+":"+$field.Name+$crlf+$crlf+$crlf
	}

	#foreach($fo in $table.FieldOrder)
	#{
	#		$wnf += $fo+$crlf
	#}
	
	
	
	return $wnf
}
function Open-Form($FormName)
{
     
     $formFile = "forms\"+$FormName
	 #write-host $formFile
	 $frm = ""
     if (!$(Test-Path $formFile))
	 {
		write-host $("Form file "+$formFile+" not exists") -foreground yellow
		
	 }
	 else
	 {
         $frm = Get-content $formFile
	 }
	 return $frm
}
function Open-TabbedForm($FormName)
{
     
     $formFile = "..\..\tabbedforms\"+$FormName
	 # write-host $formFile
	 $frm = ""
     if (!$(Test-Path $formFile))
	 {
		write-host $("Form file "+$formFile+" not exists") -foreground yellow
		
	 }
	 else
	 {
         $frm = Get-content $formFile
	 }
	 return $frm
}
function get-TabbedFormObj($formctx)
{
	$tabbedForm = "" | Select Name,FormName,Description, Params, ParamString, tabs, FormGroup
	
	$tabbedForm.Name=""
	$tabbedForm.FormName=""
	$tabbedForm.ParamString=""
	$tabbedForm.Description=""
	$tabbedForm.Params=@()
	$tabbedForm.tabs=@()


	$currentTab="" | Select Name,Fields
	$currentTab.Name = ""
	$currentTab.Fields=@()
	
	 foreach($line in $formctx)
	 {
	     $l = $line.trim()
		if ($l.length -gt 0)
		{
			$arr=$l.split(":")
			if ($arr.count -gt 0)
			{
			    <#
			    foreach($a in $arr)
				{
					write-host $a
				}
				read-host
				#>
				$fisrtw=$arr[0].trim().tolower()
				if ($fisrtw -eq 't')
				{
					$tabbedForm.Name=$arr[1]
					$tabbedForm.FormName=$arr[2]
					$tabbedForm.Description=$arr[3]
					
					
				}elseif($fisrtw -eq 'params')
				{
					$tabbedForm.Params=$arr[1].Split(",")
					$tabbedForm.ParamString = $arr[1]
				}
				elseif($fisrtw -eq 'tab')
				{
					if ($currentTab.Fields.Count -gt 0)
					{
					    $tabbedForm.tabs += $currentTab
					}
					$currentTab="" | Select Name,Fields
					$currentTab.Name = $arr[1]
					$currentTab.Fields=@()

				}
				elseif($tabbedForm.Params.Contains($arr[1]))
				{
					$isReq = $false
					if ($arr.count -eq 3)
					{
					   if($arr[2].ToUpper().Trim() -eq 'REQ')
					   {
							$isReq = $true
					   }
					}
					$field = "" | select Label,Name,IsReq 
					$field.Label = $arr[0]
					$field.Name = $arr[1]
					$field.IsReq=$isReq
					
					$currentTab.Fields += $field
				}
			}
			
				
			
		}
	}

	$tabbedForm.tabs += $currentTab
	
	return $tabbedForm	
	
	
	
}

function get-TabbedFormHtml($formo)
{
      

}


Function Get-Formjs($formctx)
{
     $formo = "" | Select Name, FormName, Params, ParamString, FormGroup
	 $formo.Name=""
	 $formo.FormName=""
	 $formo.ParamString=""
	 $formo.Params=@()

	 $formo.FormGroup=@()
	 
	 
	 
	 foreach($line in $formctx)
	 {
	     $l = $line.trim()
		if ($l.length -gt 0)
		{
			$arr=$l.split(":")
			if ($arr.count -gt 0)
			{
				$fisrtw=$arr[0].trim().tolower()
				if ($fisrtw -eq 't')
				{
					$formo.Name=$arr[1]
					$formo.FormName=$arr[2]
					
					
				}elseif($fisrtw -eq 'params')
				{
					$formo.Params=$arr[1].Split(",")
					$formo.ParamString = $arr[1]
				}
				elseif($formo.Params.Contains($arr[1]))
				{
					
					$arrtemp = $arr[0],$arr[1]
					$formo.FormGroup += , $arrtemp
				}
			}
			
				
			
		}
	}

	return $formo 
	 
}
function create-js($formo)
{
	$crlf = [char][int]13+[char][int]10
	
	$hiddenFormID=get-hidden-formID($formo)
	$scr  = "function showModal("+$formo.ParamString+") {"+$crlf +$crlf
	$scr += "    html =  '<form class="+'"'+'form-horizontal"   role="form" action="/'+"'+siteroot+'"
	$scr += $formo.Name
	$scr += '/ask_for_delete" method="post">'+">';"+$crlf +$crlf
	
    # html =  '<form class="form-horizontal"   role="form" action="/'+siteroot+'pbk/ask_for_delete" method="post">';


    foreach($fgr in $formo.FormGroup){

		$formid =$fgr[1]+"-"+$formo.FormName
		# block text
		$scr += @"
	html+=	'<div class="form-group">'+
			'<label  class="col-sm-2 control-label" for="
"@
		#end block
		
		


		$scr+=$formid+'">'+$fgr[0]+":</label>'+"+$crlf


		# block text
		$scr+=@"
			'<div class="col-sm-10">'+
			'<label type="text" class="form-control" id="
"@		
		#end block

		$scr+=$formid+'"  name="'+$formid+'"'+"   >'+"+$fgr[1]+"+'<label/>'+"+$crlf
		$scr+="            '</div>'+"+$crlf
		$scr+="            '</div>';"+$crlf+$crlf+$crlf
		

	}
	
	$scr+=@"
	
    html+= '<input type="hidden"  id="
"@
	$scr+=$hiddenFormID+'" name="'	+ $hiddenFormID+'" value="'+"'+id+'"+'"/>'+"';"+$crlf+$crlf
   
    $scr+=@"
	editModtxt ='onclick="editModal('+

"@
   $i=0
   foreach($param in $formo.Params)
   {
		$i++
		if ($i -lt $formo.Params.Count)
		{
			$scr+='							"'+"'"+'"+'+$param+'+"'+"',"+'"+'+$crlf
   
		}
   
   }
   $scr+='							"'+"'"+'"+siteroot+"'+"')"+'";'+$crlf
   
   
   $scr+=@'

   html+=    '</div><div class="form-group">'+
        '<div class="col-sm-offset-2 col-sm-10">'+
        '<button  class="btn btn-info" '+
         editModtxt+
        ' ><span class="glyphicon glyphicon-pencil"'+
        '"></span>Редактировать</button>'+
        '<button type="submit" class="btn btn-danger"><span class="glyphicon glyphicon-trash"></span>Удалить</button>'+
        '</div><div>'+
        '</form>';
		
		
	$("#myModal .modal-header").html("<b>Просмотр: </b>")
    $("#myModal .modal-title").html("")
    $("#myModal .modal-body").html(html)
    $("myModal").modal();	
}   
'@
   return $scr
	
	
}
function get-hidden-formID($Form)
{
return "hidden-form-id-"+$Form.FormName
}

function get-JSName ($Name, $FormName)
{
	return $($Name+$FormName+".js")
}
function Open-Template($templateName)
{
    $templFileName  =  $templateName + ".tmpl"
    $tmpl = ""
	
	#write-host $templFileName
	#read-host
    if ($(Test-Path $templFileName))
    {
        $tmpl = Get-Content $templFileName # -encoding UTF8
    }
    return $tmpl
}

function Render-Template($tmpl)
{
	$source = ""
	$crlf = [char][int]13+[char][int]10  
    $linenumb = 1	
	$isDebug = $true
	foreach ($line in $tmpl)
	{
        $lw = $line.Trim()
		if ($lw.Contains("@"))
		{
		   # it is a  comments nothing to do
		}
		elseif($lw.Contains("<<") -and $lw.Contains(">>") -and (!$lw.Contains("%")))
		{
		    #if (!$lw.Contains("%"))
			#{
				# source code ps script

				$ls = $line.Replace("<<","").Replace(">>","")
				$source+=$ls+$crlf
				
			#}
		}
		elseif(!($lw.Contains("<<") -and $lw.Contains(">>"))){
				if ($lw.Length -eq 0)
				{
					$source += '# '+ $linenumb+$crlf
				}
				else
				{
		
					$source += '		$script +='+"@'"+$crlf
					$source += $line+$crlf
					$source += "'@"+$crlf
					$source+='		$script +=$crlf;'+$crlf
					

				}
		}
		elseif ($lw.Length -gt 0)
		{
		    $currentline = "'"
			
			
			$delimtxt = ""
			
			$singledelim_beg = "'+"+'"'+"'"+'"'+"+'"
			$singledelim_end = "'+"+'"'+"'"+'"'+"+'"

			$isBegin = $false
			$ch = $line.Split()[0]
			# first char
			$s = $line.Replace("'",$singledelim_beg)
            $s = "'"+$s+"'"
			
			$source+='		$script +='+$s+'+$crlf'+$crlf
			
		
			
			#$currentline+=$delim
	
			
			#write-host $linenumb
			#write-host $currentline
			#read-host
			
		
			
		}
		
		
		$linenumb++
	}
   $source = $source.Replace("<<%%","'+")
   $source = $source.Replace("%%>>","+'")
   #$source = $source.Replace("<<%","")
   #$source = $source.Replace("%>>","")
   
   return $source
}

function get-FormFieldName ($field,$FormName)
{


   return $field+"-"+$FormName

}
function dbPassportTableNew($table)
{
	

	$dbpTable = "" | Select TableName,DisplayName, View,ViewFieldNames, ViewName,  Fields,FormName,FormType;
	$dbpTable.TableName=$table.Name;
	$dbpTable.DisplayName = $table.DisplayName;
	$dbpTable.Fields = @();
	# $dbpTable.Constraints = @();
	$dbpTable.FormName =  "";
	$dbpTable.ViewFieldNames = "";
	$dbpTable.Formtype = "simple";
	
	return $dbpTable;
	
}
function dbPassportFieldNew($field,$isConstr )
{
    $dbpfield = "" | select Name,Type,Lenght,DisplayName,isConstraint,Constraint
	
	$dbpfield.Name = $field.Name;
	$dbpfield.Type = $field.Type;
	$dbpfield.Lenght = $field.Lenght;
	$dbpfield.isConstraint = $isConstr;
	$dbpfield.DisplayName = $field.DisplayName;
	$dbpfield.Constraint = dbPassportConstraintFieldNew
	
	
	
	return $dbpfield;
}
function dbPassportConstraintNew($fkName)
{
    $fk="" | Select Table
	$fk.Table = $fkName
	return $fk
}
function dbPassportConstraintFieldNew()
{
	$Constraint ="" | Select ParentTable,ParentField,View,ViewField,ViewName,SProcName
	
	$Constraint.ParentTable= ""
	$Constraint.ParentField=""
	$Constraint.View =""
	$Constraint.ViewField=""
	$Constraint.ViewName=""
	$Constraint.SProcName=""
	
	return $Constraint
	
}
function dbPassportNew($dict)
{
	# $dict = "" | select Name, Tables  
	# $table = "" | select Name,Fields,DisplayName,FormName,FKeys,FieldOrder
	# $field = "" | select Name,Type,Lenght,DisplayName,Key
	# $foreignkey = "" | Select Table
	
	
	$dbPassport = "" | select Name, Tables  ;
	$dbPassport.Name = $dict.Name;
	$dbPassport.Tables = @();
	

	
	foreach($table in $dict.Tables)
	{
		$dpTable = dbPassportTableNew($table);
		$dpTable.FormName = $table.FormName
		if ($table.Fields.count -gt 6)
		{
			$dpTable.Formtype = "tabbed";
		}
		
		foreach($field in $table.Fields)
		{
		    $dbpField = dbPassportFieldNew $field $false;
			$dpTable.Fields +=	$dbpField;
		}
		
		foreach($fk in $table.FKeys)
		{
			#write-host $dpTable.Formtype
			#read-host
			if ($dpTable.Formtype -eq "simple")
			{
				$dpTable.Formtype = "onetab"
			}
		    #write-host "FK:"
	    	#	write-host $fk.Table
			#read-host
		    #if (![string]::IsNullOrEmpty($table.foreignkey.Table)){
			$dbpfield = "" | select Name,Type,Lenght,DisplayName,isConstraint,Constraint
	
			$dbpField.Name = $fk.Table+"_id"
			$dbpfield.isConstraint = $true
			$dbpfield.Constraint = dbPassportConstraintFieldNew
			
			
			
			$dbpField.Constraint.ParentTable= $fk.Table
			$dbpField.Constraint.ParentField="id"
			
			
			#$dbpField.Constraint | gm
			
			$dbpField.Constraint.View = "name"
			
			$dbpField.Constraint.ViewField=get-viewFieldName $fk.Table
			$dbpField.Constraint.ViewName=$table.Name+ "_"+ $fk.Table+"_index"
			$proname = get-sqlProcName $fk.Table "name"
			#write-host $proname
			#read-host
			
			$dbpField.Constraint.SProcName=  $proname
			
			
			
			$dpTable.Fields +=	$dbpField;
			
			#}
		}
		
		
		$dbPassport.Tables += $dpTable;
	    
	}
	
	#write-host 123
	
	$noret=dbPassportSaveObj  $dbPassport ""
	
	#write-host dbPassportSaveObj 
	#read-host 
	return $dbPassport;


}
function dbPassportSaveObj($dbPassport,$name="")
{
    
	$objxmlFileName =  "..\gen\"+$dbPassport.Name+"\dbPassport\"
	
	#write-host $objxmlFileName
	#write-host $name
	#get-pscallstack | select-object -property *
	#read-host

	if (!(Test-Path -Path $objxmlFileName))
	{
		New-Item -ItemType Directory  -Force -Path $objxmlFileName
	}
    if ($name -eq ""){
		$objxmlFileName+="dbPassport"
	}
	else
	{
		$objxmlFileName+=$name
	}
			

	$dbPassport | Export-CliXML $($objxmlFileName+".xml")

	$dbPassport |ConvertTo-Json -Depth 100 | out-file $($objxmlFileName+".json")
}

function dbDictSave($dbDict)
{

	$objxmlFileName =  "..\gen\"+$dbDict.Name+"\dbPassport\"
	if (!(Test-Path -Path $objxmlFileName))
	{
		New-Item -ItemType Directory  -Force -Path $objxmlFileName
	}
	$objxmlFileName+=$dbDict.Name
	$dbDict |ConvertTo-Json -Depth 100 | out-file $($objxmlFileName+".json")
	
	
}

function dbPassportReadObj($name)
{
	$objxmlFileName ="..\gen\"+$Name+"\dbPassport\dbPassport.json"

	
	if (!(Test-Path -Path $objxmlFileName))
	{
		return $false
	}
	
	$content = Get-Content -raw $objxmlFileName
	$oDbp=$content | ConvertFrom-Json

	return $oDbp
    
}
function dbPassportViewFieldNamesSet($dicName,$dbptableName,$ViewFieldNames)
{
	  $i=0;	
	  
	 
	  
	  $oDbp = dbPassportReadObj $dicName 
	  
	 
      foreach($table in $oDbp.Tables)
	  {
		if ($table.TableName -eq $dbptableName)
		{
			$oDbp.Tables[$i].ViewFieldNames = $ViewFieldNames ;
		
		}
		$i++
	  
	  }
	  #write-host 456
	  #read-host
	  dbPassportSaveObj $oDbp ""


}
function dbPassportSelectSet($dicName,$dbptableName,$select)
{
	  $i=0;	
	  
	 
	  
	  $oDbp = dbPassportReadObj $dicName 
	  
	 
      foreach($table in $oDbp.Tables)
	  {
		if ($table.TableName -eq $dbptableName)
		{
			$oDbp.Tables[$i].View = $select ;
		
		}
		$i++
	  
	  }
	  #write-host 456
	  #read-host
	  dbPassportSaveObj $oDbp ""


}
function DbPassportProcNameSet($dicName,$dbptableparent,$dbptablechild,$nameProc)
{
	
	
	$fieldC = $dbptablechild.Name+"_id"
	
	$fieldP = $dbptableparent.Name+"_id"
	$Tablidx=0;	
	  
	#write-host we are here
	#read-host
	
	#write-host $("fieldP: "+ $fieldP)
	#write-host $("fieldC: "+ $fieldC)
	
	#lkfjwsol;k;slafk
	
	
	#write-host We are here 
	#read-host
	
	  
	$oDbp = dbPassportReadObj $dicName 
	
	
	#write-host $fieldP
	#write-host $nameProc
	#read-host
	
	foreach($table in $oDbp.Tables)
	{
		if ($table.TableName -eq $dbptablechild.Name)
		{
		    #write-host line 1633 table eq
			# write-host $dbptablechild.Name
			#read-host
		    $fieldidx = 0
		    foreach($field in $table.Fields)
			{
			    #write-host line 1639
				#write-host $field.Name
				#read-host
				
			    if ($field.Name -eq $fieldP){
					#write-host line 1656 field eq
					#write-host $fieldP
					#read-host
					if ($field.isConstraint)
					{
					
					#write-host 09876
					#read-host
						
						# $oDbp.Tables[$Tablidx].Fields[$fieldidx].Constraint.SProcName = $nameProc ;
						
					}
				}
				$fieldidx++
			}
			
		
		}
		$Tablidx++	
	}
	#write-host 789
	#read-host
	#dbPassportSaveObj $oDbp ""
	return ""

}
function dbPassportViewSet($dicName,$dbptableName,$view)
{
	  $i=0;	
	  
	 
	  
	  $oDbp = dbPassportReadObj $dicName 
	  
	 
      foreach($table in $oDbp.Tables)
	  {
		if ($table.TableName -eq $dbptableName)
		{
			$oDbp.Tables[$i].ViewName = $view+"_index" ;
		
		}
		$i++
	  
	  }
	  
	  #write-host ABC
	  #read-host
	  dbPassportSaveObj $oDbp ""


}

