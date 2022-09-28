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

# SIG # Begin signature block
# MIIjtwYJKoZIhvcNAQcCoIIjqDCCI6QCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUtSmhgHqxy520Z3mQTUVz5mKQ
# FYqggh7lMIIETzCCA7igAwIBAgIEBydYPTANBgkqhkiG9w0BAQUFADB1MQswCQYD
# VQQGEwJVUzEYMBYGA1UEChMPR1RFIENvcnBvcmF0aW9uMScwJQYDVQQLEx5HVEUg
# Q3liZXJUcnVzdCBTb2x1dGlvbnMsIEluYy4xIzAhBgNVBAMTGkdURSBDeWJlclRy
# dXN0IEdsb2JhbCBSb290MB4XDTEwMDExMzE5MjAzMloXDTE1MDkzMDE4MTk0N1ow
# bDELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQ
# d3d3LmRpZ2ljZXJ0LmNvbTErMCkGA1UEAxMiRGlnaUNlcnQgSGlnaCBBc3N1cmFu
# Y2UgRVYgUm9vdCBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMbM
# 5XPm+9S75S0tMqbf5YE/yc0lSbZxKsPVlDRnogocsF9ppkCxxLeyj9CYpKlBWTrT
# 3JTWPNt0OKRKzE0lgvdKpVMSOO7zSW1xkX5jtqumX8OkhPhPYlG++MXs2ziS4wbl
# CJEMxChBVfvLWokVfnHoNb9Ncgk9vjo4UFt3MRuNs8ckRZqnrG0AFFoEt7oT61EK
# mEFBIk5lYYeBQVCmeVyJ3hlKV9Uu5l0cUyx+mM0aBhakaHPQNAQTXKFx01p8Vdte
# ZOE3hzBWBOURtCmAEvF5OYiiAhF8J2a3iLd48soKqDirCmTCv2ZdlYTBoSUeh10a
# UAsgEsxBu24LUTi4S8sCAwEAAaOCAW8wggFrMBIGA1UdEwEB/wQIMAYBAf8CAQEw
# UwYDVR0gBEwwSjBIBgkrBgEEAbE+AQAwOzA5BggrBgEFBQcCARYtaHR0cDovL2N5
# YmVydHJ1c3Qub21uaXJvb3QuY29tL3JlcG9zaXRvcnkuY2ZtMA4GA1UdDwEB/wQE
# AwIBBjCBiQYDVR0jBIGBMH+heaR3MHUxCzAJBgNVBAYTAlVTMRgwFgYDVQQKEw9H
# VEUgQ29ycG9yYXRpb24xJzAlBgNVBAsTHkdURSBDeWJlclRydXN0IFNvbHV0aW9u
# cywgSW5jLjEjMCEGA1UEAxMaR1RFIEN5YmVyVHJ1c3QgR2xvYmFsIFJvb3SCAgGl
# MEUGA1UdHwQ+MDwwOqA4oDaGNGh0dHA6Ly93d3cucHVibGljLXRydXN0LmNvbS9j
# Z2ktYmluL0NSTC8yMDE4L2NkcC5jcmwwHQYDVR0OBBYEFLE+w2kD+L9HAdSYJhoI
# Au9jZCvDMA0GCSqGSIb3DQEBBQUAA4GBAC52hdk3lm2vifMGeIIxxEYHH2XJjrPJ
# VHjm0ULfdS4eVer3+psEwHV70Xk8Bex5xFLdpgPXp1CZPwVZ2sZV9IacDWejSQSV
# Mh3Hh+yFr2Ru1cVfCadAfRa6SQ2i/fbfVTBs13jGuc9YKWQWTKMggUexRJKEFhtv
# Srwhxgo97TPKMIIGczCCBVugAwIBAgIQBGjh02n+Kl8qpI6sM2FaCzANBgkqhkiG
# 9w0BAQUFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkw
# FwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBBc3N1
# cmVkIElEIENBLTEwHhcNMTEwNTIyMDAwMDAwWhcNMTIwNjA1MDAwMDAwWjBHMQsw
# CQYDVQQGEwJVUzERMA8GA1UEChMIRGlnaUNlcnQxJTAjBgNVBAMTHERpZ2lDZXJ0
# IFRpbWVzdGFtcCBSZXNwb25kZXIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
# AoIBAQCAzBAMZMMWfTTQx0rP2GUEAdEqzg8dkAUXCZS46pcOvYQzkij07MN8E6F+
# fDPBFLKHLg5aUJNv9QoJR0cQj2DIOxMfycX8TUT62XXb1SLMtpoBUhSsNTjl/Szm
# j7lwfzI1f+I80aBvzLqn4jU3GsEeftonJiI+YBHQGBGEwunsnV2jhGPNlWXjUfjO
# dsLW/Onw9EEb26dMhlSJ3x0DU3EtGc8orcsL5xgaHHFEiXRbO7m8Jw4aduL7Qh1S
# Dwiur9YI0ITR5asUzLF7ZJ6I9aEpaeLRbn4A/52oFvfnz8QoIzvjLkGfcPFgpgz1
# Ny4QAzHZt2sH7ND0eyxG4ica8dm3AgMBAAGjggM+MIIDOjAOBgNVHQ8BAf8EBAMC
# BsAwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDCCAcQGA1Ud
# IASCAbswggG3MIIBswYJYIZIAYb9bAcBMIIBpDA6BggrBgEFBQcCARYuaHR0cDov
# L3d3dy5kaWdpY2VydC5jb20vc3NsLWNwcy1yZXBvc2l0b3J5Lmh0bTCCAWQGCCsG
# AQUFBwICMIIBVh6CAVIAQQBuAHkAIAB1AHMAZQAgAG8AZgAgAHQAaABpAHMAIABD
# AGUAcgB0AGkAZgBpAGMAYQB0AGUAIABjAG8AbgBzAHQAaQB0AHUAdABlAHMAIABh
# AGMAYwBlAHAAdABhAG4AYwBlACAAbwBmACAAdABoAGUAIABEAGkAZwBpAEMAZQBy
# AHQAIABDAFAALwBDAFAAUwAgAGEAbgBkACAAdABoAGUAIABSAGUAbAB5AGkAbgBn
# ACAAUABhAHIAdAB5ACAAQQBnAHIAZQBlAG0AZQBuAHQAIAB3AGgAaQBjAGgAIABs
# AGkAbQBpAHQAIABsAGkAYQBiAGkAbABpAHQAeQAgAGEAbgBkACAAYQByAGUAIABp
# AG4AYwBvAHIAcABvAHIAYQB0AGUAZAAgAGgAZQByAGUAaQBuACAAYgB5ACAAcgBl
# AGYAZQByAGUAbgBjAGUALjAfBgNVHSMEGDAWgBQVABIrE5iymQftHt+ivlcNK2cC
# zTAdBgNVHQ4EFgQU7B0sNPsiT4qILfxlfkwVc4mOq6cwewYIKwYBBQUHAQEEbzBt
# MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wRQYIKwYBBQUH
# MAKGOWh0dHA6Ly93d3cuZGlnaWNlcnQuY29tL0NBQ2VydHMvRGlnaUNlcnRBc3N1
# cmVkSURDQS0xLmNydDB9BgNVHR8EdjB0MDigNqA0hjJodHRwOi8vY3JsMy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURDQS0xLmNybDA4oDagNIYyaHR0cDov
# L2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEQ0EtMS5jcmwwDQYJ
# KoZIhvcNAQEFBQADggEBAMhBy0QW3nxihaJMAzG9tTGMCh7KEgqNExTghkynqcom
# jhHtCCASpPTzVlxtRGmbByBAwM+UMSLkd1Y4GFOJ+iAtTOqQliqXSKsZAHSpnIeJ
# AADEHtk+FvD/CszaAX/uFyPN3ePu3lXeJeq2XMU8rC3Hrx0mR81rXv1qDEOCIcHn
# 0ztaDShKjYlwTR2VMPk/hwb4PljMz1qzRRydpCTu6Wx6nZwHfahj8m+exxZ+z+B0
# aTd676XGRfzXDr+qRtBfagmjHxdAIN3/YAahQZh60TO/gy8ZVhOresm7lDEH7Cwk
# ic7M5K7uMExk7GifLFPN/BwXKQBi0qJsGC47VcgM1/4wggaOMIIFdqADAgECAhAN
# HRAEcxUH1NtaEcGrzV1GMA0GCSqGSIb3DQEBBQUAMHMxCzAJBgNVBAYTAlVTMRUw
# EwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20x
# MjAwBgNVBAMTKURpZ2lDZXJ0IEhpZ2ggQXNzdXJhbmNlIENvZGUgU2lnbmluZyBD
# QS0xMB4XDTExMDkzMDAwMDAwMFoXDTE0MTAwODEyMDAwMFowXDELMAkGA1UEBhMC
# VVMxCzAJBgNVBAgTAlROMRIwEAYDVQQHEwlUdWxsYWhvbWExFTATBgNVBAoTDENh
# cmwgV2Vic3RlcjEVMBMGA1UEAxMMQ2FybCBXZWJzdGVyMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAr/bj8kHv8EK+JUvF6wqaokOzFDLjd17cGkjbLayB
# dysQn2tmWX/uRp4TZeK39uasT/529mW6IoojOcmkV7xge9dMLUHcIClOg5agd3fz
# 4BckVUcCEZX25s/sh3G42AAcEyjU4PGwyI/icIXEHNAFrNUQEj3F/w2jE+eLTanl
# iXfPTRPXxst9xF5LujW0HHFiqfsG4AUCaX2h+zgL5RTwhKVhT2RnpQUDhWjeY8kW
# FrguJLQJO+SVrS7N2my5VjcLiKyjwq3noisf77X4yC+5Ll10nE9fxUel0btmTeBk
# RPpNi3nKcXULy6+fKECnzv6GAXAFlM+0OIlzxFf43Rt1KwIDAQABo4IDMzCCAy8w
# HwYDVR0jBBgwFoAUl0gD6xUIa7myWCPMlC7xxmXSZI4wHQYDVR0OBBYEFEcgbHxI
# DKYG+beFUFr7IgtC5SUsMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEF
# BQcDAzBpBgNVHR8EYjBgMC6gLKAqhihodHRwOi8vY3JsMy5kaWdpY2VydC5jb20v
# aGEtY3MtMjAxMWEuY3JsMC6gLKAqhihodHRwOi8vY3JsNC5kaWdpY2VydC5jb20v
# aGEtY3MtMjAxMWEuY3JsMIIBxAYDVR0gBIIBuzCCAbcwggGzBglghkgBhv1sAwEw
# ggGkMDoGCCsGAQUFBwIBFi5odHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9zc2wtY3Bz
# LXJlcG9zaXRvcnkuaHRtMIIBZAYIKwYBBQUHAgIwggFWHoIBUgBBAG4AeQAgAHUA
# cwBlACAAbwBmACAAdABoAGkAcwAgAEMAZQByAHQAaQBmAGkAYwBhAHQAZQAgAGMA
# bwBuAHMAdABpAHQAdQB0AGUAcwAgAGEAYwBjAGUAcAB0AGEAbgBjAGUAIABvAGYA
# IAB0AGgAZQAgAEQAaQBnAGkAQwBlAHIAdAAgAEMAUAAvAEMAUABTACAAYQBuAGQA
# IAB0AGgAZQAgAFIAZQBsAHkAaQBuAGcAIABQAGEAcgB0AHkAIABBAGcAcgBlAGUA
# bQBlAG4AdAAgAHcAaABpAGMAaAAgAGwAaQBtAGkAdAAgAGwAaQBhAGIAaQBsAGkA
# dAB5ACAAYQBuAGQAIABhAHIAZQAgAGkAbgBjAG8AcgBwAG8AcgBhAHQAZQBkACAA
# aABlAHIAZQBpAG4AIABiAHkAIAByAGUAZgBlAHIAZQBuAGMAZQAuMIGGBggrBgEF
# BQcBAQR6MHgwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBQ
# BggrBgEFBQcwAoZEaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0
# SGlnaEFzc3VyYW5jZUNvZGVTaWduaW5nQ0EtMS5jcnQwDAYDVR0TAQH/BAIwADAN
# BgkqhkiG9w0BAQUFAAOCAQEAi7rw3R/Jw4vHxkkaVKpSm0x34GA3rqyEUunVmpMW
# eEO1IhDViwZx9MgcIgBZs3UoZIzxEiX7s64NJAyJuHnva6V1q4H7Jnpmt4M9oEdS
# zye54GndLh6oWIeeCl5XjzCHSqAD5s+kH2gIYkgOOJ531SH+xpP9TFq5q/EC1UjM
# G7c646lVm/WbWUgky3h3j+JgEbRNVWlFlg2IbGzFPTge93tH3vo1RHV93lHsOh9Z
# Z6+VKyaunoM4KUeqjtUeB9JgYsnu50xEv5wvbXd9G7ig9Rvvj8MOTi2zv+HN+Mzn
# Q6pMubiiIsN/vWo+lH0KC+MalrDFlMtcX4dxz9tTwvRxxjCCBr8wggWnoAMCAQIC
# EAgcV+5dcOuboLFSDHKcGwkwDQYJKoZIhvcNAQEFBQAwbDELMAkGA1UEBhMCVVMx
# FTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNv
# bTErMCkGA1UEAxMiRGlnaUNlcnQgSGlnaCBBc3N1cmFuY2UgRVYgUm9vdCBDQTAe
# Fw0xMTAyMTAxMjAwMDBaFw0yNjAyMTAxMjAwMDBaMHMxCzAJBgNVBAYTAlVTMRUw
# EwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20x
# MjAwBgNVBAMTKURpZ2lDZXJ0IEhpZ2ggQXNzdXJhbmNlIENvZGUgU2lnbmluZyBD
# QS0xMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxfkj5pQnxIAUpIAy
# X0CjjW9wwOU2cXE6daSqGpKUiV6sI3HLTmd9QT+q40u3e76dwag4j2kvOiTpd1kS
# x2YEQ8INJoKJQBnyLOrnTOd8BRq4/4gJTyY37zqk+iJsiMlKG2HyrhBeb7zReZtZ
# GGDl7im1AyqkzvGDGU9pBXMoCfsiEJMioJAZGkwx8tMr2IRDrzxj/5jbINIJK1TB
# 6v1qg+cQoxJx9dbX4RJ61eBWWs7qAVtoZVvBP1hSM6k1YU4iy4HKNqMSywbWzxtN
# GH65krkSz0Am2Jo2hbMVqkeThGsHu7zVs94lABGJAGjBKTzqPi3uUKvXHDAGeDyl
# ECNnkQIDAQABo4IDVDCCA1AwDgYDVR0PAQH/BAQDAgEGMBMGA1UdJQQMMAoGCCsG
# AQUFBwMDMIIBwwYDVR0gBIIBujCCAbYwggGyBghghkgBhv1sAzCCAaQwOgYIKwYB
# BQUHAgEWLmh0dHA6Ly93d3cuZGlnaWNlcnQuY29tL3NzbC1jcHMtcmVwb3NpdG9y
# eS5odG0wggFkBggrBgEFBQcCAjCCAVYeggFSAEEAbgB5ACAAdQBzAGUAIABvAGYA
# IAB0AGgAaQBzACAAQwBlAHIAdABpAGYAaQBjAGEAdABlACAAYwBvAG4AcwB0AGkA
# dAB1AHQAZQBzACAAYQBjAGMAZQBwAHQAYQBuAGMAZQAgAG8AZgAgAHQAaABlACAA
# RABpAGcAaQBDAGUAcgB0ACAARQBWACAAQwBQAFMAIABhAG4AZAAgAHQAaABlACAA
# UgBlAGwAeQBpAG4AZwAgAFAAYQByAHQAeQAgAEEAZwByAGUAZQBtAGUAbgB0ACAA
# dwBoAGkAYwBoACAAbABpAG0AaQB0ACAAbABpAGEAYgBpAGwAaQB0AHkAIABhAG4A
# ZAAgAGEAcgBlACAAaQBuAGMAbwByAHAAbwByAGEAdABlAGQAIABoAGUAcgBlAGkA
# bgAgAGIAeQAgAHIAZQBmAGUAcgBlAG4AYwBlAC4wDwYDVR0TAQH/BAUwAwEB/zB/
# BggrBgEFBQcBAQRzMHEwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0
# LmNvbTBJBggrBgEFBQcwAoY9aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0Rp
# Z2lDZXJ0SGlnaEFzc3VyYW5jZUVWUm9vdENBLmNydDCBjwYDVR0fBIGHMIGEMECg
# PqA8hjpodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRIaWdoQXNzdXJh
# bmNlRVZSb290Q0EuY3JsMECgPqA8hjpodHRwOi8vY3JsNC5kaWdpY2VydC5jb20v
# RGlnaUNlcnRIaWdoQXNzdXJhbmNlRVZSb290Q0EuY3JsMB0GA1UdDgQWBBSXSAPr
# FQhrubJYI8yULvHGZdJkjjAfBgNVHSMEGDAWgBSxPsNpA/i/RwHUmCYaCALvY2Qr
# wzANBgkqhkiG9w0BAQUFAAOCAQEAggXpha+nTL+vzj2y6mCxaN5nwtLLJuDDL5u1
# aw5TkIX2m+A1Av/6aYOqtHQyFDwuEEwomwqtCAn584QRk4/LYEBW6XcvabKDmVWr
# RySWy39LsBC0l7/EpZkG/o7sFFAeXleXy0e5NNn8OqL/UCnCCmIE7t6WOm+gwoUP
# b/wI5DJ704SuaWAJRiac6PD//4bZyAk6ZsOnNo8YT+ixlpIuTr4LpzOQrrxuT/F+
# jbRGDmT5WQYiIWQAS+J6CAPnvImQnkJPAcC2Fn916kaypVQvjJPNETY0aihXzJQ/
# 6XzIGAMDBH5D2vmXoVlH2hKq4G04AF01K8UihssGyrx6TT0mRjCCBsIwggWqoAMC
# AQICEAoE3yF0XU0rjOozcgUAUOkwDQYJKoZIhvcNAQEFBQAwZTELMAkGA1UEBhMC
# VVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0
# LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENBMB4XDTA2
# MTExMDAwMDAwMFoXDTIxMTExMDAwMDAwMFowYjELMAkGA1UEBhMCVVMxFTATBgNV
# BAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8G
# A1UEAxMYRGlnaUNlcnQgQXNzdXJlZCBJRCBDQS0xMIIBIjANBgkqhkiG9w0BAQEF
# AAOCAQ8AMIIBCgKCAQEA6IItmfnKwkKVpYBzQHDSnlZUXKnE0kEGj8kz/E1FkVyB
# n+0snPgWWd+etSQVwpi5tHdJ3InECtqvy15r7a2wcTHrzzpADEZNk+yLejYIA6sM
# NP4YSYL+x8cxSIB8HqIPkg5QycaH6zY/2DDD/6b3+6LNb3Mj/qxWBZDwMiEWicZw
# iPkFl32jx0PdAug7Pe2xQaPtP77blUjE7h6z8rwMK5nQxl0SQoHhg26Ccz8mSxSQ
# rllmCsSNvtLOBq6thG9IhJtPQLnxTPKvmPv2zkBdXPao8S+v7Iki8msYZbHBc63X
# 8djPHgp0XEK4aH631XcKJ1Z8D2KkPzIUYJX9BwSiCQIDAQABo4IDbzCCA2swDgYD
# VR0PAQH/BAQDAgGGMDsGA1UdJQQ0MDIGCCsGAQUFBwMBBggrBgEFBQcDAgYIKwYB
# BQUHAwMGCCsGAQUFBwMEBggrBgEFBQcDCDCCAcYGA1UdIASCAb0wggG5MIIBtQYL
# YIZIAYb9bAEDAAQwggGkMDoGCCsGAQUFBwIBFi5odHRwOi8vd3d3LmRpZ2ljZXJ0
# LmNvbS9zc2wtY3BzLXJlcG9zaXRvcnkuaHRtMIIBZAYIKwYBBQUHAgIwggFWHoIB
# UgBBAG4AeQAgAHUAcwBlACAAbwBmACAAdABoAGkAcwAgAEMAZQByAHQAaQBmAGkA
# YwBhAHQAZQAgAGMAbwBuAHMAdABpAHQAdQB0AGUAcwAgAGEAYwBjAGUAcAB0AGEA
# bgBjAGUAIABvAGYAIAB0AGgAZQAgAEQAaQBnAGkAQwBlAHIAdAAgAEMAUAAvAEMA
# UABTACAAYQBuAGQAIAB0AGgAZQAgAFIAZQBsAHkAaQBuAGcAIABQAGEAcgB0AHkA
# IABBAGcAcgBlAGUAbQBlAG4AdAAgAHcAaABpAGMAaAAgAGwAaQBtAGkAdAAgAGwA
# aQBhAGIAaQBsAGkAdAB5ACAAYQBuAGQAIABhAHIAZQAgAGkAbgBjAG8AcgBwAG8A
# cgBhAHQAZQBkACAAaABlAHIAZQBpAG4AIABiAHkAIAByAGUAZgBlAHIAZQBuAGMA
# ZQAuMA8GA1UdEwEB/wQFMAMBAf8wfQYIKwYBBQUHAQEEcTBvMCQGCCsGAQUFBzAB
# hhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wRwYIKwYBBQUHMAKGO2h0dHA6Ly93
# d3cuZGlnaWNlcnQuY29tL0NBQ2VydHMvRGlnaUNlcnRBc3N1cmVkSURSb290Q0Eu
# Y3J0MIGBBgNVHR8EejB4MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20v
# RGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMDqgOKA2hjRodHRwOi8vY3JsNC5k
# aWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMB0GA1UdDgQW
# BBQVABIrE5iymQftHt+ivlcNK2cCzTAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYun
# pyGd823IDzANBgkqhkiG9w0BAQUFAAOCAQEAhGFOQR64dgQqtbbvj/JVhbldVv4K
# mObkvWWKfUAp0/yxXUX9OrgqWzNLJFzNubTkc61hXXatdDOKZtUjr0wfcm5F2XVA
# u6I7z41JL8BBsOIpo1E4Q1CZFKwzBjViiX13qVIH5WwgV7aBum+8s8KU7XYCgNl8
# zoWoHOzHQ0pLsVfPcs7f9SU8yyJP/Z9S0TfLCLs4PuDVPm95Ca1bfDGzdzXD5GP5
# aAqYB+dGOHeE0j6XvAqgqKwlT0RukeHSWq9r7zAcjaNEQrMQiyP61+Y1dDesz+ur
# WB/JiCP/NtQH6jRqR+qdlWyeKU9T7eMrlSBOKs+WYHr4LIDwlVLOKZaBYjGCBDww
# ggQ4AgEBMIGHMHMxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMjAwBgNVBAMTKURpZ2lDZXJ0IEhp
# Z2ggQXNzdXJhbmNlIENvZGUgU2lnbmluZyBDQS0xAhANHRAEcxUH1NtaEcGrzV1G
# MAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3
# DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEV
# MCMGCSqGSIb3DQEJBDEWBBTzhsjqdwXAUHOPI3W6aZsBD8AAlzANBgkqhkiG9w0B
# AQEFAASCAQBhd91rnAOhPr0HmvzJDqTkSu9PUZFrJMhEdIttekK055VFLk87KZ0O
# SwvWYqhgyzNrD/Z4FqC+XQtT7WsZ5FLqOmKQnc7OQSZ/S7RisHVDEa22w2I254CW
# AZlAqvn6+/hp9+DTJMRE+5hv7hv8S/53C05kaMd5r2dKgIVMlRYqzw5vqvBogcXi
# h8naNGJ6fxI2q6t3VbACYQCIAdxemYQRlX1+2JtMO+6aAfp9g3i10O7xyXC+hE7Z
# a9xO+TdWO6oGItbFiKY4LiXJMFDR/kp5iVqv0lqHzmEMpO5vzyqgHPt9zctfeb7Y
# Bk1gaPHgc6jS/9jpWS5Y8Jye/XsXznnToYICDzCCAgsGCSqGSIb3DQEJBjGCAfww
# ggH4AgEBMHYwYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZ
# MBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgQXNz
# dXJlZCBJRCBDQS0xAhAEaOHTaf4qXyqkjqwzYVoLMAkGBSsOAwIaBQCgXTAYBgkq
# hkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xMjA0MDUwMTAz
# NDhaMCMGCSqGSIb3DQEJBDEWBBSYwAVZnQlzy1brPKFNjtji+lVjyTANBgkqhkiG
# 9w0BAQEFAASCAQAUJjdsjmxMattr6knd2qwlEkNM0BUPTv2zIPgT7q1R9n7A5YRV
# fs1K/DYXWiBYyHda1y2svd1+PvdXjSlLkJB0dYMfnZzK4dEsUzvSG+644nf0swQY
# NWWu0M4N1LXs96XepPs8166OytZlHI+CPiMyL6TJ51ti464NLJQPf13GUf1AErpK
# hLl7d6+/KDKF33UjdfiXFSmHxv6tyAJyP/A4Sm56cLeC8OkI1bdezUiWJVVXqQ7D
# Regd5HZu0Own98EgGJqiK7bGNp7+dR0+j0FArPW88sRIGFGs1j9A8MWtqiXKk+wG
# wpjkaejwAs6O+Z8astt5UJtCIMFBVrCSdPE9
# SIG # End signature block
