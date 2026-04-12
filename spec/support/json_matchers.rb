# frozen_string_literal: true

require "json_matchers/rspec"

# Configure JSON Matchers to look for schema files in spec/support/api/schemas
JsonMatchers.schema_root = "spec/support/api/schemas"
