# 📅 Día 8: API de Citas (Appointments)

## 🎯 Objetivo del Día

Implementar sistema completo de citas con validación de disponibilidad, estados y notificaciones básicas.

---

## ✅ Checklist de Tareas

- [ ] Crear DTOs de cita
- [ ] Crear validadores
- [ ] Crear repositorio de citas
- [ ] Crear servicio de citas con lógica de disponibilidad
- [ ] Crear controlador y rutas
- [ ] Implementar máquina de estados
- [ ] Crear tests completos

---

## 📋 Pasos Detallados

### **Paso 1: Crear DTOs**

Crear archivo `src/dto/appointment/create-appointment.dto.ts`:

```typescript
export interface CreateAppointmentDto {
  businessId: string;
  serviceId: string;
  date: string; // ISO string
  notes?: string;
}
```

### **Paso 2: Crear Servicio con Validación de Disponibilidad**

Crear archivo `src/services/appointment.service.ts`:

```typescript
import { appointmentRepository } from "../repositories/appointment.repository";
import { serviceRepository } from "../repositories/service.repository";
import { businessRepository } from "../repositories/business.repository";
import { CreateAppointmentDto } from "../dto/appointment";
import { AppError } from "../middleware/error.middleware";
import { logger } from "../config/logger";
import { Appointment, AppointmentStatus } from "@prisma/client";

export class AppointmentService {
  async create(
    userId: string,
    data: CreateAppointmentDto
  ): Promise<Appointment> {
    // Verificar que el servicio existe
    const service = await serviceRepository.findByIdWithBusiness(
      data.serviceId
    );
    if (!service || service.businessId !== data.businessId) {
      throw new AppError(404, "Service not found");
    }

    // Verificar que el negocio está activo
    if (!service.business.isActive) {
      throw new AppError(400, "Business is not active");
    }

    const appointmentDate = new Date(data.date);

    // Validar disponibilidad
    await this.validateAvailability(
      data.businessId,
      appointmentDate,
      service.durationMinutes
    );

    logger.info(`Creating appointment for user: ${userId}`);

    const appointment = await appointmentRepository.create({
      businessId: data.businessId,
      userId,
      serviceId: data.serviceId,
      date: appointmentDate,
      status: AppointmentStatus.PENDING,
      notes: data.notes,
    });

    logger.info(`Appointment created: ${appointment.id}`);
    return appointment;
  }

  private async validateAvailability(
    businessId: string,
    date: Date,
    durationMinutes: number
  ): Promise<void> {
    const startTime = new Date(date);
    const endTime = new Date(date.getTime() + durationMinutes * 60000);

    // Buscar citas conflictivas
    const conflictingAppointments = await appointmentRepository.findConflicting(
      businessId,
      startTime,
      endTime
    );

    if (conflictingAppointments.length > 0) {
      throw new AppError(400, "Time slot is not available");
    }
  }

  async findByUser(userId: string): Promise<Appointment[]> {
    return await appointmentRepository.findByUserId(userId);
  }

  async findByBusiness(
    businessId: string,
    ownerId: string
  ): Promise<Appointment[]> {
    // Verificar permisos
    const business = await businessRepository.findById(businessId);
    if (!business || business.ownerId !== ownerId) {
      throw new AppError(403, "You do not have permission");
    }

    return await appointmentRepository.findByBusinessId(businessId);
  }

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

    return await appointmentRepository.update(id, { status });
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
}

export const appointmentService = new AppointmentService();
```

---

## ✅ Verificación Final

- [ ] Sistema de citas funcionando
- [ ] Validación de disponibilidad implementada
- [ ] Máquina de estados funcionando
- [ ] Tests pasando

---

## 📝 Entregables del Día

1. ✅ CRUD completo de citas
2. ✅ Validación de disponibilidad
3. ✅ Máquina de estados
4. ✅ Tests completos

---

## 🎯 Próximo Día

**Día 9**: Dashboard y Métricas

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_
