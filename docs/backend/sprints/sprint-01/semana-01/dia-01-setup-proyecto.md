# 📅 Día 1: Configuración del Proyecto Express.js + TypeScript

## 🎯 Objetivo del Día

Crear la estructura base del proyecto backend con Express.js y TypeScript, configurando todas las herramientas necesarias para comenzar el desarrollo.

---

## ✅ Checklist de Tareas

- [ ] Crear estructura de carpetas del proyecto
- [ ] Inicializar proyecto npm
- [ ] Instalar dependencias base
- [ ] Configurar TypeScript
- [ ] Configurar scripts de desarrollo
- [ ] Crear estructura Clean Architecture
- [ ] Configurar variables de entorno
- [ ] Configurar logging básico
- [ ] Crear servidor Express básico
- [ ] Verificar que todo funciona

---

## 📋 Pasos Detallados

### **Paso 1: Crear Estructura de Carpetas**

```bash
# Crear carpeta del proyecto
mkdir elicaapp-backend
cd elicaapp-backend

# Crear estructura de carpetas
mkdir -p src/routes
mkdir -p src/controllers
mkdir -p src/services
mkdir -p src/repositories
mkdir -p src/models
mkdir -p src/dto
mkdir -p src/middleware
mkdir -p src/utils
mkdir -p src/config
mkdir -p src/validators
mkdir -p tests/unit
mkdir -p tests/integration
mkdir -p tests/fixtures
```

**Resultado esperado**: Estructura de carpetas creada siguiendo Clean Architecture.

---

### **Paso 2: Inicializar Proyecto npm**

```bash
# Inicializar package.json
npm init -y
```

**Editar `package.json`** con la siguiente configuración:

```json
{
  "name": "elicaapp-backend",
  "version": "1.0.0",
  "description": "Backend API para ElicaApp - Gestión de negocios de servicios",
  "main": "dist/server.js",
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
  "keywords": ["express", "typescript", "api", "rest"],
  "author": "",
  "license": "ISC"
}
```

**Verificación**:

- [ ] `package.json` creado correctamente
- [ ] Scripts configurados

---

### **Paso 3: Instalar Dependencias Base**

```bash
# Dependencias de producción
npm install express cors helmet dotenv express-rate-limit
npm install jsonwebtoken bcryptjs
npm install zod
npm install winston morgan
npm install @supabase/supabase-js

# Dependencias de desarrollo
npm install -D typescript @types/express @types/node @types/cors
npm install -D @types/jsonwebtoken @types/bcryptjs @types/morgan
npm install -D ts-node nodemon
npm install -D jest @types/jest ts-jest supertest @types/supertest
npm install -D eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin
npm install -D prettier eslint-config-prettier
```

**Verificación**:

- [ ] Todas las dependencias instaladas sin errores
- [ ] `node_modules` creado
- [ ] `package-lock.json` generado

---

### **Paso 4: Configurar TypeScript**

Crear archivo `tsconfig.json` en la raíz:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "moduleResolution": "node",
    "allowSyntheticDefaultImports": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
```

**Verificación**:

- [ ] `tsconfig.json` creado
- [ ] Configuración correcta
- [ ] Compilar con `npm run build` (debe crear carpeta `dist`)

---

### **Paso 5: Configurar Variables de Entorno**

Crear archivo `.env.example`:

```env
# Server Configuration
NODE_ENV=development
PORT=3000

# Database (Supabase)
DATABASE_URL=postgresql://postgres:password@localhost:5432/elicaapp
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRES_IN=1h
JWT_REFRESH_SECRET=your-refresh-secret-key
JWT_REFRESH_EXPIRES_IN=7d

# Redis (opcional para desarrollo)
REDIS_URL=redis://localhost:6379

# Logging
LOG_LEVEL=info

# CORS
CORS_ORIGIN=http://localhost:3000
```

Crear archivo `.env` (copiar de `.env.example` y llenar con valores reales).

**Verificación**:

- [ ] `.env.example` creado
- [ ] `.env` creado (NO versionar este archivo)
- [ ] `.gitignore` incluye `.env`

---

### **Paso 6: Configurar Logging**

Crear archivo `src/config/logger.ts`:

```typescript
import winston from "winston";

const logFormat = winston.format.combine(
  winston.format.timestamp({ format: "YYYY-MM-DD HH:mm:ss" }),
  winston.format.errors({ stack: true }),
  winston.format.splat(),
  winston.format.json()
);

export const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || "info",
  format: logFormat,
  defaultMeta: { service: "elicaapp-backend" },
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.printf(
          ({ timestamp, level, message, ...meta }) =>
            `${timestamp} [${level}]: ${message} ${
              Object.keys(meta).length ? JSON.stringify(meta, null, 2) : ""
            }`
        )
      ),
    }),
    new winston.transports.File({
      filename: "logs/error.log",
      level: "error",
    }),
    new winston.transports.File({
      filename: "logs/combined.log",
    }),
  ],
});

// Crear carpeta logs si no existe
import fs from "fs";
if (!fs.existsSync("logs")) {
  fs.mkdirSync("logs");
}
```

**Verificación**:

- [ ] Logger configurado
- [ ] Carpeta `logs` creada
- [ ] Logger funciona correctamente

---

### **Paso 7: Crear Configuración de Express**

Crear archivo `src/config/env.ts`:

```typescript
import dotenv from "dotenv";

dotenv.config();

export const env = {
  // Server
  NODE_ENV: process.env.NODE_ENV || "development",
  PORT: parseInt(process.env.PORT || "3000", 10),

  // Database
  DATABASE_URL: process.env.DATABASE_URL || "",
  SUPABASE_URL: process.env.SUPABASE_URL || "",
  SUPABASE_ANON_KEY: process.env.SUPABASE_ANON_KEY || "",
  SUPABASE_SERVICE_ROLE_KEY: process.env.SUPABASE_SERVICE_ROLE_KEY || "",

  // JWT
  JWT_SECRET: process.env.JWT_SECRET || "",
  JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || "1h",
  JWT_REFRESH_SECRET: process.env.JWT_REFRESH_SECRET || "",
  JWT_REFRESH_EXPIRES_IN: process.env.JWT_REFRESH_EXPIRES_IN || "7d",

  // Redis
  REDIS_URL: process.env.REDIS_URL || "",

  // Logging
  LOG_LEVEL: process.env.LOG_LEVEL || "info",

  // CORS
  CORS_ORIGIN: process.env.CORS_ORIGIN || "http://localhost:3000",
};

// Validar variables críticas
const requiredEnvVars = ["DATABASE_URL", "JWT_SECRET"];

requiredEnvVars.forEach((varName) => {
  if (!process.env[varName]) {
    throw new Error(`Missing required environment variable: ${varName}`);
  }
});
```

**Verificación**:

- [ ] Archivo `env.ts` creado
- [ ] Variables de entorno validadas
- [ ] Sin errores de compilación

---

### **Paso 8: Crear Aplicación Express Base**

Crear archivo `src/app.ts`:

```typescript
import express, { Express, Request, Response, NextFunction } from "express";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";
import rateLimit from "express-rate-limit";
import { logger } from "./config/logger";
import { env } from "./config/env";

const app: Express = express();

// Security middleware
app.use(helmet());

// CORS configuration
app.use(
  cors({
    origin: env.CORS_ORIGIN,
    credentials: true,
  })
);

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: "Too many requests from this IP, please try again later.",
});
app.use("/api/", limiter);

// Body parsing middleware
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

// Logging middleware
if (env.NODE_ENV === "development") {
  app.use(morgan("dev"));
} else {
  app.use(
    morgan("combined", {
      stream: { write: (message) => logger.info(message.trim()) },
    })
  );
}

// Health check endpoint
app.get("/health", (req: Request, res: Response) => {
  res.status(200).json({
    status: "ok",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: env.NODE_ENV,
  });
});

// API routes (se agregarán en siguientes días)
app.get("/api", (req: Request, res: Response) => {
  res.json({
    message: "ElicaApp API v1.0.0",
    documentation: "/api/docs",
  });
});

// 404 handler
app.use((req: Request, res: Response) => {
  res.status(404).json({
    success: false,
    message: "Route not found",
  });
});

// Error handler
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  logger.error("Error:", err);
  res.status(500).json({
    success: false,
    message:
      env.NODE_ENV === "production" ? "Internal server error" : err.message,
  });
});

export default app;
```

**Verificación**:

- [ ] `app.ts` creado correctamente
- [ ] Middleware configurado
- [ ] Sin errores de TypeScript

---

### **Paso 9: Crear Servidor**

Crear archivo `src/server.ts`:

```typescript
import app from "./app";
import { env } from "./config/env";
import { logger } from "./config/logger";

const PORT = env.PORT;

const server = app.listen(PORT, () => {
  logger.info(`🚀 Server running on port ${PORT}`);
  logger.info(`📝 Environment: ${env.NODE_ENV}`);
  logger.info(`🔗 Health check: http://localhost:${PORT}/health`);
});

// Graceful shutdown
process.on("SIGTERM", () => {
  logger.info("SIGTERM signal received: closing HTTP server");
  server.close(() => {
    logger.info("HTTP server closed");
    process.exit(0);
  });
});

process.on("SIGINT", () => {
  logger.info("SIGINT signal received: closing HTTP server");
  server.close(() => {
    logger.info("HTTP server closed");
    process.exit(0);
  });
});
```

**Verificación**:

- [ ] `server.ts` creado
- [ ] Manejo de señales configurado

---

### **Paso 10: Configurar ESLint y Prettier**

Crear archivo `.eslintrc.json`:

```json
{
  "parser": "@typescript-eslint/parser",
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "prettier"
  ],
  "plugins": ["@typescript-eslint"],
  "parserOptions": {
    "ecmaVersion": 2020,
    "sourceType": "module"
  },
  "env": {
    "node": true,
    "es6": true,
    "jest": true
  },
  "rules": {
    "@typescript-eslint/no-explicit-any": "warn",
    "@typescript-eslint/explicit-function-return-type": "off",
    "@typescript-eslint/no-unused-vars": [
      "error",
      { "argsIgnorePattern": "^_" }
    ]
  }
}
```

Crear archivo `.prettierrc`:

```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false
}
```

Crear archivo `.prettierignore`:

```
node_modules
dist
logs
*.log
.env
```

**Verificación**:

- [ ] ESLint configurado
- [ ] Prettier configurado
- [ ] Ejecutar `npm run lint` (debe funcionar)

---

### **Paso 11: Configurar Jest**

Crear archivo `jest.config.js`:

```javascript
module.exports = {
  preset: "ts-jest",
  testEnvironment: "node",
  roots: ["<rootDir>/tests"],
  testMatch: ["**/__tests__/**/*.ts", "**/?(*.)+(spec|test).ts"],
  transform: {
    "^.+\\.ts$": "ts-jest",
  },
  collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts", "!src/server.ts"],
  coverageDirectory: "coverage",
  coverageReporters: ["text", "lcov", "html"],
  moduleNameMapper: {
    "^@/(.*)$": "<rootDir>/src/$1",
  },
  setupFilesAfterEnv: ["<rootDir>/tests/setup.ts"],
};
```

Crear archivo `tests/setup.ts`:

```typescript
// Global test setup
beforeAll(() => {
  // Configurar variables de entorno para tests
  process.env.NODE_ENV = "test";
  process.env.JWT_SECRET = "test-secret-key";
  process.env.DATABASE_URL = "postgresql://test:test@localhost:5432/test_db";
});

afterAll(() => {
  // Cleanup después de todos los tests
});
```

**Verificación**:

- [ ] Jest configurado
- [ ] Crear test básico: `tests/unit/app.test.ts`
- [ ] Ejecutar `npm test` (debe pasar)

---

### **Paso 12: Crear Test Básico**

Crear archivo `tests/unit/app.test.ts`:

```typescript
import request from "supertest";
import app from "../../src/app";

describe("App", () => {
  describe("GET /health", () => {
    it("should return 200 and health status", async () => {
      const response = await request(app).get("/health");

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty("status", "ok");
      expect(response.body).toHaveProperty("timestamp");
      expect(response.body).toHaveProperty("uptime");
    });
  });

  describe("GET /api", () => {
    it("should return API information", async () => {
      const response = await request(app).get("/api");

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty("message");
    });
  });
});
```

**Verificación**:

- [ ] Test creado
- [ ] `npm test` pasa correctamente

---

### **Paso 13: Actualizar .gitignore**

Asegurar que `.gitignore` incluya:

```gitignore
# Dependencies
node_modules/
package-lock.json

# Build output
dist/
build/

# Environment variables
.env
.env.local
.env.*.local

# Logs
logs/
*.log
npm-debug.log*

# Testing
coverage/
.nyc_output/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
```

---

## ✅ Verificación Final

Ejecutar los siguientes comandos para verificar que todo está correcto:

```bash
# 1. Compilar TypeScript
npm run build

# 2. Ejecutar linter
npm run lint

# 3. Ejecutar tests
npm test

# 4. Iniciar servidor en desarrollo
npm run dev
```

**Verificaciones**:

- [ ] Compilación exitosa (carpeta `dist` creada)
- [ ] Sin errores de linting
- [ ] Tests pasando
- [ ] Servidor inicia correctamente en `http://localhost:3000`
- [ ] Endpoint `/health` responde correctamente
- [ ] Endpoint `/api` responde correctamente

---

## 📝 Entregables del Día

Al finalizar este día debes tener:

1. ✅ Proyecto Express.js + TypeScript creado
2. ✅ Estructura Clean Architecture implementada
3. ✅ Todas las dependencias instaladas
4. ✅ TypeScript configurado y compilando
5. ✅ Variables de entorno configuradas
6. ✅ Logging funcionando
7. ✅ Servidor Express básico funcionando
8. ✅ Tests básicos pasando
9. ✅ ESLint y Prettier configurados
10. ✅ Health check endpoint funcionando

---

## 🐛 Troubleshooting

### **Error: Cannot find module**

- Verificar que `node_modules` esté instalado: `npm install`
- Verificar que las rutas de importación sean correctas

### **Error de compilación TypeScript**

- Verificar `tsconfig.json`
- Ejecutar `npm run build` para ver errores específicos

### **Servidor no inicia**

- Verificar que el puerto 3000 no esté en uso
- Verificar variables de entorno en `.env`
- Revisar logs en consola

### **Tests fallan**

- Verificar configuración de Jest
- Verificar que `tests/setup.ts` existe
- Ejecutar `npm test -- --verbose` para más detalles

---

## 📚 Recursos Adicionales

- [Express.js Documentation](https://expressjs.com/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Jest Documentation](https://jestjs.io/)
- [ESLint Rules](https://eslint.org/docs/rules/)

---

## 🎯 Próximo Día

**Día 2**: Conexión a Base de Datos (Supabase + Prisma/TypeORM)

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_
