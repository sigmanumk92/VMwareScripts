<###########################################
.SYNOPSIS
This script will allow the user to get the alerts from the Operations REST API
.DESCRIPTION
This script will allow the user to get the alerts from the Operations REST API
.NOTES
Author: Anthony Schulte
Created: 01/25/2025
.PARAMETER Filename
Pass the Content xml for each 
.EXAMPLE
Create-NewXML -outputpath "c:\scripts" -FileName 'view.xml'
#############################################>

Function Create-NewXML {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [String] $outputpath,
        [Parameter(Mandatory = $True)]
        [String] $ViewXMLFile
    )
    Begin {
        #Loading the views from the dashviews file
        Log-It "Importing the list of ids from the csv"
        $dashfilt = @()
		$dashfilt = Import-csv -Path "$($outputcsvdir)\viewinfo.csv" | Where-Object {$_.ViewID -and $_.ViewID -ne ''} | Select-Object -expandproperty ViewID
		
		Foreach($dashviewitem in $dashfilt){
			Log-it "View Item - $($dashviewitem)"
		}
               
        Log-it "Starting the process of creating XMLS"
        # Load the XML file
        $xml = [xml](Get-Content $ViewXMLFile)
        Log-it "XML file has been imported"

        # Select the Property nodes
        $rootname = $xml.DocumentElement.Name
        Log-it $rootname
        #$mainproperties = $xml.Content.Views
        $parentn1 = $xml.SelectSingleNode("/$rootname/Views")
        Foreach($xmlitem in $dashfilt){
            $viewfound = $parentn1.ViewDef | where {$_.id -match $xmlitem}
            If ($viewfound){
                foreach ($ChildNode in $viewfound) {
                    #Create a new XML document with same Root name
                    $newXml = New-Object System.Xml.XmlDocument
                    #Add the header for the XML File
                    $xmlDec = $newXml.CreateXmlDeclaration("1.0", "UTF-8", "yes")
                    $newXml.AppendChild($xmlDec)
                    #Create the New Root Structure
                    $newRoot = $newXml.CreateElement($xml.DocumentElement.Name)
                    $newXml.AppendChild($newRoot)

                    #Create the Views Element
                    $elementv = $newXml.CreateElement("Views")
                    $newRoot.AppendChild($elementv)

                    #Append main with root
                    $newdef = $newxml.ImportNode($ChildNode, $true)
                    $elementv.AppendChild($newdef)

                    #append the Main with the rest of child nodes
                    $xmlTitle = $childNode.id

                    # Save the new XML document
                    $newXml.Save("$($outputpath)\$xmlTitle.xml")
                }
            }else{
                Write-Output "view not found"
            }
        }

            
    }
}