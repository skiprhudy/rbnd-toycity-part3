# a class that allows managing products in the store
# for a basic product management
class Product
  attr_reader :title, :price, :stock
  @@products = []

  def initialize(options={})
    @title = options[:title]
    @price = options[:price]
    @stock = options[:stock]
    add_to_products
	rescue DuplicateProductError => error
		# for this PARTICULAR error only i rescue without rethrowing
		# owing to the nature of how app.rb was written (it uses product directly
		# and does not rescue ... i could change that of course but wanted to stay
		# strictly to spec) and just print an error message. all other errors are
		# logged and re-thrown.
		puts "#{error.message}: '#{@title}' already exists."
	rescue Exception => error
		puts "#{error.message}"
		raise error
  end

  def self.all
    @@products
  end

  def self.find_by_title(title)
    @@products.find { |product| product.title == title }
  end

  def self.in_stock
    @@products.select {|product| product.in_stock? }
  end

  def add_to_products
		raise DuplicateProductError if product_exists?
    @@products << self
  end

  # this should always work because index returns nil if not found which evaluates
  # to false in ternary ... plus this is an instance method not a class method
  def product_exists?
    @@products.index { |product| product.title == @title } ? true : false
  end

  def in_stock?
    @stock > 0
  end

  def sell_to_customer
		raise OutOfStockError unless in_stock?
		decrement_stock
  end

  def return_to_store
		raise ProductNotFoundError unless product_exists?
    increment_stock
  end

  private

  def decrement_stock
    @stock -= 1
  end

  def increment_stock
    @stock += 1
  end
end
