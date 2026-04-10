# frozen_string_literal: true

puts "🌱 Seeding Phase 4: Roles & Permissions..."

# ============================================================
# PERMISSIONS
# ============================================================
permissions_data = {
  bookings: %w[create read update delete manage],
  courts: %w[create read update delete],
  venues: %w[read update manage],
  users: %w[create read update delete],
  roles: %w[create read update delete],
  reports: %w[read manage],
  settings: %w[read update],
  pricing: %w[create read update delete],
  closures: %w[create read update delete],
  notifications: %w[read create]
}

permissions = {}
permissions_data.each do |resource, actions|
  actions.each do |action|
    permission = Permission.find_or_create_by!(
      resource: resource.to_s,
      action: action
    ) do |p|
      p.description = "Can #{action} #{resource}"
    end
    permissions["#{action}:#{resource}"] = permission
    puts "  ✅ Created permission: #{permission.name}"
  end
end

# ============================================================
# SYSTEM ROLES
# ============================================================

# OWNER Role
owner_role = Role.find_or_create_by!(slug: 'owner') do |r|
  r.name = 'Owner'
  r.description = 'Venue owner with full control'
  r.is_custom = false
end

# Owner gets ALL permissions
Permission.all.each do |permission|
  owner_role.add_permission(permission)
end

puts "  ✅ Created role: Owner (#{owner_role.permissions.count} permissions)"

# ADMIN Role
admin_role = Role.find_or_create_by!(slug: 'admin') do |r|
  r.name = 'Admin'
  r.description = 'Administrator with most permissions'
  r.is_custom = false
end

admin_permissions = [
  'manage:bookings', 'manage:courts', 'create:users', 'read:users',
  'update:users', 'read:roles', 'manage:reports', 'read:settings',
  'update:settings', 'manage:pricing', 'manage:closures',
  'read:notifications', 'create:notifications', 'read:venues', 'update:venues'
]

admin_permissions.each do |perm_name|
  admin_role.add_permission(permissions[perm_name]) if permissions[perm_name]
end

puts "  ✅ Created role: Admin (#{admin_role.permissions.count} permissions)"

# RECEPTIONIST Role
receptionist_role = Role.find_or_create_by!(slug: 'receptionist') do |r|
  r.name = 'Receptionist'
  r.description = 'Front desk staff managing bookings'
  r.is_custom = false
end

receptionist_permissions = [
  'manage:bookings', 'read:courts', 'create:closures', 'read:closures',
  'read:users', 'read:reports', 'read:settings', 'read:notifications'
]

receptionist_permissions.each do |perm_name|
  receptionist_role.add_permission(permissions[perm_name]) if permissions[perm_name]
end

puts "  ✅ Created role: Receptionist (#{receptionist_role.permissions.count} permissions)"

# STAFF Role
staff_role = Role.find_or_create_by!(slug: 'staff') do |r|
  r.name = 'Staff'
  r.description = 'General staff with basic access'
  r.is_custom = false
end

staff_permissions = [
  'read:bookings', 'read:courts', 'read:users',
  'read:closures', 'read:notifications'
]

staff_permissions.each do |perm_name|
  staff_role.add_permission(permissions[perm_name]) if permissions[perm_name]
end

puts "  ✅ Created role: Staff (#{staff_role.permissions.count} permissions)"

# CUSTOMER Role
customer_role = Role.find_or_create_by!(slug: 'customer') do |r|
  r.name = 'Customer'
  r.description = 'Regular user who books courts'
  r.is_custom = false
end

customer_permissions = [
  'create:bookings', 'read:bookings', 'update:bookings',
  'read:courts', 'read:notifications'
]

customer_permissions.each do |perm_name|
  customer_role.add_permission(permissions[perm_name]) if permissions[perm_name]
end

puts "  ✅ Created role: Customer (#{customer_role.permissions.count} permissions)"

# ============================================================
# ASSIGN ROLES TO EXISTING USERS (if any)
# ============================================================

# Assign customer role as default to any existing users without roles
User.find_each do |user|
  if user.roles.empty?
    user.assign_role(customer_role)
    puts "  ✅ Assigned 'customer' role to #{user.email}"
  end
end

puts "\n✅ Phase 4 seeding complete!"
puts "  👥 Roles: #{Role.count}"
puts "  🔑 Permissions: #{Permission.count}"
puts "  🔗 Role-Permission assignments: #{RolePermission.count}"
puts "  👤 User-Role assignments: #{UserRole.count}"
