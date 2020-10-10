Facter.add('services') do
    confine :osfamily => :windows
    setcode do
      value = nil
      value = Array.new 
      Win32::Service.services do |service|
        value << service
      end
      value
    end
  end