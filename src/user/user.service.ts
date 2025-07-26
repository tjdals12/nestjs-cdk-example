import { Injectable } from '@nestjs/common';
import { Prisma } from 'generated/prisma';
import { PrismaService } from 'src/prisma/prisma.service';
import { CreateUserDto } from './dto/create-user.dto';

@Injectable()
export class UserService {
  constructor(private readonly prismaService: PrismaService) {}

  async listUsers() {
    const users = await this.prismaService.user.findMany({
      skip: 0,
      take: 10,
      orderBy: {
        id: Prisma.SortOrder.desc,
      },
    });
    return users;
  }

  async createUser(createUserDto: CreateUserDto) {
    const { name } = createUserDto;
    const createdUser = await this.prismaService.user.create({
      data: {
        name,
      },
    });
    return createdUser;
  }
}
