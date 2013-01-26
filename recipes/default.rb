#
# Cookbook Name:: maradns
# Recipe:: default
#
# Copyright 2009, Chef Software, Inc.
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

package 'maradns' do
  action :upgrade
end.run_action(:install)

service 'maradns' do
  action :enable
  supports(
    restart: true,
    status: true
  )
end

service 'zoneserver' do
  action node[:maradns][:enable_tcp_zoneserver] ? :disable : :enable
  supports restart: true
end

node.run_state[:maradns_zones] = []

template '/etc/maradns/mararc' do
  source 'mararc.erb'
  mode 0644
  owner 'root'
  group 'root'
  variables(
    :bind_addresses => node[:maradns][:bind_addresses] || [node[:ipaddress]],
    :uid => `getent passwd maradns | cut -d: -f3`.chomp,
    :gid => `getent group maradns | cut -d: -f3`.chomp
  )
  notifies :restart, 'service[maradns]'
end

# Be sure to create a data bag or cookbook file for your domain
maradns_zone node[:domain]
