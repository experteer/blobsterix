# Blobsterix

[![Gem Version](https://badge.fury.io/rb/blobsterix.png)](http://badge.fury.io/rb/blobsterix)
[![Build Status](https://travis-ci.org/experteer/blobsterix.svg?branch=master)](https://travis-ci.org/experteer/blobsterix)

# What's this?

Blobsterix is a s3 compliant content server that supports on the fly transformations for its data. 
Images for example can be scaled, rotated and so on before delivered to the client just by url modification. 
The system also supports encryption of urls (so nobody can mess with the transformations) and transformation signing for the non s3 interface functions. 

So if you are tired of:
 * days of migration just to introduce a new size of an image
 * high bills for amazon's s3 as you also pay for the storage of all the versions of the transformed original
 * lots of dependencies to modify binary files in your main app

and if you want:
 * content negotiation for your images (webp or not to webp)
 * on the fly transformation for your images and other binary formats with caching

Blobsterix might be your friend.

# Install

Simply run

    gem install blobsterix

This will install blobsterix with all its dependencies. IT requires at least ruby version 2.0.0-p451 (reference: https://github.com/eventmachine/eventmachine/issues/457).
Some binary dependencies are needed for the transformation pipeline not for the server itself. If you have your own transformations you might not need these:

* Setup binary dependencies
  * Webp
    - Download precompiled binaries from google: https://developers.google.com/speed/webp/download
    - OR apt-get install webp (on newer ubuntu this should work)
    - OR make sure you have a cwbep script that behaves the right way
  * MiniMagick
    sudo apt-get install imagemagick
  * lightpd config(not needed): 
    sudo apt-get install libpcre3-dev libbz2-dev libglib2.0-dev
  * ASCII Art (optional)
    sudo apt-get install jp2a

# Usage

Now the server is basicly ready to run with 

    blobsterix server

This will run the server in the current directory which will create a contents and a cache folder uppon the first request that needs them. If this is enough you are basicly done and you can use the server. When you need more control over the server you will have to create a server configuration. For this process there are generators shipped with blobsterix.

# HTTP interface

Now the server has two http interface and a status page.

## Status Page

The status page can be retrived via 

  * GET /status
  * GET /status.json
  * GET /status.xml

The first returns a "beautifull" html page. The other two return the status data as json or xml as expected.

## S3 interface

The s3 interface works like the aws system but without the encryption and security parameters. Because of this you shouldn't route GET, PUT, POST requests to the outside.
Check the amazon s3 specs for more information. It only supports the REST api with the following actions:

  * list buckets
  * list bucket entries
  * get file
  * head file
  * create bucket
  * delete bucket
  * put file into bucket
  * delete file from bucket

The s3 interface itself is unsecured and should not be visible to the outside.

## Blob interface

The blob interface is reachable at 

  * GET /blob/v1/

It only supports GET and HEAD requests and the url is constructed as this:

  * /blob/v1/$trafo.$bucket/$file

The transformation is expected in the following format:

  * $trafoname_$value,$trafoname_$value,...

The trafo is optional the bucket and file are not. The blob interface does not allow listing of buckets or files inside buckets.


# Config setup

To setup a special server change into and empty directory:

    mkdir special-blobsterix
    blobsterix generate init special-blobsterix

This will copy a base template into special-blobsterix. Now you can checkout the generated config files for documentation on how to change things.

# Custom Transformation

The biggest strength of the system is it supports custom transformations without much coding required. To use a custom transformation you first have to setup a configuration as explained in the step before. Then you can use transformation generator to create a new transformation with

    blobsterix generate transformator CropToFace

This will generate a new transforamtion in the transformators subdirectory of your server configuration. The transformation has standard parameters set which already make the transformation work. There are five functions:

  * name
  * is_format?
  * input_type
  * output_type
  * transform

The name function is used to match a parameter in the transformation string to a specific transformator. If it can not a transformator with the given name a dummy transformator is used which does nothing. The is_format? function tells the transformation manager if this transformator is an output format which should override a requested format send by the browser. For example images requested by a chrome browser are requested as webp and if in the transformation chain is no transformator with is_format? == true then in the end the transformation manager will try to find a transformation which will convert the image to webp. Now the input_type and output_type function do what they say. They tell the system what kind of file the transformator accepts and what kind of file it produces. With this information the transformation chain is build. So incase those function return wrong values the transformation might fail horribly. The last function is the one with all the magic. It transforms an input file to an output file. Now those files are passed as paths and are saved in the tmp folder or where ever ruby decides to save TempFiles. Those are outmaticly cleaned up after the transformation finishes. The value parameter is the second part of the transformation: resize_50
Now the 50 would be passed as value with type string. The transformation has to take care of parsing the parameter and ensuring its not doing any harm to the system. Another thing to keep in mind is that the transform functions are called in a different thread than the rest of the server.

# Custom Storage

Blobsterix also supports different kinds of backend storages. For this purpose you can again use a generator to create template storage system with:

    blobsterix generate storage MyBackend

This will again generate a working empty storage that doesn't allow saving or retriving of data. To see a working storage implementation checkout the FileSystem storage in the source code. Now you will see that all data there is returned as a BlobMetaData or better in the FileSystem storage as a FileSystemMetaData. As long as your implementation supports the interface everything should work like expected.