# ✅ Día 14: Refinamiento y Testing Final

## 🎯 Objetivo del Día

Realizar refinamiento final del código, completar tests de integración, optimizar performance, y preparar el código para producción.

---

## ✅ Checklist de Tareas

- [ ] Ejecutar todos los tests y verificar cobertura
- [ ] Completar tests de integración faltantes
- [ ] Optimizar queries de base de datos
- [ ] Revisar y refactorizar código duplicado
- [ ] Completar documentación Swagger
- [ ] Code review completo
- [ ] Preparar para producción

---

## 📋 Pasos Detallados

### **Paso 1: Verificar Cobertura de Tests**

Ejecutar tests con cobertura:

```bash
npm run test:coverage
```

Verificar que la cobertura sea >80%:

```bash
# Verificar en coverage/lcov-report/index.html
# O ejecutar:
npm run test:coverage -- --coverageThreshold='{"global":{"branches":80,"functions":80,"lines":80,"statements":80}}'
```

Si la cobertura es menor, crear tests adicionales para las áreas faltantes.

### **Paso 2: Completar Tests de Integración**

Crear archivo `tests/integration/appointments.integration.test.ts`:

```typescript
import request from "supertest";
import app from "../../src/app";
import prisma from "../../src/config/database";
import { User, Business, Service, Appointment } from "@prisma/client";

describe("Appointments Integration Tests", () => {
  let authToken: string;
  let userId: string;
  let businessId: string;
  let serviceId: string;

  beforeAll(async () => {
    // Crear usuario de prueba
    const user = await prisma.user.create({
      data: {
        email: "test@example.com",
        password: "hashedpassword",
        fullName: "Test User",
        role: "CUSTOMER",
      },
    });
    userId = user.id;

    // Login para obtener token
    const loginResponse = await request(app)
      .post("/api/auth/login")
      .send({
        email: "test@example.com",
        password: "password123",
      });
    authToken = loginResponse.body.data.accessToken;

    // Crear negocio de prueba
    const business = await prisma.business.create({
      data: {
        name: "Test Business",
        ownerId: userId,
        isActive: true,
      },
    });
    businessId = business.id;

    // Crear servicio de prueba
    const service = await prisma.service.create({
      data: {
        name: "Test Service",
        businessId,
        price: 50,
        durationMinutes: 60,
        isActive: true,
      },
    });
    serviceId = service.id;
  });

  afterAll(async () => {
    // Limpiar datos de prueba
    await prisma.appointment.deleteMany({});
    await prisma.service.deleteMany({});
    await prisma.business.deleteMany({});
    await prisma.user.deleteMany({});
    await prisma.$disconnect();
  });

  describe("POST /api/appointments", () => {
    it("should create an appointment", async () => {
      const appointmentDate = new Date();
      appointmentDate.setDate(appointmentDate.getDate() + 1); // Mañana

      const response = await request(app)
        .post("/api/appointments")
        .set("Authorization", `Bearer ${authToken}`)
        .send({
          businessId,
          serviceId,
          date: appointmentDate.toISOString(),
        });

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty("id");
    });

    it("should fail with invalid date", async () => {
      const response = await request(app)
        .post("/api/appointments")
        .set("Authorization", `Bearer ${authToken}`)
        .send({
          businessId,
          serviceId,
          date: "invalid-date",
        });

      expect(response.status).toBe(400);
    });
  });

  describe("GET /api/appointments", () => {
    it("should get user appointments", async () => {
      const response = await request(app)
        .get("/api/appointments")
        .set("Authorization", `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(Array.isArray(response.body.data)).toBe(true);
    });
  });
});
```

### **Paso 3: Optimizar Queries de Base de Datos**

Revisar y optimizar queries en repositorios. Ejemplo de optimización en `src/repositories/business.repository.ts`:

```typescript
// ❌ Antes: Query ineficiente
async findById(id: string): Promise<Business | null> {
  return await prisma.business.findUnique({
    where: { id },
  });
}

// ✅ Después: Query optimizada con select específico
async findById(id: string): Promise<Business | null> {
  return await prisma.business.findUnique({
    where: { id },
    select: {
      id: true,
      name: true,
      description: true,
      // ... solo campos necesarios
    },
  });
}

// ✅ Para queries con relaciones, usar include selectivo
async findByIdWithServices(id: string): Promise<Business | null> {
  return await prisma.business.findUnique({
    where: { id },
    include: {
      services: {
        where: { isActive: true },
        select: {
          id: true,
          name: true,
          price: true,
          // ... solo campos necesarios
        },
      },
    },
  });
}
```

### **Paso 4: Refactorizar Código Duplicado**

Identificar y refactorizar código duplicado. Ejemplo:

**Antes (código duplicado):**

```typescript
// En business.service.ts
async create(data: CreateBusinessDto, ownerId: string) {
  const business = await businessRepository.findById(data.id);
  if (!business || business.ownerId !== ownerId) {
    throw new AppError(403, "Permission denied");
  }
  // ...
}

// En service.service.ts
async create(data: CreateServiceDto, ownerId: string) {
  const business = await businessRepository.findById(data.businessId);
  if (!business || business.ownerId !== ownerId) {
    throw new AppError(403, "Permission denied");
  }
  // ...
}
```

**Después (refactorizado):**

```typescript
// Crear utilidad compartida
// src/utils/business-permission.util.ts
export class BusinessPermissionUtil {
  static async verifyOwnership(
    businessId: string,
    userId: string
  ): Promise<Business> {
    const business = await businessRepository.findById(businessId);
    if (!business || business.ownerId !== userId) {
      throw new AppError(403, "You do not have permission");
    }
    return business;
  }
}

// Usar en servicios
import { BusinessPermissionUtil } from "../utils/business-permission.util";

async create(data: CreateBusinessDto, ownerId: string) {
  await BusinessPermissionUtil.verifyOwnership(data.id, ownerId);
  // ...
}
```

### **Paso 5: Completar Documentación Swagger**

Actualizar controladores con documentación Swagger completa. Ejemplo:

```typescript
/**
 * @swagger
 * /api/appointments:
 *   post:
 *     summary: Create a new appointment
 *     tags: [Appointments]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - businessId
 *               - serviceId
 *               - date
 *             properties:
 *               businessId:
 *                 type: string
 *                 format: uuid
 *                 example: "123e4567-e89b-12d3-a456-426614174000"
 *               serviceId:
 *                 type: string
 *                 format: uuid
 *                 example: "123e4567-e89b-12d3-a456-426614174001"
 *               date:
 *                 type: string
 *                 format: date-time
 *                 example: "2024-12-25T10:00:00Z"
 *               notes:
 *                 type: string
 *                 example: "Please arrive 10 minutes early"
 *     responses:
 *       201:
 *         description: Appointment created successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   $ref: '#/components/schemas/Appointment'
 *       400:
 *         description: Bad request
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden
 */
async create(req: Request, res: Response): Promise<void> {
  // ... implementation
}
```

### **Paso 6: Implementar Manejo de Errores Mejorado**

Crear middleware de manejo de errores mejorado:

```typescript
// src/middleware/error.middleware.ts
export const errorHandler = (
  err: Error | AppError | ZodError,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  // Log error con contexto completo
  logger.error("Error occurred:", {
    error: err,
    path: req.path,
    method: req.method,
    body: req.body,
    query: req.query,
    params: req.params,
    user: req.user?.id,
    ip: req.ip,
    userAgent: req.get("user-agent"),
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
      ...(env.NODE_ENV === "development" && { stack: err.stack }),
    });
    return;
  }

  // Error desconocido
  res.status(500).json({
    success: false,
    message:
      env.NODE_ENV === "production"
        ? "Internal server error"
        : err.message,
    ...(env.NODE_ENV === "development" && { stack: err.stack }),
  });
};
```

### **Paso 7: Agregar Validación de Entrada Global**

Crear middleware de validación global:

```typescript
// src/middleware/validation.middleware.ts
import { Request, Response, NextFunction } from "express";
import { ZodSchema } from "zod";

export const validate = (schema: ZodSchema) => {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      schema.parse({
        body: req.body,
        query: req.query,
        params: req.params,
      });
      next();
    } catch (error) {
      next(error); // Pasar al error handler
    }
  };
};
```

### **Paso 8: Configurar Variables de Entorno para Producción**

Crear archivo `.env.production.example`:

```env
NODE_ENV=production
PORT=3000

# Database
DATABASE_URL=postgresql://user:password@host:5432/database

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRES_IN=7d

# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Logging
LOG_LEVEL=info

# CORS
CORS_ORIGIN=https://your-frontend-domain.com
```

### **Paso 9: Crear Scripts de Producción**

Actualizar `package.json`:

```json
{
  "scripts": {
    "build": "tsc",
    "start": "node dist/server.js",
    "start:prod": "NODE_ENV=production node dist/server.js",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "test:integration": "jest --testPathPattern=integration",
    "lint": "eslint src --ext .ts",
    "lint:fix": "eslint src --ext .ts --fix",
    "format": "prettier --write \"src/**/*.ts\"",
    "prisma:generate": "prisma generate",
    "prisma:migrate": "prisma migrate deploy",
    "prisma:studio": "prisma studio"
  }
}
```

### **Paso 10: Crear Checklist de Code Review**

Crear archivo `docs/backend/CODE_REVIEW_CHECKLIST.md`:

```markdown
# ✅ Checklist de Code Review

## Funcionalidad
- [ ] El código cumple con los requisitos de la historia de usuario
- [ ] Los casos edge están manejados
- [ ] Los errores se manejan apropiadamente

## Código
- [ ] El código sigue las convenciones del proyecto
- [ ] No hay código duplicado
- [ ] Las funciones son pequeñas y hacen una sola cosa
- [ ] Los nombres de variables y funciones son descriptivos

## Testing
- [ ] Hay tests unitarios para la nueva funcionalidad
- [ ] Hay tests de integración si es necesario
- [ ] Los tests pasan
- [ ] La cobertura de código es adecuada (>80%)

## Seguridad
- [ ] Las validaciones de entrada están implementadas
- [ ] Los permisos están verificados
- [ ] No hay información sensible expuesta
- [ ] Las queries SQL están protegidas contra inyección

## Performance
- [ ] Las queries de base de datos están optimizadas
- [ ] No hay N+1 queries
- [ ] Los datos se cargan de forma eficiente

## Documentación
- [ ] El código está documentado si es necesario
- [ ] La documentación Swagger está actualizada
- [ ] Los comentarios explican el "por qué", no el "qué"
```

### **Paso 11: Ejecutar Análisis Estático**

Configurar ESLint y ejecutar:

```bash
npm run lint
npm run lint:fix
```

Configurar Prettier:

```bash
npm run format
```

### **Paso 12: Preparar para Deploy**

Crear archivo `Dockerfile`:

```dockerfile
FROM node:18-alpine

WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./
COPY prisma ./prisma/

# Instalar dependencias
RUN npm ci --only=production

# Copiar código compilado
COPY dist ./dist

# Generar Prisma Client
RUN npx prisma generate

# Exponer puerto
EXPOSE 3000

# Comando de inicio
CMD ["node", "dist/server.js"]
```

Crear archivo `.dockerignore`:

```
node_modules
npm-debug.log
.env
.env.local
coverage
tests
src
*.md
.git
.gitignore
```

---

## ✅ Verificación Final

- [ ] Todos los tests pasando (unitarios e integración)
- [ ] Cobertura de código >80%
- [ ] Código refactorizado y optimizado
- [ ] Documentación Swagger completa
- [ ] Code review completado
- [ ] Linting y formatting aplicados
- [ ] Preparado para producción

---

## 📝 Entregables del Día

1. ✅ Tests completos con cobertura >80%
2. ✅ Código optimizado y refactorizado
3. ✅ Documentación Swagger completa
4. ✅ Code review realizado
5. ✅ Preparación para producción
6. ✅ Dockerfile y configuración de deploy

---

## 🎉 Sprint 1 Completado

¡Felicidades! Has completado el Sprint 1. El backend está listo con:

- ✅ Configuración completa del proyecto
- ✅ Sistema de autenticación
- ✅ APIs core (Usuarios, Negocios, Servicios, Citas)
- ✅ Dashboard y métricas
- ✅ Sistema de notificaciones
- ✅ Búsqueda y filtros avanzados
- ✅ Upload de archivos
- ✅ Horarios y disponibilidad
- ✅ Tests completos

---

## 🎯 Próximo Sprint

**Sprint 2**: Funcionalidades Avanzadas
- Sistema de pagos
- Reviews y ratings
- Reportes avanzados
- Optimizaciones de performance

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_

