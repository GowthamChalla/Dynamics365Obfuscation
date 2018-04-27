
<# Summary
- Synopsis : Install-Module PowerShellGet & AzureRM
 
- DESCRIPTION :
  Install Azure PowerShell & AzureRM modules in Windows environment.

- Parameters : None  

- Example : ./InstallationScript
 
Author  : Gowtham Challa  
Email   : v-chgowt@microsoft.com 
#>

try
{
    Write-Host "`nStarted Installation of Required Powershell modules, It will take few minutes,Please wait..." -ForegroundColor Green
    Install-Module PowerShellGet -Force
    Install-Module -Name AzureRM -AllowClobber -Force
}
catch
{
    Write-Host $_.Exception.Message -ForegroundColor Red
}
finally
{
    Write-Host "`nInstallation Completed !!!" -ForegroundColor Green
}
#Reference : https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps?view=azurermps-5.7.0
