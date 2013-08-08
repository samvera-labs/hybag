require 'rdf/rdfxml'

module Hybag
  class Ingester
    attr_accessor :bag
    def initialize(bag)
      @bag = bag
    end

    def ingest!
      raise "Unable to determine model from bag" if model_name.blank?
    end

    private

    def model_name
      # TODO: Add a default model_name configuration option?
      @model_name ||= extract_model_from_rels || extract_model_from_yaml

    end

    def extract_model_from_rels
      model_name = nil
      if File.exist?(fedora_rels)
        # Move this out?
        model_predicate = "info:fedora/fedora-system:def/model#hasModel"
        rels_graph = RDF::Graph.load(fedora_rels)
        if(rels_graph.has_predicate?(model_predicate))
          model_name = rels_graph.to_a.select{|x| x.predicate == model_predicate}[0].object.to_s
          model_name["info:fedora/afmodel:"] = ''
        end
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