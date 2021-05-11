require "./spec_helper"

describe Suntime do
  it "should work for bangalore" do
    bangalore_tz = Time::Location.load("Asia/Kolkata")
    tt = Time.local(2020, 5, 23, 14, 0, 0, location: bangalore_tz)
    t = Suntime::Suntime.new(12.955800, 77.620979, tt)

    a = t.sunrise
    a.year.should eq(2020)
    a.month.should eq(5)
    a.day.should eq(23)
    a.hour.should eq(5)
    a.minute.should eq(52)
    a.second.should eq(30)
    a.offset.should eq(5.5 * 60 * 60)
    a.location.should eq bangalore_tz

    b = t.sunset
    b.year.should eq(2020)
    b.month.should eq(5)
    b.day.should eq(23)
    b.hour.should eq(18)
    b.minute.should eq(39)
    b.second.should eq(26)
    b.offset.should eq(5.5 * 60 * 60)
    b.location.should eq bangalore_tz
  end
end
