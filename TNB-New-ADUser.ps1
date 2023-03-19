<#
The purpose of this script is to create AD user using cmdlet New-ADUser using double splatting for normal attributes and custom attributes
This script is only applicable for TNB environment
Should you need to use for other customers, this script has to be customized to cater for other customers environment

You may create your own function using this script, if you have the time

Created by Leewx
20230319
#>

#create variable for csv path
$ADUserList = Import-Csv -Path "C:\Temp\MRIS Development User List test null.csv" 

foreach ($user in $ADUserList)
    {
       # Hash Table splatting for standard attributes
       $ADUserSplat = @{
        
            SamAccountName          = $user.UserName                    
            UserPrincipalName       = "$($user.UserName)@tnbtest.my"        
            Name                    = $user.FullName
            GivenName               = $user.GivenName
            Surname                 = $user.Surname
            DisplayName             = $user.FullName
            Division                = $user.Division
            Department              = $user.Department
            Title                   = $user.JobTitle
            OfficePhone             = $user.OfficeNumber
            EmailAddress            = $user.Email
            MobilePhone             = $user.PhoneNumber
            State                   = $user.StateNames
            ChangePasswordAtLogon   = $True
            PasswordNeverExpires    = $False
            AccountPassword         = (ConvertTo-SecureString "P@ssw0rd12131415" -AsPlainText -Force)
            
        }
            
        # Hash Table splatting for custom attributes 
        $OtherAttrib         = @{
                                        
        Nric            = $user.Nric
        Grade           = $user.Grade
        RoleNames       = $user.RoleNames
        ZoneNames       = $user.ZoneNames
        StateNames      = $user.StateNames
        StationNames    = $user.StationNames
        SecurityStamp   = $user.SecurityStamp   
                                        
        }
                 
    
    # check on "IsActive" property
    # if equals "1", user account is enabled
    if ($user.IsActive -eq '1')
        {
            $ADUserSplat.Enabled = $true
        }
    
    # check on "Nric" property
    # if "Nric" value exists, use the Nric value
    # else, "<not set"
    # same goes with all the properties below
    if ($user.Nric)
        {
            $OtherAttrib['Nric']=$user.Nric
        }
    else {
            $OtherAttrib['Nric']="<not set>" 
    }

    if ($user.Grade)
        {
            $OtherAttrib['Grade']=$user.Grade
        }
    else {
            $OtherAttrib['Grade']="<not set>"
    }

    if($user.RoleNames) 
        {
            $OtherAttrib['RoleNames']=$user.RoleNames
        }  
    else {
        $OtherAttrib['RoleNames']="<not set>"
    }

    if ($user.ZoneNames)
        {
            $OtherAttrib['ZoneNames']=$user.ZoneNames
        }
    else {
            $OtherAttrib['ZoneNames']="<not set>"
    }

    if ($user.StateNames)
        {
            $OtherAttrib['StateNames']=$user.StateNames
        }
    else {
            $OtherAttrib['StateNames']="<not set>"
    }

    if ($user.StationNames)
    {
        $OtherAttrib['StationNames']=$user.StationNames
    }
    else {
        $OtherAttrib['StationNames']="<not set>"
    }

    if ($user.SecurityStamp)
    {
        $OtherAttrib['SecurityStamp']=$user.SecurityStamp
    }
    else {
        $OtherAttrib['SecurityStamp']="<not set>"
    }
       
    # try to create user with double splatting info above
    Try
    {
        New-ADUser @ADUserSplat -otherattributes $OtherAttrib
    }
    Catch 
    {
        Write-Warning "error creating user $($User).FullName: $($_.Exception.Message)"
    }
    

}

