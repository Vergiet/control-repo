# /etc/puppetlabs/code/environments/production/modules/mymodule/lib/puppet/functions/mymodule/upcase.rb
Puppet::Functions.create_function(:'nagios::upcase') do
  dispatch :up do
    param 'String', :some_string
  end

  require 'logger'  


  def up(some_string)
    log = Logger.new(STDOUT)
    log.level = Logger::INFO
    log.info(some_string.upcase)
  end
end