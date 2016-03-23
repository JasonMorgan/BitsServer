configuration default {
  param (
    $ComputerName = 'localhost'
  )
  Import-DscResource -Module cBitsServer
  node $ComputerName {
    cBitsServer 'bits' {
      path = 'c:\bits'
      webSiteName = 'bits'
      port = 81 
      protocol = 'http'
    }
  }
}