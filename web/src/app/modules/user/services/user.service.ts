import { HttpErrorResponse } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { catchError, map, Observable, throwError } from 'rxjs';
import { ApiBaseService } from 'src/app/shared/services/api-base.service';
import { User, UserCreatePayload, UserUpdatePayload } from '../models/user.model';

interface ApiResponseWrapper<T> {
    success: boolean;
    data: T;
    errors?: string[];
}

@Injectable({ providedIn: 'root' })
export class UserService extends ApiBaseService<User> {
    private readonly resource = 'users';

    public listUsers(): Observable<User[]> {
        return this.http.get<ApiResponseWrapper<User[]>>(`${this.baseUrl}/${this.resource}`).pipe(
            map((response) => {
                if (!response?.success) {
                    throw new Error('Unable to load users.');
                }
                return response.data;
            }),
            catchError((error) => this.handleServiceError('listUsers', error)),
        );
    }

    public getUser(id: number): Observable<User> {
        return this.http.get<ApiResponseWrapper<User>>(`${this.baseUrl}/${this.resource}/${id}`).pipe(
            map((response) => {
                if (!response?.success) {
                    throw new Error('Unable to load user.');
                }
                return response.data;
            }),
            catchError((error) => this.handleServiceError('getUser', error)),
        );
    }

    public createUser(payload: UserCreatePayload): Observable<User> {
        return this.http.post<ApiResponseWrapper<User>>(`${this.baseUrl}/${this.resource}`, { user: payload }).pipe(
            map((response) => {
                if (!response?.success) {
                    throw new Error('Unable to create user.');
                }
                return response.data;
            }),
            catchError((error) => this.handleServiceError('createUser', error)),
        );
    }

    public updateUser(id: number, payload: UserUpdatePayload): Observable<User> {
        return this.http.put<ApiResponseWrapper<User>>(`${this.baseUrl}/${this.resource}/${id}`, { user: payload }).pipe(
            map((response) => {
                if (!response?.success) {
                    throw new Error('Unable to update user.');
                }
                return response.data;
            }),
            catchError((error) => this.handleServiceError('updateUser', error)),
        );
    }

    public deleteUser(id: number): Observable<void> {
        return this.http.delete<ApiResponseWrapper<Record<string, unknown>>>(`${this.baseUrl}/${this.resource}/${id}`).pipe(
            map((response) => {
                if (!response?.success) {
                    throw new Error('Unable to delete user.');
                }
                return undefined;
            }),
            catchError((error) => this.handleServiceError('deleteUser', error)),
        );
    }

    private handleServiceError(operation: string, error: HttpErrorResponse): Observable<never> {
        return this.handleError(operation, error);
    }
}
