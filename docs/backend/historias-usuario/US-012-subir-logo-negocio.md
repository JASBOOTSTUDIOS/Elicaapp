# 📤 US-012: Subir Logo de mi Negocio

## 📋 Información General

- **Épica**: Upload de Archivos
- **Prioridad**: P0 (Crítica)
- **Story Points**: 3
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-003 (Crear Negocio)

---

## 📖 Historia de Usuario

**Como** propietario de negocio  
**Quiero** subir un logo para mi negocio  
**Para** personalizar la apariencia de mi página

---

## ✅ Criterios de Aceptación

- [ ] Puedo subir un archivo de imagen como logo
- [ ] El sistema valida que sea una imagen (JPEG, PNG, WebP)
- [ ] El sistema valida el tamaño máximo (2MB)
- [ ] La imagen se optimiza automáticamente
- [ ] Se genera un thumbnail automáticamente
- [ ] La URL del logo se guarda en el negocio
- [ ] Solo puedo subir logo para mis propios negocios

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Configurar Supabase Storage**

**Archivo**: `src/config/storage.ts`

```typescript
import { createClient } from "@supabase/supabase-js";
import { env } from "./env";

export const supabaseStorage = createClient(
  env.SUPABASE_URL,
  env.SUPABASE_SERVICE_ROLE_KEY
);

export const STORAGE_BUCKETS = {
  BUSINESS_LOGOS: "business-logos",
} as const;
```

**Criterios de verificación**:
- [ ] Configuración creada
- [ ] Variables de entorno configuradas

---

### **Tarea 2: Crear Utilidad de Validación de Archivos**

**Archivo**: `src/utils/file-validation.util.ts`

```typescript
export class FileValidationUtil {
  static validateLogo(file: Express.Multer.File): FileValidationResult {
    const errors: string[] = [];
    const maxSize = 2 * 1024 * 1024; // 2MB
    const allowedMimeTypes = ["image/jpeg", "image/png", "image/webp"];

    if (file.size > maxSize) {
      errors.push("File size exceeds 2MB");
    }

    if (!allowedMimeTypes.includes(file.mimetype)) {
      errors.push("Only JPEG, PNG, and WebP images are allowed");
    }

    return {
      valid: errors.length === 0,
      errors,
    };
  }
}
```

**Criterios de verificación**:
- [ ] Utilidad creada
- [ ] Validaciones funcionando

---

### **Tarea 3: Crear Servicio de Upload**

**Archivo**: `src/services/upload.service.ts`

```typescript
async uploadBusinessLogo(
  file: Express.Multer.File,
  businessId: string
): Promise<{ url: string; thumbnailUrl?: string }> {
  // Validar archivo
  const validation = FileValidationUtil.validateLogo(file);
  if (!validation.valid) {
    throw new AppError(400, validation.errors.join(", "));
  }

  // Subir archivo
  const result = await storageService.uploadFile(
    file,
    STORAGE_BUCKETS.BUSINESS_LOGOS,
    businessId,
    true // optimizar
  );

  return {
    url: result.url,
    thumbnailUrl: result.thumbnailUrl,
  };
}
```

**Criterios de verificación**:
- [ ] Servicio creado
- [ ] Validación funcionando
- [ ] Upload funcionando

---

### **Tarea 4: Crear Endpoint POST /api/upload/business/:businessId/logo**

**Archivo**: `src/controllers/upload.controller.ts`

```typescript
async uploadBusinessLogo(req: Request, res: Response): Promise<void> {
  try {
    const file = req.file;
    if (!file) {
      throw new AppError(400, "No file provided");
    }

    const businessId = req.params.businessId;
    const userId = req.user!.id;

    // Verificar permisos
    const business = await businessRepository.findById(businessId);
    if (!business || business.ownerId !== userId) {
      throw new AppError(403, "You do not have permission");
    }

    const result = await uploadService.uploadBusinessLogo(file, businessId);

    // Actualizar negocio con URL del logo
    await businessService.updateLogo(businessId, result.url, result.thumbnailUrl);

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
- [ ] Middleware de upload configurado (multer)
- [ ] Permisos verificados
- [ ] URL guardada en negocio

---

## 🔍 Definition of Done

- [ ] Upload funcionando
- [ ] Validación funcionando
- [ ] Optimización funcionando
- [ ] Thumbnail generado
- [ ] Tests pasando

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_

