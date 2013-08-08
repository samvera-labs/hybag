require 'rdf/rdfxml'

module Hybag
  class Ingester
    attr_accessor :bag
    def initialize(bag)
      @bag = bag
    end

    def ingest!
      raise "Unable to determine model from bag" if model_name.blank?
      new_object = ActiveFedora.class_from_string(model_name.to_s).new
    end

    private

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