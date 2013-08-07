module Hybag
  class BagWriter
    attr_reader :bag
    attr_reader :object
    def initialize(object)
      @object = object
      @bag = object.bag
    end
    def write!
      # add the datastreams to the bag, then manifest
      @object.datastreams.each do |label, ds|
        unless ds.content.nil?
          label = label + mime_extension(ds)
          if bag_tags.include? ds
            bag.add_tag_file(label) { |f|
              f.puts ds.content
            }
          elsif bag_fedora_tags.values.include? ds
            bag.add_tag_file('fedora/' + label) { |f|
              f.puts ds.content
            }
          else
            bag.add_file(label) { |f|
              content = ds.content
              content = ds.content.read if ds.content.respond_to?(:read)
              f.puts content.force_encoding('UTF-8')
            }
          end
        end
      end
      bag.tagmanifest!
      bag.manifest!
      return bag
    end

    private

    # return all non-fedora tag files
    def bag_tags
      object.metadata_streams
    end

    def mime_extension(ds)
      if ds.kind_of?(ActiveFedora::NtriplesRDFDatastream)
        ext = 'nt'
      else
        if ds.mimeType.blank?
          ext = ''
        else
          ext = MIME::Types[ds.mimeType] || ''
          ext = ext.first.extensions[0] unless ext.blank?

        end
      end
      return '.' + ext
    end

    def bag_fedora_tags
      object.datastreams.select { |label, ds| ds.is_a?(ActiveFedora::RelsExtDatastream) or ds.dsid == "DC"}
    end


  end
end