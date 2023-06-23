NOTE: THIS SCRIPT HAS ONLY BEEN TESTED WITH PowerShell V2.  It will NOT work with PowerShell V1.

Before you can start using PowerShell to document anything in the XenDesktop 4 farm you 
first need to install the XenDesktop SDK.  From either your XenDesktop 4 DDC or another 
computer, go to https://carlwebster.sharefile.com/d-sb9bec4d2dcc4479d8b5cb3918724e434.
  
For instructions on how to install the SDK from the XenDesktop 4 installation media, 
please see https://carlwebster.sharefile.com/d-s5ca9e46ccdd048f68269707266d5a03d

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

