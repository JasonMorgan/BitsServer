configuration default {
  param (
    $ComputerName = 'localhost'
  )
  Import-DscResource -Module BitsServer
  node $ComputerName {
    BitsServer 'alt_bits' {
      path = 'c:\package_mgr\bits'
      webSiteName = 'alt_bits'
      port = 81 
      protocol = 'http'
    }
  }
}