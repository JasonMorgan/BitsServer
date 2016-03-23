enum actions {
  Set
  Test
}

function features {
  param(
    [actions]$action
  )
  $features = 'Web-Server','BITS','BITS-IIS-Ext'
  switch ($action) {
    Test {
      Write-Verbose 'Checking for required features'
      Get-WindowsFeature -Name $features | foreach {
        if (! $_.installed) {
          return $false
        }
        return $true
      }
    }
    Set {
      Write-Verbose 'Installing required features'
      Add-WindowsFeature -Name $features
    }
  }
}

function bitsuploads {
  param (
    [actions]$action,
    $Website
  )
  $site = Get-Website -Name $Website
  switch ($action) {
    Test {
      Write-Verbose "Checking if Bits Uploads are Enabled"
      return (New-Object System.DirectoryServices.DirectoryEntry("IIS://localhost/W3SVC/$($site.id)/root")).BITSUploadEnabled
    }
    Set {
      Write-Verbose 'enabling Bits Uploads'
      (New-Object System.DirectoryServices.DirectoryEntry("IIS://localhost/W3SVC/$($site.id)/root")).EnableBitsUploads()
    }
  }
}

function website {
  param (
    [actions]$action,
    $Website,
    $port,
    $path,
    $protocol
  )
  switch ($action) {
    Test {
      Write-Verbose "Checking for website $Website"
      if (Get-Website -Name $Website) {
        return $true
      }
      return $false
    }
    Set {
      Write-Verbose "Creating website $Website"
      switch ($protocol) {
        http {
          $null = New-Website -Name $Website -Port $port -PhysicalPath $path
        }
        https {
          $null = New-Website -Name $Website -Port $port -PhysicalPath $path -Ssl
        }
      }
    }
  }
}

function permissions {
  param (
    [actions]$action,
    $path
  )
  switch ($action) {
    Test {
      Write-Verbose "testing the acl on $path"
      $Acl = Get-Acl -Path $path
      try {
        $value = ($Acl.Access |where {$_.IdentityReference -match 'NT AUTHORITY\\IUSR'}).FileSystemRights -match 'Modify'
        return $value
      }
      catch {
        return $false
      }
    }
    Set {
      Write-Verbose "Setting the acl on $path"
      $Acl = Get-Acl $path
      $Ar = New-Object  system.security.accesscontrol.filesystemaccessrule("IUSR","Modify","Allow")
      $Acl.SetAccessRule($Ar)
      Set-Acl "C:\Bits" $Acl
    }
  }
}

function directory {
  param (
    [actions]$action,
    $path
  )
  switch ($action) {
    Test {
      Write-Verbose "looking for directory @ $path"
      return (Test-Path $Path)
    }
    Set {
      Write-Verbose "Creating directory @ $path"
      $Null = New-Item -Itemtype Directory -Path $path -Force
    }
  }
}

function mimeTypes {
  param (
    [actions]$action
  )
  switch ($action) {
    Test {
      $rules = get-webconfigurationproperty //staticContent -name collection
      if ($rules.Where{$_.fileExtension -match '\.\*'}) {
        return $true
      }
      return $false
    }
    Set {
      $null = add-webconfigurationproperty //staticContent -name collection -value @{fileExtension='.otf'; mimeType='application/octet-stream'} 
    }
  }
}