# /etc/puppetlabs/code/environments/production/modules/mymodule/lib/puppet/functions/mymodule/upcase.rb
Puppet::Functions.create_function(:'nagios::upcase') do
    dispatch :up do
      param 'String', :some_string
    end
  
    def up(some_string)
      some_string.upcase
    end
  end