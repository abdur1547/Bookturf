class Court < ApplicationRecord
  # ============================================================================
  # ASSOCIATIONS
  # ============================================================================
  belongs_to :venue
  belongs_to :court_type

  # Phase 5: Bookings
  # has_many :bookings, dependent: :restrict_with_error

  # Phase 6: Court closures
  # has_many :court_closures, dependent: :destroy

  # ============================================================================
  # VALIDATIONS
  # ============================================================================
  validates :name, presence: true
  validates :name, uniqueness: { scope: :venue_id }

  # ============================================================================
  # CALLBACKS
  # ============================================================================
  # None needed

  # ============================================================================
  # SCOPES
  # ============================================================================
  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }
  scope :by_display_order, -> { order(:display_order, :name) }
  scope :of_type, ->(court_type) { where(court_type: court_type) }

  # ============================================================================
  # INSTANCE METHODS
  # ============================================================================

  def sport_name
    court_type.name
  end

  def full_name
    "#{name} (#{sport_name})"
  end

  def activate!
    update(is_active: true)
  end

  def deactivate!
    update(is_active: false)
  end

  # Check if court is available at a specific time
  # (Will be enhanced in Phase 5 with booking checks)
  def available_at?(start_time, end_time)
    return false unless is_active?
    # Phase 5: Add booking overlap check
    # Phase 6: Add court closure check
    true
  end
end
