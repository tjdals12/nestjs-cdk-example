#!/bin/bash
echo "prisma migration"
pnpm prisma generate
pnpm prisma migrate deploy