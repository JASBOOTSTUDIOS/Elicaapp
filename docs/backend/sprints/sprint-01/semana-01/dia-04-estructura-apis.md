# 📅 Día 4: Estructura de APIs y Endpoints Base

## 🎯 Objetivo del Día

Crear la estructura base de APIs, controladores, servicios y repositorios siguiendo Clean Architecture, implementando endpoints básicos de usuarios y negocios.

---

## ✅ Checklist de Tareas

- [ ] Crear controladores base
- [ ] Crear servicios base
- [ ] Crear repositorios para Business
- [ ] Crear DTOs base
- [ ] Crear middleware de manejo de errores
- [ ] Implementar endpoints de usuarios
- [ ] Implementar endpoints de negocios
- [ ] Configurar Swagger/OpenAPI
- [ ] Crear tests de endpoints

---

## 📋 Pasos Detallados

### **Paso 1: Crear Clase Base de Respuesta**

Crear archivo `src/dto/common/response.dto.ts`:

```typescript
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  message?: string;
  errors?: Array<{ field: string; message: string }>;
}

export interface PaginatedResponse<T> {
  success: boolean;
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}
```

**Verificación**:

- [ ] DTOs comunes creados
- [ ] Interfaces definidas

---

### **Paso 2: Crear Middleware de Manejo de Errores**

Crear archivo `src/middleware/error.middleware.ts`:

```typescript
import { Request, Response, NextFunction } from "express";
import { ZodError } from "zod";
import { logger } from "../config/logger";
import { env } from "../config/env";

export class AppError extends Error {
  constructor(
    public statusCode: number,
    public message: string,
    public isOperational = true
  ) {
    super(message);
    Object.setPrototypeOf(this, AppError.prototype);
  }
}

export const errorHandler = (
  err: Error | AppError | ZodError,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  logger.error("Error:", {
    error: err,
    path: req.path,
    method: req.method,
    body: req.body,
  });

  // Error de validación Zod
  if (err instanceof ZodError) {
    res.status(400).json({
      success: false,
      message: "Validation error",
      errors: err.errors.map((e) => ({
        field: e.path.join("."),
        message: e.message,
      })),
    });
    return;
  }

  // Error de aplicación
  if (err instanceof AppError) {
    res.status(err.statusCode).json({
      success: false,
      message: err.message,
    });
    return;
  }

  // Error desconocido
  res.status(500).json({
    success: false,
    message:
      env.NODE_ENV === "production" ? "Internal server error" : err.message,
    ...(env.NODE_ENV === "development" && { stack: err.stack }),
  });
};
```

Actualizar `src/app.ts` para usar el error handler:

```typescript
import { errorHandler } from "./middleware/error.middleware";

// Al final, antes de export
app.use(errorHandler);
```

**Verificación**:

- [ ] Middleware de errores creado
- [ ] Integrado en app.ts
- [ ] Manejo de diferentes tipos de errores

---

### **Paso 3: Crear Repositorio de Business**

Crear archivo `src/repositories/business.repository.ts`:

```typescript
import prisma from "../config/database";
import { Business, Prisma } from "@prisma/client";
import { BaseRepository } from "./base.repository";

export class BusinessRepository extends BaseRepository<Business> {
  protected getModel() {
    return prisma.business;
  }

  async findByOwnerId(ownerId: string): Promise<Business[]> {
    return await prisma.business.findMany({
      where: { ownerId },
      include: {
        owner: true,
        services: true,
        theme: true,
      },
    });
  }

  async findByIdWithRelations(id: string): Promise<Business | null> {
    return await prisma.business.findUnique({
      where: { id },
      include: {
        owner: {
          select: {
            id: true,
            email: true,
            fullName: true,
          },
        },
        services: {
          where: { isActive: true },
        },
        theme: true,
      },
    });
  }

  async findMany(args?: Prisma.BusinessFindManyArgs): Promise<Business[]> {
    return await prisma.business.findMany({
      ...args,
      include: {
        owner: {
          select: {
            id: true,
            email: true,
            fullName: true,
          },
        },
        _count: {
          select: {
            services: true,
            appointments: true,
          },
        },
      },
    });
  }
}

export const businessRepository = new BusinessRepository();
```

**Verificación**:

- [ ] Repositorio de Business creado
- [ ] Métodos con relaciones implementados

---

### **Paso 4: Crear DTOs de Business**

Crear archivo `src/dto/business/create-business.dto.ts`:

```typescript
export interface CreateBusinessDto {
  name: string;
  description?: string;
  type: "SALON" | "RESTAURANT" | "SPA" | "OTHER";
  address?: string;
  phone?: string;
  email?: string;
}
```

Crear archivo `src/dto/business/update-business.dto.ts`:

```typescript
export interface UpdateBusinessDto {
  name?: string;
  description?: string;
  type?: "SALON" | "RESTAURANT" | "SPA" | "OTHER";
  address?: string;
  phone?: string;
  email?: string;
  isActive?: boolean;
}
```

Crear archivo `src/dto/business/business-response.dto.ts`:

```typescript
export interface BusinessResponseDto {
  id: string;
  name: string;
  description?: string;
  type: string;
  address?: string;
  phone?: string;
  email?: string;
  ownerId: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
  owner?: {
    id: string;
    email: string;
    fullName?: string;
  };
  servicesCount?: number;
  appointmentsCount?: number;
}
```

**Verificación**:

- [ ] DTOs de Business creados
- [ ] Interfaces definidas

---

### **Paso 5: Crear Validadores de Business**

Crear archivo `src/validators/business.validator.ts`:

```typescript
import { z } from "zod";

export const createBusinessSchema = z.object({
  name: z.string().min(2, "Name must be at least 2 characters").max(100),
  description: z.string().max(500).optional(),
  type: z.enum(["SALON", "RESTAURANT", "SPA", "OTHER"]),
  address: z.string().max(200).optional(),
  phone: z
    .string()
    .regex(/^\+?[1-9]\d{1,14}$/)
    .optional(),
  email: z.string().email().optional(),
});

export const updateBusinessSchema = createBusinessSchema.partial();

export type CreateBusinessInput = z.infer<typeof createBusinessSchema>;
export type UpdateBusinessInput = z.infer<typeof updateBusinessSchema>;
```

**Verificación**:

- [ ] Validadores creados
- [ ] Schemas Zod definidos

---

### **Paso 6: Crear Servicio de Business**

Crear archivo `src/services/business.service.ts`:

```typescript
import { businessRepository } from "../repositories/business.repository";
import { CreateBusinessDto, UpdateBusinessDto } from "../dto/business";
import { logger } from "../config/logger";
import { AppError } from "../middleware/error.middleware";
import { Business } from "@prisma/client";

export class BusinessService {
  async create(ownerId: string, data: CreateBusinessDto): Promise<Business> {
    logger.info(`Creating business: ${data.name} for owner: ${ownerId}`);

    const business = await businessRepository.create({
      ...data,
      ownerId,
      isActive: true,
    });

    logger.info(`Business created: ${business.id}`);
    return business;
  }

  async findAll(ownerId?: string): Promise<Business[]> {
    if (ownerId) {
      return await businessRepository.findByOwnerId(ownerId);
    }
    return await businessRepository.findMany({
      where: { isActive: true },
    });
  }

  async findById(id: string, ownerId?: string): Promise<Business | null> {
    const business = await businessRepository.findByIdWithRelations(id);

    if (!business) {
      throw new AppError(404, "Business not found");
    }

    // Verificar que el usuario es el dueño si se especifica ownerId
    if (ownerId && business.ownerId !== ownerId) {
      throw new AppError(
        403,
        "You do not have permission to access this business"
      );
    }

    return business;
  }

  async update(
    id: string,
    ownerId: string,
    data: UpdateBusinessDto
  ): Promise<Business> {
    // Verificar que el negocio existe y pertenece al usuario
    const existingBusiness = await this.findById(id, ownerId);

    logger.info(`Updating business: ${id}`);

    const updated = await businessRepository.update(id, data);

    logger.info(`Business updated: ${id}`);
    return updated;
  }

  async delete(id: string, ownerId: string): Promise<void> {
    // Verificar que el negocio existe y pertenece al usuario
    await this.findById(id, ownerId);

    logger.info(`Deleting business: ${id}`);

    // Soft delete
    await businessRepository.update(id, { isActive: false });

    logger.info(`Business deleted: ${id}`);
  }
}

export const businessService = new BusinessService();
```

**Verificación**:

- [ ] Servicio de Business creado
- [ ] Métodos CRUD implementados
- [ ] Validaciones de permisos implementadas

---

### **Paso 7: Crear Controlador de Business**

Crear archivo `src/controllers/business.controller.ts`:

```typescript
import { Request, Response, NextFunction } from "express";
import { businessService } from "../services/business.service";
import { logger } from "../config/logger";

export class BusinessController {
  async create(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ success: false, message: "Unauthorized" });
        return;
      }

      const business = await businessService.create(req.user.id, req.body);

      res.status(201).json({
        success: true,
        data: business,
        message: "Business created successfully",
      });
    } catch (error) {
      logger.error("Create business error:", error);
      next(error);
    }
  }

  async findAll(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const ownerId = req.user?.id;
      const businesses = await businessService.findAll(ownerId);

      res.status(200).json({
        success: true,
        data: businesses,
      });
    } catch (error) {
      logger.error("Find all businesses error:", error);
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
      const ownerId = req.user?.id;
      const business = await businessService.findById(id, ownerId);

      res.status(200).json({
        success: true,
        data: business,
      });
    } catch (error) {
      logger.error("Find business by id error:", error);
      next(error);
    }
  }

  async update(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ success: false, message: "Unauthorized" });
        return;
      }

      const { id } = req.params;
      const business = await businessService.update(id, req.user.id, req.body);

      res.status(200).json({
        success: true,
        data: business,
        message: "Business updated successfully",
      });
    } catch (error) {
      logger.error("Update business error:", error);
      next(error);
    }
  }

  async delete(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ success: false, message: "Unauthorized" });
        return;
      }

      const { id } = req.params;
      await businessService.delete(id, req.user.id);

      res.status(200).json({
        success: true,
        message: "Business deleted successfully",
      });
    } catch (error) {
      logger.error("Delete business error:", error);
      next(error);
    }
  }
}

export const businessController = new BusinessController();
```

**Verificación**:

- [ ] Controlador creado
- [ ] Métodos implementados
- [ ] Manejo de errores con next()

---

### **Paso 8: Crear Rutas de Business**

Crear archivo `src/routes/business.routes.ts`:

```typescript
import { Router } from "express";
import { businessController } from "../controllers/business.controller";
import { authMiddleware } from "../middleware/auth.middleware";
import { validate } from "../middleware/validation.middleware";
import {
  createBusinessSchema,
  updateBusinessSchema,
} from "../validators/business.validator";

const router = Router();

// Todas las rutas requieren autenticación
router.use(authMiddleware);

router.post(
  "/",
  validate(createBusinessSchema),
  businessController.create.bind(businessController)
);

router.get("/", businessController.findAll.bind(businessController));

router.get("/:id", businessController.findById.bind(businessController));

router.put(
  "/:id",
  validate(updateBusinessSchema),
  businessController.update.bind(businessController)
);

router.delete("/:id", businessController.delete.bind(businessController));

export default router;
```

**Verificación**:

- [ ] Rutas creadas
- [ ] Middleware de autenticación aplicado
- [ ] Validación aplicada

---

### **Paso 9: Registrar Rutas en app.ts**

Actualizar `src/app.ts`:

```typescript
import businessRoutes from "./routes/business.routes";

// Después de authRoutes
app.use("/api/businesses", businessRoutes);
```

**Verificación**:

- [ ] Rutas registradas
- [ ] Endpoints accesibles

---

### **Paso 10: Configurar Swagger**

Instalar dependencias:

```bash
npm install swagger-ui-express swagger-jsdoc
npm install -D @types/swagger-ui-express @types/swagger-jsdoc
```

Crear archivo `src/config/swagger.ts`:

```typescript
import swaggerJsdoc from "swagger-jsdoc";
import { env } from "./env";

const options: swaggerJsdoc.Options = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "ElicaApp API",
      version: "1.0.0",
      description: "API Documentation for ElicaApp Backend",
    },
    servers: [
      {
        url: `http://localhost:${env.PORT}`,
        description: "Development server",
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: "http",
          scheme: "bearer",
          bearerFormat: "JWT",
        },
      },
    },
  },
  apis: ["./src/routes/*.ts", "./src/controllers/*.ts"],
};

export const swaggerSpec = swaggerJsdoc(options);
```

Actualizar `src/app.ts`:

```typescript
import swaggerUi from "swagger-ui-express";
import { swaggerSpec } from "./config/swagger";

// Después de body parsing middleware
app.use("/api/docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));
```

**Verificación**:

- [ ] Swagger configurado
- [ ] Documentación accesible en `/api/docs`

---

### **Paso 11: Agregar Documentación Swagger a Rutas**

Actualizar `src/routes/business.routes.ts`:

```typescript
/**
 * @swagger
 * /api/businesses:
 *   post:
 *     summary: Create a new business
 *     tags: [Businesses]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - type
 *             properties:
 *               name:
 *                 type: string
 *               description:
 *                 type: string
 *               type:
 *                 type: string
 *                 enum: [SALON, RESTAURANT, SPA, OTHER]
 *     responses:
 *       201:
 *         description: Business created successfully
 *       400:
 *         description: Validation error
 *       401:
 *         description: Unauthorized
 */
router.post(
  "/",
  validate(createBusinessSchema),
  businessController.create.bind(businessController)
);
```

**Verificación**:

- [ ] Documentación Swagger agregada
- [ ] Visible en `/api/docs`

---

### **Paso 12: Crear Tests**

Crear archivo `tests/integration/business.test.ts`:

```typescript
import request from "supertest";
import app from "../../src/app";
import { userRepository } from "../../src/repositories/user.repository";
import { jwtUtil } from "../../src/utils/jwt.util";

describe("Business API", () => {
  let authToken: string;
  let userId: string;

  beforeAll(async () => {
    // Crear usuario de prueba
    const user = await userRepository.create({
      email: "business-test@example.com",
      password: "hashedPassword",
      role: "BUSINESS_OWNER",
      isActive: true,
    });

    userId = user.id;
    authToken = jwtUtil.generateAccessToken({
      userId: user.id,
      email: user.email,
      role: user.role,
    });
  });

  describe("POST /api/businesses", () => {
    it("should create a business with valid token", async () => {
      const response = await request(app)
        .post("/api/businesses")
        .set("Authorization", `Bearer ${authToken}`)
        .send({
          name: "Test Business",
          type: "SALON",
          description: "A test business",
        });

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty("id");
      expect(response.body.data.name).toBe("Test Business");
    });

    it("should return 401 without token", async () => {
      const response = await request(app).post("/api/businesses").send({
        name: "Test Business",
        type: "SALON",
      });

      expect(response.status).toBe(401);
    });
  });

  describe("GET /api/businesses", () => {
    it("should return list of businesses", async () => {
      const response = await request(app)
        .get("/api/businesses")
        .set("Authorization", `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(Array.isArray(response.body.data)).toBe(true);
    });
  });
});
```

**Verificación**:

- [ ] Tests creados
- [ ] `npm test` pasa correctamente

---

## ✅ Verificación Final

```bash
# 1. Ejecutar tests
npm test

# 2. Iniciar servidor
npm run dev

# 3. Probar endpoints
# GET http://localhost:3000/api/docs (Swagger)
# POST http://localhost:3000/api/businesses (con token)
# GET http://localhost:3000/api/businesses (con token)
```

**Verificaciones**:

- [ ] Tests pasando
- [ ] Endpoints funcionando
- [ ] Swagger documentando APIs
- [ ] Autenticación requerida
- [ ] Validaciones funcionando

---

## 📝 Entregables del Día

1. ✅ Estructura de APIs implementada
2. ✅ Controladores base creados
3. ✅ Servicios base creados
4. ✅ Repositorios con relaciones
5. ✅ DTOs y validadores implementados
6. ✅ Middleware de errores configurado
7. ✅ Endpoints de Business funcionando
8. ✅ Swagger configurado
9. ✅ Tests de integración pasando

---

## 🎯 Próximo Día

**Día 5**: Testing Base y Configuración de CI/CD

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_
