# 📅 US-014: Ver Horarios Disponibles para Reservar

## 📋 Información General

- **Épica**: Horarios y Disponibilidad
- **Prioridad**: P0 (Crítica)
- **Story Points**: 3
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-013 (Configurar Horarios), US-004 (Gestión de Servicios)

---

## 📖 Historia de Usuario

**Como** cliente  
**Quiero** ver los horarios disponibles para reservar un servicio  
**Para** elegir el mejor momento para mi cita

---

## ✅ Criterios de Aceptación

- [ ] Puedo ver horarios disponibles para un servicio en una fecha específica
- [ ] Los horarios respetan el horario de atención del negocio
- [ ] Los horarios excluyen citas ya reservadas
- [ ] Los horarios excluyen breaks/pausas configuradas
- [ ] Los horarios respetan la duración del servicio
- [ ] Los horarios se muestran en formato legible (HH:mm)

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear DTO de Consulta de Disponibilidad**

**Archivo**: `src/dto/business-hours/availability-query.dto.ts`

```typescript
export interface AvailabilityQueryDto {
  businessId: string;
  serviceId: string;
  date: string; // ISO date string
  duration?: number; // Duración en minutos (opcional, se obtiene del servicio)
}
```

**Criterios de verificación**:
- [ ] DTO creado

---

### **Tarea 2: Crear Método getAvailableSlots**

**Archivo**: `src/services/business-hours.service.ts`

```typescript
async getAvailableSlots(query: AvailabilityQueryDto): Promise<string[]> {
  const { businessId, serviceId, date, duration } = query;

  // Obtener servicio para obtener duración
  const service = await serviceRepository.findById(serviceId);
  if (!service) {
    throw new AppError(404, "Service not found");
  }

  const slotDuration = duration || service.durationMinutes;
  const targetDate = BusinessHoursUtil.parseDate(date);
  const dayOfWeek = BusinessHoursUtil.getDayOfWeek(targetDate);

  // Obtener horario del día
  const businessHours = await businessHoursRepository.findByBusinessAndDay(
    businessId,
    dayOfWeek
  );

  if (!businessHours || businessHours.isClosed) {
    return [];
  }

  // Obtener breaks del día
  const breaks = await businessBreakRepository.findByBusinessAndDay(
    businessId,
    dayOfWeek
  );

  // Generar slots disponibles
  const allSlots = BusinessHoursUtil.generateTimeSlots(
    businessHours.openTime,
    businessHours.closeTime,
    slotDuration,
    breaks.map((b) => ({ startTime: b.startTime, endTime: b.endTime }))
  );

  // Filtrar slots ocupados
  const existingAppointments = await appointmentRepository.findByBusinessIdAndDate(
    businessId,
    targetDate
  );

  // Filtrar slots disponibles
  const availableSlots = allSlots.filter((slot) => {
    // Verificar si hay conflicto con citas existentes
    return !this.hasConflict(slot, slotDuration, existingAppointments);
  });

  return availableSlots;
}
```

**Criterios de verificación**:
- [ ] Método implementado
- [ ] Lógica de disponibilidad funcionando

---

### **Tarea 3: Crear Endpoint GET /api/business-hours/:businessId/available-slots**

**Archivo**: `src/controllers/business-hours.controller.ts`

```typescript
async getAvailableSlots(req: Request, res: Response): Promise<void> {
  try {
    const query: AvailabilityQueryDto = {
      businessId: req.params.businessId,
      serviceId: req.query.serviceId as string,
      date: req.query.date as string,
      duration: req.query.duration
        ? parseInt(req.query.duration as string)
        : undefined,
    };

    const slots = await businessHoursService.getAvailableSlots(query);

    res.json({
      success: true,
      data: slots,
    });
  } catch (error: any) {
    // ... manejo de errores
  }
}
```

**Criterios de verificación**:
- [ ] Endpoint creado
- [ ] Ruta registrada (pública)

---

## 🔍 Definition of Done

- [ ] Endpoint funcionando
- [ ] Horarios disponibles calculados correctamente
- [ ] Citas existentes excluidas
- [ ] Tests pasando

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_

