<#
.SYNOPSIS
Send an email report from an array input
.DESCRIPTION
The purpose of this script is to send an email report that is HTML formatted from an array.
.NOTES
Author: Kevin McClure
.PARAMETER EmailInput
Input of the email report. 
.PARAMETER EmailAddress
Email address to send HTML report to.
.PARAMETER SMTPServer
SMTP Server to use for mail delivery.
.EXAMPLE
$Array | Invoke-EmailReport -EmailAddress test@contoso.com -SMTPServer mail.contoso.com
#>

Function Invoke-EmailReport () {
    [CmdletBinding()]
    Param(
        #[Parameter(Position = 0, ValuefromPipeline, Mandatory = $True)]
        [Parameter(Mandatory = $True)]
        [array]$EmailInput,
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]$EmailAddress,
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]$SMTPServer
    )
    #Define Style of HTML Output
    $Style = @"
<title></title>
<h1></h1>
<style>
body { background-color:#FFFFFF;
font-family:Arial;
font-size:10pt; }
td, th { border:1px solid black;
border-collapse:collapse; }
th { color:black;
background-color:#8DB4E2; }
table, tr, td, th { padding: 2px; margin: 0px }
table { width:95%;margin-left:5px; margin-bottom:20px;}
.bad {color: Red ; back-ground-color: Red}
.good {color: #21A30C }
.warning {color: #F3DC1B }
.critical {color: #F3351B}
.notice {color: #F3DC1B }
.other {color: #000000 }
tr:nth-child(odd) {background-color:#d3d3d3;}
tr:nth-child(even) {background-color:white;}
</style>
<br>
"@    

    #Create email object
    $StartTimer = (Get-Date)
    $ReportDate = (Get-Date).ToString("MM-dd-yyyy")
    $HTMLOutput = "iDRACSettings-" + $ReportDate + ".htm"
    $FromAddress = "iDRACReport@ehi.com"
    $Subject = "Dell iDRAC Settings"
    $message = New-Object System.Net.Mail.MailMessage $FromAddress, $EmailAddress
    $message.Subject = "$Subject"
    $message.IsBodyHTML = $true #force html
    Set-Location -Path $PSScriptRoot
    Set-Location -Path ..\Output
    $outloc = Get-Location
    Write-Host $outloc\$HTMLOutput -ForegroundColor Blue
    New-Item $outloc\$HTMLOutput -type file -force | out-null
    $script:html = @()
    [xml]$script:html = $EmailInput | Select-Object iDrac, NICSelection, IPAddress, SubnetMask, Gateway, DNSName, DNSDomain, DNSipv4A, DNSipv4B, ActiveDirectoryEnable, DomainServer1, DomainServer2, ADDomain, `
        ADAdminGroup, NTPEnable, NTP1, NTP2, TimeZone, SMTPAlertDestAddress, SMTPAlertEnable, SMTPAlertCustomMsg, SMTPPort, SMTPServer, SNMPEnable, SNMPCommunity, SNMPTrapformat, `
        SNMPDiscoveryPort, SNMPAlertPort, SNMPAlertDestination, SyslogEnable, SyslogServer1, SyslogServer2, SyslogServer3, SyslogPort | ConvertTo-Html -Fragment
    
    #Each of these foreach statments loops through a specific column and sets the class tag for color coding.
    1..($script:html.table.tr.count - 1) | ForEach-Object {        
        #Write-Verbose -Message 'Enumerate each Table data and check for values'
        $td = $script:html.table.tr[$_]
        #create a new class attribute
        $class = $script:html.CreateAttribute("class")
        #set the class value based on the item value of Tools Status
        Switch ($td.childnodes.item(9).'#text') {
            "Enabled" { $class.value = "good"}
            "Disabled" { $class.value = "notice"}
            Default { $class.value = "other"}
        }
        $td.childnodes.item(9).attributes.append($class) | Out-Null
    }#end foreach for table 

    #Each of these foreach statments loops through a specific column and sets the class tag for color coding.
    1..($script:html.table.tr.count - 1) | ForEach-Object {        
        #Write-Verbose -Message 'Enumerate each Table data and check for values'
        $td = $script:html.table.tr[$_]
        #create a new class attribute
        $class = $script:html.CreateAttribute("class")
        #set the class value based on the item value of Tools Status
        Switch ($td.childnodes.item(14).'#text') {
            "Enabled" { $class.value = "good"}
            "Disabled" { $class.value = "notice"}
            Default { $class.value = "other"}
        }
        $td.childnodes.item(14).attributes.append($class) | Out-Null
    }#end foreach for table 

    #Each of these foreach statments loops through a specific column and sets the class tag for color coding.
    1..($script:html.table.tr.count - 1) | ForEach-Object {        
        #Write-Verbose -Message 'Enumerate each Table data and check for values'
        $td = $script:html.table.tr[$_]
        #create a new class attribute
        $class = $script:html.CreateAttribute("class")
        #set the class value based on the item value of Tools Status
        Switch ($td.childnodes.item(19).'#text') {
            "Enabled" { $class.value = "good"}
            "Disabled" { $class.value = "notice"}
            Default { $class.value = "other"}
        }
        $td.childnodes.item(19).attributes.append($class) | Out-Null
    }#end foreach for table 

    #Each of these foreach statments loops through a specific column and sets the class tag for color coding.
    1..($script:html.table.tr.count - 1) | ForEach-Object {        
        #Write-Verbose -Message 'Enumerate each Table data and check for values'
        $td = $script:html.table.tr[$_]
        #create a new class attribute
        $class = $script:html.CreateAttribute("class")
        #set the class value based on the item value of Tools Status
        Switch ($td.childnodes.item(23).'#text') {
            "Enabled" { $class.value = "good"}
            "Disabled" { $class.value = "notice"}
            Default { $class.value = "other"}
        }
        $td.childnodes.item(23).attributes.append($class) | Out-Null
    }#end foreach for table 

    #Each of these foreach statments loops through a specific column and sets the class tag for color coding.
    1..($script:html.table.tr.count - 1) | ForEach-Object {        
        #Write-Verbose -Message 'Enumerate each Table data and check for values'
        $td = $script:html.table.tr[$_]
        #create a new class attribute
        $class = $script:html.CreateAttribute("class")
        #set the class value based on the item value of Tools Status
        Switch ($td.childnodes.item(29).'#text') {
            "Enabled" { $class.value = "good"}
            "Disabled" { $class.value = "notice"}
            Default { $class.value = "other"}
        }
        $td.childnodes.item(29).attributes.append($class) | Out-Null
    }#end foreach for table 
            
    $mbody = [string]$body += ConvertTo-HTML -Head $style -Body $script:html.InnerXml
    $mbody | Out-File $outloc\$HTMLOutput -Append
    #$message.Body += Get-Content ..\Output\$HTMLOutput 

    #Attach files to email
    $attachment = "$outloc\$HTMLOutput"
    $attach = new-object Net.Mail.Attachment($attachment)
    $message.Attachments.Add($attach)

    #Insert Total Run Time into html email 
    $EndTimer = (Get-Date)
    $message.Body += Get-Content $outloc\$HTMLOutput
    $message.Body += "

    Script Process Time: $(($EndTimer-$StartTimer).totalseconds) seconds"

    #Send
    Write-Verbose "Sending email to $EmailAddress" 
    $smtp = New-Object Net.Mail.SmtpClient($smtpServer)
    $smtp.Send($message)

    #Destroy attachment
    $attach.Dispose()
    
    #Remove files 
    Remove-Item $outloc\$HTMLOutput-recurse
     
    #Output script time to host
    Write-Verbose "Elapsed Script Time: $(($EndTimer-$StartTimer).totalseconds) seconds"

    
}