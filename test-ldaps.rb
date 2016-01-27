$LOAD_PATH << './ruby-net-ldap-fix1/lib'
require 'net/ldap'
require 'timeout'
require 'optparse'
require 'io/console'

def try_bind(conn, timeout=10)
  begin
    Timeout::timeout(timeout){
      begin
        if conn.bind
          puts '  connection and bind succeeded'
          return true
        else
          puts '  connection succeeded but bind failed'
          return false
        end
      rescue Net::LDAP::Error => e
        puts '  connection or bind failed due to exception'
        warn "  Exception: #{e}"
        return false
      end
    }
  rescue Timeout::Error
      warn '  connection failed: timeout'
      return false
  end
end

# test funciton
def ldaps_tls_test(hosts, base, login, pass, ca_file)
  if hosts.empty? ||
     hosts.length < 1 ||
     base.empty? ||
     login.empty? ||
     pass.empty? ||
     ca_file.empty?
     then
     warn 'Unable to test'
   end

  puts
  puts 'test minimal config secure ldaps (single host)'
  conn = Net::LDAP.new :host => hosts[0][0],
                       :port => 636,
                       :base => base,
                       :encryption => { :method => :simple_tls },
                       :auth => { :username => login,
                                  :password => pass,
                                  :method => :simple }
  try_bind(conn)

  puts
  puts 'test minimal config secure ldaps (multiple hosts)'
  conn = Net::LDAP.new :hosts => hosts,
                       :base => base,
                       :encryption => { :method => :simple_tls },
                       :auth => { :username => login,
                                  :password => pass,
                                  :method => :simple }
  try_bind(conn)

  puts
  puts 'test explicit config secure ldaps (single host)'
  conn = Net::LDAP.new :host => hosts[0][0],
                       :port => 636,
                       :base => base,
                       :encryption => { :method => :simple_tls,
                                        :tls_options => { :verify_mode => OpenSSL::SSL::VERIFY_PEER,
                                                          :ca_file => ca_file } },
                       :auth => { :username => login,
                                  :password => pass,
                                  :method => :simple }
  try_bind(conn)

  puts
  puts 'test explicit config secure ldaps (multiple host)'
  conn = Net::LDAP.new :hosts => hosts,
                       :base => base,
                       :encryption => { :method => :simple_tls,
                                        :tls_options => { :verify_mode => OpenSSL::SSL::VERIFY_PEER,
                                                          :ca_file => ca_file } },
                       :auth => { :username => login,
                                  :password => pass,
                                  :method => :simple }
  try_bind(conn)

  puts
  puts 'test disable certifcate validation for secure ldaps (single host)'
  conn = Net::LDAP.new :host => hosts[0][0],
                       :port => 636,
                       :base => base,
                       :encryption => { :method => :simple_tls,
                                        :tls_options => { :verify_mode => OpenSSL::SSL::VERIFY_NONE } },
                       :auth => { :username => login,
                                  :password => pass,
                                  :method => :simple }
  try_bind(conn)

  puts
  puts 'test disable certifcate validation for secure ldaps (multiple hosts)'
  conn = Net::LDAP.new :hosts => hosts,
                       :base => base,
                       :encryption => { :method => :simple_tls,
                                        :tls_options => { :verify_mode => OpenSSL::SSL::VERIFY_NONE } },
                       :auth => { :username => login,
                                  :password => pass,
                                  :method => :simple }
  try_bind(conn)

  puts
  puts 'test plain insecure ldap (single host)'
  #force using 389 and simply test the first host in the array of hosts
  conn = Net::LDAP.new :host => hosts[0][0],
                       :port => 389,
                       :base => base,
                       :auth => { :username => login,
                                  :password => pass,
                                  :method => :simple }
  try_bind(conn)

  puts
  puts 'test plain insecure ldap (multiple hosts)'
  #force using 389
  conn = Net::LDAP.new :hosts => hosts.map { |p| p = [p[0],389] },
                       :base => base,
                       :auth => { :username => login,
                                  :password => pass,
                                  :method => :simple }
  try_bind(conn)

end

options = {}
ARGV.options do |opts|
  opts.banner = "Usage: test-ldap.rb [options]"
  opts.separator ""
  opts.separator "Example:"
  opts.separator "  ruby test-ldap.rb -s ldap1.local.net,ldap2.local.net -b DC=local,DC=net -u 'LOCAL\\Administrator' -c ca_bundle.pem"
  opts.separator ""
  opts.separator "Specific options:"
  opts.on('-s', '--servers=val', 'Array of hosts',
          'in FQDN1,FQDN2,... format', Array) { |val| options[:hosts] = val}
  opts.on('-b', '--base=val', 'LDAP base', String) { |val| options[:base] = val }
  opts.on('-u', '--user=val', 'Username', String) { |val| options[:username] = val }
  opts.on('-p', '--pass=val', 'Password', String) { |val| options[:password] = val }
  opts.on('-c', '--cafile=val', 'Certficate authority chain file', String) { |val| options[:cafile] = val }
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit(0)
  end
  opts.parse!
  if options[:password].nil?
      print "Enter Password: "
      options[:password] = STDIN.noecho(&:gets).chomp
      puts
  end
  if options[:hosts].nil? ||
     options[:base].nil? ||
     options[:username].nil? ||
     options[:password].nil? ||
     options[:cafile].nil?
     then
    puts opts
    raise OptionParser::MissingArgument
  else
    # test with multiple hosts
    hosts = options[:hosts].map { |s| s = [s,636] }
    ldaps_tls_test(hosts,options[:base],options[:username],options[:password],options[:cafile])
  end
end
