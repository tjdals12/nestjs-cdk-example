import { Body, Controller, Get, Post } from '@nestjs/common';
import { UserService } from './user.service';
import { CreateUserDto } from './dto/create-user.dto';

@Controller({
  path: '/users',
})
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Get('/')
  async listUsers() {
    return await this.userService.listUsers();
  }

  @Post('/')
  async createUser(@Body() createUserDto: CreateUserDto) {
    return await this.userService.createUser(createUserDto);
  }
}
