require 'simplecov'
SimpleCov.start do 
  command_name "Tests"
end

require 'bundler'

Bundler.setup
Bundler.require

require 'rack/test'
require 'goliath/test_helper'

Blobsterix.storage_dir=Blobsterix.root.join("tmp/contents")
Blobsterix.cache_dir=Blobsterix.root.join("tmp/cache")
Blobsterix.storage_event_listener=lambda{|a,b|}
Blobsterix.logger=Logger.new(nil)

module Blobsterix
  module SpecHelper
    def clear_storage
      FileUtils.rm_rf Dir.glob(Blobsterix.storage_dir.join("**/*"))
    end
    def clear_cache
      FileUtils.rm_rf Dir.glob(Blobsterix.cache_dir.join("**/*"))
    end
    def clear_data
      clear_cache
      clear_storage
    end
    def run_em(&block)
      EM.run {
        f = Fiber.new(&block)
        f.resume
        EM.stop
      }
    end
  end
end

class Nokogiri::XML::Node
  TYPENAMES = {1=>'element',2=>'attribute',3=>'text',4=>'cdata',8=>'comment'}
  def to_hash
    {kind:TYPENAMES[node_type],name:name}.tap do |h|
      h.merge! nshref:namespace.href, nsprefix:namespace.prefix if namespace
      h.merge! text:text
      h.merge! attr:attribute_nodes.map(&:to_hash) if element?
      h.merge! kids:children.map(&:to_hash) if element?
    end
  end
end
class Nokogiri::XML::Document
  def to_hash; root.to_hash; end
end

class Hash
  class << self
    def from_xml(xml_io) 
      begin
        result = Nokogiri::XML(xml_io)
        return { result.root.name.to_sym => xml_node_to_hash(result.root)} 
      rescue Exception => e
        # raise your custom exception here
      end
    end 
 
    def xml_node_to_hash(node) 
      # If we are at the root of the document, start the hash 
      if node.element?
        result_hash = {}
        if node.attributes != {}
          result_hash[:attributes] = {}
          node.attributes.keys.each do |key|
            result_hash[:attributes][node.attributes[key].name.to_sym] = prepare(node.attributes[key].value)
          end
        end
        if node.children.size > 0
          node.children.each do |child| 
            result = xml_node_to_hash(child) 
 
            if child.name == "text"
              unless child.next_sibling || child.previous_sibling
                return prepare(result)
              end
            elsif result_hash[child.name.to_sym]
              if result_hash[child.name.to_sym].is_a?(Object::Array)
                result_hash[child.name.to_sym] << prepare(result)
              else
                result_hash[child.name.to_sym] = [result_hash[child.name.to_sym]] << prepare(result)
              end
            else 
              result_hash[child.name.to_sym] = prepare(result)
            end
          end
 
          return result_hash 
        else 
          return result_hash
        end 
      else 
        return prepare(node.content.to_s) 
      end 
    end          
 
    def prepare(data)
      (data.class == String && data.to_i.to_s == data) ? data.to_i : data
    end
  end
  
  def to_struct(struct_name)
      Struct.new(struct_name,*keys).new(*values)
  end
end



RSpec.configure do |c|
  c.include Goliath::TestHelper, :example_group => {
    :file_path => /spec\/integration/
  }
end