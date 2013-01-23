actions :create, :delete
default_action :create

attribute :zone,     :kind_of => String, :name_attribute => true
attribute :data_bag, :kind_of => String, :default => 'maradns'
attribute :records,  :kind_of => Array
