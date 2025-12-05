# 📷 US-021: Subir Imagen de Servicio

## 📋 Información General

- **Épica**: Upload de Archivos
- **Prioridad**: P0 (Crítica)
- **Story Points**: 2
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-004 (Gestión de Servicios), US-012 (Subir Logo)

---

## 📖 Historia de Usuario

**Como** propietario de negocio  
**Quiero** subir imágenes para mis servicios  
**Para** mostrar visualmente qué ofrece cada servicio

---

## ✅ Criterios de Aceptación

- [ ] Puedo subir una imagen para un servicio
- [ ] El sistema valida que sea una imagen (JPEG, PNG, WebP)
- [ ] El sistema valida el tamaño máximo (5MB)
- [ ] La imagen se optimiza automáticamente
- [ ] Se genera un thumbnail automáticamente
- [ ] La URL de la imagen se guarda en el servicio
- [ ] Solo puedo subir imágenes para servicios de mis negocios

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Agregar Campos de Imagen al Modelo Service**

**Archivo**: `prisma/schema.prisma`

```prisma
model Service {
  // ... campos existentes ...
  imageUrl     String?  @map("image_url")
  imageThumbnailUrl String? @map("image_thumbnail_url")
  // ... resto del modelo ...
}
```

Ejecutar migración:

```bash
npx prisma migrate dev --name add_service_image_urls
npx prisma generate
```

**Criterios de verificación**:
- [ ] Campos agregados
- [ ] Migración aplicada

---

### **Tarea 2: Agregar Método al Servicio de Upload**

**Archivo**: `src/services/upload.service.ts`

```typescript
async uploadServiceImage(
  file: Express.Multer.File,
  serviceId: string,
  businessId: string
): Promise<{ url: string; thumbnailUrl?: string }> {
  // Validar archivo
  const validation = FileValidationUtil.validateImage(file);
  if (!validation.valid) {
    throw new AppError(400, validation.errors.join(", "));
  }

  // Subir archivo
  const result = await storageService.uploadFile(
    file,
    STORAGE_BUCKETS.SERVICE_IMAGES,
    `${businessId}/${serviceId}`,
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
- [ ] Validación funcionando

---

### **Tarea 3: Crear Endpoint POST /api/upload/service/:serviceId/image**

**Archivo**: `src/controllers/upload.controller.ts`

```typescript
async uploadServiceImage(req: Request, res: Response): Promise<void> {
  try {
    const file = req.file;
    if (!file) {
      throw new AppError(400, "No file provided");
    }

    const serviceId = req.params.serviceId;
    const businessId = req.body.businessId || req.params.businessId;
    const userId = req.user!.id;

    // Verificar permisos
    const service = await serviceRepository.findByIdWithBusiness(serviceId);
    if (!service || service.business.ownerId !== userId) {
      throw new AppError(403, "You do not have permission");
    }

    const result = await uploadService.uploadServiceImage(
      file,
      serviceId,
      businessId
    );

    // Actualizar servicio con URL de imagen
    await serviceService.update(serviceId, userId, {
      imageUrl: result.url,
      imageThumbnailUrl: result.thumbnailUrl,
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
- [ ] Permisos verificados
- [ ] URL guardada en servicio

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

