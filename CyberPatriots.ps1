#note if you're reading this message you're currently wasting your time btw because this message is a bit unnecessarily long and, indeed, I would say a bit unproductive so you may be allowed to
#go do something else instead of reading this message that is still going on for some reason.

$startDirectory = Get-Location
$fireWallStatus = Get-NetFirewallProfile

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
	
	Write-Host "changing password policies" -ForegroundColor blue -BackgroundColor darkyellow
	
	secedit /configure /db C:\Windows\security\new.sdb /cfg .\securityconfig.cfg /areas SECURITYPOLICY
}

function criticalServices(){
	Write-Host "type true if it is true, false otherwise" -ForegroundColor yellow -BackgroundColor black
	$needFtp = Read-Host -Prompt "Does this machine need ftp?"
	
	if($needFtp -eq $true){
		net stop msftpsvc
		sc config msftpsvc start = disabled
	}elseif($needFtp = $false){
		net start msftpsvc
		sc config msftpsvc start = enabled
	}
	
	$needSSH = Read-Host -Prompt "Does this machine need SSH?"
	if($needSSH -eq $true){
		net stop sshd
		sc config sshd start = disabled
	}elseif($needSSH = $false){
		net start sshd
		sc config sshd start = enabled
	}
	
	$needRemoteDesktop = Read-Host -Prompt "Does this machine require remote desktop to be enabled?"
	if($needRemoteDesktop -eq $true){
	reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
	}elseif($needRemoteDesktop = $false){
		reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 1 /f
	}
}

function manageGroups(){
	$addGroup = Read-Host -Prompt "Would you like to add a group? type true or false"
	
	if($addGroup -eq $true){
	$nameOfGroup = Read-Host -Prompt "Enter Group Name"
	New-LocalGroup -Name $nameOfGroup
	
	$stop = 0
	echo "Enter 0 if you want to stop entering users"
	while($stop -eq 0){
		$userName = Read-Host -Prompt "Enter User Name"
		if(userName -eq 0){
			$stop = 123
		}
		$userExists = Get-LocalUser -Name $userName -ErrorAction SilentlyContinue
		
		if ($userExists) {
			Add-LocalGroupMember -Group $nameOfGroup -Member $userName
		}else{
			Write-Host "This user does not exist"
		}
	}
		
	manageGroups
	}
}

function manageUsers(){
	 $usernames = Get-LocalGroupMember -Group "Users" | Where-Object { $_.Name -ne 'Authenticated Users' -and $_.PrincipalSource -eq 'MicrosoftAccount' } | Sort-Object Name | Select-Object -ExpandProperty Name
	 echo $usernames
	 echo "Lol I'll add this function later or smth"
}

function help(){
	Write-Host "help: help list,`nrunAll: runs all commands, `nfireWall: enables firewall, `nSecurityPolicy: configures the local security policies, `nexit: exits the program, `ngetDefaultApps: installs all default windows apps" -ForegroundColor darkred -BackgroundColor darkcyan
}

function runAll(){
	fireWall
	securityPolicy
	criticalServices
	manageUsers
	manageGroups
	
	echo "Finished Running"
	Read-Host -Prompt "press enter to end the script"
}

function Prompter (){
	$theCommand = Read-Host -Prompt "enter Command, help for help"
	
	invoke-Expression $theCommand
	Prompter
}

function distractor(){
	$distraction = Read-Host -Prompt "Please enter the number corresponding to the action you would like to take, `n0:watch youtube, `n11:fun fact 1, `n2:fun fact 3, `n3:fun fact 2"
	
	switch ( $distraction )
{
    0 {start https://www.youtube.com/watch?v=dQw4w9WgXcQ}
    1 {echo "did you know that it is impossible for most people to lick their own elbow?"}
    2 {echo "Did you know that if you spell hello backwards and you spell it backwards against it you get hello"}
    3 {echo "Did you know that you're wasting time?"}
}
}

function greetUser(){
	$response = Read-Host -Prompt "Greetings user, if you would like to run all reccomended actions at once please enter 1, if you would like to individually select actions please enter 2, if you would like to be unproductive, please enter 3"

	if($response -eq 1){
		runall
	}elseif($response -eq 2){
		Prompter
	}elseif($response -eq 3){
		distractor
	}
}

greetUser
