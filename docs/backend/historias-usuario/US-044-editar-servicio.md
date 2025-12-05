# ✏️ US-044: Editar Servicio

## 📋 Información General

- **Épica**: Servicios
- **Prioridad**: P0 (Crítica)
- **Story Points**: 2
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-004 (Gestión de Servicios)

---

## 📖 Historia de Usuario

**Como** propietario de negocio  
**Quiero** editar la información de un servicio  
**Para** actualizar precios, descripciones o duraciones

---

## ✅ Criterios de Aceptación

- [ ] Puedo actualizar nombre del servicio
- [ ] Puedo actualizar descripción
- [ ] Puedo actualizar precio
- [ ] Puedo actualizar duración
- [ ] Puedo actualizar categoría
- [ ] Solo puedo editar servicios de mis negocios
- [ ] No puedo editar servicios con citas futuras (solo desactivar)

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear DTO de Actualización**

**Archivo**: `src/dto/service/update-service.dto.ts`

```typescript
export interface UpdateServiceDto {
  name?: string;
  description?: string;
  durationMinutes?: number;
  price?: number;
  category?: string;
  isActive?: boolean;
}
```

**Criterios de verificación**:
- [ ] DTO creado

---

### **Tarea 2: Crear Validador**

**Archivo**: `src/validators/service.validator.ts`

```typescript
export const updateServiceSchema = z.object({
  name: z.string().min(2).max(100).optional(),
  description: z.string().max(500).optional(),
  durationMinutes: z.number().int().positive().optional(),
  price: z.number().nonnegative().optional(),
  category: z.string().max(50).optional(),
  isActive: z.boolean().optional(),
});
```

**Criterios de verificación**:
- [ ] Validador creado

---

### **Tarea 3: Agregar Validación de Citas Futuras**

**Archivo**: `src/services/service.service.ts`

En el método `update`, agregar validación:

```typescript
async update(
  id: string,
  ownerId: string,
  data: UpdateServiceDto
): Promise<Service> {
  const service = await this.findById(id, ownerId);

  // Si se intenta cambiar precio o duración, verificar citas futuras
  if (data.price !== undefined || data.durationMinutes !== undefined) {
    const futureAppointments =
      await serviceRepository.countFutureAppointments(id);
    if (futureAppointments > 0) {
      throw new AppError(
        400,
        "Cannot update price or duration for service with future appointments"
      );
    }
  }

  return await serviceRepository.update(id, data);
}
```

**Criterios de verificación**:
- [ ] Validación implementada

---

### **Tarea 4: Crear Endpoint PUT /api/services/:id**

**Archivo**: `src/controllers/service.controller.ts`

```typescript
async update(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id;
    const userId = req.user!.id;
    const validatedData = updateServiceSchema.parse(req.body);

    const service = await serviceService.update(id, userId, validatedData);

    res.json({
      success: true,
      data: service,
      message: "Service updated successfully",
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
- [ ] Validación de citas futuras funcionando
- [ ] Permisos verificados
- [ ] Tests pasando

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_

