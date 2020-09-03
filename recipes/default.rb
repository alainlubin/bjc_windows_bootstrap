#
# Cookbook:: bjc_windows_bootstrap
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#
# Validator.pem on Workstation C:\opscode\chefdk\embedded\lib\ruby\gems\2.4.0\gems\berkshelf-6.3.1\spec\config
#
template 'c:\waiver.yml' do
    source 'waiver.yml.erb'
end

  powershell_script 'Create config.rb' do
    code <<-EOH
    $nodeName = "Win2016-Ant-{0}" -f (-join ((65..90) + (97..122) | Get-Random -Count 4 | % {[char]$_}))
  
    $clientrb = @"
chef_server_url 'https://#{node['environment']['automate_url']}/organizations/#{node['environment']['chef_org']}'
validation_key 'C:\\Users\\Administrator\\AppData\\Local\\Temp\\kitchen\\cookbooks\\bjc_windows_bootstrap\\recipes\\validator.pem'
node_name '{0}'
policy_group 'development'
policy_name 'base_windows'
ssl_verify_mode :verify_none
chef_license 'accept'
"@ -f $nodeName
  
    Set-Content -Path c:\\chef\\client.rb -Value $clientrb
    C:\\opscode\\chef\\bin\\chef-client.bat
    EOH
    not_if { ::File.exist?('c:\chef\client.rb') }
  end
