require "./spec_helper"

describe Suntime do
  it "should return correct timestamp for example" do
    lat = 40.9
    lng = -74.3

    l = Time::Location.load("America/New_York")
    t = Suntime::Suntime.new(lat, lng, Time.local(1990, 6, 25, 0, 0, 0, location: l))

    # TODO: These are stupid tests, figure out how to use epsilon for float tests in Crystal
    t.day_of_year.should eq(176)
    t.approx_time.should be_close(176.45, 0.01)
    t.approx_time(false).should be_close(176.95, 0.01)
    t.sun_mean_anomaly(176.456).should be_close(170.62, 0.01)
    t.sun_true_longitude(170.62).should be_close(93.56, 0.01)
    t.sun_right_ascension(93.56).should be_close(6.258, 0.01)
    t.sun_local_hour_angle(93.56).should be_close(-0.395, 0.01)
    t.calculate_h(-0.3957).should be_close(16.446, 0.01)
    t.local_mean_time(16.446, 6.258, 176.456).should be_close(5.441, 0.01)

    a = t.sunrise
    a.year.should eq(1990)
    a.month.should eq(6)
    a.day.should eq(25)
    a.hour.should eq(5)
    a.minute.should eq(26)
    a.second.should eq(29)
    a.offset.should eq(-4 * 60 * 60)
    a.location.should eq l
  end

  it "should work for bangalore" do
    # +5.5
    bangalore_tz = Time::Location.load("Asia/Kolkata")
    t = Suntime::Suntime.new(12.955800, 77.620979, Time.local(2020, 5, 23, 0, 0, 0, location: bangalore_tz))
    a = t.sunrise
    a.year.should eq(2020)
    a.month.should eq(5)
    a.day.should eq(23)
    a.hour.should eq(5)
    a.minute.should eq(52)
    a.second.should eq(41)
    a.offset.should eq(5.5 * 60 * 60)
    a.location.should eq bangalore_tz

    b = t.sunset
    b.year.should eq(2020)
    b.month.should eq(5)
    b.day.should eq(23)
    b.hour.should eq(18)
    b.minute.should eq(40)
    b.second.should eq(0)
    b.offset.should eq(5.5 * 60 * 60)
    b.location.should eq bangalore_tz
  end
end
