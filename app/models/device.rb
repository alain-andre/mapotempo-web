# Copyright © Mapotempo, 2017
#
# This file is part of Mapotempo.
#
# Mapotempo is free software. You can redistribute it and/or
# modify since you respect the terms of the GNU Affero General
# Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Mapotempo is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the Licenses for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Mapotempo. If not, see:
# <http://www.gnu.org/licenses/agpl.html>
#
require 'value_to_boolean'

class Device
  def initialize(customer)
    @customer = customer
  end

  def all
    @all ||= Mapotempo::Application.config.devices.to_h.except(:cache_object)
  end

  def definitions
    @definitions ||= Hash[all.collect{ |key, device|
      [key, device.definition]
    }]
  end

  def enableds
    all.select{ |key, _|
      @customer.devices.key?(key) && ValueToBoolean.value_to_boolean(@customer.devices[key][:enable])
    } || {}
  end

  def enabled_definitions
    definitions.select{ |key, _|
      @customer.devices.key?(key) && ValueToBoolean.value_to_boolean(@customer.devices[key][:enable])
    } || {}
  end

  def configured_definitions
    enabled_definitions.select{ |key, _|
      configured?(key)
    }
  end

  def configured?(key)
    @customer.devices.key?(key) && ValueToBoolean.value_to_boolean(@customer.devices[key][:enable]) && @customer.devices[key].all?{ |_, v|
      !v.blank?
    }
  end

  def available_position?
    @customer.enable_vehicle_position? && !configured_definitions.empty?
  end

  def available_stop_status?
    # FIXME: add new key to devices definition to check availability for stop status (and vehicle position)
    # Mapotempo::Application.config.devices[service_name]

    has_stop_status = false
    Mapotempo::Application.config.devices.each_pair.map { |key, device|
      has_stop_status ||= device.respond_to?(:fetch_stops) && @customer.device.configured?(key)
    }
    has_stop_status
  end

  # @planning.customer.device.configured?(:tomtom) && @planning.routes.any?{ |r| r.vehicle_usage && r.vehicle_usage.vehicle.devices[:tomtom_id] }
end
