# spec/controllers/forecast_controller_spec.rb
require 'rails_helper'

RSpec.describe ForecastsController, type: :controller do
  describe "GET #new" do
    it "renders the new template" do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context "when address is valid" do
      it "fetches forecast and renders the show template" do
        allow_any_instance_of(ForecastService).to receive(:fetch_forecast).and_return({ data: "some forecast data" })
        
        post :create, params: { address: "New York" }
        
        expect(response).to render_template(:show)
        expect(assigns(:forecast_data)).to eq("some forecast data")
      end
    end

    context "when address is empty" do
      it "returns an error message and renders the new template" do
        post :create, params: { address: "" }
        
        expect(flash[:alert]).to eq('Please enter a zip code or city.')
        expect(response).to render_template(:new)
      end
    end
  end
end
