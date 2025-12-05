# 📅 Día 6: API de Usuarios Completa

## 🎯 Objetivo del Día

Implementar CRUD completo de usuarios con paginación, filtros, búsqueda y gestión de roles, incluyendo endpoints protegidos y validaciones.

---

## ✅ Checklist de Tareas

- [ ] Crear DTOs de usuario
- [ ] Crear validadores de usuario
- [ ] Crear servicio de usuario
- [ ] Crear controlador de usuario
- [ ] Crear rutas de usuario
- [ ] Implementar paginación
- [ ] Implementar filtros y búsqueda
- [ ] Implementar gestión de roles
- [ ] Crear tests completos
- [ ] Documentar endpoints

---

## 📋 Pasos Detallados

### **Paso 1: Crear DTOs de Usuario**

Crear archivo `src/dto/user/create-user.dto.ts`:

```typescript
export interface CreateUserDto {
  email: string;
  password: string;
  fullName?: string;
  phone?: string;
  role?: "ADMIN" | "BUSINESS_OWNER" | "SERVICE_PROVIDER" | "CUSTOMER";
}
```

Crear archivo `src/dto/user/update-user.dto.ts`:

```typescript
export interface UpdateUserDto {
  email?: string;
  fullName?: string;
  phone?: string;
  role?: "ADMIN" | "BUSINESS_OWNER" | "SERVICE_PROVIDER" | "CUSTOMER";
  isActive?: boolean;
}
```

Crear archivo `src/dto/user/user-response.dto.ts`:

```typescript
export interface UserResponseDto {
  id: string;
  email: string;
  fullName?: string;
  phone?: string;
  role: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}
```

Crear archivo `src/dto/user/user-query.dto.ts`:

```typescript
export interface UserQueryDto {
  page?: number;
  limit?: number;
  search?: string;
  role?: string;
  isActive?: boolean;
  sortBy?: "email" | "createdAt" | "fullName";
  sortOrder?: "asc" | "desc";
}
```

**Verificación**:

- [ ] Todos los DTOs creados
- [ ] Interfaces definidas

---

### **Paso 2: Crear Validadores de Usuario**

Crear archivo `src/validators/user.validator.ts`:

```typescript
import { z } from "zod";

export const createUserSchema = z.object({
  email: z.string().email("Invalid email format"),
  password: z
    .string()
    .min(8, "Password must be at least 8 characters")
    .regex(/[A-Z]/, "Password must contain at least one uppercase letter")
    .regex(/[a-z]/, "Password must contain at least one lowercase letter")
    .regex(/[0-9]/, "Password must contain at least one number")
    .regex(
      /[!@#$%^&*]/,
      "Password must contain at least one special character"
    ),
  fullName: z.string().min(2).max(100).optional(),
  phone: z
    .string()
    .regex(/^\+?[1-9]\d{1,14}$/)
    .optional(),
  role: z
    .enum(["ADMIN", "BUSINESS_OWNER", "SERVICE_PROVIDER", "CUSTOMER"])
    .optional(),
});

export const updateUserSchema = z.object({
  email: z.string().email().optional(),
  fullName: z.string().min(2).max(100).optional(),
  phone: z
    .string()
    .regex(/^\+?[1-9]\d{1,14}$/)
    .optional(),
  role: z
    .enum(["ADMIN", "BUSINESS_OWNER", "SERVICE_PROVIDER", "CUSTOMER"])
    .optional(),
  isActive: z.boolean().optional(),
});

export const userQuerySchema = z.object({
  page: z
    .string()
    .regex(/^\d+$/)
    .transform(Number)
    .pipe(z.number().min(1))
    .optional(),
  limit: z
    .string()
    .regex(/^\d+$/)
    .transform(Number)
    .pipe(z.number().min(1).max(100))
    .optional(),
  search: z.string().optional(),
  role: z
    .enum(["ADMIN", "BUSINESS_OWNER", "SERVICE_PROVIDER", "CUSTOMER"])
    .optional(),
  isActive: z
    .string()
    .transform((val) => val === "true")
    .optional(),
  sortBy: z.enum(["email", "createdAt", "fullName"]).optional(),
  sortOrder: z.enum(["asc", "desc"]).optional(),
});

export type CreateUserInput = z.infer<typeof createUserSchema>;
export type UpdateUserInput = z.infer<typeof updateUserSchema>;
export type UserQueryInput = z.infer<typeof userQuerySchema>;
```

**Verificación**:

- [ ] Validadores creados
- [ ] Schemas Zod definidos
- [ ] Transformaciones aplicadas

---

### **Paso 3: Actualizar Repositorio de Usuario**

Actualizar `src/repositories/user.repository.ts`:

```typescript
import prisma from "../config/database";
import { User, Prisma, UserRole } from "@prisma/client";
import { BaseRepository } from "./base.repository";
import { UserQueryDto } from "../dto/user/user-query.dto";

export class UserRepository extends BaseRepository<User> {
  protected getModel() {
    return prisma.user;
  }

  async findByEmail(email: string): Promise<User | null> {
    return await prisma.user.findUnique({
      where: { email },
    });
  }

  async findManyWithPagination(query: UserQueryDto) {
    const {
      page = 1,
      limit = 10,
      search,
      role,
      isActive,
      sortBy = "createdAt",
      sortOrder = "desc",
    } = query;

    const skip = (page - 1) * limit;

    // Construir where clause
    const where: Prisma.UserWhereInput = {};

    if (search) {
      where.OR = [
        { email: { contains: search, mode: "insensitive" } },
        { fullName: { contains: search, mode: "insensitive" } },
      ];
    }

    if (role) {
      where.role = role as UserRole;
    }

    if (isActive !== undefined) {
      where.isActive = isActive;
    }

    // Ejecutar query con paginación
    const [users, total] = await Promise.all([
      prisma.user.findMany({
        where,
        skip,
        take: limit,
        orderBy: {
          [sortBy]: sortOrder,
        },
        select: {
          id: true,
          email: true,
          fullName: true,
          phone: true,
          role: true,
          isActive: true,
          createdAt: true,
          updatedAt: true,
        },
      }),
      prisma.user.count({ where }),
    ]);

    return {
      data: users,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async updatePassword(userId: string, hashedPassword: string): Promise<void> {
    await prisma.user.update({
      where: { id: userId },
      data: { password: hashedPassword },
    });
  }
}

export const userRepository = new UserRepository();
```

**Verificación**:

- [ ] Repositorio actualizado
- [ ] Paginación implementada
- [ ] Filtros implementados

---

### **Paso 4: Crear Servicio de Usuario**

Crear archivo `src/services/user.service.ts`:

```typescript
import { userRepository } from "../repositories/user.repository";
import { CreateUserDto, UpdateUserDto, UserQueryDto } from "../dto/user";
import { passwordUtil } from "../utils/password.util";
import { logger } from "../config/logger";
import { AppError } from "../middleware/error.middleware";
import { User, UserRole } from "@prisma/client";

export class UserService {
  async create(data: CreateUserDto, createdBy?: string): Promise<User> {
    logger.info(`Creating user: ${data.email} by: ${createdBy || "system"}`);

    // Verificar si el usuario ya existe
    const existingUser = await userRepository.findByEmail(data.email);
    if (existingUser) {
      throw new AppError(400, "User with this email already exists");
    }

    // Validar contraseña
    const passwordValidation = passwordUtil.validate(data.password);
    if (!passwordValidation.valid) {
      throw new AppError(400, passwordValidation.errors.join(", "));
    }

    // Hash de contraseña
    const hashedPassword = await passwordUtil.hash(data.password);

    // Crear usuario
    const user = await userRepository.create({
      email: data.email,
      password: hashedPassword,
      fullName: data.fullName,
      phone: data.phone,
      role: (data.role as UserRole) || UserRole.CUSTOMER,
      isActive: true,
    });

    logger.info(`User created: ${user.id}`);
    return user;
  }

  async findAll(query: UserQueryDto) {
    logger.info("Finding users with query:", query);
    return await userRepository.findManyWithPagination(query);
  }

  async findById(id: string): Promise<User | null> {
    const user = await userRepository.findById(id);
    if (!user) {
      throw new AppError(404, "User not found");
    }
    return user;
  }

  async update(
    id: string,
    data: UpdateUserDto,
    updatedBy?: string
  ): Promise<User> {
    logger.info(`Updating user: ${id} by: ${updatedBy || "system"}`);

    // Verificar que el usuario existe
    const existingUser = await this.findById(id);

    // Si se actualiza el email, verificar que no esté en uso
    if (data.email && data.email !== existingUser.email) {
      const emailExists = await userRepository.findByEmail(data.email);
      if (emailExists) {
        throw new AppError(400, "Email already in use");
      }
    }

    const updated = await userRepository.update(id, data);
    logger.info(`User updated: ${id}`);
    return updated;
  }

  async delete(id: string, deletedBy?: string): Promise<void> {
    logger.info(`Deleting user: ${id} by: ${deletedBy || "system"}`);

    // Verificar que el usuario existe
    await this.findById(id);

    // Soft delete
    await userRepository.update(id, { isActive: false });
    logger.info(`User deleted: ${id}`);
  }

  async changePassword(
    userId: string,
    currentPassword: string,
    newPassword: string
  ): Promise<void> {
    const user = await this.findById(userId);

    // Verificar contraseña actual
    const isCurrentPasswordValid = await passwordUtil.compare(
      currentPassword,
      user.password
    );
    if (!isCurrentPasswordValid) {
      throw new AppError(400, "Current password is incorrect");
    }

    // Validar nueva contraseña
    const passwordValidation = passwordUtil.validate(newPassword);
    if (!passwordValidation.valid) {
      throw new AppError(400, passwordValidation.errors.join(", "));
    }

    // Hash nueva contraseña
    const hashedPassword = await passwordUtil.hash(newPassword);
    await userRepository.updatePassword(userId, hashedPassword);

    logger.info(`Password changed for user: ${userId}`);
  }
}

export const userService = new UserService();
```

**Verificación**:

- [ ] Servicio creado
- [ ] Métodos CRUD implementados
- [ ] Validaciones implementadas

---

### **Paso 5: Crear Controlador de Usuario**

Crear archivo `src/controllers/user.controller.ts`:

```typescript
import { Request, Response, NextFunction } from "express";
import { userService } from "../services/user.service";
import { logger } from "../config/logger";

export class UserController {
  async create(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const createdBy = req.user?.id;
      const user = await userService.create(req.body, createdBy);

      res.status(201).json({
        success: true,
        data: user,
        message: "User created successfully",
      });
    } catch (error) {
      logger.error("Create user error:", error);
      next(error);
    }
  }

  async findAll(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const result = await userService.findAll(req.query as any);

      res.status(200).json({
        success: true,
        data: result.data,
        pagination: result.pagination,
      });
    } catch (error) {
      logger.error("Find all users error:", error);
      next(error);
    }
  }

  async findById(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const { id } = req.params;
      const user = await userService.findById(id);

      res.status(200).json({
        success: true,
        data: user,
      });
    } catch (error) {
      logger.error("Find user by id error:", error);
      next(error);
    }
  }

  async update(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const updatedBy = req.user?.id;
      const user = await userService.update(id, req.body, updatedBy);

      res.status(200).json({
        success: true,
        data: user,
        message: "User updated successfully",
      });
    } catch (error) {
      logger.error("Update user error:", error);
      next(error);
    }
  }

  async delete(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id } = req.params;
      const deletedBy = req.user?.id;
      await userService.delete(id, deletedBy);

      res.status(200).json({
        success: true,
        message: "User deleted successfully",
      });
    } catch (error) {
      logger.error("Delete user error:", error);
      next(error);
    }
  }

  async changePassword(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ success: false, message: "Unauthorized" });
        return;
      }

      const { currentPassword, newPassword } = req.body;
      await userService.changePassword(
        req.user.id,
        currentPassword,
        newPassword
      );

      res.status(200).json({
        success: true,
        message: "Password changed successfully",
      });
    } catch (error) {
      logger.error("Change password error:", error);
      next(error);
    }
  }
}

export const userController = new UserController();
```

**Verificación**:

- [ ] Controlador creado
- [ ] Métodos implementados
- [ ] Manejo de errores correcto

---

### **Paso 6: Crear Rutas de Usuario**

Crear archivo `src/routes/user.routes.ts`:

```typescript
import { Router } from "express";
import { userController } from "../controllers/user.controller";
import { authMiddleware } from "../middleware/auth.middleware";
import { validate } from "../middleware/validation.middleware";
import {
  createUserSchema,
  updateUserSchema,
  userQuerySchema,
} from "../validators/user.validator";

const router = Router();

// Todas las rutas requieren autenticación
router.use(authMiddleware);

router.post(
  "/",
  validate(createUserSchema),
  userController.create.bind(userController)
);

router.get(
  "/",
  validate(userQuerySchema, "query"),
  userController.findAll.bind(userController)
);

router.get("/:id", userController.findById.bind(userController));

router.put(
  "/:id",
  validate(updateUserSchema),
  userController.update.bind(userController)
);

router.delete("/:id", userController.delete.bind(userController));

router.post(
  "/change-password",
  userController.changePassword.bind(userController)
);

export default router;
```

Actualizar `src/middleware/validation.middleware.ts` para soportar query params:

```typescript
export const validate = (
  schema: ZodSchema,
  source: "body" | "query" = "body"
) => {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = source === "query" ? req.query : req.body;
      schema.parse(data);
      next();
    } catch (error) {
      // ... resto del código
    }
  };
};
```

**Verificación**:

- [ ] Rutas creadas
- [ ] Validación de query params funcionando

---

### **Paso 7: Registrar Rutas**

Actualizar `src/app.ts`:

```typescript
import userRoutes from "./routes/user.routes";

app.use("/api/users", userRoutes);
```

---

### **Paso 8: Crear Tests Completos**

Crear archivo `tests/integration/user.integration.test.ts`:

```typescript
import request from "supertest";
import app from "../../src/app";
import prisma from "../../src/config/database";
import { passwordUtil } from "../../src/utils/password.util";
import { jwtUtil } from "../../src/utils/jwt.util";

describe("User API Integration Tests", () => {
  let adminToken: string;
  let adminId: string;

  beforeAll(async () => {
    await prisma.$connect();
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  beforeEach(async () => {
    await prisma.appointment.deleteMany();
    await prisma.service.deleteMany();
    await prisma.businessTheme.deleteMany();
    await prisma.business.deleteMany();
    await prisma.user.deleteMany();

    // Crear admin para tests
    const admin = await prisma.user.create({
      data: {
        email: "admin@example.com",
        password: await passwordUtil.hash("Password123!"),
        role: "ADMIN",
        isActive: true,
      },
    });

    adminId = admin.id;
    adminToken = jwtUtil.generateAccessToken({
      userId: admin.id,
      email: admin.email,
      role: admin.role,
    });
  });

  describe("POST /api/users", () => {
    it("should create a new user", async () => {
      const response = await request(app)
        .post("/api/users")
        .set("Authorization", `Bearer ${adminToken}`)
        .send({
          email: "newuser@example.com",
          password: "Password123!",
          fullName: "New User",
          role: "CUSTOMER",
        });

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data.email).toBe("newuser@example.com");
    });
  });

  describe("GET /api/users", () => {
    beforeEach(async () => {
      // Crear usuarios de prueba
      await prisma.user.createMany({
        data: [
          {
            email: "user1@example.com",
            password: await passwordUtil.hash("Password123!"),
            role: "CUSTOMER",
            isActive: true,
          },
          {
            email: "user2@example.com",
            password: await passwordUtil.hash("Password123!"),
            role: "BUSINESS_OWNER",
            isActive: true,
          },
        ],
      });
    });

    it("should return paginated list of users", async () => {
      const response = await request(app)
        .get("/api/users?page=1&limit=10")
        .set("Authorization", `Bearer ${adminToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toBeInstanceOf(Array);
      expect(response.body.pagination).toHaveProperty("page", 1);
      expect(response.body.pagination).toHaveProperty("limit", 10);
      expect(response.body.pagination).toHaveProperty("total");
    });

    it("should filter users by role", async () => {
      const response = await request(app)
        .get("/api/users?role=BUSINESS_OWNER")
        .set("Authorization", `Bearer ${adminToken}`);

      expect(response.status).toBe(200);
      expect(
        response.body.data.every((u: any) => u.role === "BUSINESS_OWNER")
      ).toBe(true);
    });

    it("should search users by email or name", async () => {
      const response = await request(app)
        .get("/api/users?search=user1")
        .set("Authorization", `Bearer ${adminToken}`);

      expect(response.status).toBe(200);
      expect(response.body.data.length).toBeGreaterThan(0);
    });
  });
});
```

---

## ✅ Verificación Final

```bash
npm test
npm run dev
# Probar endpoints en Postman
```

---

## 📝 Entregables del Día

1. ✅ CRUD completo de usuarios
2. ✅ Paginación implementada
3. ✅ Filtros y búsqueda funcionando
4. ✅ Gestión de roles implementada
5. ✅ Cambio de contraseña implementado
6. ✅ Tests completos pasando

---

## 🎯 Próximo Día

**Día 7**: API de Servicios Completa

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_
