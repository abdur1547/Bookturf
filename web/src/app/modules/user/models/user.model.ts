export interface User {
    id: number;
    first_name: string;
    last_name: string;
    email: string;
    role?: string;
    created_at?: string;
    updated_at?: string;
}

export interface UserCreatePayload {
    first_name: string;
    last_name: string;
    email: string;
    password: string;
    password_confirmation: string;
}

export interface UserUpdatePayload {
    first_name: string;
    last_name: string;
    email: string;
    password?: string;
    password_confirmation?: string;
}
