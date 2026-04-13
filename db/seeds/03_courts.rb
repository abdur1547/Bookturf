puts "🌱 Seeding Phase 3: Court Types and Courts..."

# ============================================================
# COURT TYPES (Sports)
# ============================================================
court_types_data = [
  { name: 'Badminton', slug: 'badminton', icon: '🏸' },
  { name: 'Tennis', slug: 'tennis', icon: '🎾' },
  { name: 'Basketball', slug: 'basketball', icon: '🏀' },
  { name: 'Squash', slug: 'squash', icon: '🎾' },
  { name: 'Volleyball', slug: 'volleyball', icon: '🏐' },
  { name: 'Futsal', slug: 'futsal', icon: '⚽' },
  { name: 'Table Tennis', slug: 'table-tennis', icon: '🏓' }
]

court_types = {}
court_types_data.each do |data|
  court_type = CourtType.find_or_create_by!(slug: data[:slug]) do |ct|
    ct.name = data[:name]
    ct.icon = data[:icon]
    ct.description = "#{data[:name]} court"
  end
  court_types[data[:slug]] = court_type
  puts "  ✅ Created court type: #{court_type.name}"
end

# ============================================================
# COURTS
# ============================================================
venue = Venue.first

unless venue
  puts "  ⚠️  No venue found. Run Phase 2 seeds first."
  exit
end

courts_data = [
  { name: 'Badminton Court 1', type: 'badminton', order: 1 },
  { name: 'Badminton Court 2', type: 'badminton', order: 2 },
  { name: 'Badminton Court 3', type: 'badminton', order: 3 },
  { name: 'Tennis Court 1', type: 'tennis', order: 4 },
  { name: 'Tennis Court 2', type: 'tennis', order: 5 },
  { name: 'Basketball Court', type: 'basketball', order: 6 }
]

courts_data.each do |data|
  court = Court.find_or_create_by!(venue: venue, name: data[:name]) do |c|
    c.court_type = court_types[data[:type]]
    c.display_order = data[:order]
    c.is_active = true
    c.description = "Premium #{court_types[data[:type]].name} court with professional flooring"
  end
  puts "  ✅ Created court: #{court.full_name}"
end

# ============================================================
# PRICING RULES
# ============================================================

# Badminton Pricing
badminton = court_types['badminton']

# Weekday Morning (Mon-Fri, 6 AM - 12 PM): 1500 PKR/hour
PricingRule.find_or_create_by!(
  venue: venue,
  court_type: badminton,
  name: 'Weekday Morning'
) do |pr|
  pr.price_per_hour = 1500
  pr.start_time = '06:00'
  pr.end_time = '12:00'
  pr.priority = 1
  pr.is_active = true
end

# Weekday Afternoon (Mon-Fri, 12 PM - 6 PM): 1200 PKR/hour
PricingRule.find_or_create_by!(
  venue: venue,
  court_type: badminton,
  name: 'Weekday Afternoon'
) do |pr|
  pr.price_per_hour = 1200
  pr.start_time = '12:00'
  pr.end_time = '18:00'
  pr.priority = 1
  pr.is_active = true
end

# Weekday Evening - PEAK (Mon-Fri, 6 PM - 11 PM): 2500 PKR/hour
PricingRule.find_or_create_by!(
  venue: venue,
  court_type: badminton,
  name: 'Weekday Evening (Peak)'
) do |pr|
  pr.price_per_hour = 2500
  pr.start_time = '18:00'
  pr.end_time = '23:00'
  pr.priority = 2  # Higher priority for peak time
  pr.is_active = true
end

# Weekend (Sat-Sun, All Day): 2000 PKR/hour
[ 0, 6 ].each do |day|  # 0 = Sunday, 6 = Saturday
  day_name = Date::DAYNAMES[day]
  PricingRule.find_or_create_by!(
    venue: venue,
    court_type: badminton,
    name: "#{day_name} All Day",
    day_of_week: day
  ) do |pr|
    pr.price_per_hour = 2000
    pr.priority = 1
    pr.is_active = true
  end
end

puts "  ✅ Created pricing rules for Badminton"

# Tennis Pricing (Higher rates)
tennis = court_types['tennis']

PricingRule.find_or_create_by!(
  venue: venue,
  court_type: tennis,
  name: 'Standard Rate'
) do |pr|
  pr.price_per_hour = 3000
  pr.priority = 0
  pr.is_active = true
end

puts "  ✅ Created pricing rules for Tennis"

# Basketball Pricing
basketball = court_types['basketball']

PricingRule.find_or_create_by!(
  venue: venue,
  court_type: basketball,
  name: 'Standard Rate'
) do |pr|
  pr.price_per_hour = 2500
  pr.priority = 0
  pr.is_active = true
end

puts "  ✅ Created pricing rules for Basketball"

puts "\n✅ Phase 3 seeding complete!"
puts "  📊 Court Types: #{CourtType.count}"
puts "  🏟️  Courts: #{Court.count}"
puts "  💰 Pricing Rules: #{PricingRule.count}"
