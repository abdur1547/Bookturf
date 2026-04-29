import { CommonModule } from '@angular/common';
import { Component, OnInit, inject } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { ButtonComponent } from '../../../../shared/components/button/button.component';
import { User } from '../../models/user.model';
import { UserService } from '../../services/user.service';

@Component({
    selector: 'app-user-list-page',
    templateUrl: './user-list-page.component.html',
    styleUrls: ['./user-list-page.component.css'],
    imports: [CommonModule, RouterLink, ButtonComponent],
})
export class UserListPageComponent implements OnInit {
    users: User[] = [];
    loading = false;
    error = '';

    private readonly _router = inject(Router);
    private readonly _userService = inject(UserService);

    ngOnInit(): void {
        this.loadUsers();
    }

    loadUsers(): void {
        this.loading = true;
        this.error = '';

        this._userService.listUsers().subscribe({
            next: (users) => {
                this.users = users;
                this.loading = false;
            },
            error: (error) => {
                this.error = error?.message || 'Unable to load users.';
                this.loading = false;
            },
        });
    }

    getFullName(user: User): string {
        return `${user.first_name} ${user.last_name}`;
    }

    openUser(user: User): void {
        this._router.navigate([user.id]);
    }
}
