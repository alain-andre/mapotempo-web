require 'test_helper'

class MasternautTest < ActionController::TestCase

  require Rails.root.join("test/lib/devices/masternaut_base")
  include MasternautBase

  setup do
    @customer = add_masternaut_credentials customers(:customer_one)
    @service = Mapotempo::Application.config.devices.masternaut
    @service.set_params customer: @customer
    @service.fetch_wsdl
  end

  test 'send route' do
    with_stubs [:poi_wsdl, :poi, :job_wsdl, :job] do
      set_route
      assert_nothing_raised do
        @service.send_route route: @route
      end
    end
  end

end
