# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V0 Courts', type: :request do
  let(:headers) { { 'Content-Type' => 'application/json' } }

  let(:owner_role) { create(:role, :owner) }
  let(:admin_role) { create(:role, :admin) }
  let(:customer_role) { create(:role, :customer) }

  let(:owner_user) { create(:user, email: 'owner@example.com') }
  let(:admin_user) { create(:user, email: 'admin@example.com') }
  let(:customer_user) { create(:user, email: 'customer@example.com') }

  before do
    owner_user.assign_role(owner_role)
    admin_user.assign_role(admin_role)
    customer_user.assign_role(customer_role)
  end

  let!(:court_type) { create(:court_type, name: 'Badminton') }
  let!(:venue) { create(:venue, name: 'Alpha Arena', owner: owner_user) }

  let!(:active_court) do
    create(:court,
           venue: venue,
           court_type: court_type,
           name: 'Court A',
           is_active: true,
           display_order: 1)
  end

  let!(:inactive_court) do
    create(:court,
           venue: venue,
           court_type: court_type,
           name: 'Court B',
           is_active: false,
           display_order: 2)
  end

  describe 'GET /api/v0/courts' do
    before do
      get '/api/v0/courts', headers: headers
    end

    it 'returns success status' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns court list' do
      data = response.parsed_body['data']
      expect(data).to be_an(Array)
      expect(data.size).to eq(2)
    end

    it 'includes court type details' do
      data = response.parsed_body['data'].first
      expect(data['court_type']).to include('id' => court_type.id, 'name' => 'Badminton')
    end

    it 'includes venue minimal details' do
      data = response.parsed_body['data'].first
      expect(data['venue']).to include('id' => venue.id, 'name' => 'Alpha Arena', 'slug' => venue.slug)
    end
  end

  describe 'GET /api/v0/courts/:id' do
    before do
      get "/api/v0/courts/#{active_court.id}", headers: headers
    end

    it 'returns success status' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns the court details' do
      data = response.parsed_body['data']
      expect(data).to include(
        'id' => active_court.id,
        'name' => 'Court A',
        'is_active' => true,
        'display_order' => 1
      )
      expect(data['court_type']).to include('id' => court_type.id)
      expect(data['venue']).to include('id' => venue.id)
    end
  end

  describe 'POST /api/v0/courts' do
    let(:request_headers) { headers.merge('Authorization' => auth_token_for(owner_user)) }
    let(:request_params) do
      {
        court: {
          venue_id: venue.id,
          court_type_id: court_type.id,
          name: 'Court C',
          description: 'Premium badminton court',
          is_active: true,
          display_order: 3
        }
      }
    end

    before do
      post '/api/v0/courts', params: request_params.to_json, headers: request_headers
    end

    it 'creates a court successfully' do
      expect(response).to have_http_status(:created)
      expect(Court.find_by(name: 'Court C')).to be_present
    end

    it 'returns court details' do
      data = response.parsed_body['data']
      expect(data).to include('name' => 'Court C', 'description' => 'Premium badminton court')
      expect(data['court_type']).to include('id' => court_type.id)
    end
  end

  describe 'PATCH /api/v0/courts/:id' do
    let(:request_headers) { headers.merge('Authorization' => auth_token_for(owner_user)) }
    let(:request_params) do
      {
        court: {
          name: 'Court A Updated',
          is_active: false,
          display_order: 5
        }
      }
    end

    before do
      patch "/api/v0/courts/#{active_court.id}", params: request_params.to_json, headers: request_headers
    end

    it 'updates the court successfully' do
      expect(response).to have_http_status(:ok)
      expect(active_court.reload.name).to eq('Court A Updated')
      expect(active_court.reload.is_active).to eq(false)
      expect(active_court.reload.display_order).to eq(5)
    end
  end

  describe 'PATCH /api/v0/courts/:id/reorder' do
    let(:request_headers) { headers.merge('Authorization' => auth_token_for(owner_user)) }
    let(:request_params) do
      {
        display_order: 10
      }
    end

    before do
      patch "/api/v0/courts/#{active_court.id}/reorder", params: request_params.to_json, headers: request_headers
    end

    it 'reorders the court successfully' do
      expect(response).to have_http_status(:ok)
      expect(active_court.reload.display_order).to eq(10)
      expect(response.parsed_body['data']).to include('id' => active_court.id, 'display_order' => 10)
    end
  end

  describe 'DELETE /api/v0/courts/:id' do
    let(:request_headers) { headers.merge('Authorization' => auth_token_for(owner_user)) }

    before do
      delete "/api/v0/courts/#{inactive_court.id}", headers: request_headers
    end

    it 'deletes the court successfully' do
      expect(response).to have_http_status(:ok)
      expect(Court.exists?(inactive_court.id)).to be false
    end

    it 'returns a success message' do
      expect(response.parsed_body['data']).to include('message' => 'Court deleted successfully')
    end
  end

  describe 'authorization restrictions' do
    let(:request_headers) { headers.merge('Authorization' => auth_token_for(customer_user)) }
    let(:request_params) do
      {
        court: {
          venue_id: venue.id,
          court_type_id: court_type.id,
          name: 'Court Unauthorized',
          description: 'Unauthorized court',
          is_active: true,
          display_order: 4
        }
      }
    end

    it 'prevents customers from creating courts' do
      post '/api/v0/courts', params: request_params.to_json, headers: request_headers
      expect(response).to have_http_status(:forbidden)
    end

    it 'prevents customers from updating courts' do
      patch "/api/v0/courts/#{active_court.id}", params: request_params.to_json, headers: request_headers
      expect(response).to have_http_status(:forbidden)
    end

    it 'prevents customers from deleting courts' do
      delete "/api/v0/courts/#{active_court.id}", headers: request_headers
      expect(response).to have_http_status(:forbidden)
    end
  end
end
