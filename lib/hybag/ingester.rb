require 'rdf/rdfxml'

module Hybag
  class Ingester
    attr_accessor :bag, :model_name, :old_subject
    def initialize(bag)
      @bag = bag
    end

    def ingest
      raise Hybag::UndiscoverableModelName.new(bag) if model_name.blank?
      new_object = model_name.constantize.new
      # Assign a pid
      new_object.inner_object.pid = new_object.inner_object.assign_pid
      set_metadata_streams(new_object)
      set_file_streams(new_object)
      return new_object
    end

    def model_name
      # TODO: Add a default model_name configuration option?
      @model_name ||= extract_model_from_rels

    end

    private

    # TODO: Add some sort of configuration to map bag filenames -> dsids.
    def set_metadata_streams(object)
      bag_tag_files.each do |tag_file|
        add_bag_file_to_object(object, tag_file, false)
      end
    end


    # Returns all registered tag files except those generated for the bag
    # These includes the bag_info.txt, bagit.txt, and manifest files.
    def bag_tag_files
      bag.tag_files - [bag.bag_info_txt_file] - bag.manifest_files - [bag.bagit_txt_file]
    end

    def add_bag_file_to_object(object, bag_file, binary=true)
      parsed_name = bag_filename_to_label(bag_file)
      found_datastream = object.datastreams.values.find{|x| x.dsid.downcase == bag_filename_to_label(bag_file).downcase}
      open_tag = 'r'
      open_tag = 'rb' if binary
      content = File.open(bag_file, open_tag).read
      content = transform_content(content) unless binary
      if found_datastream
        found_datastream = replace_subject(content, found_datastream)
      else
        object.add_file_datastream(content, :dsid => parsed_name)
      end
    end

    def transform_content(content)
      content = content.strip
    end

    # Replaces the subject in RDF files with the datastream's rdf_subject.
    # TODO: Deal with what happens when there's no defined datastream.
    def replace_subject(content, ds)
      ds.content = content
      if ds.respond_to?(:rdf_subject)
        # Assume the first subject in the metadata is about this object.
        # TODO: Move this to configuration?
        old_subject = self.old_subject || ds.graph.first_subject
        new_repository = RDF::Repository.new
        ds.graph.each_statement do |statement|
          if statement.subject == old_subject
            ds.graph.delete statement
            ds.graph << RDF::Statement.new(ds.rdf_subject, statement.predicate, statement.object)
          end
        end
      end
      ds
    end

    def set_file_streams(object)
      bag.bag_files.each do |bag_file|
        add_bag_file_to_object(object, bag_file)
      end
    end

    # TODO: Might consider decoration at some point.
    def bag_filename_to_label(bag_filename)
      Pathname.new(bag_filename).basename.sub_ext('').to_s
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

    def fedora_rels
      File.join(bag.bag_dir,"fedora","RELS-EXT.rdf")
    end
  end
end
