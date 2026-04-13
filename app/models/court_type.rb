class CourtType < ApplicationRecord
  # ============================================================================
  # ASSOCIATIONS
  # ============================================================================
  has_many :courts, dependent: :restrict_with_error
  has_many :pricing_rules, dependent: :destroy

  # ============================================================================
  # VALIDATIONS
  # ============================================================================
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :slug, format: { with: /\A[a-z0-9\-]+\z/, message: "only lowercase letters, numbers, and hyphens" }

  # ============================================================================
  # CALLBACKS
  # ============================================================================
  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  # ============================================================================
  # SCOPES
  # ============================================================================
  scope :alphabetical, -> { order(:name) }

  # ============================================================================
  # INSTANCE METHODS
  # ============================================================================

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug = name.parameterize
  end
end
