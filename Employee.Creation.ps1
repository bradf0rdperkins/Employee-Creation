#Generated Form Function
function GenerateForm {
########################################################################
Import-Module ActiveDirectory
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
########################################################################

#region Import the Assemblies
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
#endregion

#region Generated Form Objects
$form1 = New-Object System.Windows.Forms.Form
$lmanager = New-Object System.Windows.Forms.Label
$cmbmgr = New-Object System.Windows.Forms.ComboBox
$val5 = New-Object System.Windows.Forms.Label
$pictureBox1 = New-Object System.Windows.Forms.PictureBox
$pgbar = New-Object System.Windows.Forms.ProgressBar
$infodisplay = New-Object System.Windows.Forms.Label
$tuser = New-Object System.Windows.Forms.ComboBox
$clear = New-Object System.Windows.Forms.Button
$val4 = New-Object System.Windows.Forms.Label
$val3 = New-Object System.Windows.Forms.Label
$mailboxlist = New-Object System.Windows.Forms.ListBox
$bcopy = New-Object System.Windows.Forms.Button
$val2 = New-Object System.Windows.Forms.Label
$val1 = New-Object System.Windows.Forms.Label
$bvalidate = New-Object System.Windows.Forms.Button
$label4 = New-Object System.Windows.Forms.Label
$label3 = New-Object System.Windows.Forms.Label
$label2 = New-Object System.Windows.Forms.Label
$label1 = New-Object System.Windows.Forms.Label
$tlname = New-Object System.Windows.Forms.TextBox
$tfname = New-Object System.Windows.Forms.TextBox
$tnewuser = New-Object System.Windows.Forms.TextBox
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
#endregion Generated Form Objects

#----------------------------------------------
#Generated Event Script Blocks
#----------------------------------------------
#Provide Custom Code for events specified in PrimalForms.

$form1.FormBorderStyle = "FixedToolWindow"


#ComboBox Ad user generation
$arrac = get-aduser -SearchBase "<OU=,DC=domain,DC=local>" -Filter * | sort-object


foreach($muser in $arrac)
                {
                    $tuser.items.add($muser.Name)
                    $cmbmgr.items.add($muser.Name)
                                        }


#Logo

$picturebox1.imagelocation = "<Company logo path>"
$picturebox1.sizemode = "StretchImage" 

#Mailbox Storage Group Listing

$mailboxlist.items.add("Mailbox Database")
$mailboxlist.items.add("Mailbox Second Storage Group")
$mailboxlist.items.add("Mailbox ThirdStorage Group")

# Global Var
[string]$global:name = $null
[string]$global:nameok = $null
[string]$global:Newuser = $null
[string]$global:fname = $null
[string]$global:lname = $null
[string]$global:nameds = $null
[string]$global:NewUserds = $null
[string]$global:db = $null
[string]$global:mgr = $null
[Int]$global:count = $null
[string]$global:DN = $null
[string]$global:OldUser = $null
[string]$global:Parent = $null
[string]$global:OU = $null
[string]$global:OUDN = $null
[string]$global:domain = $null
[Int]$global:countr = $null
[Int]$global:index = $null
[string]$global:iuser = $null
[Int]$global:index2 = $null 

$bcopy_OnClick= 
{
$clear.visible = $False
$pgbar.visible = $true
$bcopy.visible = $False
$bvalidate.visible = $False


# Gets all of the users info to be copied to the new account

$name = Get-AdUser -Identity $global:nameok -Properties *
$DN = $name.distinguishedName
$OldUser = [ADSI]"LDAP://$DN"
$Parent = $OldUser.Parent
$OU = [ADSI]$Parent
$OUDN = $OU.distinguishedName
$domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain() 
$NewName = "$fname $lname"
$flname = "$global:fname.$global:lname"

# Creates the user from the copied properties #Step 1

New-ADUser -SamAccountName $global:NewUser -Name $NewName -GivenName $fname -Surname $lname -Instance $DN -Path "$OUDN" -AccountPassword (ConvertTo-SecureString -AsPlainText "abc123**" -Force) –userPrincipalName $global:NewUser@$domain -Company $name.Company -Department $name.Department -Manager $name.Manager -title $name.Title -Office $name.Office -City $name.city -PostalCode $name.postalcode -Country $name.country -OfficePhone $name.OfficePhone -Fax $name.fax -State $name.State -StreetAddress $name.StreetAddress -Enabled $true -ProfilePath "\\<YOURSERVER>\<YOURPROFILEPATH>\$global:NewUser" -homedirectory  "\\<YOURSERVER>\YOURUSERPATH>\$global:NewUser" -HomePage "www.<YOURCOMPANY>.com"
$pgbar.value = ($pgbar.value + 10)

# Requires Change Password at Logon
 
Set-ADUser -Identity $global:NewUser -ChangePasswordAtLogon $true

# gets groups from the Copied user and populates the new user in them #Step 2

$groups = (GET-ADUSER –Identity $name –Properties MemberOf).MemberOf
$global:count = $groups.count
$global:countr = $groups.count
$pgtot = 290
$pgbar.maximum = ($pgtot + ($global:count * 10))
$infodisplay.text = "Groupe a copier: $global:count"

# Group copy 

$groups = (GET-ADUSER –Identity $name –Properties MemberOf).MemberOf
foreach ($group in $groups) { 

Add-ADGroupMember -Identity $group -Members $global:NewUser
$pgbar.value = ($pgbar.value + 10)

}




# After some testing it seems that sometimes AD don't have time to process everything and while trying to access the user for exchange it gave errors.
$infodisplay.Text = $infodisplay.Text + "`r`nProcessing time... "
$sec = 15
While($sec -ne 0) {Start-Sleep -s 1
$pgbar.value = ($pgbar.value + 10)
$sec--}

# Creates the New users mailbox #Step 3

Enable-Mailbox -Identity $global:NewUser@$domain -alias "$flname" –managedfoldermailboxpolicy "Company Retention Policies" -ManagedFolderMailboxPolicyAllowed -Database <Mail Server>\"$global:db"
$pgbar.value = ($pgbar.value + 10)
$infodisplay.Text = $infodisplay.Text + "`r`nLinking Mailbox to $global:NewUser@$domain"

# Sets secondary smtp adress while specifying the Primary smtp adress. # Step 4
$infodisplay.Text = $infodisplay.Text + "`r`nEditing Mailbox $global:NewUser@$domain for SMTP"
$sec = ""
$sec = 10
While($sec -ne 0) {Start-Sleep -s 1
$pgbar.value = ($pgbar.value + 10)
$sec--}

# Address next to SMTP is the primary SMTP address

Set-Mailbox $flname -EmailAddressPolicyEnabled $False -EmailAddresses SMTP:"$flname@contoso.com", $flname@contoso2.ca, $flname@domain.ca, $flname@$domain


$pgbar.value = ($pgbar.value + 10)

# Creates the New user personal Folder # Step 5

$infodisplay.Text = $infodisplay.Text + "`r`nCreating Home Folder for $global:NewUser"

New-item <HomeFolder Path>\"$global:NewUser" -type directory
$acl = Get-Acl <HomeFolder Path\"$global:NewUser"
$acl | Format-List
$acl.GetAccessRules($true, $true, [System.Security.Principal.NTAccount])
$acl.SetAccessRuleProtection($true, $true)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule "<Domain>\$global:NewUser","FullControl", "ContainerInherit, ObjectInherit", "None", "Allow"
$acl.addAccessRule($rule)
Set-Acl <HomeFolder Path\"$global:NewUser" $acl
$pgbar.value = ($pgbar.value + 10)

$infodisplay.Text = "Creation Succesfull"

# Creates the New user Profile Folder # Step 6
 
$infodisplay.Text = $infodisplay.Text + "`r`nCreating Profile Folder for $global:NewUser"
 
New-item \\<YOURSERVER>\<YOURPROFILEPATH>\\"$global:NewUser" -type directory
$acl = Get-Acl \\<YOURSERVER>\<YOURPROFILEPATH>\\"$global:NewUser"
$acl | Format-List
$acl.GetAccessRules($true, $true, [System.Security.Principal.NTAccount])
$acl.SetAccessRuleProtection($true, $true)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule "$domain\$global:NewUser","FullControl", "ContainerInherit, ObjectInherit", "None", "Allow"
$acl.addAccessRule($rule)
Set-Acl \\<YOURSERVER>\<YOURPROFILEPATH>\\"$global:NewUser" $acl

 
$infodisplay.Text = "Profile Folder: Successfull"

#Email report to It
#Manager to Notify

$emailmgr = Get-ADUser "$mgr" -Properties EmailAddress
$notifymgr = $emailmgr.EmailAddress


$smtpServer = "mail server"
$smtpFrom = "it@domain.ca"}"

if ($notifymgr -eq $null){$smtpTo = "it@domain.ca"}
else {$smtpTo = "$notifymgr", "it@domain.ca"}"}

$messageSubject = "Automated User Creation Report"

[string]$messagebody = ""

$messagebody = "User to Copy: $global:nameok `r`nLogon Name of New user: $global:NewUser `r`nFirst Name: $global:fname `r`nLast Name : $global:lname `r`nTemporary Password: abc123** `r`nGroupMembership Copied: $global:countr `r`nMailbox Storage Selection : $global:db  `r`nUser Email: $global:fname.$global:lname@hutchinsonna.com `r`nAlias: $global:fname.$global:lname `r`nHome Folder: \\sequoia\documents$\$global:NewUser"


Send-MailMessage -To $smtpTo -From $smtpFrom -Subject $messagesubject -Body $messagebody -SmtpServer $smtpServer

#Welcome letter to user

$messageSubject = "Welcome To <Company Name>"
$smtpTo = "$global:fname.$global:lname@domain.com"

$messagebody = "Hello, $global:fname $global:lname, and welcome to the <Company Name> family! Please keep this email for future use. It contains vital information.

-----------------------------------
Username and Password
-----------------------------------
Your network username is $global:NewUser, and your initial password is abc123** . Use your username and password to log on to the network. You will be prompted to change your password upon first login. Your password should NEVER be shared with anyone. Please do not write it down on anything that can be seen by your coworkers. You will be prompted to change it regularly.

-----------------------------------
Email
-----------------------------------
Your email address is $global:fname.$global:lname@domain.com.

To access your email, calendar, and contacts away from your desk, you can do so from any Internet-connected computer. Simply open your web browser, go to the Outlook Web Access (OWA) page at  https://mail.domain.ca , and log in using your email address and network password. Please note the S in https.

If you would like to have access to your email and contacts from your mobile phone, you will need a current smartphone. Currently supported mobile operating systems include Apple iOS and Android. Support for configuring your device can currently be sought from the IT department.

-----------------------------------
Personal Folder
-----------------------------------
A personal folder has been created for you, located at U:\.  Any file or folder in your U: drive will be included in our daily backup. No file stored on your local computer will be backed up, so be sure all important files and documents are in your U: drive!

-----------------------------------
Technical Assistance
-----------------------------------
Should you need technical assistance, please check the Knowledge Base of our Helpdesk at http://helpdesk. If you cannot find an answer there, submit a Ticket in the Helpdesk at the same location. If you are unable to access the Helpdesk, you may reach the IT department at it@domain.ca or extension 298/342 or (111-111-1111 ).

Thank you, and, again, welcome to <Company Name>!

The Information Technology Department"



Send-MailMessage -To $smtpTo -From $smtpFrom -Subject $messagesubject -Body $messagebody -SmtpServer $smtpServer

$clear.visible = $True

}

$bvalidate_OnClick= 
{
# Gets all of the users info to be copied to the new account

#array index selection
$global:index = $tuser.SelectedIndex
$indexuser = $arrac[$index]
$iuser = get-aduser  $indexuser.SamAccountName  | select -ExpandProperty SamAccountName
$global:nameds = $iuser
$global:nameok = $iuser

#Array mgr selection
if ($cmbmgr.SelectedIndex -eq -1){$global:mgr = ""}
else {
$global:index2 = $cmbmgr.SelectedIndex
$indexmgr = $arrac[$index2]
$global:mgr = get-aduser  $indexmgr.SamAccountName  | select -ExpandProperty SamAccountName}

#Checking the user to copy if it exist

if ($tuser.SelectedIndex -eq -1) {$val1.Text = "Not OK"
$global:nameok = ""}

else {$val1.Text = "OK"}



#Checking if the new user exist

$global:NewUserds = $tnewuser.Text
$global:NewUserds = $global:NewUserds.trim( )
$global:NewUser = $global:NewUserds

if ( $global:NewUserds -eq "" ) {$val2.Text = "Empty"}
	
elseif (dsquery user -samid $global:NewUserds){$val2.Text = "User Exist"}

elseif ($global:NewUserds = "null") {$val2.Text = "OK"}

#Checking if Fisrt Name isn't empty

if ( $tfname.Text -eq "" ) {$val3.Text = "Empty"}
elseif ($tfname.Text -ne "") {$val3.Text = "OK"}
$global:fname = $tfname.Text
$global:fname = $global:fname.trim( )

#Checking if Last Name isn't empty

if ( $tlname.Text -eq "" ) {$val4.Text = "Empty"}
elseif ($tlname.Text -ne "") {$val4.Text = "OK"}
$global:lname = $tlname.Text
$global:lname = $global:lname.trim( )

#Checking if hte Mailbox Storage is selected

if ($mailboxlist.SelectedIndex -eq "-1") {
$val5.Text = "No Selection"
$infodisplay.Text = "Please Select a Mailbox Storage"
}
else {$val5.Text = "OK"}

$global:db = $mailboxlist.Selecteditem


#Checking if All Validation is OK

if ( $val1.Text -eq "OK" -and $val2.Text -eq "OK" -and $val3.Text -eq "OK" -and $val4.Text -eq "OK" -and $val5.Text -eq "OK") { 
$tuser.enabled = $False
$tnewuser.enabled = $False
$tfname.enabled = $False
$tlname.enabled = $False 
$mailboxlist.enabled = $False
$cmbmgr.enabled = $false
$clear.visible = $True
$bcopy.visible = $True }

#Displaying Info
$nmgr = $cmbmgr.SelectedItem
$infodisplay.Text = "Manager to notify: $nmgr `r`nUser to Copy: $global:nameok `r`nLogon Name of New user: $global:NewUser `r`nFirst Name: $global:fname `r`nLast Name : $global:lname `r`nMailbox Storage Selection : $global:db "


}

$handler_label1_Click= 
{
#TODO: Place custom script here

}

$clear_OnClick= 
{

$tuser.enabled = $True
$tnewuser.enabled = $True
$tfname.enabled = $True
$tlname.enabled = $True
$mailboxlist.enabled = $True
$cmbmgr.enabled = $true
$val1.Text = ""
$val2.Text = ""
$val3.Text = ""
$val4.Text = ""
$val5.Text = ""
$tuser.SelectedIndex = -1
$cmbmgr.SelectedIndex = -1
$tnewuser.Text = ""
$tfname.Text = ""
$tlname.Text = ""
$infodisplay.Text = ""
$pgbar.value = 0
$pgbar.maximum = 0
$clear.visible = $False
$bcopy.visible = $False 

$bvalidate.visible = $True
$mailboxlist.clearSelected()

}

$handler_form1_Load= 
{
#TODO: Place custom script here

}

$OnLoadForm_StateCorrection=
{#Correct the initial state of the form to prevent the .Net maximized form issue
	$form1.WindowState = $InitialFormWindowState
}

#----------------------------------------------
#region Generated Form Code
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 394
$System_Drawing_Size.Width = 534
$form1.ClientSize = $System_Drawing_Size
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$form1.Name = "form1"
$form1.Text = "Ad Copy User"
$form1.add_Load($handler_form1_Load)

$lmanager.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 38
$System_Drawing_Point.Y = 15
$lmanager.Location = $System_Drawing_Point
$lmanager.Name = "lmanager"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 84
$lmanager.Size = $System_Drawing_Size
$lmanager.TabIndex = 24
$lmanager.Text = "Notify Manager"

$form1.Controls.Add($lmanager)

$cmbmgr.AutoCompleteMode = 3
$cmbmgr.AutoCompleteSource = 256
$cmbmgr.DataBindings.DefaultDataSourceUpdateMode = 0
$cmbmgr.FormattingEnabled = $True
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 128
$System_Drawing_Point.Y = 11
$cmbmgr.Location = $System_Drawing_Point
$cmbmgr.Name = "cmbmgr"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 21
$System_Drawing_Size.Width = 145
$cmbmgr.Size = $System_Drawing_Size
$cmbmgr.TabIndex = 23

$form1.Controls.Add($cmbmgr)

$val5.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 287
$System_Drawing_Point.Y = 204
$val5.Location = $System_Drawing_Point
$val5.Name = "val5"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 18
$System_Drawing_Size.Width = 108
$val5.Size = $System_Drawing_Size
$val5.TabIndex = 22

$form1.Controls.Add($val5)


$pictureBox1.DataBindings.DefaultDataSourceUpdateMode = 0


$pictureBox1.InitialImage = [System.Drawing.Image]::FromFile('\\sequoia\installs$\hut_logo.jpg')
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 336
$System_Drawing_Point.Y = 261
$pictureBox1.Location = $System_Drawing_Point
$pictureBox1.Name = "pictureBox1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 109
$System_Drawing_Size.Width = 185
$pictureBox1.Size = $System_Drawing_Size
$pictureBox1.TabIndex = 21
$pictureBox1.TabStop = $False

$form1.Controls.Add($pictureBox1)

$pgbar.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 39
$System_Drawing_Point.Y = 149
$pgbar.Location = $System_Drawing_Point
$pgbar.Name = "pgbar"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 28
$System_Drawing_Size.Width = 234
$pgbar.Size = $System_Drawing_Size
$pgbar.TabIndex = 20
$pgbar.Visible = $False

$form1.Controls.Add($pgbar)

$infodisplay.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 12
$System_Drawing_Point.Y = 255
$infodisplay.Location = $System_Drawing_Point
$infodisplay.Name = "infodisplay"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 116
$System_Drawing_Size.Width = 311
$infodisplay.Size = $System_Drawing_Size
$infodisplay.TabIndex = 19

$form1.Controls.Add($infodisplay)

$tuser.AutoCompleteMode = 3
$tuser.AutoCompleteSource = 256
$tuser.DataBindings.DefaultDataSourceUpdateMode = 0
$tuser.FormattingEnabled = $True
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 128
$System_Drawing_Point.Y = 38
$tuser.Location = $System_Drawing_Point
$tuser.Name = "tuser"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 21
$System_Drawing_Size.Width = 145
$tuser.Size = $System_Drawing_Size
$tuser.TabIndex = 1

$form1.Controls.Add($tuser)


$clear.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 413
$System_Drawing_Point.Y = 178
$clear.Location = $System_Drawing_Point
$clear.Name = "clear"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 110
$clear.Size = $System_Drawing_Size
$clear.TabIndex = 16
$clear.Text = "Clear"
$clear.UseVisualStyleBackColor = $True
$clear.Visible = $False
$clear.add_Click($clear_OnClick)

$form1.Controls.Add($clear)

$val4.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 290
$System_Drawing_Point.Y = 119
$val4.Location = $System_Drawing_Point
$val4.Name = "val4"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 18
$System_Drawing_Size.Width = 108
$val4.Size = $System_Drawing_Size
$val4.TabIndex = 15

$form1.Controls.Add($val4)

$val3.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 290
$System_Drawing_Point.Y = 93
$val3.Location = $System_Drawing_Point
$val3.Name = "val3"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 18
$System_Drawing_Size.Width = 108
$val3.Size = $System_Drawing_Size
$val3.TabIndex = 14

$form1.Controls.Add($val3)

$mailboxlist.DataBindings.DefaultDataSourceUpdateMode = 0
$mailboxlist.FormattingEnabled = $True
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 38
$System_Drawing_Point.Y = 194
$mailboxlist.Location = $System_Drawing_Point
$mailboxlist.Name = "mailboxlist"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 43
$System_Drawing_Size.Width = 190
$mailboxlist.Size = $System_Drawing_Size
$mailboxlist.TabIndex = 13

$form1.Controls.Add($mailboxlist)


$bcopy.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 412
$System_Drawing_Point.Y = 149
$bcopy.Location = $System_Drawing_Point
$bcopy.Name = "bcopy"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 110
$bcopy.Size = $System_Drawing_Size
$bcopy.TabIndex = 12
$bcopy.Text = "Start Copy"
$bcopy.UseVisualStyleBackColor = $True
$bcopy.Visible = $False
$bcopy.add_Click($bcopy_OnClick)

$form1.Controls.Add($bcopy)

$val2.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 290
$System_Drawing_Point.Y = 67
$val2.Location = $System_Drawing_Point
$val2.Name = "val2"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 18
$System_Drawing_Size.Width = 108
$val2.Size = $System_Drawing_Size
$val2.TabIndex = 11

$form1.Controls.Add($val2)

$val1.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 290
$System_Drawing_Point.Y = 41
$val1.Location = $System_Drawing_Point
$val1.Name = "val1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 18
$System_Drawing_Size.Width = 108
$val1.Size = $System_Drawing_Size
$val1.TabIndex = 10

$form1.Controls.Add($val1)


$bvalidate.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 412
$System_Drawing_Point.Y = 119
$bvalidate.Location = $System_Drawing_Point
$bvalidate.Name = "bvalidate"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 110
$bvalidate.Size = $System_Drawing_Size
$bvalidate.TabIndex = 9
$bvalidate.Text = "Validate"
$bvalidate.UseVisualStyleBackColor = $True
$bvalidate.add_Click($bvalidate_OnClick)

$form1.Controls.Add($bvalidate)

$label4.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 38
$System_Drawing_Point.Y = 119
$label4.Location = $System_Drawing_Point
$label4.Name = "label4"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 19
$System_Drawing_Size.Width = 84
$label4.Size = $System_Drawing_Size
$label4.TabIndex = 8
$label4.Text = "Lastname"

$form1.Controls.Add($label4)

$label3.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 38
$System_Drawing_Point.Y = 95
$label3.Location = $System_Drawing_Point
$label3.Name = "label3"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 19
$System_Drawing_Size.Width = 84
$label3.Size = $System_Drawing_Size
$label3.TabIndex = 7
$label3.Text = "First Name"

$form1.Controls.Add($label3)

$label2.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 38
$System_Drawing_Point.Y = 69
$label2.Location = $System_Drawing_Point
$label2.Name = "label2"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 19
$System_Drawing_Size.Width = 84
$label2.Size = $System_Drawing_Size
$label2.TabIndex = 6
$label2.Text = "New Username"

$form1.Controls.Add($label2)

$label1.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 38
$System_Drawing_Point.Y = 43
$label1.Location = $System_Drawing_Point
$label1.Name = "label1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 19
$System_Drawing_Size.Width = 84
$label1.Size = $System_Drawing_Size
$label1.TabIndex = 5
$label1.Text = "User to Copy"
$label1.add_Click($handler_label1_Click)

$form1.Controls.Add($label1)

$tlname.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 128
$System_Drawing_Point.Y = 119
$tlname.Location = $System_Drawing_Point
$tlname.Name = "tlname"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 145
$tlname.Size = $System_Drawing_Size
$tlname.TabIndex = 4

$form1.Controls.Add($tlname)

$tfname.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 128
$System_Drawing_Point.Y = 93
$tfname.Location = $System_Drawing_Point
$tfname.Name = "tfname"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 145
$tfname.Size = $System_Drawing_Size
$tfname.TabIndex = 3

$form1.Controls.Add($tfname)

$tnewuser.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 128
$System_Drawing_Point.Y = 67
$tnewuser.Location = $System_Drawing_Point
$tnewuser.Name = "tnewuser"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 145
$tnewuser.Size = $System_Drawing_Size
$tnewuser.TabIndex = 2

$form1.Controls.Add($tnewuser)

#endregion Generated Form Code

#Save the initial state of the form
$InitialFormWindowState = $form1.WindowState
#Init the OnLoad event to correct the initial state of the form
$form1.add_Load($OnLoadForm_StateCorrection)
#Show the Form
$form1.ShowDialog()| Out-Null

} #End Function

#Call the Function
GenerateForm
