def get_records_from_data_bag
  begin
    data_bag_item(new_resource.data_bag, new_resource.zone.gsub('.', '_'))['records']
  rescue Net::HTTPServerException
    nil
  end
end

action :create do
  if records = new_resource.records || get_records_from_data_bag
    template "/etc/maradns/db.#{new_resource.zone}" do
      source 'zone.erb'
      cookbook 'maradns'
      mode '0644'
      variables :records => records
      notifies :restart, 'service[maradns]'
    end
  else
    cookbook_file "/etc/maradns/db.#{new_resource.zone}" do
      source "maradns-zones/#{new_resource.zone}"
      mode '0644'
    end
  end
  node.run_state[:maradns_zones] << new_resource.zone
end

action :delete do
  file "/etc/maradns/db.#{new_resource.zone}" do
    action :delete
    notifies :restart, 'service[maradns]'
  end
end
