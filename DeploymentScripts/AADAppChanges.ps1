<# Summary
- Synopsis : Azure Active Directory Application Changes
 
- DESCRIPTION :
  Applications registered (Web APP & Native App) in Azure Active Directory need changes.

  List of Changes & inline Functions:

  1. Manifest Setting - Oauth2AllowImplicitFlow need to be updated with True (Default value is false)
     Function - Set-Oauth2AllowImplicitFlow, will Update Manifest Setting - Oauth2AllowImplicitFlow to True in both AAD Web App & Native App.
  
  2. ReplyUrl need to be updated.
     Function - Set-ReplyUrl, will update ReplyUrl in both AAD Web App & Native App.

  3. Required APIs need to be Added
     Function - Set-API, will add APIs in both AAD Web App & Native App.
     
     List of APIs to be added in AAD Web Application are:
     - Microsoft Azure Data Catalog with Delegated Pemission (Have full access to the Microsoft Azure Data Catalog)
     - Windows Azure Active Directory with Delegated Permission (Sign in and read user profile)
     - Azure Key Vault with Delegated Permission (Have full access to the Azure Key Vault service)

     List of APIs to be added in AAD Native Application are:
     - Dynamics CRM Online (Microsoft.CRM) with Delegated Permission (Access Dynamics 365 as organization users)
     - Windows Azure Active Directory with Delegated Permission (Sign in and read user profile)


- Parameters :
  1.  UserAADAppName
  2.  AADWebAppID
  3.  AADNativeAppID
  4.  ReplyUrl

- Example : ./AADAppChanges -UserAADAppName "AADApplicationName" -AADWebAppID "AADWebApplicationID" -AADNativeAppID "AADNativeApplicationID" -ReplyUrl "CRM Base URL"
 
Author  : Gowtham Challa  
Email   : v-chgowt@microsoft.com 
#>

[cmdletbinding()]
param (  
     [Parameter(Position=0,mandatory=$true)]
     [string] $UserAADAppName,
     [Parameter(Position=1,mandatory=$true)]
     [string]$AADWebAppID,
     [Parameter(Position=2,mandatory=$true)]
     [string]$AADNativeAppID,
     [Parameter(Position=3,mandatory=$true)]
     [string]$ReplyUrl
      )

# Install AzureRM Module if not available
Install-Module -Name AzureRM

Import-Module AzureRM

# Connect to Micrsoft Azure AD
Connect-AzureAD

function Set-Oauth2AllowImplicitFlow
{
 Write-Host "`nTrying to Update Manifest Setting - Oauth2AllowImplicitFlow to True in both AAD Web & Native Applications..."
 
 $Oauth2AllowImplicitFlow = 0
 $AllObjectIDS = Get-AzureADApplication  -SearchString $UserAADAppName -ErrorAction Stop
    try
    {
        foreach ($ObjectID in $AllObjectIDS)
        { 
          Set-AzureADApplication -ObjectId $ObjectID.ObjectId -Oauth2AllowImplicitFlow 1 -ErrorAction Stop
          $Oauth2AllowImplicitFlow++ 
        }
    }
    catch
    {     
       Write-Host $_.Exception.Message -ForegroundColor Red     
            
    }
    finally
    {
     if ($AllObjectIDS.Count -eq 0)
     {
      Write-Host "`nAzure Active Directory Don't have any Application With Name : "$UserAADAppName `
      ",Work with Administrator to Update Manifest in both AAD Applications (Web & Native)" -ForegroundColor Red
     }
     else
     {
          if ($AllObjectIDS.Count -eq $Oauth2AllowImplicitFlow)
          {
           Write-Host "`nAAD Web App    -  $UserAADAppName Manifest Settings are Updated to True"  -ForegroundColor Green 
           Write-Host "AAD Native App -  $UserAADAppName Manifest Settings are Updated to True"  -ForegroundColor Green
          }
          else
          {
           Write-Host "`nSomething Went Wrong in Updating Manifest Settings of Native or Web APP, Check with Administrator" -ForegroundColor Red
          }         
     }
   }
}

function Set-ReplyUrl
{ 
   Write-Host "`nTrying to Update ReplyUrl in AAD Web & Native Applications..."
   $AddReplyUrl = 0   
   $AllObjectIDS = Get-AzureADApplication  -SearchString $UserAADAppName -ErrorAction Stop
 try
  { 
     foreach ($ObjectID in $AllObjectIDS)
        { 
          Set-AzureADApplication -ObjectId $ObjectID.ObjectId -ReplyUrls $ReplyUrl -ErrorAction Stop
          $AddReplyUrl++ 
        }
  }
 catch
  {
   Write-Host $_.Exception.Message -ForegroundColor Red
  }
 finally
  {
   if ($AllObjectIDS.Count -eq 0)
     {
      Write-Host "`nAzure Active Directory Don't have any Application With Name : "$UserAADAppName `
      ",Work with Administrator to Update ReplyUrl in both AAD Applications (Web & Native)" -ForegroundColor Red
     }
   else
   {
       if ($AllObjectIDS.Count -eq $AddReplyUrl)
          {
               Write-Host "`nReplyUrl is Updated in Web App    - $UserAADAppName Successfully" -ForegroundColor Green
               Write-Host "ReplyUrl is Updated in Native App - $UserAADAppName Successfully" -ForegroundColor Green
          }
        else
          {
               Write-Host "`nSomething Went Wrong in Updating ReplyUrl of Native or Web APP, Check with Administrator" -ForegroundColor Red
          }
    }
  }
}

function Set-API
{
 Write-Host "`nTrying to Add APIs to Web App & Native in Azure Active Directory..."
 $WindowsAzureActiveDirectory = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess" 
 $WindowsAzureActiveDirectoryAPIWithDelegatedPermission = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "311a71cc-e848-46a1-bdf8-97ff7156d8e6","Scope"
 $WindowsAzureActiveDirectory.ResourceAccess = $WindowsAzureActiveDirectoryAPIWithDelegatedPermission
 $WindowsAzureActiveDirectory.ResourceAppId = "00000002-0000-0000-c000-000000000000"

 $MicrosoftAzureDataCatalog = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess" 
 $MicrosoftAzureDataCatalogAPIWithDelegatedPermission = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "f53da476-18e3-4152-8e01-aec403e6edc0","Scope"
 $MicrosoftAzureDataCatalog.ResourceAccess = $MicrosoftAzureDataCatalogAPIWithDelegatedPermission
 $MicrosoftAzureDataCatalog.ResourceAppId = "9d3e55ba-79e0-4b7c-af50-dc460b81dca1"

 $AzureKeyVault = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess" 
 $AzureKeyVaultAPIWithDelegatedPermission = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "e431adf3-7996-426b-b947-db8d7960cf27","Scope"
 $AzureKeyVault.ResourceAccess = $AzureKeyVaultAPIWithDelegatedPermission
 $AzureKeyVault.ResourceAppId = "cfa8b339-82a2-471a-a3c9-0fc0be7a4093"

 $DynamicsCRMOnline = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess" 
 $DynamicsCRMOnlineAPIWithDelegatedPermission = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "b75a5e0d-b1c4-45ed-bcdc-60671e541011","Scope"
 $DynamicsCRMOnline.ResourceAccess = $DynamicsCRMOnlineAPIWithDelegatedPermission
 $DynamicsCRMOnline.ResourceAppId = "00000007-0000-0000-c000-000000000000"
    
 $AllObjectIDS = Get-AzureADApplication  -SearchString $UserAADAppName -ErrorAction Stop
 try
  { 
     foreach ($ObjectID in $AllObjectIDS)
        { 
             if ($ObjectID.AppId -eq $AADWebAppID)
             {
                  Write-Host "`nStarted Adding APIs to Web Application..."
                  Set-AzureADApplication -ObjectId $ObjectID.ObjectId  -RequiredResourceAccess $WindowsAzureActiveDirectory,$MicrosoftAzureDataCatalog,$AzureKeyVault -ErrorAction Stop
                  Write-Host "`nWindows Azure Active Directory API With Delegated Permission (Sign in and read user profile) is Added Successfully" -ForegroundColor Green
                  Write-Host "Microsoft Azure Data Catalog API With Delegated Permission (Have full access to the Microsoft Azure Data Catalog) is Added Successfully" -ForegroundColor Green
                  Write-Host "Azure Keyvault API With Delegated Permission (Have full access to the Azure Key Vault service) is Added Successfully" -ForegroundColor Green     
             }
             if ($ObjectID.AppId -eq $AADNativeAppID) 
             {
                 Write-Host "`nStarted Adding APIs to Native Application..."
                 Set-AzureADApplication -ObjectId $ObjectID.ObjectId  -RequiredResourceAccess $WindowsAzureActiveDirectory,$DynamicsCRMOnline -ErrorAction Stop
                 Write-Host "`nWindows Azure Active Directory API With Delegated Permission (Sign in and read user profile) is Added Successfully" -ForegroundColor Green
                 Write-Host "Dynamics CRM Online API With Delegated Permission (Access Dynamics 365 as organization users) is Added Successfully" -ForegroundColor Green

             }         
        }
  }
 catch
  {
   Write-Host $_.Exception.Message -ForegroundColor Red
   Write-Host "`nSomething went wrong while adding APIs to AAD Web or Native Applications, Check with Administrator !!" -ForegroundColor Red
  }
 finally
  {
   if ($AllObjectIDS.Count -eq 0)
     {
      Write-Host "`nAzure Active Directory Don't have any Application With Name : "$UserAADAppName `
      ",Check with Administrator !!" -ForegroundColor Red
     }
  }
   #Page Reference : https://stackoverflow.com/questions/42164581/how-to-configure-a-new-azure-ad-application-through-powershell/42166700
}

try
{                    
  # Call Set-Oauth2AllowImplicitFlow Function
  Set-Oauth2AllowImplicitFlow

  # Call Set-ReplyUrl Function
  Set-ReplyUrl

  # Call Set-API Function
  Set-API
}
catch
{
 Write-Host $_.Exception.Message -ForegroundColor Red
 Write-Host "Script has stopped" -ForegroundColor Red
}
finally
{
Write-Host "`nScript Completed..." -ForegroundColor Green
}



