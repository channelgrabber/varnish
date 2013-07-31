# Cookbook Name:: varnish
# Recipe:: default
# Author:: Joe Williams <joe@joetify.com>
# Contributor:: Patrick Connolly <patrick@myplanetdigital.com>
#
# Copyright 2008-2009, Joe Williams
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package "varnish"

template "#{node['varnish']['dir']}/#{node['varnish']['vcl_conf']}" do
  source node['varnish']['vcl_source']
  if node['varnish']['vcl_cookbook']
    cookbook node['varnish']['vcl_cookbook']
  end
  owner "root"
  group "root"
  mode 0644
  notifies :reload, "service[varnish]"
end

template node['varnish']['default'] do
  source "custom-default.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, "service[varnish]"
end

directory "#{node['varnish']['error_page_dir']}" do
  owner "root"
  group "root"
  mode 0755
  action :create
end

cookbook_file "#{node['varnish']['error_page_dir']}/#{node['varnish']['error_page']}" do
    source "50x.html"
    owner "root"
    group "root"
    mode 0644
    action :create
end

cookbook_file "#{node['varnish']['error_page_dir']}/#{node['varnish']['404_page']}" do
    source "404.html"
    owner "root"
    group "root"
    mode 0644
    action :create
end

if node['hetzner']
    template "#{node['hetzner']['failover_script']}" do
        source "heartbeat.erb"
        owner "root"
        group "root"
        mode 0644
        action :create
    end
    cron "heartbeat" do
      minute "*"
      hour "*"
      day "*"
      month "*"
      weekday "*"
      command "php #{node['hetzner']['failover_script']}"
      action :create
    end
end

service "varnish" do
  supports :restart => true, :reload => true
  action [ :enable, :start ]
end

service "varnishlog" do
  supports :restart => true, :reload => true
  action [ :enable, :start ]
end
