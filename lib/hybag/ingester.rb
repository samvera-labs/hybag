require 'rdf/rdfxml'

module Hybag
  class Ingester
    attr_accessor :bag
    def initialize(bag)
      @bag = bag
    end

    def ingest
      raise "Unable to determine model from bag" if model_name.blank?
      new_object = ActiveFedora.class_from_string(model_name.to_s).new
      # Assign a pid
      new_object.inner_object.pid = ActiveFedora::Base.assign_pid(new_object)
      set_metadata_streams(new_object)
      set_file_streams(new_object)
      return new_object
    end

    private

    # TODO: What to do if the bag has files that don't have model definitions?
    # TODO: Add some sort of configuration to map bag filenames -> dsids.
    def set_metadata_streams(object)
      object.metadata_streams.each do |ds|
        if bag_has_metastream?(ds.dsid)
          ds.content = bag_metastream(ds.dsid).read.strip
          # Assume the first subject in the metadata is about this object.
          # TODO: Move this to configuration?
          first_subject = ds.graph.first_subject
          new_repository = RDF::Repository.new
          ds.graph.each_statement do |statement|
            subject = statement.subject
            subject = ds.rdf_subject if subject == first_subject
            new_repository << [subject, statement.predicate, statement.object]
          end
          ds.instance_variable_set(:@graph,new_repository)
        end
      end
    end

    def set_file_streams(object)
      file_streams = object.datastreams.select{|k, ds| !ds.metadata?}.values
      file_streams.each do |ds|
        if bag_has_datastream?(ds.dsid)
          ds.content = bag_datastream(ds.dsid).read
        end
      end
    end

    # TODO: Might consider decoration at some point.
    def bag_filename_to_label(bag_filename)
      Pathname.new(bag_filename).basename.sub_ext('').to_s
    end

    def bag_has_datastream?(label)
      bag.bag_files.any?{|x| bag_filename_to_label(x) == label}
    end

    def bag_datastream(label)
      bag_file = bag.bag_files.select{|x| bag_filename_to_label(x) == label}.first
      result = File.open(bag_file) unless bag_file.blank?
      return result
    end

    def bag_has_metastream?(label)
      bag.tag_files.any?{|x| bag_filename_to_label(x) == label}
    end

    def bag_metastream(label)
      tag_file = bag.tag_files.select{|x| bag_filename_to_label(x) == label}.first
      result = File.open(tag_file) unless tag_file.blank?
      return result
    end

    def model_name
      # TODO: Add a default model_name configuration option?
      @model_name ||= extract_model_from_rels || extract_model_from_yaml

    end

    def extract_model_from_rels
      if File.exist?(fedora_rels)
        filler_object = ActiveFedora::Base.new
        rels_datastream = ActiveFedora::RelsExtDatastream.new
        rels_datastream.model = filler_object
        ActiveFedora::RelsExtDatastream.from_xml(File.read(fedora_rels).strip,rels_datastream)
        model_name = ActiveFedora::ContentModel.known_models_for(filler_object).first
        return model_name.to_s
      end
      return model_name
    end

    def extract_model_from_yaml
      model_name = nil
      if(File.exist?(yaml_config))
        conf = YAML.load(File.read(yaml_config))
        model_name = conf['model']
      end
      return model_name
    end

    def yaml_config
      File.join(bag.bag_dir,"hybag.yml")
    end

    def fedora_rels
      File.join(bag.bag_dir,"fedora","RELS-EXT.rdf")
    end
  end
end