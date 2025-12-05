# 🔐 US-016: Cambiar Mi Contraseña

## 📋 Información General

- **Épica**: Seguridad
- **Prioridad**: P0 (Crítica)
- **Story Points**: 2
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-002 (Login)

---

## 📖 Historia de Usuario

**Como** usuario  
**Quiero** cambiar mi contraseña  
**Para** mantener mi cuenta segura

---

## ✅ Criterios de Aceptación

- [ ] Debo proporcionar mi contraseña actual
- [ ] Debo proporcionar la nueva contraseña
- [ ] La nueva contraseña debe cumplir con los requisitos de seguridad
- [ ] La contraseña actual debe ser correcta
- [ ] Solo puedo cambiar mi propia contraseña
- [ ] Se envía notificación cuando cambio la contraseña

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear DTO**

**Archivo**: `src/dto/user/change-password.dto.ts`

```typescript
export interface ChangePasswordDto {
  currentPassword: string;
  newPassword: string;
}
```

**Criterios de verificación**:
- [ ] DTO creado

---

### **Tarea 2: Crear Validador**

**Archivo**: `src/validators/user.validator.ts`

```typescript
export const changePasswordSchema = z.object({
  currentPassword: z.string().min(1),
  newPassword: z
    .string()
    .min(8)
    .regex(/[A-Z]/, "Must contain uppercase")
    .regex(/[a-z]/, "Must contain lowercase")
    .regex(/[0-9]/, "Must contain number")
    .regex(/[!@#$%^&*]/, "Must contain special character"),
});
```

**Criterios de verificación**:
- [ ] Validador creado

---

### **Tarea 3: Agregar Método al Servicio**

**Archivo**: `src/services/user.service.ts`

```typescript
async changePassword(
  userId: string,
  data: ChangePasswordDto
): Promise<void> {
  // 1. Obtener usuario
  const user = await userRepository.findById(userId);
  if (!user) {
    throw new AppError(404, "User not found");
  }

  // 2. Verificar contraseña actual
  const isCurrentPasswordValid = await passwordUtil.compare(
    data.currentPassword,
    user.password
  );
  if (!isCurrentPasswordValid) {
    throw new AppError(400, "Current password is incorrect");
  }

  // 3. Validar nueva contraseña
  const validation = passwordUtil.validate(data.newPassword);
  if (!validation.valid) {
    throw new AppError(400, validation.errors.join(", "));
  }

  // 4. Hash nueva contraseña
  const hashedPassword = await passwordUtil.hash(data.newPassword);

  // 5. Actualizar contraseña
  await userRepository.updatePassword(userId, hashedPassword);

  // 6. Crear notificación
  await notificationService.createFromTemplate(
    userId,
    NotificationType.PASSWORD_CHANGED,
    {}
  );

  logger.info(`Password changed for user: ${userId}`);
}
```

**Criterios de verificación**:
- [ ] Método implementado
- [ ] Validación de contraseña actual funcionando
- [ ] Notificación creada

---

### **Tarea 4: Crear Endpoint PUT /api/users/me/password**

**Archivo**: `src/controllers/user.controller.ts`

```typescript
async changePassword(req: Request, res: Response): Promise<void> {
  try {
    const userId = req.user!.id;
    const validatedData = changePasswordSchema.parse(req.body);

    await userService.changePassword(userId, validatedData);

    res.json({
      success: true,
      message: "Password changed successfully",
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
- [ ] Validación de contraseña actual funcionando
- [ ] Nueva contraseña hasheada correctamente
- [ ] Notificación enviada
- [ ] Tests pasando

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_

