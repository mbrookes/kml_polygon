#
#The MIT License
#
# Copyright (c) 2007 Nick Galbreath, (c) 2013 Matthew Brookes
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

#
# Version 2.0.2 - 29-Mar-2013 More idomatic Ruby,
#                             Renamed to kml_polygon to better reflection function
# Version 2.0.1 - 29-Mar-2013 Translation to Ruby Gem
#                             No CLI
# Version 2     - 12-Sept-2007 Simplified XML output
#                              Added commandline interface
#
# Version 1     - 10-Sept-2007 Initial release
#

#require 'kml_polygon/version'

module KmlPolygon
  extend self

  include Math

  # constant to convert to degrees
  DEGREES = 180.0 / PI
  # constant to convert to radians
  RADIANS = PI / 180.0
  # Mean Radius of Earth in meters
  EARTH_MEAN_RADIUS = 6371.0 * 1000

#
# Convert [x,y,z] on unit sphere
# back to [longitude, latitude])
#
  def to_earth(point)
    point[0] == 0.0 ? lon = PI / 2.0 :lon = Math.atan(point[1]/point[0])
    lat = PI / 2.0 - Math.acos(point[2])

    # select correct branch of arctan
    (point[1] <= 0.0 ? lon = -(PI - lon) : lon = PI + lon) if point[0] < 0.0
    [lon * DEGREES, lat * DEGREES]
  end

#
# Convert [longitude, latitude] IN RADIANS to 
# spherical / cartesian [x,y,z]
#
  def to_cartesian(coord)
    theta = coord[0]
    # spherical coordinate use "co-latitude", not "latitude"
    # lat = [-90, 90] with 0 at equator
    # co-lat = [0, 180] with 0 at north pole
    phi = PI / 2.0 - coord[1]
    [Math.cos(theta) * Math.sin(phi), Math.sin(theta) * Math.sin(phi), Math.cos(phi)]
  end

# spoints -- get raw list of points in longitude,latitude format
#
# radius: radius of polygon in meters
# sides:  number of sides
# rotate: rotate polygon by number of degrees
#
# Returns a list of points comprising the object
#
  def spoints(lon, lat, radius, sides=20, rotate=0)

    rotate_radians = rotate * RADIANS

    # compute longitude degrees (in radians) at given latitude
    r = radius / (EARTH_MEAN_RADIUS * Math.cos(lat * RADIANS))

    vector = to_cartesian([lon * RADIANS, lat * RADIANS])
    point = to_cartesian([lon * RADIANS + r, lat * RADIANS])
    points = []

    for side in 0...sides
      points << to_earth(rotate_point(vector, point, rotate_radians + (2.0 * PI/sides)*side))
    end

    # Connect to starting point exactly
    # Not sure if required, but seems to help when the polygon is not filled
    points << points[0]
  end

#
# rotate point around unit vector by phi radians
# http://blog.modp.com/2007/09/rotating-point-around-vector.html
#
  def rotate_point(vector, point, phi)
    # remap vector for sanity
    u, v, w, x, y, z = vector[0], vector[1], vector[2], point[0], point[1], point[2]

    a = u*x + v*y + w*z
    d = Math.cos(phi)
    e = Math.sin(phi)

    [(a*u + (x - a*u)*d + (v*z - w*y) * e),
     (a*v + (y - a*v)*d + (w*x - u*z) * e),
     (a*w + (z - a*w)*d + (u*y - v*x) * e)]
  end

  #
  # Output points formatted as a KML string
  #
  # You may want to edit this function to change "extrude" and other XML nodes.
  #
  def points_to_kml(points)

    kml_string = "<Polygon>\n"
    kml_string << "  <outerBoundaryIs><LinearRing><coordinates>\n"

    points.each do |point|
      kml_string << "    " << point[0].to_s << "," << point[1].to_s << "\n"
    end

    kml_string << "  </coordinates></LinearRing></outerBoundaryIs>\n"
    kml_string << "</Polygon>\n"

    # kml_string << "  <extrude>1</extrude>\sides"
    # kml_string << "  <altitudeMode>clampToGround</altitudeMode>\sides"
  end

#
# kml_regular_polygon    - Regular polygon
#
#  (lon, lat)            - center point in decimal degrees
#  radius                - radius in meters
#  segments              - number of sides, > 20 looks like a circle (optional, default: 20)
#  rotate                - rotate polygon by number of degrees (optional, default: 0)
#
# Returns a string suitable for adding into a KML file.
#
  def kml_regular_polygon(lon, lat, radius, segments=20, rotate=0)
    points_to_kml(spoints(lon, lat, radius, segments, rotate))
  end

#
# kml_star - Make a "star" or "burst" pattern
#
#  (lon, lat)            - center point in decimal degrees
#  radius                - radius in meters
#  innner_radius         - radius in meters, typically < outer_radius
#  segments              - number of "points" on the star (optional, default: 10)
#  rotate                - rotate polygon by number of degrees (optional, default: 0)
#
# Returns a string suitable for adding into a KML file.
#
  def kml_star(lon, lat, radius, inner_radius, segments=10, rotate=0)
    outer_points = spoints(lon, lat, radius, segments, rotate)
    inner_points = spoints(lon, lat, inner_radius, segments, rotate + 180.0 / segments)

    # interweave the radius and inner_radius points
    # I'm sure there is a better way
    points = []
    for point in 0...outer_points.length
      points << outer_points[point]
      points << inner_points[point]
    end

    # MTB - Drop the last overlapping point leaving start and end points connecting
    # (resulting output differs from orig, but is more correct)
    points.pop

    points_to_kml(points)
  end

end

#
# Examples
#
# puts KmlPolygon::kml_star(45,45, 70000, 50000)
# puts KmlPolygon::kml_regular_polygon(50, 50, 70000)
