export type SuccessReponse<T> = {
    success: true,
    data: T
};

export type ErrorReponse = {
    success: false,
    errors: string[]
};

// helper type
export type MessageResponseType = {
    message: string;
};