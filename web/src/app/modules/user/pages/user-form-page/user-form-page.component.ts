import { CommonModule } from '@angular/common';
import { Component, inject, OnDestroy, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { ButtonComponent } from '../../../../shared/components/button/button.component';
import { NotificationService } from '../../../../shared/services/notification.service';
import { UserCreatePayload, User, UserUpdatePayload } from '../../models/user.model';
import { UserService } from '../../services/user.service';
import { Subscription } from 'rxjs';

@Component({
    selector: 'app-user-form-page',
    templateUrl: './user-form-page.component.html',
    styleUrls: ['./user-form-page.component.css'],
    imports: [CommonModule, ReactiveFormsModule, ButtonComponent],
})
export class UserFormPageComponent implements OnInit, OnDestroy {
    form!: FormGroup;
    isEditMode = false;
    loading = false;
    saving = false;
    userId?: number;

    private readonly _route = inject(ActivatedRoute);
    private readonly _router = inject(Router);
    private readonly _formBuilder = inject(FormBuilder);
    private readonly _userService = inject(UserService);
    private readonly _notificationService = inject(NotificationService);
    private subscriptions = new Subscription();

    ngOnInit(): void {
        this.form = this._formBuilder.group({
            first_name: ['', Validators.required],
            last_name: ['', Validators.required],
            email: ['', [Validators.required, Validators.email]],
            password: [''],
            password_confirmation: [''],
        });

        const idParam = this._route.snapshot.paramMap.get('id');
        if (idParam) {
            this.isEditMode = true;
            this.userId = Number(idParam);
            this.loadUser();
        }
    }

    ngOnDestroy(): void {
        this.subscriptions.unsubscribe();
    }

    get firstNameControl() {
        return this.form.get('first_name');
    }

    get lastNameControl() {
        return this.form.get('last_name');
    }

    get emailControl() {
        return this.form.get('email');
    }

    get passwordControl() {
        return this.form.get('password');
    }

    get passwordConfirmationControl() {
        return this.form.get('password_confirmation');
    }

    onSubmit(): void {
        if (this.form.invalid) {
            this.form.markAllAsTouched();
            return;
        }

        const password = this.passwordControl?.value?.trim();
        const passwordConfirmation = this.passwordConfirmationControl?.value?.trim();

        if (password && password !== passwordConfirmation) {
            this._notificationService.danger('Passwords do not match.');
            return;
        }

        const payload: UserCreatePayload | UserUpdatePayload = {
            first_name: this.firstNameControl?.value,
            last_name: this.lastNameControl?.value,
            email: this.emailControl?.value,
        } as UserCreatePayload | UserUpdatePayload;

        if (password) {
            payload.password = password;
            payload.password_confirmation = passwordConfirmation;
        }

        this.saving = true;

        if (this.isEditMode && this.userId !== undefined) {
            const updatePayload = payload as UserUpdatePayload;
            this.subscriptions.add(
                this._userService.updateUser(this.userId, updatePayload).subscribe({
                    next: () => this.handleSuccess('User updated successfully.'),
                    error: (error) => this.handleError(error),
                }),
            );
        } else {
            const createPayload = payload as UserCreatePayload;

            if (!password) {
                this._notificationService.danger('Password is required to create a new user.');
                this.saving = false;
                return;
            }

            this.subscriptions.add(
                this._userService.createUser(createPayload).subscribe({
                    next: () => this.handleSuccess('User created successfully.'),
                    error: (error) => this.handleError(error),
                }),
            );
        }
    }

    onCancel(): void {
        this._router.navigate(['/users']);
    }

    onDelete(): void {
        if (!this.userId) {
            return;
        }

        const confirmed = window.confirm('Delete this user? This action cannot be undone.');
        if (!confirmed) {
            return;
        }

        this.saving = true;
        this.subscriptions.add(
            this._userService.deleteUser(this.userId).subscribe({
                next: () => {
                    this._notificationService.success('User deleted successfully.');
                    this._router.navigate(['/users']);
                },
                error: (error) => this.handleError(error),
            }),
        );
    }

    private loadUser(): void {
        if (!this.userId) {
            return;
        }

        this.loading = true;
        this.subscriptions.add(
            this._userService.getUser(this.userId).subscribe({
                next: (user) => {
                    this.form.patchValue({
                        first_name: user.first_name,
                        last_name: user.last_name,
                        email: user.email,
                    });
                    this.loading = false;
                },
                error: (error) => this.handleError(error),
            }),
        );
    }

    private handleSuccess(message: string): void {
        this._notificationService.success(message);
        this.saving = false;
        this._router.navigate(['/users']);
    }

    private handleError(error: unknown): void {
        const message = (error as { message?: string })?.message || 'Unable to save user. Please try again.';
        this._notificationService.danger(message);
        this.saving = false;
        this.loading = false;
    }
}
