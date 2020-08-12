# /etc/puppetlabs/code/environments/production/modules/mymodule/lib/puppet/functions/mymodule/upcase.rb
Puppet::Functions.create_function(:'nagios::expire_exported') do
  dispatch :up do
    param 'Tuple', :some_string
  end

  require 'logger'  


  def up(some_string)
    log = Logger.new(STDOUT)
    log.level = Logger::INFO
    hosts = some_string.flatten
    hosts.each do |host|
      log.info(host.upcase)
    end
  end
end