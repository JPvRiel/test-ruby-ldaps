# test-ruby-ldaps

This is a test script for [ruby-net-ldap](https://github.com/ruby-ldap/ruby-net-ldap) LDAPS certificate and hostname (FQDN) validation with SSL/TLS and X509. It was written to test issue [#258](https://github.com/ruby-ldap/ruby-net-ldap/issues/258)) and pull request [#259](https://github.com/ruby-ldap/ruby-net-ldap/pull/259)

A future ideal would be to re-factor and merge this with the [test suite](https://github.com/ruby-ldap/ruby-net-ldap/tree/master/test) already used by the project.

Example use:
```
ruby test-ldap.rb -s ldap1.local.net,ldap2.local.net -b DC=local,DC=net -u 'LOCAL\\Administrator' -c ca_bundle.pem
```

Use `ruby test-ldap.rb -h` for help
