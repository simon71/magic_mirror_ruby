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

