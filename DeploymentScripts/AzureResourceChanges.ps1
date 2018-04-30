<# Summary
- Synopsis : Changes to Azure Resources
 
- DESCRIPTION :
  Azure Resources created using ARM Template need changes.

  List of Changes & inline Functions:

  1. New tables ('ObfuscationAgent','ObfuscationTag','ObfuscationTagExecutionOrder') need to be added to User table storage
     Function - Set-TablesInUserTableStorage, will add all required tables in user table storage
  
  2. CORS in Blob Service need to be updated.
     Function - Set-CORSToBlobService, will update CORS in Blob Service.

  3. CORS in table service need to be Added
     Function - Set-CORSToTableService, will CORS in table service.

  4. Add UserPrincipal to Azure Keyvault Access Policy
     Function - Set-UserPrincipal, will add User to Keyvault Access Policy

  5. Generate SAS token for Blob & table services and Update in Keyvault
     Function - Get-SASTokenAndUpdateKeyVault, will generate SAS Token and add to Keyvault

  6. Get Azure Function URL and Update in Keyvault
     Function - Get-AzureFunctionUrlAndUpdateKeyValut, will get Azure Function URL and add to keyvault  


- Parameters :
  1.  UserResourceGroupName
  2.  UserStorageAccountName
  3.  UserKeyVaultName
  4.  UserFunctionAppName
  5.  UserPrincipalName
  6.  UserallowedOrigins

- Example : ./AzureResourceChanges -UserResourceGroupName "ResourceGroupName" -UserStorageAccountName "StorageAccountName" -UserKeyVaultName "KeyVaultName" -UserFunctionAppName "FunctionAppName" -UserPrincipalName "UserPrincipalName" -UserallowedOrigins "CRM Base URL"
 
Author  : Gowtham Challa  
Email   : v-chgowt@microsoft.com 
#>
#[cmdletbinding()]
#param (
 #     [Parameter(Position=0,mandatory=$true)]
  #    [string]$UserResourceGroupName,
   #   [Parameter(Position=1,mandatory=$true)]
    #  [string]$UserStorageAccountName,
     # [Parameter(Position=2,mandatory=$true)]
     #[string]$UserKeyVaultName,
     # [Parameter(Position=3,mandatory=$true)]
     # [string]$UserFunctionAppName,
     # [Parameter(Position=4,mandatory=$true)]
     # [string]$UserPrincipalName,
     # [Parameter(Position=5,mandatory=$true)]
     # [string]$UserallowedOrigins    
     # )

$UserResourceGroupName = "ObfuscationTesting"
$UserStorageAccountName = "obfuscationstorageacc"
$UserKeyVaultName = "obskeyvault"
$UserFunctionAppName = "ObfuscationFunctionApp"
$UserPrincipalName = 'v-sgudur@microsoft.com'
$UserallowedOrigins = "https://ocepoc.api.crm.dynamics.com/"


Import-Module AzureRM

# Connect to Micrsoft Azure
Connect-AzureRmAccount

function Set-TablesInUserTableStorage
{
  Write-Host "`nTrying to Create Tables in User Table Storage......"
  $counter = 0;
  try
  {
   $tableLst = @('ObfuscationAgent','ObfuscationTag','ObfuscationTagExecutionOrder')
   foreach ($table in $tableLst)
     {
      New-AzureStorageTable -Name $table -ErrorAction Ignore -Context $UserStorageContext 
      Write-Host "`nCreated Table : " $table -ForegroundColor Green
      $counter++
     }  
  }
  catch
  {
   Write-Host $_.Exception.Message -ForegroundColor Red
  }
  finally
  {
   if ($counter -eq 3)
    {
        Write-Host "`nAll Tables are Created Successfully !!!" -ForegroundColor Green
    }
    else
    {
        Write-Host "`nFailed To Create All or Few Tables, Try Again !!!" -ForegroundColor Red
    }
  }
}

function Set-CORSToBlobService
{ 
 Write-Host "`nTrying to Add CORS in Blob Service ..."
 $SetCORSToBlobService = 0 
 try
 {
    $CorsRules = (@{
    AllowedOrigins=$UserallowedOrigins
    AllowedMethods=@("Delete","Get","Head","Merge","Post","Options","Put")
    AllowedHeaders="*"
    ExposedHeaders="*"    
    MaxAgeInSeconds=84620})
    
    Set-AzureStorageCORSRule -ServiceType Blob -CorsRules $CorsRules -Context $UserStorageContext -ErrorAction Stop
    $SetCORSToBlobService = 1
 }
 catch
 {
    Write-Host $_.Exception.Message -ForegroundColor Red
    $SetCORSToBlobService = 0
  
 }
 finally
 {
   if ($SetCORSToBlobService -eq 1)
   {
    Write-Host "`nCORS are Added To Blob Service Successfully." -ForegroundColor Green
   }
   else
   {
    Write-Host "`nCORS are Not Added To Blob Service.Something went wrong, Please check with Administrator" -ForegroundColor Red
   }
 }
}

function Set-CORSToTableService
{
 Write-Host "`nTrying to Add CORS in Table Service ..."
 $SetCORSToTableService = 0
 try
 {
    $CorsRules = (@{
    AllowedOrigins=$UserallowedOrigins
    AllowedMethods=@("Delete","Get","Head","Merge","Post","Options","Put")
    AllowedHeaders="*"
    ExposedHeaders="*"    
    MaxAgeInSeconds=84620})
    
    Set-AzureStorageCORSRule -ServiceType Table -CorsRules $CorsRules -Context $UserStorageContext -ErrorAction Stop
    $SetCORSToTableService = 1
 }
 catch
 {  
   Write-Host $_.Exception.Message -ForegroundColor Red
   $SetCORSToTableService = 0
  
 }
 finally
 {
  if ($SetCORSToTableService -eq 1)
   {
    Write-Host "`nCORS are Added To Table Service Successfully" -ForegroundColor Green
   }
   else
   {
    Write-Host "`nCORS are Not Added To Table Service.Something went wrong, Please check with Administrator" -ForegroundColor Red
   }
 }
}

function Set-UserPrincipal
{
 Write-Host "`nTrying to Add User Principals to KeyVault Access Policy...."
 $AddUser = 0
 try
 {
  Set-AzureRmKeyVaultAccessPolicy -VaultName $UserKeyVaultName -ResourceGroupName $UserResourceGroupName -UserPrincipalName $UserPrincipalName -PermissionsToSecrets set,get,list,backup,delete,recover,restore  -PassThru -ErrorAction Stop
  $AddUser = 1
 }
 catch
 {
   Write-Host $_.Exception.Message -ForegroundColor Red
   $AddUser = 0
  
 }
 finally
 {
  if ($AddUser -eq 1)
  {
   Write-Host "`nUser Principal Added to KeyVault" -ForegroundColor Green
  }
  else
  {
   Write-Host "`nUser Principal NOT Added to KeyVault, Check your Access !!!" -ForegroundColor Red
  }
 }
}

function Get-SASTokenAndUpdateKeyVault
{
 Write-Host "`nTrying to create SAS Token for Azure Blob & Table Services and Update in Keyvault ......"
 $startTime = (get-date).AddDays(-1)
 $expiryTime = (get-date).AddYears(10)
 $permission = "rwdlacu"
 $isSASTokenGenerated = 0
 $isSASTokenUpdatedInKeyVault = 0
 try
  {
   #Get SAS Token
   $sasToken = New-AzureStorageAccountSASToken -Service Blob,Table -ResourceType Service,Container,Object -Permission "$permission" -Protocol HttpsOnly -StartTime $startTime -ExpiryTime $expiryTime -Context $UserStorageContext -ErrorAction Stop
   Write-Host 'SAS token: ' $($sasToken)
   $isSASTokenGenerated = 1

   $sasToken = ConvertTo-SecureString -String $sasToken -AsPlainText -Force
   Set-AzureKeyVaultSecret -VaultName $UserKeyVaultName -Name 'StorageSASToken' -SecretValue $sasToken -ContentType "text/plain" -ErrorAction Stop
   $isSASTokenUpdatedInKeyVault = 1
  }
 catch
  {
    Write-Host $_.Exception.Message -ForegroundColor Red
  }
 finally
  {
   if ($isSASTokenGenerated -eq 1)
     {
      Write-Host "`nSAS token Generated Successfully" -ForegroundColor Green
     }
     else
     {
       Write-Host "`nSAS token is not Generated.Something went wrong, Please check with Administrator" -ForegroundColor Red
     }
     if ($isSASTokenUpdatedInKeyVault -eq 1)
     {
      Write-Host "`nSAS token is Updated Successfully in KeyVault" -ForegroundColor Green
     }
     else
     {
       Write-Host "`nSAS token is not Updated in KeyVault.Something went wrong, Please check with Administrator" -ForegroundColor Red
     }
  } 
}

function Get-AzureFunctionUrlAndUpdateKeyValut
{
 $FoundFunctionKey = 0
 $isFunctionUrlUpdatedInKeyVault = 0
 try
  {
   Write-Host "`nTrying to Get Azure Function Url and Update Keyvault ......"

   $content = Get-AzureRmWebAppPublishingProfile -ResourceGroupName $UserResourceGroupName -Name $UserFunctionAppName -OutputFile creds.xml -Format WebDeploy -ErrorAction Stop
   $username = Select-Xml -Content $content -XPath "//publishProfile[@publishMethod='MSDeploy']/@userName" -ErrorAction Stop
   $password = Select-Xml -Content $content -XPath "//publishProfile[@publishMethod='MSDeploy']/@userPWD" -ErrorAction Stop
   $accessToken = "Basic {0}" -f [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username, $password)))

   $masterApiUrl = "https://$UserFunctionAppName.scm.azurewebsites.net/api/functions/admin/masterkey" 
   $masterKeyResult = Invoke-RestMethod -Uri $masterApiUrl -Headers @{"Authorization"=$accessToken;"If-Match"="*"} -ErrorAction Stop
   $masterKey = $masterKeyResult.Masterkey

   $functionApiUrl = "https://$UserFunctionAppName.azurewebsites.net/admin/host/keys?code=$masterKey" 
   $functionApiResult = Invoke-WebRequest -UseBasicParsing -Uri $functionApiUrl -ErrorAction Stop
   $keysCode = $functionApiResult.Content | ConvertFrom-Json
   $functionKey = $keysCode.Keys[0].Value 
   $functionurl = "https://$UserFunctionAppName.azurewebsites.net/api/GetKeyVaultSecrets?code="+$functionKey 
   Write-Host "Function URL : "$functionurl
   #https://$UserFunctionAppName.azurewebsites.net/api/GetKeyVaultSecrets?code=EwpEiaeKRTRRVxIHztl4/WuWMyfeCHqJon3xdPq8OP8XzaM3qTP4eA==
   $FoundFunctionKey = 1

   $functionurl = ConvertTo-SecureString -String $functionurl -AsPlainText -Force 
   Set-AzureKeyVaultSecret -VaultName $UserKeyVaultName -Name 'AzureFunctionURL' -SecretValue $functionurl -ContentType "text/plain" -ErrorAction Stop
   $isFunctionUrlUpdatedInKeyVault = 1
  }
 catch
  {
    Write-Host $_.Exception.Message -ForegroundColor Red
  }
 finally
  {
   if ($FoundFunctionKey -eq 1)
     {
      Write-Host "`nRetrieved Azure Function Url Successfully" -ForegroundColor Green
     }
     else
     {
       Write-Host "`nError in getting the Function Url.Something went wrong, Please check with Administrator" -ForegroundColor Red
     }
     if ($isFunctionUrlUpdatedInKeyVault -eq 1)
     {
      Write-Host "`nFunctionUrl is Updated Successfully in KeyVault" -ForegroundColor Green
     }
     else
     {
       Write-Host "`nFunctionUrl is not Updated in KeyVault.Something went wrong, Please check with Administrator" -ForegroundColor Red
     }
  }   
}

try
{ 
    $foundStorageAcc = 0
    $loopThroughSubscription = 0
    
    #Get all Subscriptions of User
    $LstOfSubscriptions = Get-AzureRmSubscription

    foreach($subscription in $LstOfSubscriptions)
    {
        #Set Default Subscription 
        Select-AzureRmSubscription "$subscription"

        #Get all Storage Accounts in Subscription
        $lstOfStorageAccounts = Get-AzureRmStorageAccount

        foreach ($StorageAccount in $lstOfStorageAccounts)
        {
              # Compare UserStorageAccount with each Available Storage Account in Subscription
              if ( $StorageAccount.StorageAccountName -eq $UserStorageAccountName)
              {
                  # Retrieve User StrorageAccountKey 
                  $UserStorageKey = Get-AzureRmStorageAccountKey -ResourceGroupName $UserResourceGroupName -AccountName $UserStorageAccountName -ErrorAction Stop

                  #create user storage context 
                  $UserStorageContext = New-AzureStorageContext -StorageAccountName $UserStorageAccountName -StorageAccountKey $UserStorageKey[0].Value -ErrorAction Stop                 
                  
                  # Call Set-TablesInUserTableStorage Function
                  Set-TablesInUserTableStorage

                  #Call Set-CORSToBlobService Function
                  Set-CORSToBlobService

                  #Call Set-CORSToTableService Function
                  Set-CORSToTableService

                  # Call Set-UserPrincipal Function
                  Set-UserPrincipal                 
               
                  #Call Get-SASTokenAndUpdateKeyVault Function
                  Get-SASTokenAndUpdateKeyVault

                  #Call Get-AzureFunctionUrlAndUpdateKeyValut Function
                  Get-AzureFunctionUrlAndUpdateKeyValut            

                  # variable - foundStorageAcc,  set to 1 and break the loop when Storage Account is found. 
                  $foundStorageAcc = 1  
                  break; 
              }
         }

         #Stop looping through after storage account is found.
         if ($foundStorageAcc -eq 1)
         {
           break;
         }
    $loopThroughSubscription++
    }
    
    #Message after Searching for a Storage Account in all available subscriptions
    if ($loopThroughSubscription -eq $LstOfSubscriptions.Count)
    {
      Write-Host "`nStorage Account $UserStorageAccountName is not available in any of the available subscriptions !!!" -ForegroundColor Red
    }
}
catch
{
 Write-Host $_.Exception.Message -ForegroundColor Red
}
finally
{
 Write-Host "`nScript Completed !! !" -ForegroundColor Green
}



