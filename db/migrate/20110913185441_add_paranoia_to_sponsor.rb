class AddParanoiaToSponsor < ActiveRecord::Migration
  def self.up
    add_column  :sponsors, :deleted_at, :datetime
  end

  def self.down
  end
end
