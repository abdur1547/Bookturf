import { Component, OnInit, inject } from '@angular/core';
import { FormBuilder, FormGroup, FormsModule, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AngularSvgIconModule } from 'angular-svg-icon';
import { ButtonComponent } from 'src/app/shared/components/button/button.component';
import { AuthService, AuthSignUpRequest } from '../../services/auth.service';
import { NotificationService } from '../../../../shared/services/notification.service';

@Component({
  selector: 'app-sign-up',
  templateUrl: './sign-up.component.html',
  styleUrls: ['./sign-up.component.css'],
  imports: [FormsModule, ReactiveFormsModule, RouterLink, AngularSvgIconModule, ButtonComponent],
})
export class SignUpComponent implements OnInit {
  form!: FormGroup;
  submitted = false;
  passwordTextType = false;

  private readonly _formBuilder: FormBuilder = inject(FormBuilder);
  private readonly _router: Router = inject(Router);
  private readonly _authService: AuthService = inject(AuthService);
  private readonly _notificationService: NotificationService = inject(NotificationService);

  ngOnInit(): void {
    this.form = this._formBuilder.group({
      first_name: ['', Validators.required],
      last_name: ['', Validators.required],
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required, Validators.minLength(8)]],
      password_confirmation: ['', Validators.required],
      accept_terms: [false, Validators.requiredTrue],
    });
  }

  get f() {
    return this.form.controls;
  }

  togglePasswordTextType() {
    this.passwordTextType = !this.passwordTextType;
  }

  onSubmit() {
    this.submitted = true;

    if (this.form.invalid) {
      return;
    }

    if (this.form.value.password !== this.form.value.password_confirmation) {
      this._notificationService.danger('Passwords must match.', 'Please confirm your password correctly.', {
        duration: 6000,
        position: 'top-right',
      });
      return;
    }

    const payload: AuthSignUpRequest = {
      first_name: this.form.value.first_name,
      last_name: this.form.value.last_name,
      email: this.form.value.email,
      password: this.form.value.password,
      password_confirmation: this.form.value.password_confirmation,
    };

    this._authService.signUp(payload).subscribe({
      next: () => {
        this._notificationService.success('Account created', 'You are signed in and ready to go.', {
          duration: 5000,
          position: 'top-right',
        });
        this._router.navigate(['/']);
      },
      error: (error) => {
        const message = error?.message || 'Unable to sign up. Please try again.';
        const description = error?.error?.message || undefined;
        this._notificationService.danger(message, description, {
          duration: 6000,
          position: 'top-right',
        });
      },
    });
  }
}
