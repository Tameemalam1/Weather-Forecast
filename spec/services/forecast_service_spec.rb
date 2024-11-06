# spec/services/forecast_service_spec.rb
require 'rails_helper'

RSpec.describe ForecastService, type: :service do
  describe "#fetch_forecast" do
    context "when address is invalid" do
      it "returns an error" do
        service = ForecastService.new("")
        result = service.fetch_forecast
        expect(result[:error]).to eq('Invalid address')
      end
    end

    context "when address is valid" do
      it "fetches forecast data" do
        # Mocking the HTTP request and response
        allow_any_instance_of(ForecastService).to receive(:retrieve_forecast_from_api).and_return({ 'cod' => 200, 'main' => { 'temp' => 68, 'temp_max' => 75, 'temp_min' => 60 }, 'weather' => [{ 'description' => "clear sky" }], 'name' => "New York" })
        
        service = ForecastService.new("New York")
        result = service.fetch_forecast
        expect(result[:data][:city_name]).to eq("New York")
      end
    end
  end
end
