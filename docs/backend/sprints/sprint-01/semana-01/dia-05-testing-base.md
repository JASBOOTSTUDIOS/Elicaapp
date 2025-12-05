# 📅 Día 5: Testing Base y Configuración

## 🎯 Objetivo del Día

Configurar completamente el sistema de testing, crear tests unitarios y de integración para las funcionalidades implementadas, y configurar coverage reports.

---

## ✅ Checklist de Tareas

- [ ] Configurar Jest completamente
- [ ] Crear fixtures y mocks
- [ ] Crear tests unitarios de servicios
- [ ] Crear tests unitarios de repositorios
- [ ] Crear tests de integración de APIs
- [ ] Configurar coverage reports
- [ ] Crear scripts de testing
- [ ] Documentar estrategia de testing

---

## 📋 Pasos Detallados

### **Paso 1: Configurar Jest Completamente**

Actualizar `jest.config.js`:

```javascript
module.exports = {
  preset: "ts-jest",
  testEnvironment: "node",
  roots: ["<rootDir>/tests"],
  testMatch: ["**/__tests__/**/*.ts", "**/?(*.)+(spec|test).ts"],
  transform: {
    "^.+\\.ts$": "ts-jest",
  },
  collectCoverageFrom: [
    "src/**/*.ts",
    "!src/**/*.d.ts",
    "!src/server.ts",
    "!src/app.ts",
    "!src/config/**",
  ],
  coverageDirectory: "coverage",
  coverageReporters: ["text", "lcov", "html", "json"],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70,
    },
  },
  moduleNameMapper: {
    "^@/(.*)$": "<rootDir>/src/$1",
  },
  setupFilesAfterEnv: ["<rootDir>/tests/setup.ts"],
  testTimeout: 10000,
  clearMocks: true,
  resetMocks: true,
  restoreMocks: true,
};
```

**Verificación**:

- [ ] Jest configurado
- [ ] Coverage thresholds definidos

---

### **Paso 2: Crear Fixtures y Helpers**

Crear archivo `tests/fixtures/user.fixture.ts`:

```typescript
import { User, UserRole } from "@prisma/client";

export const createMockUser = (overrides?: Partial<User>): User => ({
  id: "user-123",
  email: "test@example.com",
  password: "hashedPassword123",
  fullName: "Test User",
  phone: "+1234567890",
  role: UserRole.CUSTOMER,
  isActive: true,
  createdAt: new Date(),
  updatedAt: new Date(),
  ...overrides,
});

export const createMockBusinessOwner = (overrides?: Partial<User>): User => {
  return createMockUser({
    role: UserRole.BUSINESS_OWNER,
    ...overrides,
  });
};
```

Crear archivo `tests/fixtures/business.fixture.ts`:

```typescript
import { Business, BusinessType } from "@prisma/client";

export const createMockBusiness = (
  overrides?: Partial<Business>
): Business => ({
  id: "business-123",
  name: "Test Business",
  description: "A test business",
  type: BusinessType.SALON,
  address: "123 Test St",
  phone: "+1234567890",
  email: "business@example.com",
  ownerId: "user-123",
  isActive: true,
  createdAt: new Date(),
  updatedAt: new Date(),
  ...overrides,
});
```

Crear archivo `tests/helpers/test-helpers.ts`:

```typescript
import { Request } from "express";
import { JWTPayload } from "../../src/utils/jwt.util";

export const createMockRequest = (
  overrides?: Partial<Request>
): Partial<Request> => ({
  body: {},
  params: {},
  query: {},
  headers: {},
  user: undefined,
  ...overrides,
});

export const createMockUserPayload = (
  overrides?: Partial<JWTPayload>
): JWTPayload => ({
  userId: "user-123",
  email: "test@example.com",
  role: "CUSTOMER",
  ...overrides,
});
```

**Verificación**:

- [ ] Fixtures creados
- [ ] Helpers creados
- [ ] Tipos correctos

---

### **Paso 3: Crear Tests Unitarios de Servicios**

Crear archivo `tests/unit/services/auth.service.test.ts`:

```typescript
import { authService } from "../../../src/services/auth.service";
import { userRepository } from "../../../src/repositories/user.repository";
import { passwordUtil } from "../../../src/utils/password.util";
import { createMockUser } from "../../fixtures/user.fixture";
import { AppError } from "../../../src/middleware/error.middleware";

jest.mock("../../../src/repositories/user.repository");
jest.mock("../../../src/utils/password.util");

describe("AuthService", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe("register", () => {
    it("should register a new user successfully", async () => {
      const mockUser = createMockUser();

      (userRepository.findByEmail as jest.Mock).mockResolvedValue(null);
      (passwordUtil.validate as jest.Mock).mockReturnValue({
        valid: true,
        errors: [],
      });
      (passwordUtil.hash as jest.Mock).mockResolvedValue("hashedPassword");
      (userRepository.create as jest.Mock).mockResolvedValue(mockUser);

      const result = await authService.register({
        email: "newuser@example.com",
        password: "Password123!",
        fullName: "New User",
      });

      expect(result).toHaveProperty("accessToken");
      expect(result).toHaveProperty("refreshToken");
      expect(result.user.email).toBe("newuser@example.com");
      expect(userRepository.create).toHaveBeenCalledTimes(1);
    });

    it("should throw error if user already exists", async () => {
      (userRepository.findByEmail as jest.Mock).mockResolvedValue(
        createMockUser()
      );

      await expect(
        authService.register({
          email: "existing@example.com",
          password: "Password123!",
        })
      ).rejects.toThrow("User with this email already exists");
    });

    it("should throw error if password is invalid", async () => {
      (userRepository.findByEmail as jest.Mock).mockResolvedValue(null);
      (passwordUtil.validate as jest.Mock).mockReturnValue({
        valid: false,
        errors: ["Password too short"],
      });

      await expect(
        authService.register({
          email: "test@example.com",
          password: "123",
        })
      ).rejects.toThrow();
    });
  });

  describe("login", () => {
    it("should login successfully with valid credentials", async () => {
      const mockUser = createMockUser();

      (userRepository.findByEmail as jest.Mock).mockResolvedValue(mockUser);
      (passwordUtil.compare as jest.Mock).mockResolvedValue(true);

      const result = await authService.login({
        email: "test@example.com",
        password: "Password123!",
      });

      expect(result).toHaveProperty("accessToken");
      expect(result.user.email).toBe("test@example.com");
    });

    it("should throw error with invalid email", async () => {
      (userRepository.findByEmail as jest.Mock).mockResolvedValue(null);

      await expect(
        authService.login({
          email: "nonexistent@example.com",
          password: "Password123!",
        })
      ).rejects.toThrow("Invalid email or password");
    });

    it("should throw error with invalid password", async () => {
      const mockUser = createMockUser();

      (userRepository.findByEmail as jest.Mock).mockResolvedValue(mockUser);
      (passwordUtil.compare as jest.Mock).mockResolvedValue(false);

      await expect(
        authService.login({
          email: "test@example.com",
          password: "WrongPassword",
        })
      ).rejects.toThrow("Invalid email or password");
    });

    it("should throw error if user is inactive", async () => {
      const mockUser = createMockUser({ isActive: false });

      (userRepository.findByEmail as jest.Mock).mockResolvedValue(mockUser);
      (passwordUtil.compare as jest.Mock).mockResolvedValue(true);

      await expect(
        authService.login({
          email: "test@example.com",
          password: "Password123!",
        })
      ).rejects.toThrow("User account is inactive");
    });
  });
});
```

**Verificación**:

- [ ] Tests unitarios creados
- [ ] Mocks configurados
- [ ] Casos de éxito y error cubiertos

---

### **Paso 4: Crear Tests Unitarios de Repositorios**

Crear archivo `tests/unit/repositories/business.repository.test.ts`:

```typescript
import { businessRepository } from "../../../src/repositories/business.repository";
import prisma from "../../../src/config/database";
import { createMockBusiness } from "../../fixtures/business.fixture";

jest.mock("../../../src/config/database", () => ({
  __esModule: true,
  default: {
    business: {
      findUnique: jest.fn(),
      findMany: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    },
  },
}));

describe("BusinessRepository", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe("findById", () => {
    it("should find business by id", async () => {
      const mockBusiness = createMockBusiness();

      (prisma.business.findUnique as jest.Mock).mockResolvedValue(mockBusiness);

      const result = await businessRepository.findById("business-123");

      expect(result).toEqual(mockBusiness);
      expect(prisma.business.findUnique).toHaveBeenCalledWith({
        where: { id: "business-123" },
      });
    });

    it("should return null if business not found", async () => {
      (prisma.business.findUnique as jest.Mock).mockResolvedValue(null);

      const result = await businessRepository.findById("nonexistent");

      expect(result).toBeNull();
    });
  });

  describe("findByOwnerId", () => {
    it("should find businesses by owner id", async () => {
      const mockBusinesses = [createMockBusiness()];

      (prisma.business.findMany as jest.Mock).mockResolvedValue(mockBusinesses);

      const result = await businessRepository.findByOwnerId("user-123");

      expect(result).toEqual(mockBusinesses);
      expect(prisma.business.findMany).toHaveBeenCalledWith({
        where: { ownerId: "user-123" },
        include: {
          owner: true,
          services: true,
          theme: true,
        },
      });
    });
  });

  describe("create", () => {
    it("should create a new business", async () => {
      const mockBusiness = createMockBusiness();
      const createData = {
        name: "New Business",
        type: "SALON" as const,
        ownerId: "user-123",
        isActive: true,
      };

      (prisma.business.create as jest.Mock).mockResolvedValue(mockBusiness);

      const result = await businessRepository.create(createData);

      expect(result).toEqual(mockBusiness);
      expect(prisma.business.create).toHaveBeenCalledWith({
        data: createData,
      });
    });
  });
});
```

**Verificación**:

- [ ] Tests de repositorio creados
- [ ] Prisma mockeado correctamente

---

### **Paso 5: Crear Tests de Integración Completos**

Crear archivo `tests/integration/auth.integration.test.ts`:

```typescript
import request from "supertest";
import app from "../../src/app";
import prisma from "../../src/config/database";
import { passwordUtil } from "../../src/utils/password.util";

describe("Auth Integration Tests", () => {
  beforeAll(async () => {
    await prisma.$connect();
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  beforeEach(async () => {
    // Limpiar base de datos antes de cada test
    await prisma.appointment.deleteMany();
    await prisma.service.deleteMany();
    await prisma.businessTheme.deleteMany();
    await prisma.business.deleteMany();
    await prisma.user.deleteMany();
  });

  describe("POST /api/auth/register", () => {
    it("should register a new user", async () => {
      const response = await request(app).post("/api/auth/register").send({
        email: "newuser@example.com",
        password: "Password123!",
        fullName: "New User",
      });

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty("accessToken");
      expect(response.body.data).toHaveProperty("refreshToken");
      expect(response.body.data.user.email).toBe("newuser@example.com");

      // Verificar que el usuario fue creado en la BD
      const user = await prisma.user.findUnique({
        where: { email: "newuser@example.com" },
      });
      expect(user).toBeDefined();
      expect(user?.email).toBe("newuser@example.com");
    });

    it("should return validation error for invalid email", async () => {
      const response = await request(app).post("/api/auth/register").send({
        email: "invalid-email",
        password: "Password123!",
      });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
      expect(response.body.errors).toBeDefined();
    });

    it("should return error if user already exists", async () => {
      // Crear usuario primero
      await prisma.user.create({
        data: {
          email: "existing@example.com",
          password: await passwordUtil.hash("Password123!"),
          role: "CUSTOMER",
          isActive: true,
        },
      });

      const response = await request(app).post("/api/auth/register").send({
        email: "existing@example.com",
        password: "Password123!",
      });

      expect(response.status).toBe(500);
      expect(response.body.success).toBe(false);
    });
  });

  describe("POST /api/auth/login", () => {
    beforeEach(async () => {
      // Crear usuario para tests de login
      await prisma.user.create({
        data: {
          email: "login@example.com",
          password: await passwordUtil.hash("Password123!"),
          role: "CUSTOMER",
          isActive: true,
        },
      });
    });

    it("should login successfully", async () => {
      const response = await request(app).post("/api/auth/login").send({
        email: "login@example.com",
        password: "Password123!",
      });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty("accessToken");
      expect(response.body.data.user.email).toBe("login@example.com");
    });

    it("should return error for wrong password", async () => {
      const response = await request(app).post("/api/auth/login").send({
        email: "login@example.com",
        password: "WrongPassword",
      });

      expect(response.status).toBe(500);
      expect(response.body.success).toBe(false);
    });
  });
});
```

**Verificación**:

- [ ] Tests de integración creados
- [ ] Base de datos limpiada entre tests
- [ ] Casos reales probados

---

### **Paso 6: Crear Tests de Integración de Business**

Crear archivo `tests/integration/business.integration.test.ts`:

```typescript
import request from "supertest";
import app from "../../src/app";
import prisma from "../../src/config/database";
import { passwordUtil } from "../../src/utils/password.util";
import { jwtUtil } from "../../src/utils/jwt.util";

describe("Business Integration Tests", () => {
  let authToken: string;
  let userId: string;

  beforeAll(async () => {
    await prisma.$connect();
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  beforeEach(async () => {
    // Limpiar y crear usuario de prueba
    await prisma.appointment.deleteMany();
    await prisma.service.deleteMany();
    await prisma.businessTheme.deleteMany();
    await prisma.business.deleteMany();
    await prisma.user.deleteMany();

    const user = await prisma.user.create({
      data: {
        email: "business-owner@example.com",
        password: await passwordUtil.hash("Password123!"),
        role: "BUSINESS_OWNER",
        isActive: true,
      },
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
          name: "My Salon",
          type: "SALON",
          description: "A beautiful salon",
          address: "123 Main St",
        });

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty("id");
      expect(response.body.data.name).toBe("My Salon");
      expect(response.body.data.ownerId).toBe(userId);
    });

    it("should return 401 without token", async () => {
      const response = await request(app).post("/api/businesses").send({
        name: "My Salon",
        type: "SALON",
      });

      expect(response.status).toBe(401);
    });

    it("should return validation error for invalid data", async () => {
      const response = await request(app)
        .post("/api/businesses")
        .set("Authorization", `Bearer ${authToken}`)
        .send({
          name: "A", // Muy corto
          type: "INVALID_TYPE",
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
      expect(response.body.errors).toBeDefined();
    });
  });

  describe("GET /api/businesses", () => {
    beforeEach(async () => {
      // Crear negocios de prueba
      await prisma.business.createMany({
        data: [
          {
            name: "Business 1",
            type: "SALON",
            ownerId: userId,
            isActive: true,
          },
          {
            name: "Business 2",
            type: "RESTAURANT",
            ownerId: userId,
            isActive: true,
          },
        ],
      });
    });

    it("should return list of businesses", async () => {
      const response = await request(app)
        .get("/api/businesses")
        .set("Authorization", `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(Array.isArray(response.body.data)).toBe(true);
      expect(response.body.data.length).toBeGreaterThan(0);
    });
  });

  describe("GET /api/businesses/:id", () => {
    let businessId: string;

    beforeEach(async () => {
      const business = await prisma.business.create({
        data: {
          name: "Test Business",
          type: "SALON",
          ownerId: userId,
          isActive: true,
        },
      });
      businessId = business.id;
    });

    it("should return business by id", async () => {
      const response = await request(app)
        .get(`/api/businesses/${businessId}`)
        .set("Authorization", `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.id).toBe(businessId);
      expect(response.body.data.name).toBe("Test Business");
    });

    it("should return 404 for nonexistent business", async () => {
      const response = await request(app)
        .get("/api/businesses/nonexistent-id")
        .set("Authorization", `Bearer ${authToken}`);

      expect(response.status).toBe(404);
    });
  });

  describe("PUT /api/businesses/:id", () => {
    let businessId: string;

    beforeEach(async () => {
      const business = await prisma.business.create({
        data: {
          name: "Original Name",
          type: "SALON",
          ownerId: userId,
          isActive: true,
        },
      });
      businessId = business.id;
    });

    it("should update business", async () => {
      const response = await request(app)
        .put(`/api/businesses/${businessId}`)
        .set("Authorization", `Bearer ${authToken}`)
        .send({
          name: "Updated Name",
          description: "Updated description",
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.name).toBe("Updated Name");
      expect(response.body.data.description).toBe("Updated description");
    });
  });

  describe("DELETE /api/businesses/:id", () => {
    let businessId: string;

    beforeEach(async () => {
      const business = await prisma.business.create({
        data: {
          name: "To Delete",
          type: "SALON",
          ownerId: userId,
          isActive: true,
        },
      });
      businessId = business.id;
    });

    it("should soft delete business", async () => {
      const response = await request(app)
        .delete(`/api/businesses/${businessId}`)
        .set("Authorization", `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);

      // Verificar que está desactivado en BD
      const business = await prisma.business.findUnique({
        where: { id: businessId },
      });
      expect(business?.isActive).toBe(false);
    });
  });
});
```

**Verificación**:

- [ ] Tests de integración completos
- [ ] CRUD completo probado
- [ ] Autenticación verificada

---

### **Paso 7: Configurar Scripts de Testing**

Actualizar `package.json`:

```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "test:unit": "jest tests/unit",
    "test:integration": "jest tests/integration",
    "test:ci": "jest --coverage --ci --maxWorkers=2"
  }
}
```

**Verificación**:

- [ ] Scripts configurados
- [ ] Todos funcionan correctamente

---

### **Paso 8: Crear Documentación de Testing**

Crear archivo `docs/backend/TESTING.md`:

```markdown
# 🧪 Estrategia de Testing - Backend

## 📋 Tipos de Tests

### Unit Tests

- Ubicación: `tests/unit/`
- Objetivo: Probar lógica de negocio aislada
- Cobertura objetivo: >80%

### Integration Tests

- Ubicación: `tests/integration/`
- Objetivo: Probar flujos completos de APIs
- Cobertura objetivo: >70%

## 🎯 Criterios de Aceptación

- Todos los tests deben pasar
- Coverage mínimo: 70%
- Tests deben ser independientes
- Base de datos debe limpiarse entre tests

## 📊 Ejecutar Tests

\`\`\`bash

# Todos los tests

npm test

# Solo unitarios

npm run test:unit

# Solo integración

npm run test:integration

# Con coverage

npm run test:coverage
\`\`\`
```

---

## ✅ Verificación Final

```bash
# 1. Ejecutar todos los tests
npm test

# 2. Ver coverage
npm run test:coverage

# 3. Verificar que coverage > 70%
```

**Verificaciones**:

- [ ] Todos los tests pasando
- [ ] Coverage > 70%
- [ ] Tests unitarios y de integración funcionando
- [ ] Documentación creada

---

## 📝 Entregables del Día

1. ✅ Jest completamente configurado
2. ✅ Fixtures y helpers creados
3. ✅ Tests unitarios de servicios
4. ✅ Tests unitarios de repositorios
5. ✅ Tests de integración de APIs
6. ✅ Coverage reports configurados
7. ✅ Scripts de testing configurados
8. ✅ Documentación de testing creada

---

## 🎯 Próximo Día

**Día 6**: API de Usuarios Completa

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_
