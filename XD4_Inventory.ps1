#Carl Webster, CTP and independent consultant
#webster@carlwebster.com
#@carlwebster on Twitter
#http://www.CarlWebster.com
#This script written for "SR", March 9, 2012
#Thanks to Michael B. Smith, Joe Shock, Jarian Gibson and James Rankin
#for testing and fine-tuning tips

Param(
[string]$DDCAddress = ""
)

Function line
#function created by Michael B. Smith, Exchange MVP
#@essentialexchange on Twitter
#http://TheEssentialExchange.com

{
	Param( [int]$tabs = 0, [string]$name = ’’, [string]$value = ’’, [string]$newline = “`n”, [switch]$nonewline )

	While( $tabs –gt 0 ) { $global:output += “`t”; $tabs--; }

	If( $nonewline )
	{
		$global:output += $name + $value
	}
	Else
	{
		$global:output += $name + $value + $newline
	}
}

#script begins
#get farm information
$global:output = ""

If($DDCAddress)
{
	$farm = Get-XdFarm -adminaddress $DDCAddress -EA 0
}
Else
{
	$farm = Get-XdFarm -EA 0
}

If( $? )
{
	line 0 "XenDesktop Farm Name: " $farm.Name
	line 1 "XenDesktop Edition: " -nonewline
	switch ($farm.edition)
	{
		"PLT"   {line 0 "Platinum"  }
		"STD"   {line 0 "VDI"       }
		"ADV"   {line 0 "Advanced"  }
		"ENT"   {line 0 "Enterprise"}
		default {line 0 "Farm Edition could not be determined: $($farm.edition)"}
	}

	line 1 "Base OU: " $farm.BaseOU
	line 1 "License server"
	line 2 "Name: " $farm.LicenseServerName
	line 2 "Port number: " $farm.LicenseServerPort
	line 1 "Session reliability"
	line 2 "Allow users to view sessions during broken connections: " $farm.EnableSessionReliability

	If($farm.EnableSessionReliability)
	{
		line 3 "Port number: " $farm.SessionReliabilityPort
		line 3 "Seconds to keep sessions active: " $farm.SessionReliabilityDurationSeconds
	}
} 
Else 
{
	line 0 "XenDesktop Farm information could not be retrieved"
}
write-output $global:output
$farm = $null
$global:output = $null

$global:output = ""

#get controller information
If($DDCAddress)
{
	$XDControllers = Get-XdController -adminaddress $DDCAddress -EA 0
}
Else
{
	$XDControllers = Get-XdController -EA 0
}

If( $? )
{
	line 0 "Desktop Delivery Controllers:"
	ForEach($XDController in $XDControllers)
	{
		line 1 "Controller: " $XDController.Name
		line 1 "Version: " $XDController.Version
		line 1 "Zone Election Preference: " $XDController.ZoneElectionPreference
		line 1 "License Server"
		If($XDController.UseFarmLicenseServerSettings)
		{
			line 2 "Using Farm Setting"
		}
		Else
		{
			Line 2 "License server"
			line 3 "Name: " $XDController.LicenseServerName
			line 3 "Port number: " $XDController.LicenseServerPort
		}
		line 1 ""
	}
} 
Else 
{
	line 0 "Desktop Delivery Controller information could not be retrieved"
}
write-output $global:output
$XDControllers = $null
$global:output = $null

#get desktop group information
$global:output = ""

If($DDCAddress)
{
	$XDGroups = Get-XdDesktopGroup -adminaddress $DDCAddress -EA 0
}
Else
{
	$XDGroups = Get-XdDesktopGroup -EA 0
}

If( $? )
{
	line 0 "Desktop Groups:"
	ForEach($XDGroup in $XDGroups)
	{
		line 1 "Basic"
		line 2 "Desktop Group Name"
		line 3 "Display name: " $XDGroup.Name
		line 3 "Description: " $XDGroup.Description
		line 3 "Desktop Group name: " $XDGroup.InternalName
		line 3 "Disable desktop group: " -nonewline
		If($XDGroup.Enabled)
		{
			line 0 "group is enabled"
		}
		Else
		{
			line 0 "group is disabled"
		}

		line 2 "Assignment Type"
		line 3 "Assignment Behavior: " $XDGroup.AssignmentBehavior

		If($XDGroup.IsHosted)
		{
			line 2 "Hosting infrastructure: " $XDGroup.HostingSettings.HostingServer
		}

		line 2 "Users"
		line 3 "Configured users:"
		ForEach($User in $XDGroup.Users)
		{
			line 4 $User
			#line 4 "SID: " $User.Sid
			line 4 "Group or User: " -nonewline
			If($User.IsSecurityGroup)
			{
				line 0 "Group"
			}
			Else
			{
				line 0 "User"
			}
		}
		line 2 "Virtual Desktops"
		line 3 "Virtual desktops:"
		ForEach($Desktop in $XDGroup.Desktops)
		{
			line 4 "Folder: " $XDGroup.Folder
			line 4 "Virtual Machine: " $Desktop
			$objSID = New-Object System.Security.Principal.SecurityIdentifier ($Desktop.MachineSid.Value)
			$objComputer = $objSID.Translate([System.Security.Principal.NTAccount])
			line 4 "AD Computer Account: " $objComputer.Value
			line 4 "Desktop State: " $Desktop.State
			line 4 "Assigned User: " -nonewline
			If($Desktop.AssignUserName)
			{
				line 0 $Desktop.AssignUserName
			}
			ElseIf($Desktop.AssignedUserSid)
			{
				$objSID = New-Object System.Security.Principal.SecurityIdentifier ($Desktop.AssignedUserSid.Value)
				$objUser = $objSID.Translate([System.Security.Principal.NTAccount])
				line 0 $objUser.Value
			}
			Else
			{
				line 0 ""
			}
			line 4 "Maintenance Mode: " $Desktop.MaintenanceMode
			line 4 "Machine State: " $Desktop.PowerState
			line 4 "Controller: " $Desktop.Controller
			line 4 "Agent Version: " $Desktop.AgentVersion
			line 1 ""
		}
		line 1 "Advanced"
		line 2 "Access Control"

		$test = $XDGroup.AccessGatewayControl.ToString()
		$test1 = $test.replace(", ","`n`t`t")

		line 3 $test1
		line 2 "Access Gateway Conditions: "
		ForEach($Condition in $XDGroup.AccessGatewayConditions)
		{
			line 3 $Condition
		}
		line 2 "Client Options"
		line 3 "Appearance"
		line 4 "Colors: " -nonewline
		switch ($XDGroup.DefaultColorDepth)
		{
			"FourBit"       {line 0 "16 colors"          }
			"EightBit"      {line 0 "256 colors"         }
			"SixteenBit"    {line 0 "High color (16-bit)"}
			"TwentyFourBit" {line 0 "True color (24-bit)"}
			default         {line 0 "Color depth could not be determined: $($XDGroup.DefaultColorDepth)"}

		}
		line 3 "Connection"
		line 4 "Encryption: " -nonewline
		switch ($XDGroup.DefaultEncryptionLevel)
		{
			"Basic"               {line 0 "Basic"                    }
			"LogOnRC5Using128Bit" {line 0 "128-Bit Login Only (RC-5)"}
			"RC5Using40Bit"       {line 0 "40-Bit (RC-5)"            }
			"RC5Using56Bit"       {line 0 "56-Bit (RC-5)"            }
			"RC5Using128Bit"      {line 0 "128-Bit (RC-5)"           }
			default               {line 0 "Encryption level could not be determined: $($XDGroup.DefaultEncryptionLevel)"}

		}
		line 3 "Connection Protocols: "
		ForEach($Protocol in $XDGroup.Protocols)
		{
			line 4 "Name: " $Protocol.Protocol
			line 4 "Enabled: " $Protocol.Enabled
		}

		#only show the next section if the Desktop Group is Pooled
		If($XDGroup.AssignmentBehavior -eq "Pooled")
		{
			line 2 "Idle Pool Settings"
			line 3 "Business Hours"
			line 4 "Business days "
			ForEach($Day in $XDGroup.HostingSettings.BusinessDays)
			{
				line 5 $Day
			}
			line 4 "Time zone "  $XDGroup.HostingSettings.IdleTimesTimeZone
			IF($XDGroup.HostingSettings.PeakHoursStart)
			{
				line 4 "Day start "  $XDGroup.HostingSettings.PeakHoursStart.ToString()
			}
			If($XDGroup.HostingSettings.PeakHoursEnd)
			{
				line 4 "Peak end "  $XDGroup.HostingSettings.PeakHoursEnd.ToString()
			}
			If($XDGroup.HostingSettings.BusinessHoursEnd)
			{
				line 4 "Day end " $XDGroup.HostingSettings.BusinessHoursEnd.ToString()
			}
			line 3 "Idle Desktop Count"
			line 2 "Business hours " $XDGroup.HostingSettings.BusinessHoursIdleCount
			line 2 "Peak time " $XDGroup.HostingSettings.PeakHoursIdleCount
			line 2 "Out of hours " $XDGroup.HostingSettings.OutOfHoursIdleCount
		}
		
		# I can't find these settings in the console
		line 1 "Other settings"
		line 2 "Allow User Desktop Restart: " $XDGroup.AllowUserDesktopRestart
		line 2 "Tainted Machine Action: " $XDGroup.HostingSettings.TaintedMachineAction
		line 3 "Actions: "
		ForEach($Action in  $XDGroup.HostingSettings.Actions)
		{
			line 4 "Action point: " $Action.ActionPoint
			line 4 "Action: " $Action.Action
			line 4 "Delay: " $Action.Delay
			line 4 ""
		}
		line 1 ""
	}
} 
Else 
{
	line 0 "Desktop Group information could not be retrieved"
}
write-output $global:output
$XDGroups = $null
$test = $null
$test1 = $null
$global:output = $null
