Import-Module $PSScriptRoot\tools.psm1

enum protocols {
  http
  https
}

[DscResource()]
class cBitsServer {
  # Properties
  # Path for Bits Transfers directory
  [DscProperty(Key)]
  [string] $path
  
  # Port Number
  [DscProperty()]
  [int] $port = 80
  
  # WebSite Name
  [DscProperty()]
  [string] $webSiteName = 'Bits'
  
  # Protocol
  [DscProperty()]
  [protocols] $protocol = 'http'
  
  # Gets the resource's current state.
  [cBitsServer] Get() {
    return $this
  }
  
  # Sets the desired state of the resource.
  [void] Set() {
    if (! (features -action Test)) {
      features -action Set
    }
    if (! (directory -path $this.path -action Test)) {
      directory -path $this.path -action Set
    }
    if (! (permissions -action Test -path $this.path)) {
      permissions -action Set -path $this.path
    }
    if (! (website -action Test -path $this.path -website $this.webSiteName -port $this.port -protocol $this.protocol)) {
      website -action Set -path $this.path -website $this.webSiteName -port $this.port -protocol $this.protocol
    }
    if (! (mimeTypes -action Test)) {
      mimeTypes -action Set
    }
    if (! (bitsuploads -action Test -website $this.webSiteName)) {
      bitsuploads -action Set -website $this.webSiteName
    }
  }
  
  # Tests if the resource is in the desired state.
  [bool] Test() {
    if (! (features -action Test)) {
      return $false
    }
    if (! (directory -path $this.path -action Test)) {
      return $false
    }
    if (! (permissions -action Test -path $this.path)) {
      return $false
    }
    if (! (website -action Test -path $this.path -website $this.webSiteName -port $this.port -protocol $this.protocol)) {
      return $false
    }
    if (! (mimeTypes -action Test)) {
      return $false
    }
    if (! (bitsuploads -action Test -website $this.webSiteName)) {
      return $false
    }
    return $true
  }
}