class AddDeletedAtToTalks < ActiveRecord::Migration
  def self.up
    add_column :talks, :deleted_at, :datetime
  end

  def self.down
  end
end
