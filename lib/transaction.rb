# customer transactions are managed in this class
class Transaction
  attr_reader :customer, :product, :id, :trans_type, :status
  @@id_count     = 0
  @@transactions = []

  # note that we are capturing all transactions including
  # those that failed. using that info the store can analyse
  # potential system problems (eg out of stock item problems,
  # or even a case where an item isn't out of stock but is
  # failing with an 'OutOfStockError' anyway).
  def initialize(customer, product, opts = {})
    @@id_count += 1
    @customer  = customer
    @product   = product
    @id        = @@id_count
    if opts[:type] == :prod_return
      begin
        @trans_type = :prod_return
        return_product
        @status = :successful
      rescue StandardError => e
        @status = e.message
      end
    else
      begin
        @trans_type = :purchase
        buy_product
        @status = :successful
      rescue StandardError => e
        @status = e.message
      end
    end
    @@transactions << self
    i = 0
  end

  def self.all
    @@transactions
  end

  def self.find(index)
    return nil if index <= 0
    @@transactions[index - 1]
  end

  private

  def buy_product
    begin
      raise OutOfStockError unless product.in_stock?
    rescue OutOfStockError => e
      puts e.message
      raise e
    end
    @product.sell_to_customer
  end

  def return_product
    @product.return_to_store
  end

end