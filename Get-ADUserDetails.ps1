<#
.SYNOPSIS

"Get-ADUserDetails" gets details about a domain account.

.DESCRIPTION

"Get-ADUserDetails" gets details about a domain account.

.PARAMETER UserName

The SamAccountName of the user. Defaults to one's own AD account.

.PARAMETER Clipboard

Boolean value to put data in your clipboard.

.NOTES

Assumes 180 days for the password expiry. IDK how to query this for a user.

.INPUTS

$UserName

.EXAMPLE

Get-ADUserDetails.ps1

==========================================================
              Administrator (Administrator)
__________________________________________________________


CN                     : Administrator
DisplayName            : Administrator
CanonicalName          : ad.example.com/Users/Administrator
SamAccountName         : Administrator
PrimaryGroup           : CN=Domain Users,CN=Users,DC=ad,DC=example,DC=com
SID                    : S-1-5-21-1234567890-0987654321-1029384756-000
EmailAddress           : Administrator@example.com
Description            : Built-in account for administering the computer/domain
Enabled                : True
Created                : 2007/02/14 14:33:32
LastBadPasswordAttempt : 2019/06/21 15:29:49
Modified               : 2019/06/12 05:00:36
WhenChanged            : 2019/06/12 05:00:36
PasswordLastSet        : 2019/03/19 19:07:27
LastLogonDate          : 2019/06/12 05:00:33
PasswordExpired        : False
PasswordNeverExpires   : False
PasswordExpires        : 2019/09/17 19:07:27
LogonCount             : 65535




==========================================================

Called without a user name, gets details for the currently executing user.

.EXAMPLE

Get-ADUserDetails.ps1 -UserName jdoe -Clipboard $False

Getting information for 'jdoe'

===================================
         Jon Doe (jdoe)
____________________________________


CN                     : Jon Doe
DisplayName            : Jon Doe
CanonicalName          : ad.example.com/IT/Jon Doe
SamAccountName         : jdoe
PrimaryGroup           : CN=Domain Users,CN=Users,DC=ad,DC=example,DC=com
SID                    : S-1-5-21-0987654321-1234567890-0192738465-6842
EmailAddress           : jdoe@example.com
Description            : Network Administrator
Enabled                : True
Created                : 2013/01/24 20:37:24
LastBadPasswordAttempt : 2019/06/06 21:02:20
Modified               : 2019/06/13 19:05:41
WhenChanged            : 2019/06/13 19:05:41
PasswordLastSet        : 2019/04/03 23:49:58
LastLogonDate          : 2019/06/13 19:05:33
PasswordExpired        : False
PasswordNeverExpires   : False
PasswordExpires        : 2019/09/30 23:49:58
LogonCount             : 7362




===================================

Get information for user "jdoe" and don't put the data into the clipboard.

#>

[CmdletBinding()]
param (
	[Parameter(Mandatory=$False)]
	[string]$UserName=(Get-Content Env:\USERNAME),
	
	[Parameter(Mandatory=$False)]
	[Alias('Clip')]
	[bool]$Clipboard = $True
	
)

$BG='black'
$OK='green'
$ERROR='red'

$PasswordLengthInDays=180

Write-Host `
	-BackgroundColor $BG `
	-ForegroundColor $OK `
	"`nGetting information for '$UserName'"

$Identity = `

	Get-ADUser -Properties "*" -Filter "SamAccountName -like '${UserName}'" | `
		Select-Object `
			-Property `
				CN, `
				DisplayName, `
				CanonicalName, `
				SamAccountName, `
				PrimaryGroup, `
				SID, `
				EmailAddress, `
				Description, `
				Enabled, `
				@{Name = 'Created'                ; Expression = {Get-Date -Date $_.WhenCreated -UFormat '%Y/%m/%d %H:%M:%S'}}, `
				@{Name = 'LastBadPasswordAttempt' ; Expression = {Get-Date -Date $_.LastBadPasswordAttempt -UFormat '%Y/%m/%d %H:%M:%S'}}, `
				@{Name = 'Modified'               ; Expression = {Get-Date -Date $_.Modified -UFormat '%Y/%m/%d %H:%M:%S'}}, `
				@{Name = 'WhenChanged'            ; Expression = {Get-Date -Date $_.WhenChanged -UFormat '%Y/%m/%d %H:%M:%S'}}, `
				@{Name = 'PasswordLastSet'        ; Expression = {Get-Date -Date $_.PasswordLastSet -UFormat '%Y/%m/%d %H:%M:%S'}}, `
				@{Name = 'LastLogonDate'          ; Expression = {Get-Date -Date $_.LastLogonDate -UFormat '%Y/%m/%d %H:%M:%S'}}, `
				PasswordExpired, `
				PasswordNeverExpires, `
				@{Name='PasswordExpires'          ; Expression={ Get-Date -Date ((Get-Date -Date $_.PasswordLastSet).AddDays($PasswordLengthInDays)) -UFormat '%Y/%m/%d %H:%M:%S' }}, `
				LogonCount

$FriendlyDisplayName = $Identity.DisplayName + " (" + $Identity.SamAccountName + ")"
# Generate a header for the output.
$Data = `
	"`n" + "=" * $FriendlyDisplayName.length * 2 + "`n" + `
	" " * ($FriendlyDisplayName.length / 2) + $FriendlyDisplayName + " " * ($FriendlyDisplayName.length / 2) + "`n" + `
	"_" * $FriendlyDisplayName.length * 2 + "`n";

$Data += $Identity | Out-String
$Data += "`n" + "=" * $FriendlyDisplayName.length * 2 + "`n";

$Data = $Data | Out-String
$Data

if($Clipboard) {
	$Data | Set-Clipboard
}