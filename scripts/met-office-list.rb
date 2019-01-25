#!/bin/ruby
# frozen_string_literal: true

#
# This script get the list of UK forecast locations
#
require 'pp'
require 'net/http'
require 'json'
require 'uri'

@apikey = ENV['METOFFICEAPIKEY']
@base_url = 'http://datapoint.metoffice.gov.uk/public/data/'
@format = 'json'

# Make API call to get list of UK locations

def sitelist_data
  res = "val/wxfcs/all/#{@format}/sitelist?"
  url = "#{@base_url}#{res}key=#{@apikey}"
  pp url
  url = URI.parse(url)
  resp = Net::HTTP.get(url)
  pp resp
  data = ::JSON.parse(resp)
  data['Locations']['Location'] # Step into the array to get location list
end

# Create a list to display all available locations
def sitelist
  @fulllist = sitelist_data
  region_list = {}
  @fulllist.map do |k, _v|
    k.each do |key, value|
      @auth = value if key == 'unitaryAuthArea'
      @name = value if key == 'name'
    end
    region_list[@auth] = @name
  end
  region_list # Return list of locations
end

# Get a 3 hrly forecast for the next 5 days for the chosen location

# Get the raw 3hrly data for a specific region 
def three_hourly_forecast_raw(region)
  res = 'val/wxfcs/all/'
  reg = region
  url = "#{@base_url}#{res}#{@format}/#{reg}?res=3hourly&key=#{@apikey}"
  url = URI.parse(url)
  resp = Net::HTTP.get(url)
  data = ::JSON.parse(resp)
  data['SiteRep']['DV']['Location'] # Step into array to get to forecasts data
end

# Get the headders from the data id, name, longitude and latittude
def three_hourly_forecast_headder(region)
  raw_data = three_hourly_forecast_raw(region)
  raw_data.each do |key, value|
    @id = value if key == 'i'
    @reg = value if key == 'name'
    @lon = value if key == 'lon'
    @lat = value if key == 'lat'
  end
end

# def three_hourly_forecast_values(region)
#   three_hourly_forecast = {}
#   raw_data = three_hourly_forecast_raw(region)
#   raw_data['Period'].map do |key, _value|
#     @date = key['value']
#     key['Rep'].map do |weather_data, _v|
#       three_hourly_forecast[@date] = forecast_hash(weather_data)
#     end
#   end
#   three_hourly_forecast
# end
# Create a hash of the forecast data with new keys as
# the ones provided by met office are not great
def three_hourly_forecast_values(region)
  three_hourly_forecast = {}
  raw_data = three_hourly_forecast_raw(region)
  raw_data['Period'].map do |key, _value|
    @date = key['value']
    key['Rep'].map do |weather_data, _v|
      three_hourly_forecast = forecast_hash(weather_data)
    end
  end
  three_hourly_forecast
end

# Complie weather data hash
def forecast_hash(weather_data)
  {
    hr: weather_data["\$"],
    feels_like: weather_data['F'], # unit = c
    w_gust: weather_data['G'], # unit = mph
    rel_humid: weather_data['H'], # unit = %
    temp: weather_data['T'], # unit = c
    visability: weather_data['V'],
    wind_dir: weather_data['D'], # unit = compass
    wind_speed: weather_data['S'], # unit = mph
    max_uv: weather_data['U'],
    type: weather_data['W'],
    percipitation_probability: weather_data['Pp'] # unit = %
  }
end

three_hourly_forecast_values('310069')
