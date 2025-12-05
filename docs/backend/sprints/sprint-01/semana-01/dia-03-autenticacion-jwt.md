# 📅 Día 3: Autenticación JWT

## 🎯 Objetivo del Día

Implementar sistema completo de autenticación con JWT, incluyendo registro, login, refresh tokens y middleware de autenticación.

---

## ✅ Checklist de Tareas

- [ ] Instalar dependencias de JWT
- [ ] Crear servicio de autenticación
- [ ] Crear DTOs de autenticación
- [ ] Crear validadores con Zod
- [ ] Crear controlador de autenticación
- [ ] Crear rutas de autenticación
- [ ] Crear middleware de autenticación
- [ ] Implementar hash de contraseñas
- [ ] Implementar generación de JWT
- [ ] Crear tests de autenticación

---

## 📋 Pasos Detallados

### **Paso 1: Instalar Dependencias**

```bash
npm install jsonwebtoken bcryptjs
npm install -D @types/jsonwebtoken @types/bcryptjs
```

**Verificación**:

- [ ] Dependencias instaladas
- [ ] Tipos TypeScript disponibles

---

### **Paso 2: Crear Utilidades de JWT**

Crear archivo `src/utils/jwt.util.ts`:

```typescript
import jwt from "jsonwebtoken";
import { env } from "../config/env";

export interface JWTPayload {
  userId: string;
  email: string;
  role: string;
  businessId?: string;
}

export const jwtUtil = {
  generateAccessToken(payload: JWTPayload): string {
    return jwt.sign(payload, env.JWT_SECRET, {
      expiresIn: env.JWT_EXPIRES_IN,
      issuer: "elicaapp",
      audience: "elicaapp-users",
    });
  },

  generateRefreshToken(payload: JWTPayload): string {
    return jwt.sign(payload, env.JWT_REFRESH_SECRET, {
      expiresIn: env.JWT_REFRESH_EXPIRES_IN,
      issuer: "elicaapp",
      audience: "elicaapp-users",
    });
  },

  verifyAccessToken(token: string): JWTPayload {
    try {
      return jwt.verify(token, env.JWT_SECRET) as JWTPayload;
    } catch (error) {
      throw new Error("Invalid or expired token");
    }
  },

  verifyRefreshToken(token: string): JWTPayload {
    try {
      return jwt.verify(token, env.JWT_REFRESH_SECRET) as JWTPayload;
    } catch (error) {
      throw new Error("Invalid or expired refresh token");
    }
  },
};
```

**Verificación**:

- [ ] Utilidades JWT creadas
- [ ] Funciones de generación y verificación implementadas

---

### **Paso 3: Crear Utilidades de Password**

Crear archivo `src/utils/password.util.ts`:

```typescript
import bcrypt from "bcryptjs";

const SALT_ROUNDS = 10;

export const passwordUtil = {
  async hash(password: string): Promise<string> {
    return await bcrypt.hash(password, SALT_ROUNDS);
  },

  async compare(password: string, hash: string): Promise<boolean> {
    return await bcrypt.compare(password, hash);
  },

  validate(password: string): { valid: boolean; errors: string[] } {
    const errors: string[] = [];

    if (password.length < 8) {
      errors.push("Password must be at least 8 characters long");
    }

    if (!/[A-Z]/.test(password)) {
      errors.push("Password must contain at least one uppercase letter");
    }

    if (!/[a-z]/.test(password)) {
      errors.push("Password must contain at least one lowercase letter");
    }

    if (!/[0-9]/.test(password)) {
      errors.push("Password must contain at least one number");
    }

    if (!/[!@#$%^&*]/.test(password)) {
      errors.push("Password must contain at least one special character");
    }

    return {
      valid: errors.length === 0,
      errors,
    };
  },
};
```

**Verificación**:

- [ ] Utilidades de password creadas
- [ ] Hash y compare implementados
- [ ] Validación de contraseña implementada

---

### **Paso 4: Crear DTOs de Autenticación**

Crear archivo `src/dto/auth/register.dto.ts`:

```typescript
export interface RegisterDto {
  email: string;
  password: string;
  fullName?: string;
  phone?: string;
}
```

Crear archivo `src/dto/auth/login.dto.ts`:

```typescript
export interface LoginDto {
  email: string;
  password: string;
}
```

Crear archivo `src/dto/auth/auth-response.dto.ts`:

```typescript
export interface AuthResponseDto {
  accessToken: string;
  refreshToken: string;
  user: {
    id: string;
    email: string;
    fullName?: string;
    role: string;
  };
}
```

**Verificación**:

- [ ] DTOs creados
- [ ] Interfaces TypeScript definidas

---

### **Paso 5: Crear Validadores con Zod**

Crear archivo `src/validators/auth.validator.ts`:

```typescript
import { z } from "zod";

export const registerSchema = z.object({
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
  fullName: z
    .string()
    .min(2, "Full name must be at least 2 characters")
    .optional(),
  phone: z
    .string()
    .regex(/^\+?[1-9]\d{1,14}$/, "Invalid phone format")
    .optional(),
});

export const loginSchema = z.object({
  email: z.string().email("Invalid email format"),
  password: z.string().min(1, "Password is required"),
});

export type RegisterInput = z.infer<typeof registerSchema>;
export type LoginInput = z.infer<typeof loginSchema>;
```

**Verificación**:

- [ ] Validadores creados
- [ ] Schemas Zod definidos
- [ ] Tipos inferidos correctamente

---

### **Paso 6: Crear Servicio de Autenticación**

Crear archivo `src/services/auth.service.ts`:

```typescript
import { userRepository } from "../repositories/user.repository";
import { passwordUtil } from "../utils/password.util";
import { jwtUtil, JWTPayload } from "../utils/jwt.util";
import { RegisterDto, LoginDto, AuthResponseDto } from "../dto/auth";
import { logger } from "../config/logger";
import { User, UserRole } from "@prisma/client";

export class AuthService {
  async register(data: RegisterDto): Promise<AuthResponseDto> {
    // Verificar si el usuario ya existe
    const existingUser = await userRepository.findByEmail(data.email);
    if (existingUser) {
      throw new Error("User with this email already exists");
    }

    // Validar contraseña
    const passwordValidation = passwordUtil.validate(data.password);
    if (!passwordValidation.valid) {
      throw new Error(passwordValidation.errors.join(", "));
    }

    // Hash de contraseña
    const hashedPassword = await passwordUtil.hash(data.password);

    // Crear usuario
    const user = await userRepository.create({
      email: data.email,
      password: hashedPassword,
      fullName: data.fullName,
      phone: data.phone,
      role: UserRole.CUSTOMER,
      isActive: true,
    });

    logger.info(`User registered: ${user.email}`);

    // Generar tokens
    return this.generateAuthResponse(user);
  }

  async login(data: LoginDto): Promise<AuthResponseDto> {
    // Buscar usuario
    const user = await userRepository.findByEmail(data.email);
    if (!user) {
      throw new Error("Invalid email or password");
    }

    // Verificar contraseña
    const isPasswordValid = await passwordUtil.compare(
      data.password,
      user.password
    );
    if (!isPasswordValid) {
      throw new Error("Invalid email or password");
    }

    // Verificar si el usuario está activo
    if (!user.isActive) {
      throw new Error("User account is inactive");
    }

    logger.info(`User logged in: ${user.email}`);

    // Generar tokens
    return this.generateAuthResponse(user);
  }

  async refreshToken(refreshToken: string): Promise<{ accessToken: string }> {
    try {
      const payload = jwtUtil.verifyRefreshToken(refreshToken);

      // Verificar que el usuario aún existe y está activo
      const user = await userRepository.findById(payload.userId);
      if (!user || !user.isActive) {
        throw new Error("User not found or inactive");
      }

      // Generar nuevo access token
      const newPayload: JWTPayload = {
        userId: user.id,
        email: user.email,
        role: user.role,
      };

      return {
        accessToken: jwtUtil.generateAccessToken(newPayload),
      };
    } catch (error) {
      throw new Error("Invalid refresh token");
    }
  }

  private generateAuthResponse(user: User): AuthResponseDto {
    const payload: JWTPayload = {
      userId: user.id,
      email: user.email,
      role: user.role,
    };

    return {
      accessToken: jwtUtil.generateAccessToken(payload),
      refreshToken: jwtUtil.generateRefreshToken(payload),
      user: {
        id: user.id,
        email: user.email,
        fullName: user.fullName || undefined,
        role: user.role,
      },
    };
  }
}

export const authService = new AuthService();
```

**Verificación**:

- [ ] Servicio de autenticación creado
- [ ] Métodos register, login y refreshToken implementados
- [ ] Manejo de errores implementado

---

### **Paso 7: Crear Controlador de Autenticación**

Crear archivo `src/controllers/auth.controller.ts`:

```typescript
import { Request, Response, NextFunction } from "express";
import { authService } from "../services/auth.service";
import { registerSchema, loginSchema } from "../validators/auth.validator";
import { logger } from "../config/logger";

export class AuthController {
  async register(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      // Validar datos de entrada
      const validatedData = registerSchema.parse(req.body);

      // Registrar usuario
      const result = await authService.register(validatedData);

      res.status(201).json({
        success: true,
        data: result,
        message: "User registered successfully",
      });
    } catch (error: any) {
      logger.error("Registration error:", error);
      next(error);
    }
  }

  async login(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      // Validar datos de entrada
      const validatedData = loginSchema.parse(req.body);

      // Login
      const result = await authService.login(validatedData);

      res.status(200).json({
        success: true,
        data: result,
        message: "Login successful",
      });
    } catch (error: any) {
      logger.error("Login error:", error);
      next(error);
    }
  }

  async refreshToken(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const { refreshToken } = req.body;

      if (!refreshToken) {
        res.status(400).json({
          success: false,
          message: "Refresh token is required",
        });
        return;
      }

      const result = await authService.refreshToken(refreshToken);

      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (error: any) {
      logger.error("Refresh token error:", error);
      next(error);
    }
  }
}

export const authController = new AuthController();
```

**Verificación**:

- [ ] Controlador creado
- [ ] Métodos implementados
- [ ] Manejo de errores con next()

---

### **Paso 8: Crear Middleware de Validación**

Crear archivo `src/middleware/validation.middleware.ts`:

```typescript
import { Request, Response, NextFunction } from "express";
import { ZodSchema, ZodError } from "zod";
import { logger } from "../config/logger";

export const validate = (schema: ZodSchema) => {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      schema.parse(req.body);
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        const errors = error.errors.map((err) => ({
          field: err.path.join("."),
          message: err.message,
        }));

        res.status(400).json({
          success: false,
          message: "Validation error",
          errors,
        });
      } else {
        logger.error("Validation error:", error);
        next(error);
      }
    }
  };
};
```

**Verificación**:

- [ ] Middleware de validación creado
- [ ] Manejo de errores de Zod implementado

---

### **Paso 9: Crear Middleware de Autenticación**

Crear archivo `src/middleware/auth.middleware.ts`:

```typescript
import { Request, Response, NextFunction } from "express";
import { jwtUtil, JWTPayload } from "../utils/jwt.util";
import { userRepository } from "../repositories/user.repository";
import { logger } from "../config/logger";

// Extender Request para incluir user
declare global {
  namespace Express {
    interface Request {
      user?: JWTPayload & { id: string };
    }
  }
}

export const authMiddleware = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    // Obtener token del header
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      res.status(401).json({
        success: false,
        message: "No token provided",
      });
      return;
    }

    const token = authHeader.substring(7); // Remover "Bearer "

    // Verificar token
    const payload = jwtUtil.verifyAccessToken(token);

    // Verificar que el usuario existe y está activo
    const user = await userRepository.findById(payload.userId);
    if (!user || !user.isActive) {
      res.status(401).json({
        success: false,
        message: "User not found or inactive",
      });
      return;
    }

    // Agregar usuario al request
    req.user = {
      ...payload,
      id: payload.userId,
    };

    next();
  } catch (error: any) {
    logger.error("Auth middleware error:", error);
    res.status(401).json({
      success: false,
      message: "Invalid or expired token",
    });
  }
};
```

**Verificación**:

- [ ] Middleware de autenticación creado
- [ ] Verificación de token implementada
- [ ] Usuario agregado al request

---

### **Paso 10: Crear Rutas de Autenticación**

Crear archivo `src/routes/auth.routes.ts`:

```typescript
import { Router } from "express";
import { authController } from "../controllers/auth.controller";
import { validate } from "../middleware/validation.middleware";
import { registerSchema, loginSchema } from "../validators/auth.validator";

const router = Router();

router.post(
  "/register",
  validate(registerSchema),
  authController.register.bind(authController)
);

router.post(
  "/login",
  validate(loginSchema),
  authController.login.bind(authController)
);

router.post("/refresh", authController.refreshToken.bind(authController));

export default router;
```

**Verificación**:

- [ ] Rutas creadas
- [ ] Validación aplicada
- [ ] Controladores vinculados

---

### **Paso 11: Registrar Rutas en app.ts**

Actualizar `src/app.ts`:

```typescript
import authRoutes from "./routes/auth.routes";

// Después de la configuración de middleware
app.use("/api/auth", authRoutes);
```

**Verificación**:

- [ ] Rutas registradas
- [ ] Endpoints accesibles

---

### **Paso 12: Crear Tests de Autenticación**

Crear archivo `tests/unit/auth.service.test.ts`:

```typescript
import { authService } from "../../src/services/auth.service";
import { userRepository } from "../../src/repositories/user.repository";
import { passwordUtil } from "../../src/utils/password.util";

jest.mock("../../src/repositories/user.repository");
jest.mock("../../src/utils/password.util");

describe("AuthService", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe("register", () => {
    it("should register a new user successfully", async () => {
      const mockUser = {
        id: "1",
        email: "test@example.com",
        password: "hashedPassword",
        role: "CUSTOMER",
        isActive: true,
      };

      (userRepository.findByEmail as jest.Mock).mockResolvedValue(null);
      (passwordUtil.validate as jest.Mock).mockReturnValue({
        valid: true,
        errors: [],
      });
      (passwordUtil.hash as jest.Mock).mockResolvedValue("hashedPassword");
      (userRepository.create as jest.Mock).mockResolvedValue(mockUser);

      const result = await authService.register({
        email: "test@example.com",
        password: "Password123!",
      });

      expect(result).toHaveProperty("accessToken");
      expect(result).toHaveProperty("refreshToken");
      expect(result.user.email).toBe("test@example.com");
    });

    it("should throw error if user already exists", async () => {
      (userRepository.findByEmail as jest.Mock).mockResolvedValue({
        id: "1",
        email: "test@example.com",
      });

      await expect(
        authService.register({
          email: "test@example.com",
          password: "Password123!",
        })
      ).rejects.toThrow("User with this email already exists");
    });
  });

  describe("login", () => {
    it("should login successfully with valid credentials", async () => {
      const mockUser = {
        id: "1",
        email: "test@example.com",
        password: "hashedPassword",
        role: "CUSTOMER",
        isActive: true,
      };

      (userRepository.findByEmail as jest.Mock).mockResolvedValue(mockUser);
      (passwordUtil.compare as jest.Mock).mockResolvedValue(true);

      const result = await authService.login({
        email: "test@example.com",
        password: "Password123!",
      });

      expect(result).toHaveProperty("accessToken");
      expect(result.user.email).toBe("test@example.com");
    });

    it("should throw error with invalid credentials", async () => {
      (userRepository.findByEmail as jest.Mock).mockResolvedValue(null);

      await expect(
        authService.login({
          email: "test@example.com",
          password: "WrongPassword",
        })
      ).rejects.toThrow("Invalid email or password");
    });
  });
});
```

Crear archivo `tests/integration/auth.test.ts`:

```typescript
import request from "supertest";
import app from "../../src/app";

describe("Auth API", () => {
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
    });

    it("should return validation error for invalid data", async () => {
      const response = await request(app).post("/api/auth/register").send({
        email: "invalid-email",
        password: "123",
      });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
      expect(response.body.errors).toBeDefined();
    });
  });

  describe("POST /api/auth/login", () => {
    it("should login successfully", async () => {
      // Primero registrar un usuario
      await request(app).post("/api/auth/register").send({
        email: "login@example.com",
        password: "Password123!",
      });

      // Luego hacer login
      const response = await request(app).post("/api/auth/login").send({
        email: "login@example.com",
        password: "Password123!",
      });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty("accessToken");
    });

    it("should return error for invalid credentials", async () => {
      const response = await request(app).post("/api/auth/login").send({
        email: "nonexistent@example.com",
        password: "WrongPassword",
      });

      expect(response.status).toBe(500); // O el código de error que uses
      expect(response.body.success).toBe(false);
    });
  });
});
```

**Verificación**:

- [ ] Tests unitarios creados
- [ ] Tests de integración creados
- [ ] `npm test` pasa correctamente

---

## ✅ Verificación Final

```bash
# 1. Ejecutar tests
npm test

# 2. Iniciar servidor
npm run dev

# 3. Probar endpoints con Postman o curl
# POST http://localhost:3000/api/auth/register
# POST http://localhost:3000/api/auth/login
# POST http://localhost:3000/api/auth/refresh
```

**Verificaciones**:

- [ ] Tests pasando
- [ ] Endpoint de registro funciona
- [ ] Endpoint de login funciona
- [ ] Tokens generados correctamente
- [ ] Middleware de autenticación funciona

---

## 📝 Entregables del Día

1. ✅ Sistema de autenticación completo
2. ✅ Registro de usuarios funcionando
3. ✅ Login funcionando
4. ✅ Refresh tokens implementados
5. ✅ Middleware de autenticación creado
6. ✅ Validaciones con Zod implementadas
7. ✅ Hash de contraseñas funcionando
8. ✅ Tests unitarios y de integración pasando
9. ✅ Endpoints documentados y funcionando

---

## 🐛 Troubleshooting

### **Error: JWT_SECRET not defined**

- Verificar que `.env` tenga `JWT_SECRET`
- Reiniciar servidor después de agregar variables

### **Error: Invalid token**

- Verificar formato del token (Bearer token)
- Verificar que el token no haya expirado
- Verificar que JWT_SECRET sea el mismo

### **Error: Password hash failed**

- Verificar que bcryptjs esté instalado
- Verificar que la contraseña no sea vacía

---

## 📚 Recursos Adicionales

- [JWT.io](https://jwt.io/)
- [bcryptjs Documentation](https://www.npmjs.com/package/bcryptjs)
- [Zod Documentation](https://zod.dev/)

---

## 🎯 Próximo Día

**Día 4**: Estructura de APIs y Endpoints Base

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_
