# 📅 US-005: Agenda de Citas

## 📋 Información General

- **Épica**: Sistema de Citas
- **Prioridad**: P0 (Crítica)
- **Story Points**: 8
- **Sprint**: Sprint 2 - Semana 3
- **Estado**: To Do
- **Dependencias**: US-004 (Gestión de Servicios)

---

## 📖 Historia de Usuario

**Como** cliente  
**Quiero** ver disponibilidad de horarios y reservar un servicio  
**Para** agendar mi cita sin tener que llamar

---

## ✅ Criterios de Aceptación

- [ ] Puedo ver disponibilidad de horarios para un servicio
- [ ] Puedo reservar una cita en un horario disponible
- [ ] Se valida que el horario no esté ocupado
- [ ] Se valida que el servicio existe y está activo
- [ ] Se valida que el negocio está activo
- [ ] La cita se crea con estado PENDING
- [ ] Se envía notificación al negocio
- [ ] No se pueden crear citas en el pasado

---

## 🎯 Reglas de Negocio

1. **Disponibilidad**: Verificar que no haya citas conflictivas
2. **Horarios válidos**: No se pueden crear citas en el pasado
3. **Servicio activo**: Solo servicios activos pueden ser reservados
4. **Negocio activo**: Solo negocios activos pueden recibir citas
5. **Estado inicial**: Las citas se crean con estado PENDING
6. **Duración**: La duración se toma del servicio

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear DTOs**

**Archivo**: `src/dto/appointment/create-appointment.dto.ts`

```typescript
export interface CreateAppointmentDto {
  businessId: string;
  serviceId: string;
  date: string; // ISO 8601 string
  notes?: string;
}
```

**Archivo**: `src/dto/appointment/availability-query.dto.ts`

```typescript
export interface AvailabilityQueryDto {
  businessId: string;
  serviceId: string;
  date: string; // YYYY-MM-DD
}
```

---

### **Tarea 2: Crear Validador**

**Archivo**: `src/validators/appointment.validator.ts`

```typescript
import { z } from 'zod';

export const createAppointmentSchema = z.object({
  businessId: z.string().uuid('Invalid business ID'),
  serviceId: z.string().uuid('Invalid service ID'),
  date: z.string().datetime('Invalid date format'),
  notes: z.string().max(500).optional(),
});

export const availabilityQuerySchema = z.object({
  businessId: z.string().uuid(),
  serviceId: z.string().uuid(),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be in YYYY-MM-DD format'),
});
```

---

### **Tarea 3: Crear Repositorio**

**Archivo**: `src/repositories/appointment.repository.ts`

```typescript
import prisma from '../config/database';
import { Appointment, Prisma } from '@prisma/client';
import { BaseRepository } from './base.repository';

export class AppointmentRepository extends BaseRepository<Appointment> {
  protected getModel() {
    return prisma.appointment;
  }

  async findByUserId(userId: string): Promise<Appointment[]> {
    return await prisma.appointment.findMany({
      where: { userId },
      include: {
        business: {
          select: {
            id: true,
            name: true,
          },
        },
        service: {
          select: {
            id: true,
            name: true,
            durationMinutes: true,
            price: true,
          },
        },
      },
      orderBy: {
        date: 'desc',
      },
    });
  }

  async findByBusinessId(businessId: string): Promise<Appointment[]> {
    return await prisma.appointment.findMany({
      where: { businessId },
      include: {
        user: {
          select: {
            id: true,
            email: true,
            fullName: true,
            phone: true,
          },
        },
        service: {
          select: {
            id: true,
            name: true,
            durationMinutes: true,
            price: true,
          },
        },
      },
      orderBy: {
        date: 'asc',
      },
    });
  }

  async findByIdWithRelations(id: string): Promise<Appointment | null> {
    return await prisma.appointment.findUnique({
      where: { id },
      include: {
        business: {
          select: {
            id: true,
            name: true,
            ownerId: true,
          },
        },
        user: {
          select: {
            id: true,
            email: true,
            fullName: true,
          },
        },
        service: {
          select: {
            id: true,
            name: true,
            durationMinutes: true,
          },
        },
      },
    });
  }

  async findConflicting(
    businessId: string,
    startTime: Date,
    endTime: Date
  ): Promise<Appointment[]> {
    return await prisma.appointment.findMany({
      where: {
        businessId,
        date: {
          gte: startTime,
          lt: endTime,
        },
        status: {
          not: 'CANCELLED',
        },
      },
    });
  }

  async findAvailableSlots(
    businessId: string,
    serviceId: string,
    date: Date
  ): Promise<Date[]> {
    // Obtener servicio para conocer duración
    const service = await prisma.service.findUnique({
      where: { id: serviceId },
    });

    if (!service) {
      return [];
    }

    // Horario de trabajo (ejemplo: 9 AM - 6 PM)
    const workStart = new Date(date);
    workStart.setHours(9, 0, 0, 0);

    const workEnd = new Date(date);
    workEnd.setHours(18, 0, 0, 0);

    // Obtener citas existentes del día
    const dayStart = new Date(date);
    dayStart.setHours(0, 0, 0, 0);

    const dayEnd = new Date(date);
    dayEnd.setHours(23, 59, 59, 999);

    const existingAppointments = await prisma.appointment.findMany({
      where: {
        businessId,
        date: {
          gte: dayStart,
          lte: dayEnd,
        },
        status: {
          not: 'CANCELLED',
        },
      },
      include: {
        service: true,
      },
    });

    // Generar slots disponibles (cada 30 minutos)
    const availableSlots: Date[] = [];
    const slotDuration = 30; // minutos
    const serviceDuration = service.durationMinutes;

    let currentTime = new Date(workStart);

    while (currentTime < workEnd) {
      const slotEnd = new Date(currentTime.getTime() + serviceDuration * 60000);

      // Verificar si el slot está disponible
      const isAvailable = !existingAppointments.some((apt) => {
        const aptStart = new Date(apt.date);
        const aptEnd = new Date(aptStart.getTime() + apt.service.durationMinutes * 60000);

        return (
          (currentTime >= aptStart && currentTime < aptEnd) ||
          (slotEnd > aptStart && slotEnd <= aptEnd) ||
          (currentTime <= aptStart && slotEnd >= aptEnd)
        );
      });

      if (isAvailable && slotEnd <= workEnd) {
        availableSlots.push(new Date(currentTime));
      }

      currentTime = new Date(currentTime.getTime() + slotDuration * 60000);
    }

    return availableSlots;
  }
}

export const appointmentRepository = new AppointmentRepository();
```

---

### **Tarea 4: Crear Servicio**

**Archivo**: `src/services/appointment.service.ts`

```typescript
import { appointmentRepository } from '../repositories/appointment.repository';
import { serviceRepository } from '../repositories/service.repository';
import { businessRepository } from '../repositories/business.repository';
import { CreateAppointmentDto, AvailabilityQueryDto } from '../dto/appointment';
import { AppError } from '../middleware/error.middleware';
import { logger } from '../config/logger';
import { Appointment, AppointmentStatus } from '@prisma/client';

export class AppointmentService {
  async create(userId: string, data: CreateAppointmentDto): Promise<Appointment> {
    logger.info(`Creating appointment for user: ${userId}`);

    // 1. Verificar que el servicio existe
    const service = await serviceRepository.findByIdWithBusiness(data.serviceId);
    if (!service || service.businessId !== data.businessId) {
      throw new AppError(404, 'Service not found');
    }

    // 2. Verificar que el servicio está activo
    if (!service.isActive) {
      throw new AppError(400, 'Service is not active');
    }

    // 3. Verificar que el negocio está activo
    if (!service.business.isActive) {
      throw new AppError(400, 'Business is not active');
    }

    const appointmentDate = new Date(data.date);

    // 4. Validar que la fecha no sea en el pasado
    if (appointmentDate < new Date()) {
      throw new AppError(400, 'Cannot create appointment in the past');
    }

    // 5. Validar disponibilidad
    await this.validateAvailability(
      data.businessId,
      appointmentDate,
      service.durationMinutes
    );

    // 6. Crear cita
    const appointment = await appointmentRepository.create({
      businessId: data.businessId,
      userId,
      serviceId: data.serviceId,
      date: appointmentDate,
      status: AppointmentStatus.PENDING,
      notes: data.notes,
    });

    logger.info(`Appointment created: ${appointment.id}`);

    // 7. Enviar notificación (implementar después)
    // await notificationService.sendAppointmentCreated(appointment);

    return appointment;
  }

  private async validateAvailability(
    businessId: string,
    date: Date,
    durationMinutes: number
  ): Promise<void> {
    const startTime = new Date(date);
    const endTime = new Date(date.getTime() + durationMinutes * 60000);

    const conflictingAppointments = await appointmentRepository.findConflicting(
      businessId,
      startTime,
      endTime
    );

    if (conflictingAppointments.length > 0) {
      throw new AppError(400, 'Time slot is not available');
    }
  }

  async getAvailability(query: AvailabilityQueryDto): Promise<Date[]> {
    const date = new Date(query.date);

    // Verificar que el servicio existe
    const service = await serviceRepository.findByIdWithBusiness(query.serviceId);
    if (!service || service.businessId !== query.businessId) {
      throw new AppError(404, 'Service not found');
    }

    return await appointmentRepository.findAvailableSlots(
      query.businessId,
      query.serviceId,
      date
    );
  }

  async findByUser(userId: string): Promise<Appointment[]> {
    return await appointmentRepository.findByUserId(userId);
  }

  async findByBusiness(businessId: string, ownerId: string): Promise<Appointment[]> {
    // Verificar permisos
    const business = await businessRepository.findById(businessId);
    if (!business || business.ownerId !== ownerId) {
      throw new AppError(403, 'You do not have permission');
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
      throw new AppError(404, 'Appointment not found');
    }

    // Validar transición de estado
    this.validateStatusTransition(appointment.status, status);

    // Verificar permisos
    if (appointment.userId !== userId && appointment.business.ownerId !== userId) {
      throw new AppError(403, 'You do not have permission');
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

### **Tarea 5: Crear Controlador y Rutas**

Seguir el mismo patrón que Business y Service.

---

## 🧪 Tests

```typescript
describe('AppointmentService', () => {
  it('should create appointment with valid data', async () => {
    // Test completo de creación
  });

  it('should reject appointment in the past', async () => {
    // Test de validación de fecha
  });

  it('should reject conflicting appointments', async () => {
    // Test de disponibilidad
  });
});
```

---

## ✅ Definition of Done

- [ ] Creación de citas funcionando
- [ ] Validación de disponibilidad implementada
- [ ] Consulta de disponibilidad funcionando
- [ ] Máquina de estados implementada
- [ ] Tests completos pasando

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_

