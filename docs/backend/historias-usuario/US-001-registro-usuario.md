# 👤 US-001: Registro de Usuario

## 📋 Información General

- **Épica**: Autenticación y Usuarios
- **Prioridad**: P0 (Crítica)
- **Story Points**: 5
- **Sprint**: Sprint 1 - Semana 1
- **Estado**: To Do
- **Desarrollador Asignado**: [Nombre]

---

## 📖 Historia de Usuario

**Como** nuevo usuario del sistema  
**Quiero** poder registrarme con email y contraseña  
**Para** acceder a la plataforma ElicaApp y gestionar mi negocio

---

## ✅ Criterios de Aceptación

- [ ] El usuario puede acceder al endpoint de registro
- [ ] El formulario valida email único
- [ ] El formulario valida contraseña segura (mínimo 8 caracteres, mayúsculas, números, caracteres especiales)
- [ ] La contraseña se encripta antes de guardar
- [ ] Se crea un perfil básico automáticamente
- [ ] Se genera un JWT token de acceso
- [ ] Se genera un refresh token
- [ ] Se retorna información del usuario (sin contraseña)
- [ ] Se registra el evento en logs

---

## 🎯 Reglas de Negocio

1. **Email único**: No puede haber dos usuarios con el mismo email
2. **Contraseña segura**: Debe cumplir con política de seguridad
3. **Rol por defecto**: Los nuevos usuarios tienen rol `CUSTOMER` por defecto
4. **Estado inicial**: Los usuarios se crean como `isActive: true`
5. **Encriptación**: Las contraseñas se guardan hasheadas con bcrypt (10 salt rounds)

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear DTOs de Registro**

**Archivo**: `src/dto/auth/register.dto.ts`

```typescript
export interface RegisterDto {
  email: string;
  password: string;
  fullName?: string;
  phone?: string;
}
```

**Criterios de verificación**:

- [ ] Archivo creado
- [ ] Interface definida correctamente
- [ ] Campos opcionales marcados con `?`

---

### **Tarea 2: Crear Validador con Zod**

**Archivo**: `src/validators/auth.validator.ts`

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
    .max(100)
    .optional(),
  phone: z
    .string()
    .regex(/^\+?[1-9]\d{1,14}$/, "Invalid phone format")
    .optional(),
});

export type RegisterInput = z.infer<typeof registerSchema>;
```

**Criterios de verificación**:

- [ ] Schema Zod creado
- [ ] Validaciones de email implementadas
- [ ] Validaciones de contraseña implementadas
- [ ] Validaciones de nombre y teléfono opcionales
- [ ] Tipo TypeScript inferido

**Tests a escribir**:

```typescript
describe("registerSchema", () => {
  it("should validate correct data", () => {
    const validData = {
      email: "test@example.com",
      password: "Password123!",
      fullName: "Test User",
    };
    expect(() => registerSchema.parse(validData)).not.toThrow();
  });

  it("should reject invalid email", () => {
    const invalidData = {
      email: "invalid-email",
      password: "Password123!",
    };
    expect(() => registerSchema.parse(invalidData)).toThrow();
  });

  it("should reject weak password", () => {
    const weakPassword = {
      email: "test@example.com",
      password: "123",
    };
    expect(() => registerSchema.parse(weakPassword)).toThrow();
  });
});
```

---

### **Tarea 3: Implementar Método Register en AuthService**

**Archivo**: `src/services/auth.service.ts`

**Código a implementar**:

```typescript
async register(data: RegisterDto): Promise<AuthResponseDto> {
  // 1. Verificar si el usuario ya existe
  const existingUser = await userRepository.findByEmail(data.email);
  if (existingUser) {
    throw new AppError(400, 'User with this email already exists');
  }

  // 2. Validar contraseña
  const passwordValidation = passwordUtil.validate(data.password);
  if (!passwordValidation.valid) {
    throw new AppError(400, passwordValidation.errors.join(', '));
  }

  // 3. Hash de contraseña
  const hashedPassword = await passwordUtil.hash(data.password);

  // 4. Crear usuario
  const user = await userRepository.create({
    email: data.email,
    password: hashedPassword,
    fullName: data.fullName,
    phone: data.phone,
    role: UserRole.CUSTOMER,
    isActive: true,
  });

  logger.info(`User registered: ${user.email}`);

  // 5. Generar tokens
  return this.generateAuthResponse(user);
}
```

**Pasos detallados**:

1. **Verificar usuario existente**:

   ```typescript
   const existingUser = await userRepository.findByEmail(data.email);
   if (existingUser) {
     throw new AppError(400, "User with this email already exists");
   }
   ```

   - Usar `userRepository.findByEmail()`
   - Si existe, lanzar error 400

2. **Validar contraseña**:

   ```typescript
   const passwordValidation = passwordUtil.validate(data.password);
   if (!passwordValidation.valid) {
     throw new AppError(400, passwordValidation.errors.join(", "));
   }
   ```

   - Usar `passwordUtil.validate()`
   - Si no es válida, lanzar error con mensajes

3. **Hash de contraseña**:

   ```typescript
   const hashedPassword = await passwordUtil.hash(data.password);
   ```

   - Usar `passwordUtil.hash()` con 10 salt rounds

4. **Crear usuario**:

   ```typescript
   const user = await userRepository.create({
     email: data.email,
     password: hashedPassword,
     fullName: data.fullName,
     phone: data.phone,
     role: UserRole.CUSTOMER,
     isActive: true,
   });
   ```

   - Usar `userRepository.create()`
   - Rol por defecto: `CUSTOMER`
   - Estado activo: `true`

5. **Generar respuesta**:
   ```typescript
   return this.generateAuthResponse(user);
   ```
   - Incluir accessToken y refreshToken
   - Incluir información del usuario (sin contraseña)

**Criterios de verificación**:

- [ ] Método implementado correctamente
- [ ] Validación de email único funcionando
- [ ] Hash de contraseña funcionando
- [ ] Usuario creado en base de datos
- [ ] Tokens generados correctamente
- [ ] Logs registrados

**Tests unitarios a escribir**:

```typescript
describe("AuthService.register", () => {
  it("should register a new user successfully", async () => {
    // Arrange
    const mockUser = createMockUser();
    (userRepository.findByEmail as jest.Mock).mockResolvedValue(null);
    (passwordUtil.validate as jest.Mock).mockReturnValue({
      valid: true,
      errors: [],
    });
    (passwordUtil.hash as jest.Mock).mockResolvedValue("hashedPassword");
    (userRepository.create as jest.Mock).mockResolvedValue(mockUser);

    // Act
    const result = await authService.register({
      email: "newuser@example.com",
      password: "Password123!",
      fullName: "New User",
    });

    // Assert
    expect(result).toHaveProperty("accessToken");
    expect(result).toHaveProperty("refreshToken");
    expect(result.user.email).toBe("newuser@example.com");
    expect(userRepository.create).toHaveBeenCalledTimes(1);
  });

  it("should throw error if user already exists", async () => {
    // Arrange
    (userRepository.findByEmail as jest.Mock).mockResolvedValue(
      createMockUser()
    );

    // Act & Assert
    await expect(
      authService.register({
        email: "existing@example.com",
        password: "Password123!",
      })
    ).rejects.toThrow("User with this email already exists");
  });

  it("should throw error if password is invalid", async () => {
    // Arrange
    (userRepository.findByEmail as jest.Mock).mockResolvedValue(null);
    (passwordUtil.validate as jest.Mock).mockReturnValue({
      valid: false,
      errors: ["Password too short"],
    });

    // Act & Assert
    await expect(
      authService.register({
        email: "test@example.com",
        password: "123",
      })
    ).rejects.toThrow();
  });
});
```

---

### **Tarea 4: Crear Endpoint POST /api/auth/register**

**Archivo**: `src/controllers/auth.controller.ts`

**Código a implementar**:

```typescript
async register(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    // Validar datos de entrada
    const validatedData = registerSchema.parse(req.body);

    // Registrar usuario
    const result = await authService.register(validatedData);

    res.status(201).json({
      success: true,
      data: result,
      message: 'User registered successfully',
    });
  } catch (error: any) {
    logger.error('Registration error:', error);
    next(error);
  }
}
```

**Pasos detallados**:

1. **Validar request body**:

   - Usar `registerSchema.parse(req.body)`
   - Si falla, Zod lanzará error automáticamente

2. **Llamar al servicio**:

   - Usar `authService.register(validatedData)`
   - Manejar errores con `next(error)`

3. **Retornar respuesta**:
   - Status 201 (Created)
   - Incluir `success: true`
   - Incluir `data` con tokens y usuario
   - Incluir `message` descriptivo

**Criterios de verificación**:

- [ ] Endpoint creado
- [ ] Validación funcionando
- [ ] Respuesta correcta
- [ ] Manejo de errores correcto

**Tests de integración**:

```typescript
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
    // Primero crear usuario
    await request(app).post("/api/auth/register").send({
      email: "existing@example.com",
      password: "Password123!",
    });

    // Intentar crear de nuevo
    const response = await request(app).post("/api/auth/register").send({
      email: "existing@example.com",
      password: "Password123!",
    });

    expect(response.status).toBe(500);
    expect(response.body.success).toBe(false);
  });
});
```

---

### **Tarea 5: Registrar Ruta**

**Archivo**: `src/routes/auth.routes.ts`

```typescript
router.post(
  "/register",
  validate(registerSchema),
  authController.register.bind(authController)
);
```

**Verificación**:

- [ ] Ruta registrada en `src/app.ts`
- [ ] Endpoint accesible en `/api/auth/register`
- [ ] Validación aplicada

---

## 🧪 Checklist de Testing

### **Tests Unitarios**

- [ ] Test de registro exitoso
- [ ] Test de email duplicado
- [ ] Test de contraseña inválida
- [ ] Test de validación de datos

### **Tests de Integración**

- [ ] Test de endpoint completo
- [ ] Test de validaciones
- [ ] Test de creación en BD
- [ ] Test de generación de tokens

### **Tests de Seguridad**

- [ ] Test de contraseña hasheada
- [ ] Test de no exposición de contraseña en respuesta
- [ ] Test de rate limiting

---

## 📊 Métricas de Éxito

- **Response Time**: < 200ms
- **Success Rate**: > 99%
- **Code Coverage**: > 80%
- **Security**: Contraseñas hasheadas correctamente

---

## 🔍 Definition of Done

- [ ] Código implementado y revisado
- [ ] Tests unitarios pasando (>80% coverage)
- [ ] Tests de integración pasando
- [ ] Validaciones funcionando
- [ ] Documentación Swagger actualizada
- [ ] Logs implementados
- [ ] Manejo de errores correcto
- [ ] Code review aprobado

---

## 📚 Recursos y Referencias

- [Zod Documentation](https://zod.dev/)
- [bcryptjs Documentation](https://www.npmjs.com/package/bcryptjs)
- [JWT Best Practices](https://datatracker.ietf.org/doc/html/rfc8725)

---

## 🐛 Problemas Comunes y Soluciones

### **Error: Email already exists**

- Verificar que no exista en BD antes de crear
- Retornar error 400 con mensaje claro

### **Error: Password validation failed**

- Verificar que cumpla todos los requisitos
- Retornar mensajes de error específicos

### **Error: Hash failed**

- Verificar que bcryptjs esté instalado
- Verificar que la contraseña no sea vacía

---

## 📝 Notas Adicionales

- El email debe ser único en toda la aplicación
- La contraseña nunca debe ser retornada en respuestas
- Los tokens deben tener tiempo de expiración configurado
- Todos los errores deben ser logueados

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_
