# API v0 Reference

## Overview

This document describes the `/api/v0` endpoints currently exposed by the Bookturf Rails API.
All successful responses follow the wrapper:

```json
{
  "success": true,
  "data": { ... }
}
```

Error responses generally use:

```json
{
  "success": false,
  "errors": [ ... ]
}
```

Authentication is handled using JWT access tokens and refresh tokens. Tokens may be supplied via:
- `Authorization: Bearer <access_token>` header
- `access_token` and `refresh_token` cookies

---

## Auth Endpoints

### POST /api/v0/auth/signup
Creates a new user and returns auth tokens.

Request body:
```json
{
  "first_name": "string",
  "last_name": "string",
  "email": "string",
  "password": "string",
  "password_confirmation": "string"
}
```

Response data:
```json
{
  "id": integer,
  "email": "string",
  "name": "string",
  "avatar_url": "string|null",
  "created_at": "string",
  "access_token": "Bearer <token>",
  "refresh_token": "string"
}
```

### POST /api/v0/auth/signin
Signs in an existing user and returns auth tokens.

Request body:
```json
{
  "email": "string",
  "password": "string"
}
```

Response data:
```json
{
  "access_token": "Bearer <token>",
  "refresh_token": "string",
  "user": {
    "id": integer,
    "email": "string",
    "name": "string"
  }
}
```

### POST /api/v0/auth/refresh
Refreshes tokens using the refresh token.

Request body:
```json
{
  "refresh_token": "string"
}
```

Response data:
```json
{
  "access_token": "Bearer <token>",
  "refresh_token": "string"
}
```

### DELETE /api/v0/auth/signout
Invalidates current session tokens.

Requires authentication.

Response data:
```json
{}
```

### POST /api/v0/auth/reset_password
Requests a password reset OTP for an email.

Request body:
```json
{
  "email": "string"
}
```

Response data:
```json
{
  "message": "If an account exists with this email, you will receive a password reset code shortly."
}
```

### POST /api/v0/auth/verify_reset_otp
Verifies reset OTP and sets a new password.

Request body:
```json
{
  "email": "string",
  "otp_code": "string",      // 6-digit code
  "password": "string",
  "password_confirmation": "string"
}
```

Response data:
```json
{
  "message": "Your password has been successfully reset. You can now sign in with your new password."
}
```

---

## Roles Endpoints

### GET /api/v0/roles
List roles.

Query params:
- `type` (optional): `system` or `custom`

Requires authentication.

Response data:
```json
[
  {
    "id": integer,
    "name": "string",
    "slug": "string",
    "description": "string|null",
    "is_custom": boolean,
    "created_at": "string",
    "permissions_count": integer,
    "users_count": integer
  }
]
```

### GET /api/v0/roles/:id
Get a role by ID.

Requires authentication.

Response data:
```json
{
  "id": integer,
  "name": "string",
  "slug": "string",
  "description": "string|null",
  "is_custom": boolean,
  "created_at": "string",
  "updated_at": "string",
  "permissions": [
    {
      "id": integer,
      "name": "string",
      "resource": "string",
      "action": "string",
      "description": "string"
    }
  ],
  "users": [
    {
      "id": integer,
      "name": "string",
      "email": "string"
    }
  ]
}
```

### POST /api/v0/roles
Create a role.

Request body:
```json
{
  "role": {
    "name": "string",
    "description": "string|null",
    "permission_ids": [integer,...]  // optional
  }
}
```

Requires authentication.

Response data: same as GET `/api/v0/roles/:id`.

### PATCH /api/v0/roles/:id
Update a role.

Request body:
```json
{
  "role": {
    "name": "string",           // optional
    "description": "string|null", // optional
    "permission_ids": [integer,...] // optional
  }
}
```

Requires authentication.

Response data: same as GET `/api/v0/roles/:id`.

### DELETE /api/v0/roles/:id
Delete a role.

Requires authentication.

Response data:
```json
{
  "message": "Role deleted successfully"
}
```

---

## Venues Endpoints

### GET /api/v0/venues
List venues.

Query params:
- `page` (optional, integer)
- `per_page` (optional, integer)
- `city` (optional)
- `state` (optional)
- `country` (optional)
- `is_active` (optional, boolean)
- `search` (optional)
- `sort` (optional): `name`, `city`, or `created_at`
- `order` (optional): `asc` or `desc`

Response data:
```json
[
  {
    "id": integer,
    "name": "string",
    "slug": "string",
    "description": "string|null",
    "address": "string",
    "city": "string|null",
    "state": "string|null",
    "country": "string|null",
    "postal_code": "string|null",
    "phone_number": "string|null",
    "email": "string|null",
    "is_active": boolean,
    "created_at": "string",
    "latitude": number|null,
    "longitude": number|null,
    "google_maps_url": "string|null",
    "courts_count": integer
  }
]
```

### GET /api/v0/venues/:id
Get venue details by ID or slug.

Response data:
```json
{
  "id": integer,
  "name": "string",
  "slug": "string",
  "description": "string|null",
  "address": "string",
  "city": "string|null",
  "state": "string|null",
  "country": "string|null",
  "postal_code": "string|null",
  "phone_number": "string|null",
  "email": "string|null",
  "is_active": boolean,
  "created_at": "string",
  "updated_at": "string",
  "latitude": number|null,
  "longitude": number|null,
  "google_maps_url": "string|null",
  "owner": {
    "id": integer,
    "name": "string",
    "email": "string"
  },
  "venue_setting": {
    "minimum_slot_duration": integer|null,
    "maximum_slot_duration": integer|null,
    "slot_interval": integer|null,
    "advance_booking_days": integer|null,
    "requires_approval": boolean|null,
    "cancellation_hours": integer|null,
    "timezone": "string|null",
    "currency": "string|null"
  },
  "venue_operating_hours": [
    {
      "id": integer,
      "day_of_week": integer,
      "opens_at": "string|null",
      "closes_at": "string|null",
      "is_closed": boolean,
      "day_name": "string",
      "formatted_hours": "string"
    }
  ],
  "courts_count": integer
}
```

### GET /api/v0/venues/:id/availability
Check venue availability.

Query params/body:
- `id` (path): venue ID or slug
- `start_date` (required, string)
- `end_date` (optional, string; defaults to `start_date`)
- `duration_minutes` (optional, integer; defaults to venue minimum slot duration)
- `court_type_id` (optional, integer)
- `court_id` (optional, integer)
- `include_booked` (optional, boolean)

Response data:
```json
{
  "venue_id": integer,
  "start_date": "YYYY-MM-DD",
  "end_date": "YYYY-MM-DD",
  "timezone": "string",
  "court_availability": [
    {
      "court_id": integer,
      "court_name": "string",
      "slots": [
        {
          "start_time": "ISO8601 string",
          "end_time": "ISO8601 string",
          "duration_minutes": integer,
          "price_per_hour": "string",
          "total_amount": "string",
          "available": boolean,
          "booked": boolean,
          "booking_status": "confirmed"|"closed"|null
        }
      ]
    }
  ]
}
```

### POST /api/v0/venues
Create a venue.

Request body:
```json
{
  "venue": {
    "name": "string",
    "description": "string|null",
    "address": "string",
    "city": "string|null",
    "state": "string|null",
    "country": "string|null",
    "postal_code": "string|null",
    "latitude": number|null,
    "longitude": number|null,
    "phone_number": "string|null",
    "email": "string|null",
    "is_active": boolean|null,
    "venue_setting": {
      "minimum_slot_duration": integer|null,
      "maximum_slot_duration": integer|null,
      "slot_interval": integer|null,
      "advance_booking_days": integer|null,
      "requires_approval": boolean|null,
      "cancellation_hours": integer|null,
      "timezone": "string|null",
      "currency": "string|null"
    },
    "venue_operating_hours": [
      {
        "day_of_week": integer,
        "opens_at": "string|null",
        "closes_at": "string|null",
        "is_closed": boolean|null
      }
    ]
  }
}
```

Requires authentication.

Response data: same structure as GET `/api/v0/venues/:id`.

### PATCH /api/v0/venues/:id
Update a venue.

Request body: same fields as POST `/api/v0/venues`, all optional except `id` in path.

Requires authentication.

Response data: same structure as GET `/api/v0/venues/:id`.

### DELETE /api/v0/venues/:id
Delete a venue.

Requires authentication.

Response data:
```json
{
  "message": "Venue deleted successfully"
}
```

---

## Courts Endpoints

### GET /api/v0/courts
List courts.

Query params:
- `page` (optional, integer)
- `per_page` (optional, integer)
- `venue_id` (optional, integer)
- `court_type_id` (optional, integer)
- `is_active` (optional, boolean)
- `search` (optional)
- `sort` (optional): `name`, `created_at`, `display_order`
- `order` (optional): `asc` or `desc`

Response data:
```json
[
  {
    "id": integer,
    "name": "string",
    "description": "string|null",
    "court_type_id": integer,
    "venue_id": integer,
    "is_active": boolean,
    "display_order": integer|null,
    "created_at": "string",
    "updated_at": "string",
    "court_type": {
      "id": integer,
      "name": "string",
      "slug": "string"
    },
    "venue": {
      "id": integer,
      "name": "string",
      "slug": "string",
      "city": "string|null"
    }
  }
]
```

### GET /api/v0/courts/:id
Get a court by ID.

Response data: same structure as list item.

### POST /api/v0/courts
Create a court.

Request body:
```json
{
  "court": {
    "venue_id": integer,
    "court_type_id": integer,
    "name": "string",
    "description": "string|null",
    "is_active": boolean|null,
    "display_order": integer|null
  }
}
```

Requires authentication.

Response data: same structure as GET `/api/v0/courts/:id`.

### PATCH /api/v0/courts/:id
Update a court.

Request body:
```json
{
  "court": {
    "court_type_id": integer|null,
    "name": "string|null",
    "description": "string|null",
    "is_active": boolean|null,
    "display_order": integer|null
  }
}
```

Requires authentication.

Response data: same structure as GET `/api/v0/courts/:id`.

### DELETE /api/v0/courts/:id
Delete a court.

Requires authentication.

Response data:
```json
{
  "message": "Court deleted successfully"
}
```

---

## Pricing Rules Endpoints

### GET /api/v0/pricing_rules
List pricing rules.

Query params:
- `court_type_id` (optional, integer)
- `is_active` (optional, boolean)
- `day_of_week` (optional, integer)

Requires authentication.

Response data:
```json
[
  {
    "id": integer,
    "venue_id": integer,
    "court_type_id": integer,
    "name": "string",
    "price_per_hour": number,
    "day_of_week": integer|null,
    "start_time": "string|null",
    "end_time": "string|null",
    "start_date": "string|null",
    "end_date": "string|null",
    "priority": integer,
    "is_active": boolean,
    "day_name": "string|null",
    "time_range": "string|null",
    "created_at": "string",
    "updated_at": "string",
    "court_type": {
      "id": integer,
      "name": "string",
      "slug": "string"
    }
  }
]
```

### GET /api/v0/pricing_rules/:id
Get a pricing rule.

Requires authentication.

Response data: same structure as list item.

### POST /api/v0/pricing_rules
Create a pricing rule.

Request body:
```json
{
  "pricing_rule": {
    "court_type_id": integer,
    "name": "string",
    "price_per_hour": number,
    "day_of_week": integer|null,
    "start_time": "string|null",
    "end_time": "string|null",
    "start_date": "string|null",
    "end_date": "string|null",
    "priority": integer,
    "is_active": boolean|null
  }
}
```

Requires authentication.

Response data: same structure as GET `/api/v0/pricing_rules/:id`.

### PATCH /api/v0/pricing_rules/:id
Update a pricing rule.

Request body:
```json
{
  "pricing_rule": {
    "court_type_id": integer|null,
    "name": "string|null",
    "price_per_hour": number|null,
    "day_of_week": integer|null,
    "start_time": "string|null",
    "end_time": "string|null",
    "start_date": "string|null",
    "end_date": "string|null",
    "priority": integer|null,
    "is_active": boolean|null
  }
}
```

Requires authentication.

Response data: same structure as GET `/api/v0/pricing_rules/:id`.

### DELETE /api/v0/pricing_rules/:id
Delete a pricing rule.

Requires authentication.

Response data:
```json
{
  "message": "Pricing rule deleted successfully"
}
```

---

## Bookings Endpoints

### GET /api/v0/bookings
List bookings.

Query params:
- `status` (optional)
- `user_id` (optional, integer)
- `court_id` (optional, integer)
- `from_date` (optional, string)
- `to_date` (optional, string)
- `page` (optional, integer)
- `per_page` (optional, integer)

Requires authentication.

Response data:
```json
[
  {
    "id": integer,
    "booking_number": "string",
    "status": "string",
    "total_amount": number,
    "paid_amount": number,
    "payment_method": "string|null",
    "payment_status": "string|null",
    "start_time": "ISO8601 string",
    "end_time": "ISO8601 string",
    "user": {
      "id": integer,
      "name": "string",
      "email": "string"
    },
    "court": {
      "id": integer,
      "name": "string",
      "court_type_id": integer,
      "venue_id": integer,
      "is_active": boolean
    }
  }
]
```

### GET /api/v0/bookings/:id
Get booking details.

Requires authentication.

Response data:
```json
{
  "id": integer,
  "booking_number": "string",
  "status": "string",
  "payment_method": "string|null",
  "payment_status": "string|null",
  "total_amount": number,
  "paid_amount": number,
  "notes": "string|null",
  "cancellation_reason": "string|null",
  "cancelled_at": "string|null",
  "checked_in_at": "string|null",
  "start_time": "ISO8601 string",
  "end_time": "ISO8601 string",
  "duration_minutes": integer,
  "created_at": "string",
  "updated_at": "string",
  "user": {
    "id": integer,
    "name": "string",
    "email": "string"
  },
  "court": {
    "id": integer,
    "name": "string",
    "court_type_id": integer,
    "venue_id": integer,
    "is_active": boolean
  },
  "venue": {
    "id": integer,
    "name": "string",
    "slug": "string",
    "city": "string|null"
  }
}
```

### POST /api/v0/bookings
Create a booking.

Request body:
```json
{
  "booking": {
    "user_id": integer|null,
    "court_id": integer,
    "start_time": "string",
    "end_time": "string",
    "notes": "string|null",
    "payment_method": "string|null",
    "payment_status": "string|null"
  }
}
```

Notes:
- `user_id` is optional. If omitted, the authenticated user is used.
- `created_by_id` is set automatically to the authenticated user.

Requires authentication.

Response data: same structure as GET `/api/v0/bookings/:id`.

### PATCH /api/v0/bookings/:id
Update a booking.

Request body:
```json
{
  "booking": {
    "court_id": integer|null,
    "start_time": "string|null",
    "end_time": "string|null",
    "notes": "string|null",
    "payment_method": "string|null",
    "payment_status": "string|null"
  }
}
```

Requires authentication.

Response data: same structure as GET `/api/v0/bookings/:id`.

### DELETE /api/v0/bookings/:id
Delete a booking.

Requires authentication.

Response data:
```json
{
  "message": "Booking deleted successfully"
}
```

### POST /api/v0/bookings/availability
Check if a court slot is available.

Request body:
```json
{
  "availability": {
    "court_id": integer,
    "start_time": "string",
    "end_time": "string",
    "exclude_booking_id": integer|null
  }
}
```

Requires authentication.

Response data:
```json
{
  "available": boolean
}
```

### PATCH /api/v0/bookings/:id/cancel
Cancel a booking.

Request body:
```json
{
  "cancellation_reason": "string|null"
}
```

Requires authentication.

Response data: same structure as GET `/api/v0/bookings/:id`.

### PATCH /api/v0/bookings/:id/check_in
Mark a booking as checked in.

Requires authentication.

Response data: same structure as GET `/api/v0/bookings/:id`.

### PATCH /api/v0/bookings/:id/no_show
Mark a booking as no-show.

Requires authentication.

Response data: same structure as GET `/api/v0/bookings/:id`.

### PATCH /api/v0/bookings/:id/complete
Mark a booking as complete.

Requires authentication.

Response data: same structure as GET `/api/v0/bookings/:id`.

### PATCH /api/v0/bookings/:id/reschedule
Reschedule a booking.

Request body:
```json
{
  "booking": {
    "court_id": integer|null,
    "start_time": "string",
    "end_time": "string"
  }
}
```

Requires authentication.

Response data: same structure as GET `/api/v0/bookings/:id`.

---

## Notes

- Most resource create/update endpoints return the same detailed object shape as the corresponding `GET /:id` endpoint.
- The API uses the `success: true` wrapper on success, and `success: false` with an `errors` array for failures.
- Protected endpoints require authorization and will return 403 if not permitted.
- `is_active` and similar boolean query params are parsed from strings like `"true"` / `"false"` as well as boolean values.
