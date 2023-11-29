#Note, change txt extenstion to ps1 before use in powershell

$fireWallStatus = Get-NetFirewallProfile
$startDirectory = Get-Location

function getDefaultApps(){
	$confirm = Read-Host -Prompt "Type true to confirm, this process will take a while"
	
	if($confirm -eq $true){
		Get-AppxPackage -allusers | foreach {Add-AppxPackage -register "$($_.InstallLocation)\appxmanifest.xml" -DisableDevelopmentMode}
	}
}

function fireWall ($variable){
	
	foreach ($part in $fireWallStatus){
		$string = -join($part.Name, " enabled: ", $part.Enabled)
		echo $string
		
		if($part.Enabled -eq $false){
			$string = -join("enabling ", $part.Name, "...")
			echo $string
			Set-NetFirewallProfile -Profile $part.Name -Enabled True		
		}
		
	}
}

function securityPolicy(){
	echo "changing password policies"
	
	#secedit /export /cfg C:\securityconfig.cfg
	
	
	#$editObject = Get-Content  C:\securityconfig.cfg
	
	#$tempString = -join($editObject[3].subString(0,18))
	
	#if($tempString -eq "MinimumPasswordAge"){
	#	$editObject[3] = "MinimumPasswordAge = 0"
	#}
	
	#$tempString = -join($editObject[4].subString(0,18))
	
	#if($tempString -eq "MaximumPasswordAge"){
	#	$editObject[4] = "MaximumPasswordAge = 0"
	#}
	
	#set-Content C:\securityconfig.cfg -Value $editObject
	
	#yeah, I just realized a simplier solution, have a pre determined config file and use that to configure in the same folder
	#still gonna leaves these comments here because putting comments in your code makes you look cool B)
	
	#change the config file yourself if you want to, cause I have no idea what I'm doing
	
	
	#!!!!!!!!
	#Uncomment the following line when using it, personally I don't want this on my system
	
	#secedit /configure /db C:\Windows\security\new.sdb /cfg .\securityconfig.cfg /areas SECURITYPOLICY
	
	#!!!!!!!!
}

function help(){
	echo "help: help list,`nrunAll: runs all commands, `nfireWall: enables firewall, `nSecurityPolicy: configures the local security policies, `nexit: exits the program, `ngetDefaultApps: installs all default windows apps" 
}

function runAll(){
	fireWall
	securityPolicy
	getDefaultApps
}

function Prompter (){
	$theCommand = Read-Host -Prompt "enter Command, help for help"
	
	invoke-Expression $theCommand
	Prompter
}

Prompter