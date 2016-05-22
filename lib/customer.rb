require 'terminal-table'

# this class supports basic methods to support customer transactions
# and history.
class Customer
  @@customers = []

  attr_reader :name, :transactions

  def initialize(options={})
    @name         = options[:name]
    add_customer
  end

  def self.all
    @@customers
  end

  def self.find_by_name(name)
    @@customers.find { |customer| customer.name == name }
  end

  def add_customer
    begin
      raise DuplicateCustomerError if customer_exists?
    rescue DuplicateCustomerError => error
      puts "#{error.message}: #{name} already exists."
      return
    end
    @@customers << self
  end

  def customer_exists?
    @@customers.map { |customer| customer.name }.include? @name
  end

  def purchase(product)
		begin
			PurchaseTrans.new(self, product)
		rescue OutOfStockError => error
			puts "#{error.message}: '#{product.title}' is out of stock."
		rescue Exception => error
			puts "#{error.message}"
		end
	end

	def return_items(title, quantity)
		return 0 if quantity <= 0
		begin
			cust_trans = Transaction.by_customer(@name)
			transactions = cust_trans.select { |trans| trans.product.title == title}
			raise ProductNotFoundError if transactions.nil?
		rescue ProductNotFoundError => error
			puts "#{title} not found in customer transactions. (#{error.message})"
			return 0
		end

		begin
			# we really need to allow cust to return as many of the product as they want
			# but not more than they ever bought and not 0 items
			num_returned = 0
			num_items_bought = transactions.length
			quantity = num_items_bought if quantity > num_items_bought
			for idx in 0..(quantity - 1) do
				ReturnTrans.new(self,transactions[idx].product)
				num_returned += 1
			end
		rescue Exception => error
			puts "#{error.message}"
		end
		num_returned
	end

  def transaction_history
		# filter transactions by the customer name
		transactions = Transaction.by_customer(@name)
    table = Terminal::Table.new do |table_row|
      transactions.each do |column|
        row = ["#{column.id.to_s}",
							 "#{column.trans_type}",
							 "#{column.status}",
							 "#{column.product.title}",
							 "#{column.product.price}",
							 "#{column.trans_amt.to_s}"]
        table_row << row
      end
    end

    table.title    = "#{@name}'s Transactions"
    table.headings = ['Trans ID','Trans Type','Status','Product','Price','Transaction Amount']
    puts table
  end
end
