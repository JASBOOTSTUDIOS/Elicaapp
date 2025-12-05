# 👤 US-022: Subir Mi Avatar

## 📋 Información General

- **Épica**: Upload de Archivos
- **Prioridad**: P1 (Alta)
- **Story Points**: 2
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-002 (Login)

---

## 📖 Historia de Usuario

**Como** usuario  
**Quiero** subir una foto de perfil  
**Para** personalizar mi cuenta

---

## ✅ Criterios de Aceptación

- [ ] Puedo subir una imagen como avatar
- [ ] El sistema valida que sea una imagen
- [ ] El sistema valida el tamaño máximo (5MB)
- [ ] La imagen se optimiza automáticamente
- [ ] Se genera un thumbnail automáticamente
- [ ] La URL del avatar se guarda en mi perfil
- [ ] Solo puedo subir mi propio avatar

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Agregar Campos de Avatar al Modelo User**

**Archivo**: `prisma/schema.prisma`

```prisma
model User {
  // ... campos existentes ...
  avatarUrl    String?  @map("avatar_url")
  avatarThumbnailUrl String? @map("avatar_thumbnail_url")
  // ... resto del modelo ...
}
```

Ejecutar migración:

```bash
npx prisma migrate dev --name add_user_avatar_urls
npx prisma generate
```

**Criterios de verificación**:
- [ ] Campos agregados
- [ ] Migración aplicada

---

### **Tarea 2: Agregar Método al Servicio de Upload**

**Archivo**: `src/services/upload.service.ts`

```typescript
async uploadUserAvatar(
  file: Express.Multer.File,
  userId: string
): Promise<{ url: string; thumbnailUrl?: string }> {
  // Validar archivo
  const validation = FileValidationUtil.validateImage(file);
  if (!validation.valid) {
    throw new AppError(400, validation.errors.join(", "));
  }

  // Subir archivo
  const result = await storageService.uploadFile(
    file,
    STORAGE_BUCKETS.USER_AVATARS,
    userId,
    true // optimizar
  );

  return {
    url: result.url,
    thumbnailUrl: result.thumbnailUrl,
  };
}
```

**Criterios de verificación**:
- [ ] Método implementado

---

### **Tarea 3: Crear Endpoint POST /api/upload/user/avatar**

**Archivo**: `src/controllers/upload.controller.ts`

```typescript
async uploadUserAvatar(req: Request, res: Response): Promise<void> {
  try {
    const file = req.file;
    if (!file) {
      throw new AppError(400, "No file provided");
    }

    const userId = req.user!.id;

    const result = await uploadService.uploadUserAvatar(file, userId);

    // Actualizar usuario con URL del avatar
    await userService.updateProfile(userId, {
      avatarUrl: result.url,
      avatarThumbnailUrl: result.thumbnailUrl,
    });

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
- [ ] URL guardada en usuario

---

## 🔍 Definition of Done

- [ ] Upload funcionando
- [ ] Validación funcionando
- [ ] Optimización funcionando
- [ ] Tests pasando

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_

