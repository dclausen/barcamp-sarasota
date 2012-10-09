class AddDayToTalk < ActiveRecord::Migration
  def self.up
    add_column :talks, :day, :date
  end

  def self.down
  end
end
