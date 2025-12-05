# ✏️ US-048: Actualizar Excepción de Horario

## 📋 Información General

- **Épica**: Horarios y Disponibilidad
- **Prioridad**: P0 (Crítica)
- **Story Points**: 1
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-017 (Configurar Excepción)

---

## 📖 Historia de Usuario

**Como** propietario de negocio  
**Quiero** actualizar una excepción de horario existente  
**Para** modificar horarios especiales sin tener que eliminarlos y recrearlos

---

## ✅ Criterios de Aceptación

- [ ] Puedo actualizar fecha de la excepción
- [ ] Puedo actualizar horario especial
- [ ] Puedo actualizar razón
- [ ] Puedo marcar como cerrado todo el día
- [ ] Solo puedo actualizar excepciones de mis negocios

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear DTO de Actualización**

**Archivo**: `src/dto/business-hours/update-exception.dto.ts`

```typescript
export interface UpdateBusinessHoursExceptionDto {
  date?: string;
  openTime?: string;
  closeTime?: string;
  reason?: string;
}
```

**Criterios de verificación**:
- [ ] DTO creado

---

### **Tarea 2: Agregar Método al Servicio**

**Archivo**: `src/services/business-hours.service.ts`

```typescript
async updateException(
  id: string,
  ownerId: string,
  data: UpdateBusinessHoursExceptionDto
): Promise<void> {
  const exception = await businessHoursExceptionRepository.findById(id);
  if (!exception) {
    throw new AppError(404, "Exception not found");
  }

  // Verificar permisos
  const business = await businessRepository.findById(exception.businessId);
  if (!business || business.ownerId !== ownerId) {
    throw new AppError(403, "You do not have permission");
  }

  // Validar horario si se proporciona
  if (data.openTime && data.closeTime) {
    if (
      !BusinessHoursUtil.isValidTimeRange(data.openTime, data.closeTime)
    ) {
      throw new AppError(400, "Invalid time range");
    }
  }

  await businessHoursExceptionRepository.update(id, {
    ...(data.date && { date: BusinessHoursUtil.parseDate(data.date) }),
    openTime: data.openTime !== undefined ? data.openTime : exception.openTime,
    closeTime:
      data.closeTime !== undefined ? data.closeTime : exception.closeTime,
    reason: data.reason !== undefined ? data.reason : exception.reason,
  });
}
```

**Criterios de verificación**:
- [ ] Método implementado
- [ ] Validaciones funcionando

---

### **Tarea 3: Crear Endpoint PUT /api/business-hours/exceptions/:id**

**Archivo**: `src/controllers/business-hours.controller.ts`

```typescript
async updateException(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id;
    const userId = req.user!.id;
    const data: UpdateBusinessHoursExceptionDto = req.body;

    await businessHoursService.updateException(id, userId, data);

    res.json({
      success: true,
      message: "Exception updated successfully",
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
- [ ] Permisos verificados
- [ ] Tests pasando

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_

