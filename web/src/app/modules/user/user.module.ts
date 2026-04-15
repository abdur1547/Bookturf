import { NgModule } from '@angular/core';
import { provideHttpClient, withInterceptorsFromDi } from '@angular/common/http';
import { UserRoutingModule } from './user-routing.module';

@NgModule({
  imports: [UserRoutingModule],
  providers: [provideHttpClient(withInterceptorsFromDi())],
})
export class UserModule { }
