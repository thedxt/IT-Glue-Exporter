# IT Glue PWD Exporter
# Author: Daniel Keer
# Author URI: https://thedxt.ca
# Script URI: https://github.com/thedxt/IT-Glue-Exporter

$APIKEy = "YOUR API KEY HERE"
$APIEndpoint = "https://api.itglue.com"
$ExportCSV = "C:\temp\ITGlue_pwds.csv"

# check for temp
if (-not (Test-Path $Env:SystemDrive\temp))
{
New-Item -ItemType Directory $Env:SystemDrive\temp | out-null
}


# Settings IT Glue logon information
Add-ITGlueBaseURI -base_uri $APIEndpoint
Add-ITGlueAPIKey $APIKEy

# rest values
$PasswordList = $null
$i = 0

# getting all passwords
Write-Host "Getting passwords" -ForegroundColor Green
do {
    $i++
    $PasswordList += (Get-ITGluePasswords -page_size 1000 -page_number $i).data
    Write-Host "Retrieved $($PasswordList.count) Passwords" -ForegroundColor Yellow
}while ($PasswordList.count % 1000 -eq 0 -and $PasswordList.count -ne 0)
Write-Host "Processing the Passwords. This probably will take some time." -ForegroundColor Yellow
$Passwords = foreach ($PasswordItem in $passwordlist) {
    (Get-ITGluePasswords -show_password $true -id $PasswordItem.id).data
}

#output to CSV using the same elements normal IT Glue exports use
$Passwords | select  @{Name='id'; Expression={$_.id}},
@{Name='organization'; Expression={$_.attributes.'organization-name'}},
@{Name='name'; Expr={$_.attributes.'name'}},
@{Name='password_category'; Expression={$_.attributes.'password-category-name'}},
@{Name='resource_type'; Expression={$_.attributes.'resource-type'}},
@{Name='resource_id'; Expression={$_.attributes.'resource-id'}},
@{Name='username'; Expression={$_.attributes.'username'}},
@{Name='password'; Expression={$_.attributes.'password'}},
@{Name='one_time_password'; Expression={$_.attributes.'otp-enabled'}},
@{Name='archived'; Expression={$_.attributes.'archived'}},
@{Name='url'; Expression={$_.attributes.'url'}},
@{Name='notes'; Expression={$_.attributes.'notes'}} | export-csv -NoTypeInformation $ExportCSV

Write-host "Password export is located" $ExportCSV
