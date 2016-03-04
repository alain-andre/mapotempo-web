# Copyright © Mapotempo, 2015-2016
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
class Alyacom < DeviceBase

  def initialize
    super
    @api_url = 'http://partners.alyacom.fr/ws'
  end

  def send_route options
    @route = options[:route]
    store = route.vehicle_usage.default_store_start
    staff = {
      id: route.vehicle_usage.vehicle.name,
      name: route.vehicle_usage.vehicle.name,
      street: store && store.street,
      postalcode: store && store.postalcode,
      city: store && store.city
    }
    position = route.vehicle_usage.default_store_start
    waypoints = route.stops.select(&:active).collect{ |stop|
      position = stop if stop.position?
      if position.nil? || position.lat.nil? || position.lng.nil? || stop.time.nil?
        next
      end
      {
        user: {
          id: stop.base_id,
          name: stop.name,
          street: position.street,
          postalcode: position.postalcode,
          city: position.city,
          detail: stop.detail,
          comment: [
            stop.ref,
            stop.open || stop.close ? (stop.open ? stop.open.strftime('%H:%M') : '') + '-' + (stop.close ? stop.close.strftime('%H:%M') : '') : nil,
            stop.comment,
          ].compact.join(' ').strip
        },
        planning: {
          id: planning_date.strftime('%y%m%d') + '_' + stop.base_id.to_s,
          staff_id: route.vehicle_usage.vehicle.name,
          destination_id: stop.base_id,
          comment: [
            stop.is_a?(StopVisit) ? (route.planning.customer.enable_orders ? (stop.order ? stop.order.products.collect(&:code).join(',') : '') : stop.visit.quantity && stop.visit.quantity > 1 ? "x#{stop.visit.quantity}" : nil) : nil,
          ].compact.join(' ').strip,
          start: planning_date + stop.time.seconds_since_midnight.seconds,
          end: planning_date + (stop.time.seconds_since_midnight + stop.duration).seconds
        }
      }
    }.compact
    createJobRoute planning_date, staff, waypoints
  end

  private

  def createJobRoute planning_date, staff, waypoints
    update_staffs [staff]
    update_users waypoints.collect{ |w| w[:user] }

    get = Hash[get('planning', fromDate: planning_date.to_i * 1000, idStaff: staff[:id]).select{ |s| s.key?('idExt') }.map{ |s| [s['idExt'], s] }]

    plannings = waypoints.collect{ |waypoint|
      planning = waypoint[:planning]
      get.delete(planning[:id])

      {
        idExt: planning[:id],
        idStaff: planning[:staff_id],
        idUser: planning[:destination_id],
        comment: planning[:comment] != '' ? planning[:comment] : nil,
        start: planning[:start].strftime('%d/%m/%Y %H:%M'),
        end: planning[:end].strftime('%d/%m/%Y %H:%M')
      }
    }

    plannings += get.select{ |_k, planning|
      Date.parse(planning['start']) == planning_date
    }.collect{ |_k, planning|
      planning['deleted'] = true
      planning
    }

    post 'planning', plannings
  end

  def update_staffs staffs
    get = Hash[get('staff').select{ |s| s.key?('idExt') }.map{ |s| [s['idExt'], s] }]

    missing = staffs.select{ |s|
      !get.key?(s[:id])
    }.collect{ |s|
      {
        idExt: s[:id],
        firstName: '',
        lastName: s[:name],
        address: s[:street],
        postalCode: s[:postalcode],
        city: s[:city],
      }
    }

    if !missing.empty?
      post 'staff', missing
    end
  end

  def update_users users
    get = Hash[get('users').select{ |s| s.key?('idExt') }.map{ |s| [s['idExt'], s] }]

    missing = users.select{ |s|
      !get.key?(s[:id])
    }.collect{ |s|
      {
        idExt: s[:id],
        firstName: '',
        lastName: s[:name],
        address: s[:street],
        postalCode: s[:postalcode],
        city: s[:city],
        accessInfo: s[:detail],
        comment: s[:comment],
      }
    }

    if !missing.empty?
      post 'users', missing
    end
  end

  def get object, params={}
    get_raw "#{api_url}/#{customer.alyacom_association}/#{object}", {enc: :json, apiKey: api_key}.merge(params)
  end

  def get_raw url, params
    data = []
    next_ = nil
    begin
      begin
        response = RestClient.get(next_ || url, next_ ? nil : {params: params})
      rescue => e
        Rails.logger.info next_ || url
        begin
          # Parse malformed Json, replace key by string, simple quote by double quote
          response = JSON.parse(e.response.gsub('\'', '"').gsub(/([\'\"])?([a-zA-Z0-9_]+)([\'\"])?:/, '"\2":'))
        rescue
          Rails.logger.info e
          raise e
        end
        if !response['message'].blank?
          Rails.logger.info response['message']
          raise DeviceServiceError.new("Alyacom: %s" % [ response['message'] ])
        else
          Rails.logger.info e
          raise e
        end
      end
      response = JSON.parse(response)
      if response['data'] && !response['data'][-1]['deleted']
        data += response['data']
        next_ = response['next']
      else
        next_ = nil
      end
    end while !next_.nil?
    data
  end

  def post object, data
    RestClient.post "#{api_url}/#{customer.alyacom_association}/#{object}", data.to_json, content_type: :json, params: {enc: :json, apiKey: api_key}
  rescue => e
    Rails.logger.info e.response
    raise e
  end

end
