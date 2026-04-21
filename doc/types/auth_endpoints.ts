import { ErrorReponse, MessageResponseType, SuccessReponse } from "./common_types";
import { UserType } from "./user_reponses";

// **********************************************
// auth/signin

// body type
export type SigninFormType = {
    "email": string,
    "password": string
};

// helper type
type AuthSuccessResponse = {
    access_token: string;
    refresh_token: string;
    user: UserType;
};

// response type
export type SigninResponseType = SuccessReponse<AuthSuccessResponse> | ErrorReponse;

// easy to handle
const handle = (data: SigninResponseType) => {
    if (data.success === true) {
        data.data
    } else {
        data.errors
    }
};


// **********************************************
// /auth/signup

// body type
export type SignupFormType = {
    "full_name": string,
    "email": string,
    "password": string
};

// response type
export type SignupResponseType = SuccessReponse<AuthSuccessResponse> | ErrorReponse;


// **********************************************
// /auth/refresh

// body type
export type RefreshFormType = {
    "refresh_token": string
};

// helper type
type RefreshSuccessResponseType = {
    access_token: string;
    refresh_token: string;
};

// response type
export type RefreshResponseType = SuccessReponse<RefreshSuccessResponseType> | ErrorReponse;


// **********************************************
// auth/reset_password

// body type
export type ResetPasswordFormType = {
    "email": string
};

// response type
export type ResetPasswordResponseType = SuccessReponse<MessageResponseType> | ErrorReponse;


// **********************************************
// auth/verify_reset_otp

// body type
export type VerifyResetOtpFormType = {
    "email": string,
    "otp_code": string,
    "password": string
};

// response type
export type VerifyResetOtpResponseType = SuccessReponse<MessageResponseType> | ErrorReponse;


// **********************************************
// DELETE auth/signout

// body type
export type SignoutForm = {};

// response type
export type SignoutResponseType = SuccessReponse<MessageResponseType> | ErrorReponse;
