Facter.add('services') do
    confine :osfamily => :windows
    setcode do
      Win32::Service.services
    end
  end