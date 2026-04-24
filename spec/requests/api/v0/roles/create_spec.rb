# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "POST /api/v0/roles", type: :request do
  let(:headers) { { "Content-Type" => "application/json" } }

  # Create system roles
  let(:owner_role) { create(:role, :owner) }
  let(:admin_role) { create(:role, :admin) }
  let(:receptionist_role) { create(:role, :receptionist) }
  let(:customer_role) { create(:role, :customer) }

  # Create test users
  let(:owner_user) { create(:user, email: "owner@example.com") }
  let(:admin_user) { create(:user, email: "admin@example.com") }
  let(:receptionist_user) { create(:user, email: "receptionist@example.com") }
  let(:customer_user) { create(:user, email: "customer@example.com") }

  # Create permissions for testing
  let(:create_bookings_permission) { create(:permission, :create_bookings) }
  let(:read_bookings_permission) { create(:permission, :read_bookings) }
  let(:manage_bookings_permission) { create(:permission, :manage_bookings) }
  let(:read_courts_permission) { create(:permission, :read_courts) }

  before do
    # Assign roles to users
    owner_user.assign_role(owner_role)
    admin_user.assign_role(admin_role)
    receptionist_user.assign_role(receptionist_role)
    customer_user.assign_role(customer_role)
  end

  let(:endpoint) { "/api/v0/roles" }
    let(:request_headers) { headers }
    let(:role_name) { "New Custom Role" }
    let(:role_description) { "A newly created custom role" }
    let(:permission_ids) { [ create_bookings_permission.id, read_bookings_permission.id ] }

    let(:request_params) do
      {
        role: {
          name: role_name,
          description: role_description,
          permission_ids: permission_ids
        }
      }

    before do
      post endpoint, params: request_params.to_json, headers: request_headers
    end

    # SUCCESS PATHS
    context "when authenticated as owner" do
      let(:request_headers) { headers.merge("Authorization" => auth_token_for(owner_user)) }

      context "with valid complete parameters" do
        it "returns created status" do
          expect(response).to have_http_status(:created)
        end

        it "matches the create response schema" do
          expect(response).to match_json_schema("roles/create_response")
        end

        it "creates a new role" do
          expect(Role.where(name: role_name)).to exist
        end

        it "creates a custom role (not system)" do
          new_role = Role.find_by(name: role_name)
          expect(new_role.is_custom).to be true
        end

        it "returns the created role with correct attributes" do
          data = response.parsed_body["data"]
          expect(data).to include(
            "name" => "New Custom Role",
            "description" => "A newly created custom role",
            "is_custom" => true
          )
        end

        it "assigns specified permissions to the role" do
          new_role = Role.find_by(name: role_name)
          expect(new_role.permissions.count).to eq(2)
          expect(new_role.permissions.pluck(:id)).to match_array([
            create_bookings_permission.id,
            read_bookings_permission.id
          ])
        end

        it "generates a slug from name" do
          new_role = Role.find_by(name: role_name)
          expect(new_role.slug).to eq("new_custom_role")
        end

        it "includes permissions in response" do
          data = response.parsed_body["data"]
          expect(data["permissions"]).to be_an(Array)
          expect(data["permissions"].length).to eq(2)
        end
      end

      context "with valid parameters but no permissions" do
        let(:permission_ids) { nil }

        it "creates the role successfully" do
          expect(response).to have_http_status(:created)
        end

        it "creates role with no permissions" do
          new_role = Role.find_by(name: role_name)
          expect(new_role.permissions.count).to eq(0)
        end
      end

      context "with empty permission_ids array" do
        let(:permission_ids) { [] }

        it "creates the role successfully" do
          expect(response).to have_http_status(:created)
        end

        it "creates role with no permissions" do
          new_role = Role.find_by(name: role_name)
          expect(new_role.permissions.count).to eq(0)
        end
      end

      context "with minimal parameters (only name)" do
        let(:role_description) { nil }
        let(:permission_ids) { nil }

        it "creates the role successfully" do
          expect(response).to have_http_status(:created)
        end

        it "creates role without description" do
          new_role = Role.find_by(name: role_name)
          expect(new_role.description).to be_nil
        end
      end

      context "with name containing special characters" do
        let(:role_name) { "Manager & Supervisor" }

        it "creates the role successfully" do
          expect(response).to have_http_status(:created)
        end

        it "generates valid slug" do
          new_role = Role.find_by(name: role_name)
          expect(new_role.slug).to eq("manager_supervisor")
        end
      end

      context "with very long role name" do
        let(:role_name) { "A" * 255 }

        it "creates the role successfully" do
          expect(response).to have_http_status(:created)
        end
      end

      context "with duplicate permission_ids in array" do
        let(:permission_ids) do
          [
            create_bookings_permission.id,
            create_bookings_permission.id,
            read_bookings_permission.id
          ]
        end

        it "creates the role successfully" do
          expect(response).to have_http_status(:created)
        end

        it "handles duplicates gracefully (only adds once)" do
          new_role = Role.find_by(name: role_name)
          expect(new_role.permissions.count).to eq(2)
        end
      end
    end

    # FAILURE PATHS
    context "when authenticated as owner with invalid parameters" do
      let(:request_headers) { headers.merge("Authorization" => auth_token_for(owner_user)) }

      context "when name is missing" do
        let(:role_name) { nil }

        it "returns unprocessable entity status" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "matches error response schema" do
          expect(response).to match_json_schema("error_response")
        end

        it "includes validation errors" do
          expect(response.parsed_body["errors"]).to be_present
        end

        it "does not create a role" do
          expect(Role.where(name: nil)).not_to exist
        end
      end

      context "when name is empty string" do
        let(:role_name) { "" }

        it "returns unprocessable entity status" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "does not create a role" do
          expect(Role.where(name: "")).not_to exist
        end
      end

      context "when name is blank (whitespace only)" do
        let(:role_name) { "   " }

        it "returns unprocessable entity status" do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when name already exists" do
        let!(:existing_role) { create(:role, name: "UniqueExistingRole1") }
        let(:role_name) { "UniqueExistingRole1" }

        it "returns unprocessable entity status" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "includes uniqueness error" do
          expect(response.parsed_body["errors"]).to be_present
        end
      end

      context "when name exists with different case" do
        let!(:existing_role) { create(:role, name: "Test Duplicate") }
        let(:role_name) { "test duplicate" }

        it "creates role successfully (case-sensitive uniqueness)" do
          expect(response).to have_http_status(:created)
        end
      end

      context "when permission_ids contain invalid IDs" do
        let(:permission_ids) { [ 99999, 88888 ] }

        it "returns unprocessable entity status" do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when permission_ids contain mix of valid and invalid IDs" do
        let(:permission_ids) { [ create_bookings_permission.id, 99999 ] }

        it "returns unprocessable entity status" do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when permission_ids is invalid format (string)" do
        let(:permission_ids) { "not_an_array" }

        it "returns unprocessable entity status" do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when role parameter is missing entirely" do
        let(:request_params) { {} }

        it "returns unprocessable entity status" do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when authenticated as admin (insufficient permissions)" do
      let(:request_headers) { headers.merge("Authorization" => auth_token_for(admin_user)) }

      it "returns forbidden status" do
        expect(response).to have_http_status(:forbidden)
      end

      it "matches error response schema" do
        expect(response).to match_json_schema("error_response")
      end

      it "does not create a role" do
        expect(Role.where(name: role_name)).not_to exist
      end
    end

    context "when authenticated as receptionist" do
      let(:request_headers) { headers.merge("Authorization" => auth_token_for(receptionist_user)) }

      it "returns forbidden status" do
        expect(response).to have_http_status(:forbidden)
      end

      it "does not create a role" do
        expect(Role.where(name: role_name)).not_to exist
      end
    end

    context "when not authenticated" do
      let(:request_headers) { headers }

      it "returns forbidden status" do
        expect(response).to have_http_status(:forbidden)
      end

      it "does not create a role" do
        expect(Role.where(name: role_name)).not_to exist
      end
    end

    context "when authenticated with invalid token" do
      let(:request_headers) { headers.merge("Authorization" => "Bearer invalid_token") }

      it "returns unauthorized status" do
        expect(response).to have_http_status(:forbidden)
      end

      it "does not create a role" do
        expect(Role.where(name: role_name)).not_to exist
      end
    end
  end
end
