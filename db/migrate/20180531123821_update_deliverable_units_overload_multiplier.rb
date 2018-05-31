class UpdateDeliverableUnitsOverloadMultiplier < ActiveRecord::Migration
  def self.up
    DeliverableUnit.update_all(optimization_overload_multiplier: nil)
  end
end
