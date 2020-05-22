# TODO: Write documentation for `Suntime`
module Suntime
  VERSION = "0.1.0"

  # Currently based on http://www.edwilliams.org/sunrise_sunset_algorithm.htm
  # TODO: Switch to https://www.esrl.noaa.gov/gmd/grad/solcalc/solareqns.PDF
  # to use radians directly
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

    def calculate_sun_time(sunrise = true)
      t = approx_time(sunrise)
      m = sun_mean_anomaly(t)
      l = sun_true_longitude(m)
      ra = sun_right_ascension(l)
      cosH = sun_local_hour_angle(l)
      h = calculate_h(cosH, sunrise)
      fractional_time_to_proper_time local_mean_time(h, ra, t)
    end

    def fractional_time_to_proper_time(t_in_fractional_hours)
      minutes = t_in_fractional_hours * 60
      seconds = (minutes * 60).to_i
      new_time = @t.at_beginning_of_day
      new_time.shift(seconds: seconds)
    end

    def sunrise
      calculate_sun_time(true)
    end

    def sunset
      calculate_sun_time(false)
    end

    # 1. first calculate the day of the year
    def day_of_year
      n1 = (275 * @t.month / 9).floor
      n2 = ((@t.month + 9) / 12).floor
      n3 = (1 + ((@t.year - 4 * (@t.year / 4).floor + 2) / 3).floor)
      return n1 - (n2 * n3) + @t.day - 30
    end

    # 2. convert the longitude to hour value and calculate an approximate time
    # pass false for sunset
    def approx_time(sunrise = true)
      lngHour = @lng / 15
      if sunrise
        day_of_year + ((6 - lngHour) / 24)
      else
        day_of_year + ((18 - lngHour) / 24)
      end
    end

    # 3. calculate the Sun's mean anomaly
    def sun_mean_anomaly(t : Float64) : Float64
      (0.9856 * t) - 3.289
    end

    def put_in_range(number, lower, upper, adjuster)
      if number > upper
        number -= adjuster
      elsif number < lower
        number += adjuster
      else
        number
      end
    end

    # 4. calculate the Sun's true longitude
    def sun_true_longitude(m)
      m_in_radians = (Math::PI/180) * m
      l = m + (1.916 * Math.sin(m_in_radians)) + (0.020 * Math.sin(2 * m_in_radians)) + 282.634

      # NOTE: L potentially needs to be adjusted into the range [0,360) by adding/subtracting 360
      put_in_range(l, 0, 360, 360)
    end

    # 5. calculate the Sun's right ascension
    def sun_right_ascension(l)
      l_in_radians = (Math::PI/180) * l
      ra = (180/Math::PI) * Math.atan(0.91764 * Math.tan(l_in_radians))

      # 5b. right ascension value needs to be in the same quadrant as L
      l_quadrant = (l/90).floor * 90
      ra_quadrant = (ra/90).floor * 90
      ra = ra + (l_quadrant - ra_quadrant)

      # NOTE: RA potentially needs to be adjusted into the range [0,360) by adding/subtracting 360
      ra = put_in_range(ra, 0, 360, 360)

      # 5c. right ascension value needs to be converted into hours
      ra/15
    end

    # 6. calculate the Sun's declination
    # 7a. calculate the Sun's local hour angle
    def sun_local_hour_angle(l, zenith = :official)
      case zenith
      when :official
        z = 1.58534074
      when :civil
        z = 1.67552
      when :nautical
        z = 1.78024
      when :astronomical
        z = 1.88496
      else
        z = 1.58534074
      end

      l_in_radians = (Math::PI/180) * l
      sinDec = 0.39782 * Math.sin(l_in_radians)
      cosDec = Math.cos(Math.asin(sinDec))

      lat_in_radians = (Math::PI/180) * @lat

      cosH = (Math.cos(z) - (sinDec * Math.sin(lat_in_radians))) / (cosDec * Math.cos(lat_in_radians))

      raise "the sun never rises on this location (on the specified date)" if cosH > 1
      raise "the sun never sets on this location (on the specified date)" if cosH < -1
      cosH
    end

    # 7b. finish calculating H and convert into hours
    def calculate_h(cosH, sunrise = true)
      h = 0
      if sunrise
        h = 360 - (Math.acos(cosH) * (180/Math::PI))
      else
        h = Math.acos(cosH) * (180/Math::PI)
      end
      # convert it to hours
      h/15
    end

    # 8. calculate local mean time of rising/setting
    def local_mean_time(h, ra, t)
      t = h + ra - (0.06571 * t) - 6.622
      lngHour = @lng / 15
      t = (t - lngHour)
      t = put_in_range(t, 0, 24, 24)
      t + (@t.offset / 3600)
    end
  end
end
