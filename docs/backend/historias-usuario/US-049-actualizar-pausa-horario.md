# ✏️ US-049: Actualizar Pausa de Horario

## 📋 Información General

- **Épica**: Horarios y Disponibilidad
- **Prioridad**: P0 (Crítica)
- **Story Points**: 1
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-018 (Configurar Pausas)

---

## 📖 Historia de Usuario

**Como** propietario de negocio  
**Quiero** actualizar una pausa existente  
**Para** ajustar los horarios de descanso sin tener que eliminarlos y recrearlos

---

## ✅ Criterios de Aceptación

- [ ] Puedo actualizar día de la semana
- [ ] Puedo actualizar hora de inicio
- [ ] Puedo actualizar hora de fin
- [ ] Solo puedo actualizar pausas de mis negocios

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear DTO de Actualización**

**Archivo**: `src/dto/business-hours/update-break.dto.ts`

```typescript
export interface UpdateBusinessBreakDto {
  dayOfWeek?: number;
  startTime?: string;
  endTime?: string;
}
```

**Criterios de verificación**:
- [ ] DTO creado

---

### **Tarea 2: Agregar Método al Servicio**

**Archivo**: `src/services/business-hours.service.ts`

```typescript
async updateBreak(
  id: string,
  ownerId: string,
  data: UpdateBusinessBreakDto
): Promise<void> {
  const breakItem = await businessBreakRepository.findById(id);
  if (!breakItem) {
    throw new AppError(404, "Break not found");
  }

  // Verificar permisos
  const business = await businessRepository.findById(breakItem.businessId);
  if (!business || business.ownerId !== ownerId) {
    throw new AppError(403, "You do not have permission");
  }

  // Validar horario
  const startTime = data.startTime || breakItem.startTime;
  const endTime = data.endTime || breakItem.endTime;
  if (!BusinessHoursUtil.isValidTimeRange(startTime, endTime)) {
    throw new AppError(400, "Invalid break time range");
  }

  await businessBreakRepository.update(id, {
    dayOfWeek: data.dayOfWeek !== undefined ? data.dayOfWeek : breakItem.dayOfWeek,
    startTime,
    endTime,
  });
}
```

**Criterios de verificación**:
- [ ] Método implementado
- [ ] Validaciones funcionando

---

### **Tarea 3: Crear Endpoint PUT /api/business-hours/breaks/:id**

**Archivo**: `src/controllers/business-hours.controller.ts`

```typescript
async updateBreak(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id;
    const userId = req.user!.id;
    const data: UpdateBusinessBreakDto = req.body;

    await businessHoursService.updateBreak(id, userId, data);

    res.json({
      success: true,
      message: "Break updated successfully",
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

