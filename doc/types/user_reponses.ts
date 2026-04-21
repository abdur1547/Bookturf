export type UserPreferencesType = {
    preferred_city: string | null,
    preferred_town: string | null,
    notification_reminders: boolean,
    notification_30min: boolean
};

export type OwnerDataType = {
    venue_id: number
};

export type StaffDataType = {
    venue_id: number,
    joined_at: string
};


// regular user view
export type UserType = {
    id: number,
    full_name: string,
    email: string,
    avatar_url: string | null,
    created_at: string,
    updated_at: string,
    phone_number: string | null,
    user_type: "owner" | "staff" | "customer",
    preferences: UserPreferencesType,
    owner_data: OwnerDataType | null,
    staff_data: StaffDataType | null,
};

// minimal view for user
export type MinimalUserDataType = {
    id: number,
    full_name: string,
};