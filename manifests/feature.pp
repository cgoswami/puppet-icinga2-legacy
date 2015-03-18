# == Define: icinga2::feature
#
# Provide the actual feature resources
#
define icinga2::feature (
  $content  = undef,
  $template = "icinga2/feature/${name}.conf.erb",
) {

  if ! defined(Class['icinga2']) {
    fail('You must include the icinga2 base class before using any icinga2 defined resources')
  }

  if $content {
    $content_rel = $content
  }
  elsif $template {
    $content_rel = template($template)
  }
  else {
    $content_rel = undef
  }

  File {
    owner => $icinga2::params::config_owner,
    group => $icinga2::params::config_group,
    mode  => $icinga2::params::config_mode,
  }

  Class['icinga2::config'] ->
  file { "icinga2 feature ${name}":
    ensure  => file,
    path    => "/etc/icinga2/features-available/${name}.conf",
    content => $content_rel,
  } ->
  file { "icinga2 feature ${name} enabled":
    ensure => link,
    path   => "/etc/icinga2/features-enabled/${name}.conf",
    target => "../feature-available/${name}.conf",
  }

  if $::icinga2::manage_service {
    File["icinga2 feature ${name}"] ~> Class['icinga2::service']
  }

}