class Talk < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :room
  
  named_scope :by_day,   :order => "day"
  named_scope :by_time,   :order => "start_time"

  named_scope :for_logical_day, lambda { { :conditions => ["day = ?", self.logical_day], :order => "start_time" } }

  #Note: PostgreSQL (Heroku) uses date_part instead of sqlite's time function
  if ENV['RAILS_ENV'] == 'production'
    named_scope :morning,   :conditions => [ "date_part('hour', start_time) <  12" ]
    named_scope :afternoon, :conditions => [ "date_part('hour', start_time) >= 12" ]
  else
    named_scope :morning,   :conditions => [ "time(start_time) <  '12:00'" ]
    named_scope :afternoon, :conditions => [ "time(start_time) >= '12:00' " ]
  end

  # Find the current and next talk
  named_scope :active,    lambda { |*args| named_scope_active( *args ) }
  named_scope :next,      lambda { |*args| named_scope_next( *args ) }

  validates_presence_of :day, :name, :room_id, :start_time, :end_time
  validate :timecheck

  #return the best conference day for today's date
  def self.logical_day
    days = (Talk.count > 0 ? Talk.all(:select => 'distinct day').map { |t| t.day } : [Date.today])
    today = Date.today

    #three conditions for returning 
    #1. today is earlier than the first day (return first)
    #2. today is one of the conference days (return that day)
    #3. today is after the last day (return last)
    return days.first if today < days.first
    days.each { |d| return d if d == today }
    days.last
  end

  #to make talk.room.name easily accessible to to_json calls
  def room_name
    room.name
  end

  def timecheck
    min = Date.new(2000,1,1)
    if start_time && end_time
      errors.add_to_base("Please set times") if start_time == min || end_time == min
      errors.add_to_base("Please set end time after start time") if end_time <= start_time
    end
  end

  def speakable_description
    "#{name}, by #{who}. . . From #{start_time_string} until #{end_time_string}"
  end
 
  def start_time_string
    start_time ? start_time.strftime("%I:%M") : "unknown"
  end

  def end_time_string
    end_time ? end_time.strftime("%I:%M") : "unknown"
  end

  private
    def self.named_scope_active( *args )
      time = args.first || Time.now
      { :conditions => [ "time(start_time) <= time(?) and time(end_time) >= time(?)", time, time ] }
    end
    
    def self.named_scope_next( *args )
      time = args.first || Time.now
      { :conditions => [ "time(start_time) >= time(?)", time ], :order => "start_time", :limit => 1 }
    end
end
