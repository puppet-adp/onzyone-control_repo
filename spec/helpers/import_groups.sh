#!/bin/bash

puppet apply --debug <<'PP' | tee /tmp/classification.log
$groups = loadjson('/tmp/groups.json')
$filtered_data = $groups.filter |$g| {
  $g['name'] !~ /^PE / and $g['name'] != 'All Nodes'
}
$filtered_data.each |$g| {
  $rules = $g['name'] ? {
    'All Nodes' => undef,
    default     => $g['rule'],
  }
  node_group { $g['name']:
    ensure               => present,
    parent               => $g['parent'],
    override_environment => $g['environment_trumps'],
    rule                 => $g['rule'],
    variables            => $g['variables'],
    environment          => $g['environment'],
    classes              => $g['classes'],
    data                 => $g['config_data'],
  }
}
PP
