# 🏗️ **ARQUITECTURA DEL BACKEND - ElicaApp**

## 🎯 **Visión General de la Arquitectura**

### **🏛️ Principios Arquitectónicos**

- **Clean Architecture**: Separación clara de responsabilidades
- **SOLID Principles**: Principios de diseño robusto
- **Dependency Inversion**: Inversión de dependencias
- **Separation of Concerns**: Separación de conceptos
- **Testability**: Código fácilmente testeable
- **Type Safety**: TypeScript para prevenir errores en tiempo de compilación

### **🔄 Patrón de Arquitectura**

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │  Routes     │  │ Middleware   │  │   DTOs/Interfaces   │ │
│  │  (Express)  │  │  (Custom)   │  │   (TypeScript)      │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   Services  │  │ Validators   │  │   Mappers           │ │
│  │  (Business)  │  │   (Zod)      │  │   (Custom)         │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   Entities  │  │  Interfaces  │  │   Domain Services   │ │
│  │  (Models)   │  │  (Types)     │  │   (Logic)           │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  INFRASTRUCTURE LAYER                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ Repositories│  │   External  │  │   Configuration     │ │
│  │  (Prisma/   │  │   Services  │  │   (Env, DB)        │ │
│  │  TypeORM)   │  │  (Supabase) │  │                     │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 **Estructura de Carpetas del Proyecto**

```
elicaapp-backend/
├── 📁 src/
│   ├── 📁 routes/              # Rutas de Express
│   │   ├── auth.routes.ts
│   │   ├── business.routes.ts
│   │   ├── service.routes.ts
│   │   ├── appointment.routes.ts
│   │   └── dashboard.routes.ts
│   ├── 📁 controllers/         # Controladores (lógica de request/response)
│   │   ├── auth.controller.ts
│   │   ├── business.controller.ts
│   │   ├── service.controller.ts
│   │   └── appointment.controller.ts
│   ├── 📁 services/            # Lógica de negocio
│   │   ├── interfaces/
│   │   ├── auth.service.ts
│   │   ├── business.service.ts
│   │   ├── service.service.ts
│   │   └── appointment.service.ts
│   ├── 📁 middleware/          # Middleware personalizado
│   │   ├── error.middleware.ts
│   │   ├── logging.middleware.ts
│   │   ├── auth.middleware.ts
│   │   └── validation.middleware.ts
│   ├── 📁 models/              # Entidades y modelos de dominio
│   │   ├── User.model.ts
│   │   ├── Business.model.ts
│   │   ├── Service.model.ts
│   │   └── Appointment.model.ts
│   ├── 📁 repositories/        # Acceso a datos
│   │   ├── interfaces/
│   │   ├── user.repository.ts
│   │   ├── business.repository.ts
│   │   └── service.repository.ts
│   ├── 📁 dto/                 # Data Transfer Objects
│   │   ├── auth/
│   │   ├── business/
│   │   ├── service/
│   │   └── appointment/
│   ├── 📁 validators/           # Validaciones con Zod
│   │   ├── auth.validator.ts
│   │   ├── business.validator.ts
│   │   └── service.validator.ts
│   ├── 📁 utils/               # Utilidades
│   │   ├── logger.ts
│   │   ├── errors.ts
│   │   └── constants.ts
│   ├── 📁 config/              # Configuración
│   │   ├── database.ts
│   │   ├── jwt.ts
│   │   └── env.ts
│   └── 📁 app.ts               # Configuración de Express
│   └── 📁 server.ts             # Punto de entrada
├── 📁 tests/                   # Tests unitarios y de integración
│   ├── unit/
│   ├── integration/
│   └── fixtures/
├── 📁 prisma/                  # Schema y migraciones (si usas Prisma)
│   ├── schema.prisma
│   └── migrations/
├── 📄 package.json
├── 📄 tsconfig.json
├── 📄 .env.example
└── 📄 Dockerfile
```

---

## 🔧 **Componentes Principales**

### **🛣️ Routes (Presentation Layer)**

```typescript
import { Router } from "express";
import { BusinessController } from "../controllers/business.controller";
import { authMiddleware } from "../middleware/auth.middleware";
import { validateRequest } from "../middleware/validation.middleware";
import { businessSchemas } from "../validators/business.validator";

const router = Router();
const businessController = new BusinessController();

router.get(
  "/",
  authMiddleware,
  businessController.getAll.bind(businessController)
);

router.post(
  "/",
  authMiddleware,
  validateRequest(businessSchemas.create),
  businessController.create.bind(businessController)
);

export default router;
```

### **🎮 Controllers (Presentation Layer)**

```typescript
import { Request, Response, NextFunction } from "express";
import { BusinessService } from "../services/business.service";
import { CreateBusinessDto } from "../dto/business/create-business.dto";
import { logger } from "../utils/logger";

export class BusinessController {
  constructor(private readonly businessService: BusinessService) {}

  async getAll(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      logger.info("Fetching all businesses", { userId: req.user?.id });
      const businesses = await this.businessService.getAll();
      res.status(200).json({ success: true, data: businesses });
    } catch (error) {
      next(error);
    }
  }

  async create(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const createBusinessDto: CreateBusinessDto = req.body;
      const business = await this.businessService.create(createBusinessDto);
      res.status(201).json({ success: true, data: business });
    } catch (error) {
      next(error);
    }
  }
}
```

### **⚙️ Services (Application Layer)**

```typescript
import { IBusinessRepository } from "../repositories/interfaces/business.repository.interface";
import { CreateBusinessDto } from "../dto/business/create-business.dto";
import { Business } from "../models/Business.model";
import { logger } from "../utils/logger";

export class BusinessService {
  constructor(
    private readonly businessRepository: IBusinessRepository,
    private readonly logger: typeof logger
  ) {}

  async getAll(): Promise<Business[]> {
    this.logger.info("Getting all businesses");
    return await this.businessRepository.findAll();
  }

  async create(createBusinessDto: CreateBusinessDto): Promise<Business> {
    this.logger.info("Creating new business", { name: createBusinessDto.name });
    return await this.businessRepository.create(createBusinessDto);
  }
}
```

### **🏗️ Models (Domain Layer)**

```typescript
export interface Business {
  id: string;
  name: string;
  description: string;
  address: string;
  phone: string;
  email: string;
  type: BusinessType;
  status: BusinessStatus;
  ownerId: string;
  createdAt: Date;
  updatedAt: Date;
}

export enum BusinessType {
  SALON = "salon",
  RESTAURANT = "restaurant",
  SPA = "spa",
  OTHER = "other",
}

export enum BusinessStatus {
  ACTIVE = "active",
  INACTIVE = "inactive",
  SUSPENDED = "suspended",
}
```

### **🗄️ Repositories (Infrastructure Layer)**

```typescript
import { PrismaClient } from "@prisma/client";
import { Business } from "../../models/Business.model";
import { CreateBusinessDto } from "../../dto/business/create-business.dto";

export class BusinessRepository implements IBusinessRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async findAll(): Promise<Business[]> {
    return await this.prisma.business.findMany({
      where: { status: "ACTIVE" },
      include: {
        owner: true,
        services: true,
      },
    });
  }

  async create(createBusinessDto: CreateBusinessDto): Promise<Business> {
    return await this.prisma.business.create({
      data: createBusinessDto,
    });
  }
}
```

---

## 🔐 **Sistema de Autenticación y Autorización**

### **🔑 JWT Token Structure**

```typescript
interface JWTPayload {
  sub: string; // user-id
  email: string;
  role: UserRole;
  businessId?: string;
  iat: number;
  exp: number;
}

// Ejemplo de token generado
const token = jwt.sign(
  {
    sub: "user-id",
    email: "user@example.com",
    role: "BusinessOwner",
    businessId: "business-id",
  },
  process.env.JWT_SECRET!,
  { expiresIn: "1h" }
);
```

### **🛡️ Roles y Permisos**

```typescript
export enum UserRole {
  ADMIN = "admin",
  BUSINESS_OWNER = "business_owner",
  SERVICE_PROVIDER = "service_provider",
  CUSTOMER = "customer",
}

export enum Permission {
  READ_BUSINESS = "read:business",
  WRITE_BUSINESS = "write:business",
  READ_SERVICES = "read:services",
  WRITE_SERVICES = "write:services",
  READ_APPOINTMENTS = "read:appointments",
  WRITE_APPOINTMENTS = "write:appointments",
  READ_REPORTS = "read:reports",
  WRITE_REPORTS = "write:reports",
}

// Middleware de autorización
export const requirePermission = (permission: Permission) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const userPermissions = req.user?.permissions || [];
    if (!userPermissions.includes(permission)) {
      return res.status(403).json({ error: "Forbidden" });
    }
    next();
  };
};
```

---

## 📊 **Patrones de Diseño Implementados**

### **🏭 Factory Pattern**

```typescript
interface INotificationService {
  send(message: string): Promise<void>;
}

class EmailNotificationService implements INotificationService {
  async send(message: string): Promise<void> {
    // Implementación de email
  }
}

class SmsNotificationService implements INotificationService {
  async send(message: string): Promise<void> {
    // Implementación de SMS
  }
}

class NotificationServiceFactory {
  static create(type: NotificationType): INotificationService {
    switch (type) {
      case NotificationType.EMAIL:
        return new EmailNotificationService();
      case NotificationType.SMS:
        return new SmsNotificationService();
      default:
        throw new Error("Invalid notification type");
    }
  }
}
```

### **📋 Repository Pattern**

```typescript
export interface IRepository<T> {
  findById(id: string): Promise<T | null>;
  findAll(): Promise<T[]>;
  create(data: Partial<T>): Promise<T>;
  update(id: string, data: Partial<T>): Promise<T>;
  delete(id: string): Promise<void>;
}

export class BaseRepository<T> implements IRepository<T> {
  constructor(protected readonly model: any) {}

  async findById(id: string): Promise<T | null> {
    return await this.model.findUnique({ where: { id } });
  }

  async findAll(): Promise<T[]> {
    return await this.model.findMany();
  }

  async create(data: Partial<T>): Promise<T> {
    return await this.model.create({ data });
  }

  async update(id: string, data: Partial<T>): Promise<T> {
    return await this.model.update({ where: { id }, data });
  }

  async delete(id: string): Promise<void> {
    await this.model.delete({ where: { id } });
  }
}
```

### **🔄 Dependency Injection**

```typescript
// Container de dependencias
class Container {
  private services = new Map();

  register<T>(key: string, factory: () => T): void {
    this.services.set(key, factory);
  }

  resolve<T>(key: string): T {
    const factory = this.services.get(key);
    if (!factory) {
      throw new Error(`Service ${key} not found`);
    }
    return factory();
  }
}

// Uso
const container = new Container();
container.register("BusinessRepository", () => new BusinessRepository(prisma));
container.register(
  "BusinessService",
  () => new BusinessService(container.resolve("BusinessRepository"))
);
```

---

## 🧪 **Estrategia de Testing**

### **📝 Tests Unitarios**

```typescript
import { BusinessService } from "../services/business.service";
import { BusinessRepository } from "../repositories/business.repository";

describe("BusinessService", () => {
  let businessService: BusinessService;
  let mockRepository: jest.Mocked<BusinessRepository>;

  beforeEach(() => {
    mockRepository = {
      findAll: jest.fn(),
      create: jest.fn(),
    } as any;

    businessService = new BusinessService(mockRepository);
  });

  it("should return all businesses", async () => {
    const expectedBusinesses = [{ id: "1", name: "Test Business" }];
    mockRepository.findAll.mockResolvedValue(expectedBusinesses);

    const result = await businessService.getAll();

    expect(result).toEqual(expectedBusinesses);
    expect(mockRepository.findAll).toHaveBeenCalledTimes(1);
  });
});
```

### **🔗 Tests de Integración**

```typescript
import request from "supertest";
import app from "../app";

describe("Business API", () => {
  it("GET /api/business should return 200", async () => {
    const response = await request(app)
      .get("/api/business")
      .set("Authorization", `Bearer ${validToken}`)
      .expect(200);

    expect(response.body.success).toBe(true);
    expect(Array.isArray(response.body.data)).toBe(true);
  });
});
```

---

## 🚀 **Configuración y Deployment**

### **⚙️ .env.example**

```env
# Server
NODE_ENV=development
PORT=3000

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/elicaapp
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_KEY=your-service-key

# JWT
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRES_IN=1h
JWT_REFRESH_SECRET=your-refresh-secret
JWT_REFRESH_EXPIRES_IN=7d

# Redis
REDIS_URL=redis://localhost:6379

# Logging
LOG_LEVEL=info
```

### **🐳 Dockerfile**

```dockerfile
FROM node:18-alpine AS base
WORKDIR /app

# Dependencies
FROM base AS dependencies
COPY package*.json ./
RUN npm ci --only=production

# Build
FROM base AS build
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production
FROM base AS production
COPY --from=dependencies /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY package*.json ./

EXPOSE 3000
CMD ["node", "dist/server.js"]
```

### **📦 package.json (ejemplo)**

```json
{
  "name": "elicaapp-backend",
  "version": "1.0.0",
  "scripts": {
    "dev": "nodemon src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "lint": "eslint src/**/*.ts",
    "format": "prettier --write src/**/*.ts"
  },
  "dependencies": {
    "express": "^4.18.2",
    "typescript": "^5.0.0",
    "@prisma/client": "^5.0.0",
    "jsonwebtoken": "^9.0.0",
    "bcryptjs": "^2.4.3",
    "zod": "^3.22.0",
    "winston": "^3.10.0",
    "cors": "^2.8.5",
    "express-rate-limit": "^6.10.0"
  },
  "devDependencies": {
    "@types/express": "^4.17.17",
    "@types/node": "^20.0.0",
    "@types/jsonwebtoken": "^9.0.0",
    "@types/bcryptjs": "^2.4.2",
    "prisma": "^5.0.0",
    "jest": "^29.5.0",
    "ts-jest": "^29.1.0",
    "supertest": "^6.3.3",
    "nodemon": "^2.0.22",
    "ts-node": "^10.9.1",
    "eslint": "^8.45.0",
    "prettier": "^3.0.0"
  }
}
```

---

## 📈 **Métricas y Monitoreo**

### **📊 Health Checks**

```typescript
import { Router } from "express";

const healthRouter = Router();

healthRouter.get("/health", async (req, res) => {
  const health = {
    status: "ok",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    database: await checkDatabase(),
    redis: await checkRedis(),
  };

  res.status(200).json(health);
});

export default healthRouter;
```

### **📝 Logging Estructurado**

```typescript
import winston from "winston";

export const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || "info",
  format: winston.format.json(),
  defaultMeta: { service: "elicaapp-backend" },
  transports: [
    new winston.transports.File({ filename: "error.log", level: "error" }),
    new winston.transports.File({ filename: "combined.log" }),
  ],
});

if (process.env.NODE_ENV !== "production") {
  logger.add(
    new winston.transports.Console({
      format: winston.format.simple(),
    })
  );
}
```

---

## 🔒 **Seguridad y Compliance**

### **🛡️ OWASP Top 10 Compliance**

- **SQL Injection**: Prisma/TypeORM parameterized queries
- **Authentication**: JWT + Supabase Auth con refresh tokens
- **Authorization**: Role-based access control (RBAC) con middleware
- **Input Validation**: Zod validators en todos los endpoints
- **Rate Limiting**: express-rate-limit implementado
- **CORS**: Configuración restrictiva por origen
- **HTTPS**: Forzado en producción
- **Logging**: Logs de auditoría para acciones sensibles
- **Helmet**: Headers de seguridad con helmet.js

### **🔐 Data Protection**

```typescript
import helmet from "helmet";
import rateLimit from "express-rate-limit";

app.use(helmet());
app.use(
  rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // limit each IP to 100 requests per windowMs
  })
);
```

---

## 📚 **Referencias y Recursos**

### **🔗 Enlaces Oficiales**

- [Express.js Documentation](https://expressjs.com/)
- [TypeScript Documentation](https://www.typescriptlang.org/)
- [Prisma Documentation](https://www.prisma.io/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

### **📖 Libros Recomendados**

- "Clean Architecture" - Robert C. Martin
- "Domain-Driven Design" - Eric Evans
- "Node.js Design Patterns" - Mario Casciaro
- "TypeScript Deep Dive" - Basarat Ali Syed

---

_Última actualización: Diciembre 2024_  
_Versión: v2.0.0_  
_Stack: Express.js + TypeScript_
