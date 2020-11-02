Function ArrayToHTML #Param ([Array]$Collection); Returns HTML formated Output of collection as string
{Param ([Array]$Collection)
	$Properties = @()
	$ColumnHeaders = @()
	$Properties = $($Collection[0].PSObject.Properties).Name
	ForEach($Property in $Properties) 
	{
		$ColumnHeaders = $ColumnHeaders + "<font face=arial size=2><td><b>$($Property)</b></td></font>"
	}
	$body = "<font face=arial size=1><center><table border=2 width=90% cellspacing=0 cellpadding=8 bgcolor=Black cols=4><tr bgcolor=White align=center valign=middle><b>$ColumnHeaders</tr></font>"
	
	$Row = 1
	ForEach($Item in $Collection)
	{
		$i=0
		$CellValues = ""
		For($i=0; $i -lt $Properties.Count ; $i++)
		{
			$CellValues = $CellValues + "<td>$($Item.($Properties[$i]))</td>"
		}
		If ($Row % 2){$body = $body + "<font face=arial size=2><center><tr bgcolor=#99CCFF>$CellValues</tr></font>";$Row++}
		Else{$body += "<font face=arial size=2><center><tr bgcolor=#D6EBFF>$CellValues</tr></font>";$Row++}
	}
	$body = $body + "</table></center>"
	Return $body
} #end Function to Convert a collection to HTML for use in an HTML email body
