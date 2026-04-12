# Operations Code Organization Guide

## Table of Contents
1. [Overview](#overview)
2. [Architecture Principles](#architecture-principles)
3. [Parameter Handling](#parameter-handling)
4. [Step-by-Step Structure Pattern](#step-by-step-structure-pattern)
5. [Authorization Integration](#authorization-integration)
6. [Service Layer Integration](#service-layer-integration)
7. [JSON Serialization Patterns](#json-serialization-patterns)
8. [Error Handling Strategies](#error-handling-strategies)
9. [Real-World Examples](#real-world-examples)
10. [Best Practices](#best-practices)

---

## Overview

Operations provide a structured, consistent way to handle business logic in Rails applications. They encapsulate the complete workflow for a single use case, from authorization through execution to response serialization.

### Key Responsibilities

An operation should handle:
1. **Parameter Extraction** - Extract and validate required parameters from input
2. **Authorization** - Verify the user has permission to perform the action
3. **Business Logic** - Orchestrate services and models to execute the action
4. **Serialization** - Format the response data for API consumption
5. **Error Handling** - Provide consistent error responses

### Controller-Operation-Service Flow

```
┌─────────────┐
│ Controller  │  → Minimal: Call operation & handle response
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Operation   │  → Orchestrate: Authorize → Execute → Serialize
└──────┬──────┘
       │
       ├────────────────────┐
       ▼                    ▼
┌─────────────┐      ┌─────────────┐
│  Services   │      │   Policies  │
└─────────────┘      └─────────────┘
```

---

## Architecture Principles

### 1. **Single Responsibility**
Each operation handles exactly one use case (e.g., CreateRole, UpdateRole, ListRoles).

### 2. **Railway-Oriented Programming**
Operations use `Success()` and `Failure()` monads to create predictable control flow:
- Success continues to next step
- Failure immediately stops execution and returns

### 3. **Consistent Return Values**
All operations return a `Result` object with:
```ruby
{
  success: true/false,
  value: { raw_data: ..., json: ... },  # on success
  errors: ...                             # on failure
}
```

### 4. **Separation of Concerns**
- **Operations**: Orchestration, parameter extraction, and workflow
- **Services**: Reusable business logic
- **Policies**: Authorization rules
- **Blueprints**: JSON serialization
- **Controllers**: Minimal - only call operations and handle responses

### 5. **Parameter Handling in Operations**
Operations are responsible for extracting and validating **ALL** parameters through contracts:
- **Controllers ALWAYS pass full params**: Use `params.to_unsafe_h` for EVERY action
- **Controllers NEVER extract**: Not even simple values like `params[:id]`
- **ALL operations MUST have contracts**: Even if only validating a single `:id` parameter
- **Operations extract params**: Pull needed values from the params hash
- **Validation is mandatory**: Every parameter must be validated via contract

This centralizes all parameter logic in operations, keeping controllers as pure pass-through layers.

**Golden Rule:** If a controller touches params, it only converts to unsafe hash. Period.

---

## Parameter Handling

### Principle: Operations Handle All Parameter Logic

**Controllers** should NOT:
- ❌ Use `before_action` to set instance variables
- ❌ Use `params.permit()` or `params.require()`  
- ❌ Filter or transform parameters
- ❌ Extract ANY values from params (not even `params[:id]`)
- ❌ Pass anything other than `params.to_unsafe_h`

**Controllers** should ONLY:
- ✅ Pass `params.to_unsafe_h` to operations for ALL actions
- ✅ Call operations and handle responses
- ✅ That's it. Nothing else.

**Operations** MUST:
- ✅ Have a contract for EVERY operation (no exceptions)
- ✅ Define required/optional parameters via contracts
- ✅ Extract needed values from params hash
- ✅ Validate parameter structure and types
- ✅ Transform parameters if needed

### Pattern: Controllers Pass Raw Params

```ruby
# ❌ OLD PATTERN - Don't do this
class RolesController < ApiController
  before_action :set_role_id, only: [:show, :update, :destroy]
  
  def create
    result = Operation.call(role_params, current_user)
  end
  
  private
  
  def set_role_id
    @role_id = params[:id]
  end
  
  def role_params
    params.permit(role: [:name, :description]).to_h.deep_symbolize_keys
  end
end

# ✅ NEW PATTERN - Do this
class RolesController < ApiController
  def create
    result = Api::V0::Roles::CreateRoleOperation.call(params.to_unsafe_h, current_user)
    handle_operation_response(result, :created)
  end
  
  def show
    result = Api::V0::Roles::GetRoleOperation.call(params.to_unsafe_h, current_user)
    handle_operation_response(result)
  end
  
  def update
    result = Api::V0::Roles::UpdateRoleOperation.call(params.to_unsafe_h, current_user)
    handle_operation_response(result)
  end
  
  def destroy
    result = Api::V0::Roles::DeleteRoleOperation.call(params.to_unsafe_h, current_user)
    handle_operation_response(result)
  end
end
```

### Pattern: Operations Extract Parameters

**IMPORTANT:** Every operation MUST have a contract, even for simple operations that only need an ID.

```ruby
# Example: Simple show/destroy operation with just ID
class GetRoleOperation < BaseOperation
  # Contract is MANDATORY - even for single parameter
  contract do
    params do
      required(:id).filled(:string)
    end
  end

  def call(params, current_user)
    @params = params
    @current_user = current_user
    
    # Extract the ID from params
    @role_id = params[:id]
    
    # Use extracted ID
    @role = Role.find_by(id: @role_id)
    # ...
  end
end

# Example: Create operation with nested params
class CreateRoleOperation < BaseOperation
  # Define what parameters are expected
  contract do
    params do
      required(:role).hash do
        required(:name).filled(:string)
        optional(:description).maybe(:string)
        optional(:permission_ids).maybe(:array)
      end
    end
  end

  def call(params, current_user)
    @params = params
    @current_user = current_user
    
    # Extract the nested role params
    role_params = params[:role]
    
    # Use extracted params
    result = Roles::CreateService.call(
      params: role_params.except(:permission_ids),
      created_by: current_user
    )
    # ...
  end
end

# Example: Update operation with ID + nested params
class UpdateRoleOperation < BaseOperation
  contract do
    params do
      required(:id).filled(:string)  # Extract ID from params
      required(:role).hash do
        optional(:name).filled(:string)
        optional(:description).maybe(:string)
      end
    end
  end

  def call(params, current_user)
    @params = params
    @current_user = current_user
    @role_id = params[:id]  # Operation extracts the ID
    
    # Find resource using extracted ID
    @role = Role.find_by(id: @role_id)
    # ...
  end
end
```

### Benefits of This Approach

1. **Single Responsibility**: Operations own all parameter logic
2. **Testability**: Easier to test parameter extraction in operations
3. **Consistency**: All parameter rules in one place (the contract)
4. **Thin Controllers**: Controllers become trivial pass-through layers (literally just 2 lines per action)
5. **Flexibility**: Operations can transform params as needed
6. **Security**: Contract validation happens before any business logic
7. **No Exceptions**: EVERY operation has a contract - predictable and consistent
8. **Type Safety**: All parameters are validated at the operation boundary

### Contract Examples

**RULE:** Every operation MUST have a contract. No exceptions.

#### Simple Show Operation (ID only)
```ruby
contract do
  params do
    required(:id).filled(:string)
  end
end
```

#### Simple Delete Operation (ID only)
```ruby
contract do
  params do
    required(:id).filled(:string)
  end
end
```

#### Simple Index Operation
```ruby
contract do
  params do
    optional(:type).maybe(:string)
    optional(:sort).maybe(:string)
  end
end
```

#### Create with Nested Params
```ruby
contract do
  params do
    required(:role).hash do
      required(:name).filled(:string)
      optional(:description).maybe(:string)
      optional(:permission_ids).maybe(:array)
    end
  end
end
```

#### Update with ID
```ruby
contract do
  params do
    required(:id).filled(:string)
    required(:role).hash do
      optional(:name).filled(:string)
      optional(:description).maybe(:string)
    end
  end
end
```

---

## Step-by-Step Structure Pattern

### Template Structure

```ruby
module Api::V0::ResourceName
  class ActionOperation < BaseOperation
    # 1. Contract Definition (if needed)
    contract do
      params do
        # Define validation rules
      end
    end

    # 2. Main Execution Method
    def call(*args)
      # Store arguments as instance variables
      @arg1, @arg2, @current_user = args
      
      # Execute steps in order
      # Step 1: Authorization
      return Failure(:unauthorized) unless authorize
      
      # Step 2: Find/validate resources (if needed)
      return Failure(error: "Not found") unless load_resource
      
      # Step 3: Execute business logic
      return Failure(errors: result.error) unless execute_business_logic
      
      # Step 4: Serialize response
      json_data = serialize
      
      # Step 5: Return success with both raw and serialized data
      Success(resource: @resource, json: json_data)
    end

    private

    attr_reader :arg1, :arg2, :current_user, :resource

    # 3. Helper Methods (one per step)
    def authorize
      PolicyClass.new(current_user, resource_or_class).action?
    end

    def load_resource
      @resource = ResourceModel.find_by(id: resource_id)
    end

    def execute_business_logic
      # Call services or perform operations
    end

    def serialize
      Api::V0::ResourceBlueprint.render_as_hash(resource, view: :detailed)
    end
  end
end
```

### Step Ordering Guidelines

**Always follow this order:**
1. **Store arguments** - Assign to instance variables for clarity
2. **Authorization** - Check permissions first (fail fast)
3. **Resource loading** - Find and validate required records
4. **Business logic** - Execute services and operations
5. **Serialization** - Format the final response
6. **Return success** - Include both raw data and JSON

### Why This Order?

- **Authorization first**: No point loading resources if user can't access them
- **Resource loading second**: Need resources before business logic
- **Business logic third**: Core operation execution
- **Serialization last**: Only serialize if everything succeeded

---

## Authorization Integration

### Pattern: Authorization as First Step

Authorization is **always** the first step after storing arguments.

### Implementation

```ruby
def call(params, current_user)
  @params = params
  @current_user = current_user

  # Step 1: Authorization - ALWAYS FIRST
  return Failure(:unauthorized) unless authorize

  # Continue with other steps...
end

private

def authorize
  PolicyClass.new(current_user, resource_or_class).action_name?
end
```

### Authorization Return Types

**For class-level actions (index, create):**
```ruby
def authorize
  RolePolicy.new(current_user, Role).create?
end
```

**For instance-level actions (show, update, destroy):**
```ruby
def authorize
  RolePolicy.new(current_user, role).update?
end
```

### Important Notes

1. **Return boolean**: Authorization methods return `true` or `false`
2. **Use policy methods**: Don't inline authorization logic
3. **Fail with `:unauthorized`**: Always use the symbol for consistency
4. **Early return**: Stop execution immediately if unauthorized

### Example: Index Action

```ruby
def call(params, current_user)
  @params = params
  @current_user = current_user

  # Authorize before querying
  return Failure(:unauthorized) unless authorize

  @roles = filter_and_load_roles
  json_data = serialize

  Success(roles: @roles, json: json_data)
end

private

def authorize
  RolePolicy.new(current_user, Role).index?
end
```

### Example: Update Action

```ruby
def call(params, role_id, current_user)
  @params = params
  @role_id = role_id
  @current_user = current_user

  # Load resource first (needed for authorization)
  @role = Role.find_by(id: role_id)
  return Failure(error: "Role not found") unless @role

  # Then authorize against the loaded resource
  return Failure(:unauthorized) unless authorize

  # Continue with update logic...
end

private

def authorize
  RolePolicy.new(current_user, role).update?
end
```

---

## Service Layer Integration

### When to Use Services

Services handle **reusable business logic** that:
- Might be used by multiple operations
- Has complex business rules
- Performs data manipulation
- Handles external integrations

### Pattern: Service Calls in Operations

```ruby
# Step: Execute business logic via service
result = ResourceName::CreateService.call(
  params: processed_params,
  created_by: current_user
)

return Failure(errors: result.error) unless result.success?

@resource = result.data
```

### Service Integration Examples

#### Example 1: Create with Validation

```ruby
def call(params, current_user)
  @params = params
  @current_user = current_user
  
  return Failure(:unauthorized) unless authorize

  # Call service to handle creation logic
  result = Roles::CreateService.call(
    params: params[:role].except(:permission_ids),
    created_by: current_user
  )

  return Failure(errors: result.error) unless result.success?

  @role = result.data
  
  # More steps...
  
  Success(role: @role, json: serialize)
end
```

#### Example 2: Multi-Service Orchestration

```ruby
def call(params, current_user)
  @params = params
  @current_user = current_user
  role_params = params[:role]
  
  return Failure(:unauthorized) unless authorize

  # Service 1: Create the role
  result = Roles::CreateService.call(
    params: role_params.except(:permission_ids),
    created_by: current_user
  )

  return Failure(errors: result.error) unless result.success?

  @role = result.data

  # Service 2: Assign permissions (conditional)
  if role_params[:permission_ids].present?
    assign_result = Roles::AssignPermissionsService.call(
      role: @role,
      permission_ids: role_params[:permission_ids],
      assigned_by: current_user
    )

    return Failure(errors: assign_result.error) unless assign_result.success?
    
    # Reload to get fresh associations
    @role.reload
  end

  json_data = serialize

  Success(role: @role, json: json_data)
end
```

#### Example 3: Service with Post-Processing

```ruby
def call(params, role_id, current_user)
  @params = params
  @role_id = role_id
  @current_user = current_user

  @role = Role.find_by(id: role_id)
  return Failure(error: "Role not found") unless @role

  return Failure(:unauthorized) unless authorize

  # Call update service
  result = Roles::UpdateService.call(
    role: @role,
    params: params[:role],
    updated_by: current_user
  )

  return Failure(errors: result.error) unless result.success?

  # Reload to ensure fresh data
  @role = result.data
  @role.reload

  json_data = serialize

  Success(role: @role, json: json_data)
end
```

### Service Response Handling

Services should return a consistent structure:

```ruby
# Success case
OpenStruct.new(
  success?: true,
  data: <resource_object>
)

# Failure case
OpenStruct.new(
  success?: false,
  error: "Error message" # or { field: ["error"] }
)
```

### Best Practices

1. **Always check service results**: Use `return Failure(...) unless result.success?`
2. **Extract service data**: Store in instance variable for later use
3. **Reload if needed**: After updates, reload associations
4. **Pass context**: Always include `current_user` or actor information
5. **Handle service errors**: Map service errors to operation failures

---

## JSON Serialization Patterns

### Principle: Serialize as Final Step

Serialization is **always** the last step before returning success. Operations return both raw data and serialized JSON.

### Standard Serialization Pattern

```ruby
def call(*args)
  # ... assignment, authorization, business logic ...
  
  # Last step: Serialize
  json_data = serialize
  
  Success(resource: @resource, json: json_data)
end

private

def serialize
  Api::V0::ResourceBlueprint.render_as_hash(@resource, view: :detailed)
end
```

### Return Structure

Operations return a hash with:
- **Raw data**: The actual ActiveRecord object(s)
- **JSON data**: The serialized hash ready for API response

```ruby
Success(
  resource: @role,           # Raw ActiveRecord object
  json: { id: 1, name: ... } # Serialized hash
)
```

### Why Return Both?

1. **Flexibility**: Controller can use raw data for meta operations
2. **Testing**: Easier to test both data and serialization
3. **Logging**: Can log raw data without serialization overhead
4. **Future-proofing**: Enables response format changes

### Blueprint View Selection

#### List/Index Operations
```ruby
def serialize
  Api::V0::RoleBlueprint.render_as_hash(roles, view: :list)
end
```

#### Show/Create/Update Operations
```ruby
def serialize
  Api::V0::RoleBlueprint.render_as_hash(role, view: :detailed)
end
```

#### Delete Operations
```ruby
def serialize
  { message: "Role deleted successfully" }
end
```

### Collection Serialization

```ruby
def serialize
  # For arrays/collections
  Api::V0::RoleBlueprint.render_as_hash(@roles, view: :list)
end
```

### Custom Data Serialization

For operations that don't return a model:

```ruby
def serialize
  {
    message: "Operation completed successfully",
    additional_data: calculate_stats,
    timestamp: Time.current
  }
end

private

def calculate_stats
  # Custom data preparation
  { total: @roles.count, active: @roles.active.count }
end
```

### Serialization Examples

#### Example 1: Single Resource

```ruby
def call(role_id, current_user)
  @role_id = role_id
  @current_user = current_user

  @role = Role.find_by(id: role_id)
  return Failure(error: "Role not found") unless @role

  return Failure(:unauthorized) unless authorize

  json_data = serialize

  Success(role: @role, json: json_data)
end

private

def serialize
  Api::V0::RoleBlueprint.render_as_hash(role, view: :detailed)
end
```

#### Example 2: Collection

```ruby
def call(params, current_user)
  @params = params
  @current_user = current_user

  return Failure(:unauthorized) unless authorize

  @roles = filter_and_sort_roles
  json_data = serialize

  Success(roles: @roles, json: json_data)
end

private

def serialize
  Api::V0::RoleBlueprint.render_as_hash(roles, view: :list)
end
```

#### Example 3: Non-Model Response

```ruby
def call(role_id, current_user)
  @role_id = role_id
  @current_user = current_user

  @role = Role.find_by(id: role_id)
  return Failure(error: "Role not found") unless @role

  return Failure(:unauthorized) unless authorize

  result = Roles::DeleteService.call(role: @role, deleted_by: current_user)
  return Failure(error: result.error) unless result.success?

  json_data = serialize

  Success(role: @role, json: json_data)
end

private

def serialize
  { message: "Role deleted successfully" }
end
```

---

## Error Handling Strategies

### Error Types and Structures

Operations can return different types of failures:

#### 1. Authorization Failures
```ruby
return Failure(:unauthorized)
```

#### 2. Not Found Failures
```ruby
return Failure(error: "Resource not found")
```

#### 3. Validation Failures (from services)
```ruby
return Failure(errors: { name: ["can't be blank"] })
```

#### 4. Business Logic Failures (from services)
```ruby
return Failure(errors: "Cannot delete system role")
# or
return Failure(error: "Cannot delete system role")
```

### Controller Error Handling Pattern

Controllers inspect the error to determine the appropriate HTTP response:

```ruby
def handle_operation_response(result, success_status = :ok)
  if result.success
    render json: {
      success: true,
      data: result.value[:json]
    }, status: success_status
  else
    handle_operation_failure(result)
  end
end

def handle_operation_failure(result)
  errors = result.errors

  case errors
  when :unauthorized
    forbidden_response("You are not authorized to perform this action")
  else
    # All other errors return 422 with error details in response body
    # The error message/structure indicates what went wrong
    unprocessable_entity(errors)
  end
end
```

### Error Mapping

| Operation Error | HTTP Status | Response Helper |
|----------------|-------------|-----------------|
| `Failure(:unauthorized)` | 403 Forbidden | `forbidden_response` |
| `Failure(error: "...")` | 422 Unprocessable Entity | `unprocessable_entity` |
| `Failure(errors: {...})` | 422 Unprocessable Entity | `unprocessable_entity` |
| Validation errors | 422 Unprocessable Entity | `unprocessable_entity` |

**Note:** All non-authorization errors return 422. The error message/structure in the response body indicates the specific issue (not found, validation error, business logic error, etc.).

### Step-by-Step Error Handling

#### Step 1: Early Returns in Operations

```ruby
def call(params, current_user)
  # Each step can fail and return early
  return Failure(:unauthorized) unless authorize
  return Failure(error: "Not found") unless load_resource
  return Failure(errors: result.error) unless execute_service
  
  # Success path
  Success(...)
end
```

#### Step 2: Controller Handling

```ruby
def create
  result = Api::V0::Roles::CreateRoleOperation.call(role_params, current_user)
  handle_operation_response(result, :created)
end
```

#### Step 3: Response Generation

The `handle_operation_failure` method:
1. Receives the operation result
2. Checks if it's an authorization error (`:unauthorized`)
3. For all other errors, returns 422 with error details
4. Returns formatted JSON with correct status code

This simplified approach avoids brittle string comparisons while still providing clear error information in the response body.

### Validation Error Structure

From contract validation:
```ruby
{
  name: ["is missing", "must be filled"],
  email: ["is in invalid format"]
}
```

From service validation:
```ruby
{
  errors: {
    base: ["Cannot perform this action"],
    name: ["is already taken"]
  }
}
```

### Best Practices

1. **Consistent error format**: Use `:unauthorized` symbol for auth failures
2. **Descriptive messages**: Include context in error strings/hashes
3. **Early returns**: Fail fast at each step
4. **Map service errors**: Pass through service errors as-is
5. **Preserve error structure**: Don't transform error hashes unnecessarily
6. **Avoid string comparisons**: Don't compare error messages in controllers - rely on error structure

---

## Real-World Examples

### Example 1: Simple Read Operation (Show)

```ruby
# app/operations/api/v0/roles/get_role_operation.rb
module Api::V0::Roles
  class GetRoleOperation < BaseOperation
    # Contract is MANDATORY - even for single parameter
    contract do
      params do
        required(:id).filled(:string)
      end
    end

    def call(params, current_user)
      # Step 1: Store arguments and extract params
      @params = params
      @current_user = current_user
      @role_id = params[:id]

      # Step 2: Find resource
      @role = Role.find_by(id: @role_id)
      return Failure(error: "Role not found") unless @role

      # Step 3: Authorization
      return Failure(:unauthorized) unless authorize

      # Step 4: Serialize
      json_data = serialize

      # Step 5: Return success
      Success(role: @role, json: json_data)
    end

    private

    attr_reader :params, :role_id, :current_user, :role

    def authorize
      RolePolicy.new(current_user, role).show?
    end

    def serialize
      Api::V0::RoleBlueprint.render_as_hash(role, view: :detailed)
    end
  end
end
```

**Controller:**
```ruby
def show
  result = Api::V0::Roles::GetRoleOperation.call(params.to_unsafe_h, current_user)
  handle_operation_response(result)
end
```

---

### Example 2: Create Operation with Relations

```ruby
# app/operations/api/v0/roles/create_role_operation.rb
module Api::V0::Roles
  class CreateRoleOperation < BaseOperation
    contract do
      params do
        required(:role).hash do
          required(:name).filled(:string)
          optional(:description).maybe(:string)
          optional(:permission_ids).maybe(:array)
        end
      end
    end

    def call(params, current_user)
      # Step 1: Store arguments
      @params = params
      @current_user = current_user
      role_params = params[:role]

      # Step 2: Authorization
      return Failure(:unauthorized) unless authorize

      # Step 3: Create role via service
      result = Roles::CreateService.call(
        params: role_params.except(:permission_ids),
        created_by: current_user
      )

      return Failure(errors: result.error) unless result.success?

      @role = result.data

      # Step 4: Handle related resources (permissions)
      if role_params[:permission_ids].present?
        assign_result = Roles::AssignPermissionsService.call(
          role: @role,
          permission_ids: role_params[:permission_ids],
          assigned_by: current_user
        )

        return Failure(errors: assign_result.error) unless assign_result.success?
        
        @role.reload
      end

      # Step 5: Serialize
      json_data = serialize

      # Step 6: Return success
      Success(role: @role, json: json_data)
    end

    private

    attr_reader :params, :current_user, :role

    def authorize
      RolePolicy.new(current_user, Role).create?
    end

    def serialize
      Api::V0::RoleBlueprint.render_as_hash(role, view: :detailed)
    end
  end
end
```

**Controller:**
```ruby
def create
  result = Api::V0::Roles::CreateRoleOperation.call(params.to_unsafe_h, current_user)
  handle_operation_response(result, :created)
end
```

---

### Example 3: Update Operation

```ruby
# app/operations/api/v0/roles/update_role_operation.rb
module Api::V0::Roles
  class UpdateRoleOperation < BaseOperation
    contract do
      params do
        required(:id).filled(:string)
        required(:role).hash do
          optional(:name).filled(:string)
          optional(:description).maybe(:string)
          optional(:permission_ids).maybe(:array)
        end
      end
    end

    def call(params, current_user)
      # Step 1: Store arguments
      @params = params
      @current_user = current_user
      @role_id = params[:id]

      # Step 2: Find resource
      @role = Role.find_by(id: @role_id)
      return Failure(error: "Role not found") unless @role

      # Step 3: Authorization
      return Failure(:unauthorized) unless authorize

      # Step 4: Update via service
      result = Roles::UpdateService.call(
        role: @role,
        params: params[:role],
        updated_by: current_user
      )

      return Failure(errors: result.error) unless result.success?

      @role = result.data
      @role.reload

      # Step 5: Serialize
      json_data = serialize

      # Step 6: Return success
      Success(role: @role, json: json_data)
    end

    private

    attr_reader :params, :current_user, :role_id, :role

    def authorize
      RolePolicy.new(current_user, role).update?
    end

    def serialize
      Api::V0::RoleBlueprint.render_as_hash(role, view: :detailed)
    end
  end
end
```

**Controller:**
```ruby
def update
  result = Api::V0::Roles::UpdateRoleOperation.call(params.to_unsafe_h, current_user)
  handle_operation_response(result)
end
```

---

### Example 4: List/Index Operation with Filtering

```ruby
# app/operations/api/v0/roles/list_roles_operation.rb
module Api::V0::Roles
  class ListRolesOperation < BaseOperation
    contract do
      params do
        optional(:type).maybe(:string)
        optional(:sort).maybe(:string)
      end
    end

    def call(params, current_user)
      # Step 1: Store arguments
      @params = params
      @current_user = current_user

      # Step 2: Authorization
      return Failure(:unauthorized) unless authorize

      # Step 3: Filter and query
      @roles = filter_roles(params)

      # Step 4: Sort
      @roles = sort_roles(@roles, params[:sort] || "name")

      # Step 5: Serialize
      json_data = serialize

      # Step 6: Return success
      Success(roles: @roles, json: json_data)
    end

    private

    attr_reader :params, :current_user, :roles

    def authorize
      RolePolicy.new(current_user, Role).index?
    end

    def filter_roles(params)
      roles = Role.all

      if params[:type].present?
        case params[:type]
        when "system"
          roles = roles.system_roles
        when "custom"
          roles = roles.custom_roles
        end
      end

      roles
    end

    def sort_roles(roles, sort_field)
      case sort_field
      when "name"
        roles.alphabetical
      when "created_at"
        roles.order(created_at: :desc)
      else
        roles.alphabetical
      end
    end

    def serialize
      Api::V0::RoleBlueprint.render_as_hash(roles, view: :list)
    end
  end
end
```

**Controller:**
```ruby
def index
  result = Api::V0::Roles::ListRolesOperation.call(params.to_unsafe_h, current_user)
  handle_operation_response(result)
end
```

---

### Example 5: Delete Operation

```ruby
# app/operations/api/v0/roles/delete_role_operation.rb
module Api::V0::Roles
  class DeleteRoleOperation < BaseOperation
    # Contract is MANDATORY - even for single parameter
    contract do
      params do
        required(:id).filled(:string)
      end
    end

    def call(params, current_user)
      # Step 1: Store arguments and extract params
      @params = params
      @current_user = current_user
      @role_id = params[:id]

      # Step 2: Find resource
      @role = Role.find_by(id: @role_id)
      return Failure(error: "Role not found") unless @role

      # Step 3: Authorization
      return Failure(:unauthorized) unless authorize

      # Step 4: Delete via service
      result = Roles::DeleteService.call(
        role: @role,
        deleted_by: current_user
      )

      return Failure(error: result.error) unless result.success?

      # Step 5: Prepare response
      json_data = serialize

      # Step 6: Return success
      Success(role: @role, json: json_data)
    end

    private

    attr_reader :params, :role_id, :current_user, :role

    def authorize
      RolePolicy.new(current_user, role).destroy?
    end

    def serialize
      { message: "Role deleted successfully" }
    end
  end
end
```

**Controller:**
```ruby
def destroy
  result = Api::V0::Roles::DeleteRoleOperation.call(params.to_unsafe_h, current_user)
  handle_operation_response(result)
end
```

---

## Best Practices

### 1. **Consistent Structure**

✅ **DO:**
```ruby
def call(params, current_user)
  @params = params
  @current_user = current_user
  
  return Failure(:unauthorized) unless authorize
  # ... rest of steps
  
  Success(resource: @resource, json: serialize)
end
```

❌ **DON'T:**
```ruby
def call(params, current_user)
  # Mixing concerns without clear steps
  @resource = Resource.create(params)
  Api::V0::ResourceBlueprint.render(@resource) if current_user.admin?
end
```

### 2. **Authorization First**

✅ **DO:**
```ruby
def call(params, current_user)
  @current_user = current_user
  
  # Authorize immediately
  return Failure(:unauthorized) unless authorize
  
  # Continue with work
end
```

❌ **DON'T:**
```ruby
def call(params, current_user)
  # Doing work before checking authorization
  @resource = expensive_query
  return Failure(:unauthorized) unless authorize
end
```

### 3. **Use Instance Variables**

✅ **DO:**
```ruby
def call(params, current_user)
  @params = params
  @current_user = current_user
  # Accessible in all private methods
end

private

def authorize
  RolePolicy.new(@current_user, Role).create?
end
```

❌ **DON'T:**
```ruby
def call(params, current_user)
  # Passing parameters everywhere
  authorize(current_user)
  execute(params, current_user)
  serialize(params[:resource], current_user)
end
```

### 4. **Return Both Raw and JSON**

✅ **DO:**
```ruby
Success(
  role: @role,              # Raw object for flexibility
  json: serialize           # Serialized for API
)
```

❌ **DON'T:**
```ruby
Success(Api::V0::RoleBlueprint.render_as_hash(@role))
# Loses raw data access
```

### 5. **Clear Step Methods**

✅ **DO:**
```ruby
private

def authorize
  RolePolicy.new(current_user, Role).create?
end

def execute_creation
  Roles::CreateService.call(...)
end

def serialize
  Api::V0::RoleBlueprint.render_as_hash(role, view: :detailed)
end
```

❌ **DON'T:**
```ruby
private

def do_stuff
  # Everything mixed together
end
```

### 6. **Proper Error Returns**

✅ **DO:**
```ruby
return Failure(:unauthorized)
return Failure(error: "Not found")
return Failure(errors: result.error)
```

❌ **DON'T:**
```ruby
return { success: false, error: "unauthorized" }
raise UnauthorizedError
```

### 7. **Contract for Validation and Parameter Definition**

✅ **DO:**
```ruby
contract do
  params do
    required(:id).filled(:string)  # Operations extract params
    required(:role).hash do
      required(:name).filled(:string)
    end
  end
end

def call(params, current_user)
  @role_id = params[:id]  # Extract from params hash
  # ...
end
```

Use contracts to define AND validate parameters. Operations extract needed values.

### 8. **No Parameter Filtering in Controllers**

✅ **DO:**
```ruby
# Controller - pass raw params
def create
  result = Operation.call(params.to_unsafe_h, current_user)
  handle_operation_response(result, :created)
end
```

❌ **DON'T:**
```ruby
# Don't use before_action or permit
before_action :set_resource_id

def resource_params
  params.permit(:name, :description)
end
```

### 9. **Service Integration**

✅ **DO:**
```ruby
result = Roles::CreateService.call(params: @params, created_by: @current_user)
return Failure(errors: result.error) unless result.success?
@role = result.data
```

Always check service results and extract data.

### 10. **Reload After Updates**

✅ **DO:**
```ruby
@role = result.data
@role.reload  # Get fresh associations
```

Reload after service calls that modify associations.

### 11. **Controller Simplicity**

✅ **DO:**
```ruby
# ALWAYS pass params.to_unsafe_h - for ALL actions
def create
  result = Api::V0::Roles::CreateRoleOperation.call(params.to_unsafe_h, current_user)
  handle_operation_response(result, :created)
end

def show
  result = Api::V0::Roles::GetRoleOperation.call(params.to_unsafe_h, current_user)
  handle_operation_response(result)
end

def destroy
  result = Api::V0::Roles::DeleteRoleOperation.call(params.to_unsafe_h, current_user)
  handle_operation_response(result)
end
```

Controllers should only:
1. Pass `params.to_unsafe_h` to operation (ALWAYS)
2. Handle the response

**Never** use:
- `before_action` to set instance variables
- `params.permit()` or parameter filtering
- `params[:id]` or any parameter extraction
- Authorization logic

❌ **DON'T:**
```ruby
# Don't extract params[:id] or use before_action
def show
  result = Operation.call(params[:id], current_user)  # WRONG!
end
```

✅ **DO:**
```ruby
def create
  result = Api::V0::Roles::CreateRoleOperation.call(role_params, current_user)
  handle_operation_response(result, :created)
end
```

Controllers should only:
1. Call the operation
2. Handle the response

---

## Quick Reference Checklist

When creating a new operation, ensure:

**Operation Requirements:**
- [ ] Named with Action + Operation (e.g., `CreateRoleOperation`)
- [ ] **MUST have contract** - NO EXCEPTIONS (even for single `:id` parameter)
- [ ] Contract includes all required/optional parameters
- [ ] Stores `params` and `current_user` as instance variables
- [ ] Extracts ALL needed values from params hash (e.g., `@role_id = params[:id]`)
- [ ] Authorization is first step (after argument storage/extraction)
- [ ] Returns `Failure(:unauthorized)` for auth failures
- [ ] Returns `Failure(error: "...")` for not found
- [ ] Returns `Failure(errors: ...)` for validation/business errors
- [ ] Calls services for business logic
- [ ] Checks service results before continuing
- [ ] Serializes as final step
- [ ] Returns `Success(resource: ..., json: ...)` with both raw and JSON
- [ ] Has private methods for each major step
- [ ] Uses `attr_reader` for instance variables

**Controller Requirements:**
- [ ] **ALWAYS** passes `params.to_unsafe_h` to operation (for ALL actions)
- [ ] **NEVER** extracts params (not even `params[:id]`)
- [ ] Has NO `before_action` hooks
- [ ] Has NO `permit` methods
- [ ] Only calls operation and handles response

---

## Quick Template

```ruby
# app/operations/api/v0/resources/action_resource_operation.rb
module Api::V0::Resources
  class ActionResourceOperation < BaseOperation
    # Contract is MANDATORY - Define ALL expected parameters
    contract do
      params do
        required(:id).filled(:string)  # Include ID if needed
        required(:resource).hash do
          required(:name).filled(:string)
          optional(:description).maybe(:string)
        end
      end
    end

    def call(params, current_user)
      # Store arguments
      @params = params
      @current_user = current_user

      # Extract parameters from params hash
      @resource_id = params[:id]
      resource_params = params[:resource]

      # 1. Find/Load (if needed)
      @resource = Resource.find_by(id: @resource_id)
      return Failure(error: "Resource not found") unless @resource

      # 2. Authorization
      return Failure(:unauthorized) unless authorize

      # 3. Execute business logic
      result = Resources::ActionService.call(
        resource: @resource,
        params: resource_params,
        updated_by: current_user
      )
      return Failure(errors: result.error) unless result.success?
      @resource = result.data

      # 4. Serialize
      json_data = serialize

      # 5. Success
      Success(resource: @resource, json: json_data)
    end

    private

    attr_reader :params, :current_user, :resource_id, :resource

    def authorize
      ResourcePolicy.new(current_user, @resource).action?
    end

    def serialize
      Api::V0::ResourceBlueprint.render_as_hash(resource, view: :detailed)
    end
  end
end
```

**Controller:**
```ruby
# NO before_action, NO permit, NO param extraction - ALWAYS params.to_unsafe_h
class ResourcesController < ApiController
  def index
    result = Api::V0::Resources::ListResourcesOperation.call(
      params.to_unsafe_h, 
      current_user
    )
    handle_operation_response(result)
  end

  def show
    result = Api::V0::Resources::GetResourceOperation.call(
      params.to_unsafe_h,  # ALWAYS pass full params
      current_user
    )
    handle_operation_response(result)
  end

  def create
    result = Api::V0::Resources::CreateResourceOperation.call(
      params.to_unsafe_h, 
      current_user
    )
    handle_operation_response(result, :created)
  end

  def update
    result = Api::V0::Resources::UpdateResourceOperation.call(
      params.to_unsafe_h, 
      current_user
    )
    handle_operation_response(result)
  end

  def destroy
    result = Api::V0::Resources::DeleteResourceOperation.call(
      params.to_unsafe_h,  # ALWAYS pass full params
      current_user
    )
    handle_operation_response(result)
  end
      return Failure(error: "Resource not found") unless @resource

      # 3. Execute business logic
      result = Resources::ActionService.call(...)
      return Failure(errors: result.error) unless result.success?
      @resource = result.data

      # 4. Serialize
      json_data = serialize

      # 5. Success
      Success(resource: @resource, json: json_data)
    end

    private

    attr_reader :params, :current_user, :resource

    def authorize
      ResourcePolicy.new(current_user, Resource).action?
    end

    def serialize
      Api::V0::ResourceBlueprint.render_as_hash(resource, view: :detailed)
    end
  end
end
```

**Controller:**
```ruby
def action
  result = Api::V0::Resources::ActionResourceOperation.call(
    params.to_unsafe_h, 
    current_user
  )
  handle_operation_response(result, :created) # or :ok
end

private

def handle_operation_response(result, success_status = :ok)
  if result.success
    render json: { success: true, data: result.value[:json] }, status: success_status
  else
    handle_operation_failure(result)
  end
end

def handle_operation_failure(result)
  errors = result.errors

  case errors
  when :unauthorized
    forbidden_response("You are not authorized to perform this action")
  else
    # All other errors return 422 with error details in response body
    unprocessable_entity(errors)
  end
end
```

---

## Summary

### Operations Pattern Core Rules

1. **Parameter extraction in operations** - Define contracts, extract params from hash
2. **Authorization first** - Check permissions before doing any work
3. **Step-by-step execution** - Clear, ordered steps with early returns
4. **Service integration** - Delegate business logic to services
5. **Serialize last** - Format response as final step
6. **Return structured data** - Both raw and JSON for flexibility
7. **Consistent errors** - Use symbols and hashes appropriately
8. **Thin controllers** - Pass raw params, handle responses only

### Controller Pattern

**Controllers should:**
- ✅ **ALWAYS** pass `params.to_unsafe_h` to operations (for ALL actions, no exceptions)
- ✅ Call `handle_operation_response` to process results
- ✅ That's it. Controllers do exactly 2 lines per action.
- ❌ **NEVER** use `before_action` to set instance variables
- ❌ **NEVER** use `params.permit()` or parameter filtering
- ❌ **NEVER** extract parameters (not even `params[:id]`)
- ❌ **NEVER** include authorization logic

**The Golden Rule:** Every controller action looks like this:
```ruby
def action_name
  result = Operation.call(params.to_unsafe_h, current_user)
  handle_operation_response(result)
end
```

### Operation Pattern

**Operations MUST:**
- ✅ **Have a contract** - NO EXCEPTIONS (even for single `:id` parameter)
- ✅ Define contracts with ALL required/optional parameters
- ✅ Extract needed values from params hash
- ✅ Authorize as first step (after extraction)
- ✅ Execute business logic via services
- ✅ Serialize as final step
- ✅ Return both raw data and JSON

Following this pattern ensures:
- ✅ Consistent and predictable code
- ✅ Easy to test and maintain
- ✅ Clear separation of concerns
- ✅ Centralized parameter logic
- ✅ Reusable business logic
- ✅ Standardized API responses
- ✅ Proper authorization
- ✅ Clean error handling
