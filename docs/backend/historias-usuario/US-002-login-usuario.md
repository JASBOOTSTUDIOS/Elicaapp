# 🔐 US-002: Login de Usuario

## 📋 Información General

- **Épica**: Autenticación y Usuarios
- **Prioridad**: P0 (Crítica)
- **Story Points**: 3
- **Sprint**: Sprint 1 - Semana 1
- **Estado**: To Do
- **Dependencias**: US-001 (Registro de Usuario)

---

## 📖 Historia de Usuario

**Como** usuario registrado  
**Quiero** poder iniciar sesión con mis credenciales  
**Para** acceder a mi cuenta y funcionalidades de la plataforma

---

## ✅ Criterios de Aceptación

- [ ] El usuario puede acceder al endpoint de login
- [ ] Se valida email y contraseña
- [ ] Se verifica que el usuario existe
- [ ] Se verifica que la contraseña es correcta
- [ ] Se verifica que el usuario está activo
- [ ] Se genera JWT access token
- [ ] Se genera refresh token
- [ ] Se retorna información del usuario
- [ ] Se registra el evento de login en logs
- [ ] Se manejan intentos fallidos (opcional: rate limiting)

---

## 🎯 Reglas de Negocio

1. **Credenciales válidas**: Email y contraseña deben ser correctos
2. **Usuario activo**: Solo usuarios con `isActive: true` pueden hacer login
3. **Comparación segura**: Usar bcrypt.compare() para verificar contraseña
4. **Tokens**: Generar access token (1h) y refresh token (7d)
5. **Seguridad**: No revelar si el email existe o no (mensaje genérico)

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear DTOs de Login**

**Archivo**: `src/dto/auth/login.dto.ts`

```typescript
export interface LoginDto {
  email: string;
  password: string;
}
```

---

### **Tarea 2: Crear Validador**

**Archivo**: `src/validators/auth.validator.ts` (agregar)

```typescript
export const loginSchema = z.object({
  email: z.string().email("Invalid email format"),
  password: z.string().min(1, "Password is required"),
});

export type LoginInput = z.infer<typeof loginSchema>;
```

---

### **Tarea 3: Implementar Método Login**

**Archivo**: `src/services/auth.service.ts`

```typescript
async login(data: LoginDto): Promise<AuthResponseDto> {
  // 1. Buscar usuario por email
  const user = await userRepository.findByEmail(data.email);
  if (!user) {
    throw new AppError(401, 'Invalid email or password');
  }

  // 2. Verificar contraseña
  const isPasswordValid = await passwordUtil.compare(data.password, user.password);
  if (!isPasswordValid) {
    throw new AppError(401, 'Invalid email or password');
  }

  // 3. Verificar que el usuario está activo
  if (!user.isActive) {
    throw new AppError(403, 'User account is inactive');
  }

  logger.info(`User logged in: ${user.email}`);

  // 4. Generar tokens
  return this.generateAuthResponse(user);
}
```

**Pasos detallados**:

1. **Buscar usuario**:

   ```typescript
   const user = await userRepository.findByEmail(data.email);
   if (!user) {
     throw new AppError(401, "Invalid email or password");
   }
   ```

   - Mensaje genérico para no revelar si el email existe

2. **Verificar contraseña**:

   ```typescript
   const isPasswordValid = await passwordUtil.compare(
     data.password,
     user.password
   );
   if (!isPasswordValid) {
     throw new AppError(401, "Invalid email or password");
   }
   ```

   - Usar bcrypt.compare() (timing-safe)

3. **Verificar estado**:

   ```typescript
   if (!user.isActive) {
     throw new AppError(403, "User account is inactive");
   }
   ```

4. **Generar respuesta**:
   ```typescript
   return this.generateAuthResponse(user);
   ```

---

### **Tarea 4: Crear Endpoint**

**Archivo**: `src/controllers/auth.controller.ts`

```typescript
async login(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const validatedData = loginSchema.parse(req.body);
    const result = await authService.login(validatedData);

    res.status(200).json({
      success: true,
      data: result,
      message: 'Login successful',
    });
  } catch (error: any) {
    logger.error('Login error:', error);
    next(error);
  }
}
```

---

### **Tarea 5: Registrar Ruta**

**Archivo**: `src/routes/auth.routes.ts`

```typescript
router.post(
  "/login",
  validate(loginSchema),
  authController.login.bind(authController)
);
```

---

## 🧪 Tests a Escribir

### **Tests Unitarios**

```typescript
describe("AuthService.login", () => {
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
```

### **Tests de Integración**

```typescript
describe("POST /api/auth/login", () => {
  beforeEach(async () => {
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
```

---

## ✅ Definition of Done

- [ ] Método login implementado
- [ ] Endpoint funcionando
- [ ] Validaciones implementadas
- [ ] Tests unitarios pasando
- [ ] Tests de integración pasando
- [ ] Manejo de errores correcto
- [ ] Logs implementados

---

## 🎯 Próxima Historia

**US-003**: Crear Negocio

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_
