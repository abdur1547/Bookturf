# frozen_string_literal: true

module Api::V0::Courts
  class ListCourtsOperation < BaseOperation
    contract do
      params do
        optional(:page).maybe(:integer)
        optional(:per_page).maybe(:integer)
        optional(:venue_id).maybe(:integer)
        optional(:court_type_id).maybe(:integer)
        optional(:is_active).maybe(:bool)
        optional(:search).maybe(:string)
        optional(:sort).maybe(:string)
        optional(:order).maybe(:string)
      end
    end

    def call(params, current_user)
      @params = params
      @current_user = current_user

      @courts = Court.includes(:court_type, :venue).all
      @courts = @courts.where(venue_id: params[:venue_id]) if params[:venue_id].present?
      @courts = @courts.where(court_type_id: params[:court_type_id]) if params[:court_type_id].present?

      if params.key?(:is_active)
        if params[:is_active] == true || params[:is_active] == "true"
          @courts = @courts.active
        elsif params[:is_active] == false || params[:is_active] == "false"
          @courts = @courts.inactive
        end
      end

      @courts = search_courts(@courts, params[:search]) if params[:search].present?
      @courts = sort_courts(@courts, params[:sort], params[:order])
      @courts = paginate_courts(@courts, params[:page], params[:per_page])

      json_data = serialize
      Success(courts: @courts, json: json_data)
    end

    private

    attr_reader :params, :current_user, :courts

    def search_courts(courts, query)
      courts.where(
        "name ILIKE :term OR description ILIKE :term",
        term: "%#{query}%"
      )
    end

    def sort_courts(courts, sort_field, order_direction)
      sort_field ||= "name"
      order_direction ||= "asc"

      direction = order_direction.to_sym

      case sort_field
      when "name"
        courts.order(name: direction)
      when "created_at"
        courts.order(created_at: direction)
      when "display_order"
        courts.order(display_order: direction)
      else
        courts.order(name: :asc)
      end
    end

    def paginate_courts(courts, page, per_page)
      page ||= 1
      per_page ||= 10

      page = page.to_i
      per_page = per_page.to_i
      page = 1 if page < 1
      per_page = 10 if per_page < 1
      per_page = 100 if per_page > 100

      offset = (page - 1) * per_page
      courts.limit(per_page).offset(offset)
    end

    def serialize
      Api::V0::CourtBlueprint.render_as_hash(courts, view: :list)
    end
  end
end
