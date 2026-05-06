# frozen_string_literal: true

puts "🌱 Seeding Phase 5: Venue Staff..."

owner = User.find_by!(email: 'owner@example.com')
venue = owner.owned_venues.first
unless venue
  puts "  ⚠️  No venue found — skipping staff seeding. Run venue seeds first."
  return
end

# ============================================================
# CUSTOM ROLE: Court Marshal
# Limited access for staff who oversee court activity only
# ============================================================
court_marshal_role = Role.find_or_create_by!(name: "Court Marshal", venue: venue)
court_marshal_permissions = %w[read:courts read:bookings update:bookings read:closures]
court_marshal_permissions.each do |key|
  action, resource = key.split(":")
  permission = Permission.find_by(resource: resource, action: action)
  court_marshal_role.add_permission(permission) if permission
end
puts "  ✅ Created custom role: Court Marshal (#{court_marshal_role.permissions.count} permissions)"

# ============================================================
# STAFF MEMBERS — one per role
# ============================================================
staff_data = [
  {
    email:       "manager@example.com",
    full_name:   "Sara Khan",
    phone:       "+92 300 4000001",
    role_name:   "Manager"
  },
  {
    email:       "receptionist@example.com",
    full_name:   "Ali Raza",
    phone:       "+92 300 4000002",
    role_name:   "Receptionist"
  },
  {
    email:       "staff@example.com",
    full_name:   "Nadia Malik",
    phone:       "+92 300 4000003",
    role_name:   "Staff"
  },
  {
    email:       "marshal@example.com",
    full_name:   "Umar Farooq",
    phone:       "+92 300 4000004",
    role_name:   "Court Marshal"
  }
]

staff_data.each do |data|
  user = User.find_or_create_by!(email: data[:email]) do |u|
    u.full_name             = data[:full_name]
    u.phone_number          = data[:phone]
    u.password              = "password123"
    u.password_confirmation = "password123"
    u.system_role           = :normal
  end

  role = Role.find_by!(name: data[:role_name], venue: venue)

  VenueMembership.find_or_create_by!(user: user, venue: venue) do |m|
    m.role = role
  end

  puts "  ✅ #{data[:full_name]} (#{data[:email]}) → #{data[:role_name]}"
end

puts "\n✅ Phase 5 seeding complete!"
puts "  👔 Roles: #{Role.count}"
puts "  👥 Venue memberships: #{VenueMembership.count}"
