# ✏️ US-015: Actualizar Mi Perfil

## 📋 Información General

- **Épica**: Gestión de Usuario
- **Prioridad**: P0 (Crítica)
- **Story Points**: 2
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-002 (Login)

---

## 📖 Historia de Usuario

**Como** usuario  
**Quiero** actualizar mi información de perfil (nombre, teléfono)  
**Para** mantener mis datos actualizados

---

## ✅ Criterios de Aceptación

- [ ] Puedo actualizar mi nombre completo
- [ ] Puedo actualizar mi teléfono
- [ ] No puedo cambiar mi email (requiere proceso separado)
- [ ] Solo puedo actualizar mi propio perfil
- [ ] Los cambios se guardan correctamente

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear DTO de Actualización**

**Archivo**: `src/dto/user/update-profile.dto.ts`

```typescript
export interface UpdateProfileDto {
  fullName?: string;
  phone?: string;
}
```

**Criterios de verificación**:
- [ ] DTO creado

---

### **Tarea 2: Crear Validador**

**Archivo**: `src/validators/user.validator.ts`

```typescript
export const updateProfileSchema = z.object({
  fullName: z.string().min(2).max(100).optional(),
  phone: z.string().regex(/^\+?[1-9]\d{1,14}$/).optional(),
});
```

**Criterios de verificación**:
- [ ] Validador creado

---

### **Tarea 3: Agregar Método al Servicio**

**Archivo**: `src/services/user.service.ts`

```typescript
async updateProfile(userId: string, data: UpdateProfileDto): Promise<User> {
  return await userRepository.update(userId, data);
}
```

**Criterios de verificación**:
- [ ] Método implementado

---

### **Tarea 4: Crear Endpoint PUT /api/users/me**

**Archivo**: `src/controllers/user.controller.ts`

```typescript
async updateProfile(req: Request, res: Response): Promise<void> {
  try {
    const userId = req.user!.id;
    const validatedData = updateProfileSchema.parse(req.body);
    
    const user = await userService.updateProfile(userId, validatedData);

    res.json({
      success: true,
      data: user,
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
- [ ] Validaciones funcionando
- [ ] Tests pasando

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_

