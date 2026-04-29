import { Injectable } from '@angular/core';
import { HttpErrorResponse } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError, map } from 'rxjs/operators';
import { ApiBaseService } from 'src/app/shared/services/api-base.service';

export interface AuthSignInRequest {
  email: string;
  password: string;
}

export interface AuthSignUpRequest {
  first_name: string;
  last_name: string;
  email: string;
  password: string;
  password_confirmation: string;
}

export interface AuthUser {
  id: number;
  email: string;
  name: string;
}

export interface AuthSignInResponse {
  access_token: string;
  refresh_token: string;
  user: AuthUser;
}

export interface AuthSignUpResponse {
  id: number;
  email: string;
  name: string;
  avatar_url: string | null;
  created_at: string;
  access_token: string;
  refresh_token: string;
}

interface ApiResponseWrapper<T> {
  success: boolean;
  data: T;
}

@Injectable({ providedIn: 'root' })
export class AuthService extends ApiBaseService<AuthSignInResponse> {
  public signIn(payload: AuthSignInRequest): Observable<AuthSignInResponse> {
    return this.http.post<ApiResponseWrapper<AuthSignInResponse>>(`${this.baseUrl}/auth/signin`, payload).pipe(
      map((response) => {
        if (!response?.success) {
          throw new Error('Sign in failed.');
        }

        this.saveTokens(response.data);
        return response.data;
      }),
      catchError((error) => {
        if (error instanceof HttpErrorResponse) {
          return this.handleError('signIn', error);
        }
        return throwError(() => error);
      }),
    );
  }

  public signUp(payload: AuthSignUpRequest): Observable<AuthSignUpResponse> {
    return this.http.post<ApiResponseWrapper<AuthSignUpResponse>>(`${this.baseUrl}/auth/signup`, payload).pipe(
      map((response) => {
        if (!response?.success) {
          throw new Error('Sign up failed.');
        }

        this.saveTokens(response.data);
        return response.data;
      }),
      catchError((error) => {
        if (error instanceof HttpErrorResponse) {
          return this.handleError('signUp', error);
        }
        return throwError(() => error);
      }),
    );
  }

  private saveTokens(data: AuthSignInResponse | AuthSignUpResponse): void {
    try {
      localStorage.setItem('access_token', data.access_token);
      localStorage.setItem('refresh_token', data.refresh_token);
    } catch {
      // ignore storage failures; the API call itself succeeded
    }
  }

  public getAccessToken(): string | null {
    return localStorage.getItem('access_token');
  }

  public getRefreshToken(): string | null {
    return localStorage.getItem('refresh_token');
  }

  public clearTokens(): void {
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
  }
}
