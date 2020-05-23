# TODO: Write documentation for `Suntime`
module Suntime
  VERSION = "1.0.0"

  class Suntime
    @lng : Float64
    @lat : Float64
    @t : Time

    def initialize(lat : Float64, lng : Float64, t : Time | Nil = nil)
      @t = Time.local
      @t = t unless t.nil?
      @lng = lng
      @lat = lat
    end

    # First, the fractional year (γ) is calculated, in radians
    def fractional_year
      days_in_year = Time.days_in_year(@t.year)
      (2 * Math::PI / days_in_year) * (@t.day_of_year - 1 + ((@t.hour - 12) / 24))
    end

    # From γ, we can estimate the equation of time (in minutes) and the solar declination angle (in radians).
    def eqtime
      γ = fractional_year
      a = 0.001868 * Math.cos(γ)
      b = 0.032077 * Math.sin(γ)
      c = 0.014615 * Math.cos(2 * γ)
      d = 0.040849 * Math.sin(2 * γ)
      229.18 * (0.000075 + a - b - c - d)
    end

    # and the solar declination angle (in radians).
    def decl
      γ = fractional_year
      a = 0.399912 * Math.cos(γ)
      b = 0.070257 * Math.sin(γ)
      c = 0.006758 * Math.cos(2 * γ)
      d = 0.000907 * Math.sin(2 * γ)
      e = 0.002697 * Math.cos(3 * γ)
      f = 0.00148 * Math.sin (3 * γ)
      0.006918 - a + b - c + d - e + f
    end

    # I could make these available if someone wants them
    # commented out, since they don't return proper time objects
    # # Next, the true solar time is calculated in the following two equations
    # # First the time offset is found, in minutes, and then the true solar time, in minutes.
    # def time_offset
    #   # eqtime is in minutes
    #   # longitude is in degrees(positive to the eastof the Prime Meridian)
    #   # t.offset returns seconds, so we divide that with 60 to get minutes
    #   eqtime + (4 * @lng) - (@t.offset/60)
    # end

    # # Don't use this unless you want true solar time
    # def true_solar_time
    #   @t.hour * 60 + @t.minute + @time.second/60 + time_offset
    # end

    # # Uses the true solar time
    # def solar_hour_angle
    #   (true_solar_time / 4) - 180
    # end

    def degrees_to_radians(deg)
      deg * (Math::PI / 180)
    end

    def radians_to_degrees(rad)
      rad * (180 / Math::PI)
    end

    # For the special case of sunrise or sunset,
    # the zenith is set to 90.833 (the approximate correction for atmospheric refraction at sunrise and sunset, and the size of the solar disk)
    # and the hour angle becomes:
    # returns HA in radians
    def solve_for_zenith_ha(sunrise_or_sunset : Symbol)
      zenith = degrees_to_radians 90.833
      lat_in_radians = degrees_to_radians(@lat)
      a = Math.cos(zenith)
      b = Math.cos(lat_in_radians) * Math.cos(decl)
      c = Math.tan(lat_in_radians) * Math.tan(decl)
      ha = Math.acos((a/b) - c).abs
      return (-1 * ha) if sunrise_or_sunset == :sunset
      ha
    end

    # longitude and hour angle are in degrees
    # equation of time is in minutes
    def calculate_time(what_time : Symbol)
      ha = solve_for_zenith_ha(what_time)
      ha_d = radians_to_degrees(ha)
      ha_d = 0 if what_time == :noon
      utc_time_in_seconds = ((720 - (4 * (@lng + ha_d)) - eqtime) * 60).to_i

      total_time_shift = (utc_time_in_seconds + @t.offset).to_i
      new_time = @t.at_beginning_of_day
      new_time.shift(seconds: total_time_shift)
    end

    def sunrise
      calculate_time(:sunrise)
    end

    def solar_noon
      calculate_time(:noon)
    end

    def sunset
      calculate_time(:sunset)
    end
  end
end
