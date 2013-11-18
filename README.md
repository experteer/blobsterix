# Blobsterix

# Install

* Checkout the repository

* Setup binary dependencies
  * Webp
    - Download precompiled binaries from google: https://developers.google.com/speed/webp/download
    - OR apt-get install webp (on newer ubuntu this should work)
    - OR make sure you have a cwbep script that behaves the right way
  * MiniMagick
    sudo apt-get install imagemagick
  * VIPS(deprecated)
    sudo apt-get install libjpeg-dev libpng-dev libtiff-dev libvips-dev
  * lightpd config(not needed): 
    sudo apt-get install libpcre3-dev libbz2-dev libglib2.0-dev
  * ASCII Art (optional)
    sudo apt-get install jp2a

* Setup ruby
  - bundle install
# Run
* set the content and cache folders in lib/blob_server.rb
* run the server with: bundle exec bin/blob