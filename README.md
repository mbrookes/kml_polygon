
=======
kml_polygon
===========

Google earth doesn't provide polygon primitives, leaving you to generate them as a series of points.

Given only a center-point (longitude/latitude) and radius, this Gem makes it easy to create
(n) sided polygons (sufficient sides giving a circle) or stars, for inclusion in a KML file.

All credit to  Nick Galbreath for the original code, and for providing it in a portable format. Thanks!
(http://blog.client9.com/2007/09/drawing-circles-and-stars-on-google.html)

## Installation

Add this line to your application's Gemfile:

    gem 'kml_polygon'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kml_polygon

## Usage

    kml_regular_polygon(longitude, latitude, radius, [sides=20, rotate=0])
    kml_star(longitude, latitude, radius, inner_radius, [sides=10, rotate=0])

Returns a string suitable for adding into a KML file.

### kml_regular_polygon

    kml_regular_polygon(longitude, latitude, radius, [sides=0, rotate=0])

Regular polygon

    longitude, latitude - center point in decimal degrees
    radius              - radius in meters
    segments            - number of sides, > 20 looks like a circle (optional, default: 20)
    rotate              - rotate polygon <rotate> degrees (optional, default: 0)

### kml_star

    kml_star(longitude, latitude, radius, inner_radius, [sides=10, rotate=0])

Make a "star" or "burst" pattern

    longitude, latitude - center point in decimal degrees
    radius              - radius in meters
    inner_radius        - radius in meters, typically < outer_radius
    segments            - number of "points" on the star (optional, default: 10)
    rotate              - rotate polygon by <rotate> degrees (optional, default: 0)

### For Example:
    # kml_polygon_example.rb
    include kml_polygon
    circle = kml_regular_polygon(-95, 50, 70000)
    star = kml_star(-95,45, 70000, 50000)
    puts "<kml><Document>
          <Style id='polygon1'><PolyStyle><color>7fff0000</color></PolyStyle></Style>
          <Style id='polygon2'><PolyStyle><color>7f0000ff</color></PolyStyle></Style>
          <Placemark><styleUrl>polygon1</styleUrl><Polygon>" << circle << "</Polygon></Placemark>
          <Placemark><styleUrl>polygon2</styleUrl><Polygon>" << star << "</Polygon></Placemark>
          </Document></kml>"

Outputs a minimal but funtional KML file with one circle and one star in semi-transparent colors.

## Contributing

1. Fork it (`git clone git://github.com/mbrookes/kml_polygon.git`)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request



