Facter.add('windows_edition_custom') do
    confine :osfamily => :windows
    setcode do
      value = nil
      Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Microsoft\Windows NT\CurrentVersion') do |regkey|
        value = regkey['EditionID']
      end
      value
    end
  end

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