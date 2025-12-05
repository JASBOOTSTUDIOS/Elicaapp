# ✅ US-038: Validar Disponibilidad al Crear Cita

## 📋 Información General

- **Épica**: Sistema de Citas
- **Prioridad**: P0 (Crítica)
- **Story Points**: 2
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-005 (Agenda de Citas), US-013 (Configurar Horarios)

---

## 📖 Historia de Usuario

**Como** cliente  
**Quiero** que el sistema valide automáticamente la disponibilidad al crear una cita  
**Para** evitar conflictos de horarios

---

## ✅ Criterios de Aceptación

- [ ] El sistema valida que el horario está dentro del horario de atención
- [ ] El sistema valida que no hay citas conflictivas
- [ ] El sistema valida que no hay breaks/pausas en ese horario
- [ ] El sistema valida que no hay excepciones que bloqueen ese día
- [ ] Si no hay disponibilidad, se retorna error claro
- [ ] La validación es automática al crear la cita

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Mejorar Método validateAvailability**

**Archivo**: `src/services/appointment.service.ts`

El método ya existe, pero mejorarlo para incluir:

```typescript
private async validateAvailability(
  businessId: string,
  date: Date,
  durationMinutes: number
): Promise<void> {
  const startTime = new Date(date);
  const endTime = new Date(date.getTime() + durationMinutes * 60000);
  const dayOfWeek = BusinessHoursUtil.getDayOfWeek(date);

  // 1. Verificar horario de atención
  const businessHours = await businessHoursRepository.findByBusinessAndDay(
    businessId,
    dayOfWeek
  );

  if (!businessHours || businessHours.isClosed) {
    throw new AppError(400, "Business is closed on this day");
  }

  // 2. Verificar excepciones
  const exception = await businessHoursExceptionRepository.findByBusinessAndDate(
    businessId,
    date
  );

  if (exception && !exception.openTime) {
    throw new AppError(400, "Business is closed on this date");
  }

  // 3. Verificar que el horario está dentro del horario de atención
  const openTime = exception?.openTime || businessHours.openTime;
  const closeTime = exception?.closeTime || businessHours.closeTime;

  const slotStartMinutes = BusinessHoursUtil.timeToMinutes(
    BusinessHoursUtil.minutesToTime(startTime.getHours() * 60 + startTime.getMinutes())
  );
  const slotEndMinutes = slotStartMinutes + durationMinutes;
  const openMinutes = BusinessHoursUtil.timeToMinutes(openTime);
  const closeMinutes = BusinessHoursUtil.timeToMinutes(closeTime);

  if (slotStartMinutes < openMinutes || slotEndMinutes > closeMinutes) {
    throw new AppError(400, "Appointment time is outside business hours");
  }

  // 4. Verificar breaks
  const breaks = await businessBreakRepository.findByBusinessAndDay(
    businessId,
    dayOfWeek
  );

  const isInBreak = breaks.some((breakItem) => {
    const breakStart = BusinessHoursUtil.timeToMinutes(breakItem.startTime);
    const breakEnd = BusinessHoursUtil.timeToMinutes(breakItem.endTime);
    return (
      (slotStartMinutes >= breakStart && slotStartMinutes < breakEnd) ||
      (slotEndMinutes > breakStart && slotEndMinutes <= breakEnd) ||
      (slotStartMinutes < breakStart && slotEndMinutes > breakEnd)
    );
  });

  if (isInBreak) {
    throw new AppError(400, "Appointment time conflicts with business break");
  }

  // 5. Verificar citas conflictivas
  const conflictingAppointments = await appointmentRepository.findConflicting(
    businessId,
    startTime,
    endTime
  );

  if (conflictingAppointments.length > 0) {
    throw new AppError(400, "Time slot is not available");
  }
}
```

**Criterios de verificación**:
- [ ] Validación completa implementada
- [ ] Todos los casos cubiertos

---

## 🔍 Definition of Done

- [ ] Validación completa funcionando
- [ ] Todos los casos de error manejados
- [ ] Tests pasando

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_

