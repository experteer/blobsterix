# Blobsterix

# Install

* Checkout the repository

* Setup dependencies
	* Webp
		Download precompiled binaries from google: https://developers.google.com/speed/webp/download

	* MiniMagick
		sudo apt-get install imagemagick

	* VIPS(deprecated)
		sudo apt-get install libjpeg-dev libpng-dev libtiff-dev libvips-dev

	* lightpd config(not needed): 
		sudo apt-get install libpcre3-dev libbz2-dev libglib2.0-dev

# Run
* set the content and cache folders in lib/blob_server.rb
* run the server with: bundle exec bin/blob