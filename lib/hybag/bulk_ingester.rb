class Hybag::BulkIngester
  include Enumerable
  def initialize(directory)
    @bags = Dir.glob(File.join(directory,"*")).select{|f| File.directory? f}.map{|x| BagIt::Bag.new(x) unless !File.exists?(File.join(x, "bagit.txt"))}.compact
  end

  def each
    return enum_for(:each) unless block_given?
    @bags.each do |bag|
      yield Hybag::Ingester.new(bag) if bag.complete?
    end
  end
end
