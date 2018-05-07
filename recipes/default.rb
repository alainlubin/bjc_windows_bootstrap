#
# Cookbook:: bjc_windows_bootstrap
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
powershell_script 'Set host file so the instance knows where to find chef-server' do
    code '## Set host file so the instance knows where to find chef-server
    $hosts = "1.2.3.4 chef.automate-demo.com"
    $file = "C:\Windows\System32\drivers\etc\hosts"
    $hosts | Add-Content $file
    
    ## Create first-boot.json
    $firstboot = @{
       "run_list" = @("role[base]")
    }
    Set-Content -Path c:\chef\first-boot.json -Value ($firstboot | ConvertTo-Json -Depth 10)
    
    ## Create client.rb
    $nodeName = "lab-win-{0}" -f (-join ((65..90) + (97..122) | Get-Random -Count 4 | % {[char]$_}))
    
    $clientrb = @"
    chef_server_url        'https://chef.automate-demo.com/organizations/my-org'
    validation_client_name 'validator'
    validation_key         'C:\chef\validator.pem'
    node_name              '{0}'
    "@ -f $nodeName
    
    Set-Content -Path c:\chef\client.rb -Value $clientrb
    
    ## Run Chef
    C:\opscode\chef\bin\chef-client.bat -j C:\chef\first-boot.json'
end

