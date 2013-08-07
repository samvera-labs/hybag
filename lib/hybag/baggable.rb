module Hybag
  module Baggable
    # @return [BagIt::Bag] The bag that was created on the filesystem.
    def write_bag(path='')
      @bag_path = generate_bag_path(path)
      Hybag::Validator.new(self).validate!
      # Delete currently existing bag
      delete_bag
      # Make and write the bag
      FileUtils.mkdir_p bag_path
      Hybag::BagWriter.new(self).write!
    end

    def bag_path
      @bag_path ||= generate_bag_path
    end

    def bag
      @bag = nil if @bag && @bag.bag_dir != bag_path
      @bag ||= BagIt::Bag.new(bag_path)
    end

    def baggable?
      true
    end

    def delete_bag
      if(File.directory? bag_path)
        FileUtils.rm_r(bag_path, :force => true)
        @bag = nil
      end
    end

    private

    def bag_path_namespace
      File.join('tmp','bags')
    end

    def generate_bag_path(path='')
      path = Rails.root.join(bag_path_namespace, path) unless path.to_s.start_with? Rails.root.join(bag_path_namespace).to_s
      return File.join(path, self.pid)
    end
  end
end