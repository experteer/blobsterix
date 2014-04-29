require 'spec_helper'


describe Blobsterix do
 it "should allow_chunked_stream for backward comp. by default" do
   Blobsterix.allow_chunked_stream.should == true
 end
 
 it "should set allow_chunked_stream" do
   Blobsterix.allow_chunked_stream=false
   Blobsterix.allow_chunked_stream.should == false
   #set it back as this is global!
   Blobsterix.allow_chunked_stream=true
   Blobsterix.allow_chunked_stream.should == true
 end
 
end