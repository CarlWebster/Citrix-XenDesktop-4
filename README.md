# XenDesktop-4
XenDesktop 4

#Carl Webster, CTP and independent consultant
#webster@carlwebster.com
#@carlwebster on Twitter
#http://www.CarlWebster.com
#This script written for "SR", March 9, 2012
#Thanks to Michael B. Smith, Joe Shock, Jarian Gibson and James Rankin
#for testing and fine-tuning tips


Before you can start using PowerShell to document anything in the XenDesktop 4 farm you 
first need to install the XenDesktop SDK.  From either your XenDesktop 4 DDC or another 
computer, go to http://community.citrix.com/display/xd/Download+SDKS.
  
For instructions on how to install the SDK from the XenDesktop 4 installation media, 
please see http://blogs.citrix.com/2010/08/11/xendesktop-4-powershell-sdk-primer-part-1-getting-started/

Click Start, All Programs, Citrix, Desktop Delivery Controller SDK, Citrix Desktop Delivery 
Controller SDK Shell.  A PowerShell session starts with the Citrix XenDesktop 4 PowerShell 
modules already loaded.

I saved the script as XD4_Inventory.ps1 in the Z:\ folder.  From the PowerShell prompt, 
change to the Z:\ folder, or the folder where you saved the script.  From the PowerShell 
prompt, type in:

.\XD4_Inventory.ps1 |out-file Z:\XD4Farm.txt and press Enter, or

.\XD4_Inventory.ps1 DDCName|out-file Z:\XD4Farm.txt and press Enter, or

.\XD4_Inventory.ps1 DDCIPAddress|out-file Z:\XD4Farm.txt and press Enter.

Open XD4Farm.txt in either WordPad or Microsoft Word.

