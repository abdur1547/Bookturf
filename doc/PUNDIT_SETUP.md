# Pundit Authorization Setup

**Date:** April 7, 2026  
**Status:** ✅ Configured and Ready

---

## Overview

Pundit has been successfully installed and configured for authorization/policy management in the Bookturf application. No specific policies have been created yet - only the base setup.

---

## What Was Installed

### 1. **Gem Installation**
- Added `pundit (~> 2.4)` to Gemfile
- Installed version: `2.5.2`

### 2. **Core Files Created**

#### Application Policy
- **File:** `app/policies/application_policy.rb`
- **Purpose:** Base policy class that all specific policies will inherit from
- **Default behavior:** Denies all actions by default (secure by default)

#### RSpec Support
- **File:** `spec/support/pundit.rb`
- **Purpose:** Configures Pundit matchers for RSpec tests
- **Includes:** `Pundit::RSpec::Matchers`

#### Policy Spec
- **File:** `spec/policies/application_policy_spec.rb`
- **Purpose:** Tests for ApplicationPolicy
- **Status:** ✅ 8 examples, 0 failures

### 3. **ApplicationController Integration**

```ruby
class ApplicationController < ActionController::Base
  include Pundit::Authorization
  
  # Rescue from unauthorized access
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  
  private
  
  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end
end
```

---

## How It Works

### Authorization Flow

1. **Controller calls policy:**
   ```ruby
   authorize @booking
   # or
   authorize @booking, :update?
   ```

2. **Pundit finds the policy:**
   - Looks for `BookingPolicy` class
   - Falls back to `ApplicationPolicy` if not found

3. **Policy checks permission:**
   ```ruby
   class BookingPolicy < ApplicationPolicy
     def update?
       user.admin? || record.user == user
     end
   end
   ```

4. **If unauthorized:**
   - Raises `Pundit::NotAuthorizedError`
   - Caught by `ApplicationController`
   - Shows flash message and redirects

---

## Creating Policies

When ready to create policies, use the generator:

```bash
# Generate a policy for a model
rails generate pundit:policy booking

# This creates:
# - app/policies/booking_policy.rb
# - spec/policies/booking_policy_spec.rb
```

### Policy Template

```ruby
class BookingPolicy < ApplicationPolicy
  # Scopes what records the user can see
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(user: user)
      end
    end
  end

  # Who can view the list?
  def index?
    user.can?(:read, :bookings)
  end

  # Who can view this specific booking?
  def show?
    user.can?(:read, :bookings) || record.user == user
  end

  # Who can create bookings?
  def create?
    user.can?(:create, :bookings)
  end

  # Who can update this booking?
  def update?
    user.can?(:update, :bookings) || record.user == user
  end

  # Who can delete this booking?
  def destroy?
    user.can?(:delete, :bookings)
  end
end
```

---

## Usage in Controllers

### Basic Authorization

```ruby
class BookingsController < ApplicationController
  def index
    @bookings = policy_scope(Booking) # Uses Scope to filter records
  end

  def show
    @booking = Booking.find(params[:id])
    authorize @booking # Calls BookingPolicy#show?
  end

  def create
    @booking = Booking.new(booking_params)
    authorize @booking # Calls BookingPolicy#create?
    
    if @booking.save
      redirect_to @booking
    else
      render :new
    end
  end

  def update
    @booking = Booking.find(params[:id])
    authorize @booking # Calls BookingPolicy#update?
    
    if @booking.update(booking_params)
      redirect_to @booking
    else
      render :edit
    end
  end
end
```

### Checking Permissions in Views

```erb
<% if policy(@booking).update? %>
  <%= link_to "Edit", edit_booking_path(@booking) %>
<% end %>

<% if policy(@booking).destroy? %>
  <%= link_to "Delete", @booking, method: :delete %>
<% end %>
```

### Headless Policies (No Model)

For actions without a model:

```ruby
class DashboardPolicy
  attr_reader :user, :dashboard

  def initialize(user, dashboard)
    @user = user
    @dashboard = dashboard
  end

  def show?
    user.admin? || user.owner?
  end
end

# In controller:
authorize :dashboard, :show?
```

---

## Testing Policies

### RSpec Examples

```ruby
RSpec.describe BookingPolicy, type: :policy do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:booking) { create(:booking, user: user) }

  subject { described_class }

  permissions :show? do
    it "allows the booking owner" do
      expect(subject).to permit(user, booking)
    end

    it "allows admins" do
      expect(subject).to permit(admin, booking)
    end

    it "denies other users" do
      other_user = create(:user)
      expect(subject).not_to permit(other_user, booking)
    end
  end

  permissions :update? do
    it "allows the booking owner" do
      expect(subject).to permit(user, booking)
    end

    it "denies other users" do
      other_user = create(:user)
      expect(subject).not_to permit(other_user, booking)
    end
  end
end
```

---

## Integration with Existing Role System

Pundit works seamlessly with the existing Phase 4 Roles & Permissions:

```ruby
class BookingPolicy < ApplicationPolicy
  def create?
    # Use the existing User#can? method
    user.can?(:create, :bookings)
  end

  def update?
    # Combine role-based and ownership checks
    user.can?(:update, :bookings) || record.user == user
  end

  def destroy?
    # Only specific roles can delete
    user.can?(:delete, :bookings)
  end
end
```

---

## Benefits

✅ **Secure by Default** - All actions denied unless explicitly permitted  
✅ **Centralized Logic** - Authorization logic in one place  
✅ **Easy Testing** - Simple RSpec matchers for policy testing  
✅ **Scope Filtering** - Automatically filter records based on permissions  
✅ **Integration Ready** - Works with existing Phase 4 role system  
✅ **View Helpers** - Check permissions directly in views  

---

## Next Steps

When ready to implement authorization:

1. **Create policies for each model:**
   ```bash
   rails generate pundit:policy booking
   rails generate pundit:policy court
   rails generate pundit:policy venue
   ```

2. **Add authorize calls in controllers:**
   ```ruby
   authorize @resource
   ```

3. **Write policy tests:**
   ```ruby
   RSpec.describe BookingPolicy, type: :policy do
     # ... tests
   end
   ```

4. **Use in views:**
   ```erb
   <% if policy(@booking).update? %>
     <!-- show edit button -->
   <% end %>
   ```

---

## References

- **Pundit Documentation:** https://github.com/varvet/pundit
- **Phase 4 Roles & Permissions:** `doc/DB_PHASE_4_ROLES.md`
- **ApplicationPolicy:** `app/policies/application_policy.rb`

---

*Setup completed on April 7, 2026*
