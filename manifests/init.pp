# == Class: ssh
#
# Manage SSH host and users keys and settings.
# Ensure sshd is running everywhere, generate hostkeys on demand on the puppetmaster
# so that rebuilding a host doesn't cause MITM warnings.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'ssh':
#  }
#
# === Authors
#
# Nikolay Kasatkin <nikolay@kasatkin.org>
#
# === Copyright
#
# Copyright 2017 Nikolay Kasatkin, unless otherwise noted.
#

class ssh {

  package { 'openssh-server': ensure => installed }
  ~>
  file { '/etc/ssh/sshd_config':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('ssh/sshd_config.erb')
  }
  ~>
  file { '/etc/ssh/users_ca.pub':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('ssh/users_ca.pub.erb')
  }
  ~>
  file { '/etc/ssh/ssh_known_hosts':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('ssh/ssh_known_hosts.erb')
  }
  ~>
  service { 'ssh':
    ensure => running,
    enable => true,
    hasrestart => true,
  }

  # Generate RSA keys reliably
  $rsa_priv = ssh_keygen({name => "${::fqdn}", type => 'rsa', dir => 'ssh/hostkeys', side => 'host', part => 'private'})
  $rsa_pub  = ssh_keygen({name => "${::fqdn}", type => 'rsa', dir => 'ssh/hostkeys', side => 'host', part => 'public'})
  $rsa_cert = ssh_keygen({name => "${::fqdn}", type => 'rsa', dir => 'ssh/hostkeys', side => 'host', part => 'signed'})

  file { '/etc/ssh/ssh_host_rsa_key':
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $rsa_priv,
    notify => Service['ssh'],
  }

  file { '/etc/ssh/ssh_host_rsa_key.pub':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "ssh-rsa $rsa_pub host_rsa_${::hostname}\n",
    notify => Service['ssh'],
  }

  file { '/etc/ssh/ssh_host_rsa_key-cert.pub':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $rsa_cert,
    notify => Service['ssh'],
  }
}
