class Quote

  UPS_LOGIN = ENV["ACTIVESHIPPING_UPS_LOGIN"]
  UPS_KEY = ENV["ACTIVESHIPPING_UPS_KEY"]
  UPS_PASSWORD = ENV["ACTIVESHIPPING_UPS_PASSWORD"]
  USPS_LOGIN = ENV["ACTIVESHIPPING_USPS_LOGIN"]


  def initialize(weight, origin = {}, destination = {}, dimensions = [15, 10, 4.5])

    @package = ActiveShipping::Package.new(weight*16, dimensions, units: :imperial)
    #update the params when we create API wrapper in Petsy
    @origin = ActiveShipping::Location.new({country: 'US', state: 'WA', city: 'Seattle',zip: '98122'})
    @destination = ActiveShipping::Location.new(destination)
  end

  def ups
    ups = ActiveShipping::UPS.new(login: UPS_LOGIN, password: UPS_PASSWORD, key: UPS_KEY)

    ups_response = ups.find_rates(@origin, @destination, @package)
    # return ups_response.rates
    ups_rates = {}
    ups_response.rates.sort_by(&:price).each do |rate|
      ups_rates[rate.service_name] = [rate.price, rate.delivery_date]
    end
    return ups_rates
  end

  def usps
    usps = ActiveShipping::USPS.new(login: USPS_LOGIN)
    response = usps.find_rates(@origin, @destination, @package)
    usps_rates = {}
    response.rates.sort_by(&:price).each do |rate|
      usps_rates[rate.service_name] = [rate.price, rate.delivery_date]
    end
    return response

  end
end
