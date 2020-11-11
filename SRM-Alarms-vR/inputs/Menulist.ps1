Function MenuList #param([Array]$ArrayOfStrings,[String]$Message) ; Returns Selected Item String Value
{param([Array]$ArrayOfStrings,[String]$Message)
	$LoopCount = 1
	Write-Host "Selection List:" -ForegroundColor Yellow -BackgroundColor Black
	While ($LoopCount -le $ArrayOfStrings.Count)
	{
		Write-Host $LoopCount "." $ArrayOfStrings.Get($LoopCount-1) -ForegroundColor White -BackgroundColor Black
		$LoopCount++
	}
	Do
	{
		Write-Host $Message -BackgroundColor White -ForegroundColor Black
		Write-Host "Please input the number of your choice:" -NoNewline -ForegroundColor Yellow -BackgroundColor Black	
		$UserInput = Read-Host
		Write-Host 
	}
	Until ($UserInput -in 1..$ArrayOfStrings.Count)
	$UserInput = $ArrayOfStrings.Get($UserInput-1)
	Return $UserInput
} #end Function to Create a Menu list and return a selection from an array.