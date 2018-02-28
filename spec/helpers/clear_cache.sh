#!/bin/bash

PATH=/opt/puppetlabs/puppet/bin:$PATH

rm -rf $(puppet config print environmentpath)/production/.resource_types

curl -s -I -X DELETE \
--cert   $(puppet config print hostcert) \
--key    $(puppet config print hostprivkey) \
--cacert $(puppet config print localcacert) \
https://$(puppet config print server):8140/puppet-admin-api/v1/environment-cache?environment=production
