# 👤 US-041: Ver Mi Perfil

## 📋 Información General

- **Épica**: Gestión de Usuario
- **Prioridad**: P0 (Crítica)
- **Story Points**: 1
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-002 (Login)

---

## 📖 Historia de Usuario

**Como** usuario  
**Quiero** ver mi información de perfil  
**Para** revisar mis datos personales

---

## ✅ Criterios de Aceptación

- [ ] Puedo ver mi información completa (email, nombre, teléfono, avatar)
- [ ] Puedo ver mi rol
- [ ] Puedo ver fecha de registro
- [ ] Solo puedo ver mi propio perfil
- [ ] La contraseña nunca se muestra

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear DTO de Respuesta**

**Archivo**: `src/dto/user/user-response.dto.ts`

```typescript
export interface UserResponseDto {
  id: string;
  email: string;
  fullName?: string;
  phone?: string;
  role: string;
  avatarUrl?: string;
  avatarThumbnailUrl?: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}
```

**Criterios de verificación**:
- [ ] DTO creado

---

### **Tarea 2: Agregar Método al Servicio**

**Archivo**: `src/services/user.service.ts`

```typescript
async getProfile(userId: string): Promise<UserResponseDto> {
  const user = await userRepository.findById(userId);
  if (!user) {
    throw new AppError(404, "User not found");
  }

  return {
    id: user.id,
    email: user.email,
    fullName: user.fullName,
    phone: user.phone,
    role: user.role,
    avatarUrl: user.avatarUrl,
    avatarThumbnailUrl: user.avatarThumbnailUrl,
    isActive: user.isActive,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
  };
}
```

**Criterios de verificación**:
- [ ] Método implementado
- [ ] Contraseña excluida

---

### **Tarea 3: Crear Endpoint GET /api/users/me**

**Archivo**: `src/controllers/user.controller.ts`

```typescript
async getProfile(req: Request, res: Response): Promise<void> {
  try {
    const userId = req.user!.id;
    const profile = await userService.getProfile(userId);

    res.json({
      success: true,
      data: profile,
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
- [ ] Contraseña nunca expuesta
- [ ] Tests pasando

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_

