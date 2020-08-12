# /etc/puppetlabs/code/environments/production/modules/mymodule/lib/puppet/functions/mymodule/upcase.rb
Puppet::Functions.create_function(:'nagios::expire_exported') do
  dispatch :expire_exported do
    param 'Tuple', :hostslist
  end

  require 'rubygems'
  require 'pg'
  require 'puppet'


  def expire_exported(hostslist)
    hosts = hostslist.flatten
    begin
      conn = PGconn.open(:dbname => 'puppet', :user => 'postgres')
  
      hosts.each do |host|
        Puppet.notice("Expiring resources for host: #{host}")
        conn.exec("SELECT id FROM hosts WHERE name = \'#{host}\'") do |host_id|
          Puppet.notice("host_id: #{host_id}")
          raise "Too many hosts" if host_id.ntuples > 1
          conn.exec("SELECT id FROM param_names WHERE name = 'ensure'") do |param_id|
            Puppet.notice("param_id: #{param_id}")
            Puppet.notice("host_id.values.flatten[0].to_i: #{host_id.values.flatten[0].to_i}")
            conn.exec("SELECT id FROM resources WHERE host_id = #{host_id.values.flatten[0].to_i}") do |results|
  
              resource_ids = []
              results.each do |row|
                resource_ids << Hash[*row.to_a.flatten]
              end
  
              resource_ids.each do |resource|
                conn.exec("UPDATE param_values SET VALUE = 
  ↪'absent' WHERE resource_id = #{resource['id']} AND 
  ↪param_name_id = #{param_id.values}")
              end
            end
          end
        end
      end
    rescue => e
      Puppet.notice(e.message)
    ensure
      conn.close
    end
  end
end
#end