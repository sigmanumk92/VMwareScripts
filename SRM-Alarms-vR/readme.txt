SRM Alarms Module-


Before Running
1. Download the entire module to a scripts directory
2. You may have right click on each script in the folder to unblock any security settings that might been flagged from download
3. In the Inputs folder there is a text file, Update it with the Instances of SRM.  
4. The module is broken up into 4 folders, Inputs/Outputs/Private/Public
	Inputs-Inputs for the script
	Outputs-Log files
	Private-The functions that the public script calls
	Public-The Main Script that is run from powershell.

Running the script
1. Open powershell.exe
2. Navigate to the root folder for the module.
3. Run the Command - Import-Module SRM-Alarms.psm1
4. Run the Script - Invoke-SRMAlarms -vCenter <EnterVC FQDNName> -SRMinst "C:<ScriptPath>\inputs\srminstances.text"

