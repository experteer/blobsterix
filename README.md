# Blobsterix

Blobsterix is a s3 compliant content server that supports on the fly transformations for its data. Images for example can be scaled, rotated and so on before delivered to the client. The system also supports encryption and transformation signing for the non s3 interface functions. The s3 interface itself is unsecured and should not be visible to the outside.

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

# Usage

To install blobsterix simply do a:
  * gem install blobsterix
This will install blobsterix with all its dependencies. After that you have to install the binary dependecies which are written above. Those are needed for the transformation pipeline not for the server itself. If you have your own transformations you might not need thoose.

Now the server is basicly ready to run with "blobsterix server". This will run the server in the current directory which will create a contents and a cache folder uppon the first request that needs them. If this is enough you are basicly done and you can use the server. When you need more control over the server you will have to create a server configuration. For this process there are generators shipped with blobsterix.

# Config setup

To setup a special server change into and empty directory:

  * mkdir special-blobsterix
  * blobsterix generate init special-blobsterix

This will copy a base template into special-blobsterix