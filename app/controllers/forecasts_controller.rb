class ForecastsController < ApplicationController
	def new
		# Renders the form for address input
		@forecast_data = nil
    @address = ""
	end

	def create
		@address = params[:address].strip
		if @address.empty?
			flash[:alert] = 'Please enter a zip code or city.'
			render :new
			return
		end
	
		forecast_service = ForecastService.new(@address)
		forecast_result = forecast_service.fetch_forecast
	
		if forecast_result[:error]
			flash[:alert] = forecast_result[:error]
			render :new
		else
			@forecast_data = forecast_result[:data]
			@cached = forecast_result[:cached]
			render :show
		end
	end
	
	

	def show
    # Renders the show.html.erb view by default
  end
end
