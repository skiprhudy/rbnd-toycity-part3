class Formatter
  def self.format_dollars(amount)
    amt = format('%.2f', amount)
    amt
  end
end

# customer transactions are managed in this class
class Transaction
  attr_reader :customer, :product, :id, :trans_type, :status, :trans_amt
  @@id_count     = 0
  @@transactions = []

  # note that we are capturing all transactions including
  # those that failed. using that info the store can analyse
  # potential system problems (eg out of stock item problems,
  # or even a case where an item isn't out of stock but is
  # failing with an 'OutOfStockError' anyway).
  def initialize(customer, product)
    @@id_count += 1
    @customer  = customer
    @product   = product
    @id        = @@id_count
    @trans_amt = Formatter.format_dollars(0.00)
  end

  def self.all
    @@transactions
  end

  def self.find(id)
    return nil if id <= 0
    @@transactions.find {|trans| trans.id == id}
	end

	def self.by_customer(name)
		@@transactions.select { |trans| trans.customer.name == name }
	end

	def self.list_all_transactions
		table = Terminal::Table.new do |table_row|
			@@transactions.each do |transaction|
				row = ["#{transaction.customer.name}",
							 "#{transaction.id.to_s}",
							 "#{transaction.trans_type}",
							 "#{transaction.status}",
							 "#{transaction.product.title}",
							 "#{transaction.product.price}",
							 "#{transaction.trans_amt.to_s}"]
				table_row << row
			end
		end

		table.title    = "All Transactions"
		table.headings = ['Customer','Trans ID','Trans Type','Status','Product','Price','Transaction Amount']
		puts table
	end

end

class PurchaseTrans < Transaction
	def initialize(customer, product)
		super(customer, product)
		# catching error here because i want to set a transaction status
		# within transaction, but re-raise same error for calling code to
		# handle. is there another way to set status other than
		# having the calling code set it (which I think is not correct)
		begin
			@trans_type = self.class.name
			buy_product
			@status = :successful
			@trans_amt = Formatter.format_dollars(@product.price)
		rescue Exception => error
			@status = error.message
			raise error
		ensure
			@@transactions << self
		end
		self
	end

	private

	def buy_product
		@product.sell_to_customer
	end
end

class ReturnTrans < Transaction

	def initialize(customer, product)
		super(customer, product)
		begin
			@trans_type = self.class.name
			return_product
			@status = :successful
			@trans_amt = Formatter.format_dollars(@product.price)
			@trans_amt.prepend("-")
		rescue ProductNotFoundError => error
			puts "#{error.message}: '#{@product.title}' is out of stock."
			raise error
		rescue Exception => error
			@status = error.message
			raise error
		ensure
			@@transactions << self
		end
	end

	private

	def return_product
		@product.return_to_store
	end

end