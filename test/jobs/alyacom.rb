require 'alyacom_api'

class AlyacomTest < ActionController::TestCase
  setup do
    def AlyacomApi.createJobRoute(association_id, staff, waypoints)
    end

    @route = routes(:route_one)
  end

  test "should export route" do
    Alyacom.export_route(@route)
  end
end
