# 🔄 US-035: Renovar Token de Acceso (Refresh Token)

## 📋 Información General

- **Épica**: Autenticación
- **Prioridad**: P0 (Crítica)
- **Story Points**: 2
- **Sprint**: Sprint 1 - Semana 1
- **Estado**: To Do
- **Dependencias**: US-002 (Login)

---

## 📖 Historia de Usuario

**Como** usuario autenticado  
**Quiero** renovar mi token de acceso cuando expire  
**Para** mantener mi sesión activa sin tener que hacer login nuevamente

---

## ✅ Criterios de Aceptación

- [ ] Puedo renovar mi token de acceso usando el refresh token
- [ ] El refresh token debe ser válido
- [ ] El refresh token no debe estar expirado
- [ ] Se genera un nuevo access token
- [ ] Se genera un nuevo refresh token
- [ ] El refresh token anterior se invalida

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear DTO**

**Archivo**: `src/dto/auth/refresh-token.dto.ts`

```typescript
export interface RefreshTokenDto {
  refreshToken: string;
}
```

**Criterios de verificación**:
- [ ] DTO creado

---

### **Tarea 2: Crear Validador**

**Archivo**: `src/validators/auth.validator.ts`

```typescript
export const refreshTokenSchema = z.object({
  refreshToken: z.string().min(1, "Refresh token is required"),
});
```

**Criterios de verificación**:
- [ ] Validador creado

---

### **Tarea 3: Implementar Método refreshToken**

**Archivo**: `src/services/auth.service.ts`

```typescript
async refreshToken(refreshToken: string): Promise<AuthResponseDto> {
  try {
    // Verificar y decodificar refresh token
    const payload = jwtUtil.verifyRefreshToken(refreshToken);

    // Obtener usuario
    const user = await userRepository.findById(payload.userId);
    if (!user || !user.isActive) {
      throw new AppError(401, "Invalid refresh token");
    }

    // Generar nuevos tokens
    return this.generateAuthResponse(user);
  } catch (error) {
    throw new AppError(401, "Invalid or expired refresh token");
  }
}
```

**Criterios de verificación**:
- [ ] Método implementado
- [ ] Validación de token funcionando

---

### **Tarea 4: Crear Endpoint POST /api/auth/refresh**

**Archivo**: `src/controllers/auth.controller.ts`

```typescript
async refreshToken(req: Request, res: Response): Promise<void> {
  try {
    const validatedData = refreshTokenSchema.parse(req.body);
    const result = await authService.refreshToken(validatedData.refreshToken);

    res.json({
      success: true,
      data: result,
    });
  } catch (error: any) {
    // ... manejo de errores
  }
}
```

**Criterios de verificación**:
- [ ] Endpoint creado
- [ ] Ruta registrada

---

## 🔍 Definition of Done

- [ ] Endpoint funcionando
- [ ] Validación de refresh token funcionando
- [ ] Nuevos tokens generados
- [ ] Tests pasando

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_

