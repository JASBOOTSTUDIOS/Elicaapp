# 🔄 US-023: Cambiar Estado de una Cita

## 📋 Información General

- **Épica**: Sistema de Citas
- **Prioridad**: P0 (Crítica)
- **Story Points**: 3
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-005 (Agenda de Citas)

---

## 📖 Historia de Usuario

**Como** propietario de negocio o cliente  
**Quiero** cambiar el estado de una cita (confirmar, cancelar, completar)  
**Para** gestionar el flujo de las citas

---

## ✅ Criterios de Aceptación

- [ ] Puedo confirmar una cita pendiente
- [ ] Puedo cancelar una cita (pendiente o confirmada)
- [ ] Puedo marcar una cita como en progreso
- [ ] Puedo marcar una cita como completada
- [ ] Solo se permiten transiciones válidas de estado
- [ ] Solo el dueño del negocio o el cliente pueden cambiar el estado
- [ ] Se envía notificación cuando cambia el estado

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear DTO**

**Archivo**: `src/dto/appointment/update-status.dto.ts`

```typescript
export interface UpdateAppointmentStatusDto {
  status: "PENDING" | "CONFIRMED" | "IN_PROGRESS" | "COMPLETED" | "CANCELLED";
}
```

**Criterios de verificación**:
- [ ] DTO creado

---

### **Tarea 2: Crear Validador**

**Archivo**: `src/validators/appointment.validator.ts`

```typescript
export const updateStatusSchema = z.object({
  status: z.enum([
    "PENDING",
    "CONFIRMED",
    "IN_PROGRESS",
    "COMPLETED",
    "CANCELLED",
  ]),
});
```

**Criterios de verificación**:
- [ ] Validador creado

---

### **Tarea 3: Implementar Método updateStatus**

**Archivo**: `src/services/appointment.service.ts`

```typescript
async updateStatus(
  id: string,
  status: AppointmentStatus,
  userId: string
): Promise<Appointment> {
  const appointment = await appointmentRepository.findByIdWithRelations(id);
  if (!appointment) {
    throw new AppError(404, "Appointment not found");
  }

  // Validar transición de estado
  this.validateStatusTransition(appointment.status, status);

  // Verificar permisos
  if (
    appointment.userId !== userId &&
    appointment.business.ownerId !== userId
  ) {
    throw new AppError(403, "You do not have permission");
  }

  const updated = await appointmentRepository.update(id, { status });

  // Crear notificación según el nuevo estado
  let notificationType: NotificationType;
  switch (status) {
    case AppointmentStatus.CONFIRMED:
      notificationType = NotificationType.APPOINTMENT_CONFIRMED;
      break;
    case AppointmentStatus.CANCELLED:
      notificationType = NotificationType.APPOINTMENT_CANCELLED;
      break;
    case AppointmentStatus.COMPLETED:
      notificationType = NotificationType.APPOINTMENT_COMPLETED;
      break;
    default:
      return updated;
  }

  await notificationService.createFromTemplate(
    appointment.userId,
    notificationType,
    {
      appointmentId: updated.id,
      serviceName: appointment.service.name,
      businessName: appointment.business.name,
      date: NotificationTemplates.formatDate(updated.date),
    }
  );

  return updated;
}

private validateStatusTransition(
  current: AppointmentStatus,
  next: AppointmentStatus
): void {
  const validTransitions: Record<AppointmentStatus, AppointmentStatus[]> = {
    PENDING: [AppointmentStatus.CONFIRMED, AppointmentStatus.CANCELLED],
    CONFIRMED: [AppointmentStatus.IN_PROGRESS, AppointmentStatus.CANCELLED],
    IN_PROGRESS: [AppointmentStatus.COMPLETED, AppointmentStatus.CANCELLED],
    COMPLETED: [],
    CANCELLED: [],
  };

  if (!validTransitions[current].includes(next)) {
    throw new AppError(
      400,
      `Invalid status transition from ${current} to ${next}`
    );
  }
}
```

**Criterios de verificación**:
- [ ] Método implementado
- [ ] Validación de transiciones funcionando
- [ ] Notificaciones creadas

---

### **Tarea 4: Crear Endpoint PUT /api/appointments/:id/status**

**Archivo**: `src/controllers/appointment.controller.ts`

```typescript
async updateStatus(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id;
    const userId = req.user!.id;
    const validatedData = updateStatusSchema.parse(req.body);

    const appointment = await appointmentService.updateStatus(
      id,
      validatedData.status as AppointmentStatus,
      userId
    );

    res.json({
      success: true,
      data: appointment,
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
- [ ] Validación de transiciones funcionando
- [ ] Permisos verificados
- [ ] Notificaciones enviadas
- [ ] Tests pasando

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_

