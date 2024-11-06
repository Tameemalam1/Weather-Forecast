class ForecastService
  CACHE_EXPIRY = 30.minutes

  def initialize(address)
    @address = address
  end

  def fetch_forecast
    zip_code = extract_zip_code(@address)
  	return { error: "Invalid address" } if zip_code.blank?
    # Check if forecast data exists in the cache
    cached_data = Rails.cache.read(cache_key(zip_code))
    if cached_data
      return { data: cached_data, cached: true }
    end
    # Fetch forecast data from API
    forecast_data = retrieve_forecast_from_api(zip_code)
    # Handle the API response
    forecast_result = handle_response(forecast_data)
    # If there's an error, return it
    return forecast_result if forecast_result[:data].nil?
    # Store the forecast data in the cache if it's valid
    Rails.cache.write(cache_key(zip_code), forecast_result[:data], expires_in: CACHE_EXPIRY)
    { data: forecast_result[:data], cached: false }
  end

  private

  def retrieve_forecast_from_api(zip_code_or_city)
    if zip_code_or_city =~ /^\d{5}$/ 
      # For ZIP code
      response = HTTParty.get("http://api.openweathermap.org/data/2.5/weather?zip=#{zip_code_or_city},IN&appid=#{ENV['WEATHER_API_KEY']}&units=imperial")
    else
      # For city name
      response = HTTParty.get("http://api.openweathermap.org/data/2.5/weather?q=#{zip_code_or_city},IN&appid=#{ENV['WEATHER_API_KEY']}&units=imperial")
    end

    response.parsed_response
  end

  def handle_response(response)
    # puts "response"
    # puts response.inspect
    # puts "++++++++"
    # puts response['name'].inspect
    # puts "response"
    if response['cod'] == 200
      {
        data: {
          current_temp: fahrenheit_to_celsius(response['main']['temp']),
          high_temp: fahrenheit_to_celsius(response['main']['temp_max']),
          low_temp: fahrenheit_to_celsius(response['main']['temp_min']),
          weather_description: response['weather'][0]['description'],
          city_name: response['name']
        },
        cached: false
      }
    else
      Rails.logger.error("Error fetching forecast: #{response['message']}")
      { data: nil, cached: false }
    end
  end

  def fahrenheit_to_celsius(fahrenheit)
    ((fahrenheit - 32) * 5.0 / 9.0).round(2)
  end

  def extract_zip_code(address)
    if address.is_a?(Hash)
      address.dig("address_components")&.find { |component| component["types"].include?("postal_code") }&.[]("long_name")
    else
      address 
    end
  end

  def cache_key(zip_code)
    "forecast_#{zip_code}"
  end
end
