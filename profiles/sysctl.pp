# This is a simple profile class to manage sysctl.

class proflies::sysctl
  (
    Hash $sysctl_values
  )
  {

    file{ '/etc/sysctl.conf':
      ensure  => file,
      mode    => 0600,
      owner   => root,
      group   => root,
      content => epp('etc/sysctl.conf.epp', {'sysctl_values' => "${sysctl_values}"}),
    }

  }