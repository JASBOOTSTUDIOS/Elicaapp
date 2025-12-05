# 🕐 Día 13: Horarios de Negocio y Disponibilidad

## 🎯 Objetivo del Día

Implementar sistema completo de horarios de negocio, incluyendo horarios regulares, excepciones (vacaciones, días especiales), y cálculo de disponibilidad para citas.

---

## ✅ Checklist de Tareas

- [ ] Crear modelo de horarios en Prisma
- [ ] Crear DTOs de horarios
- [ ] Crear repositorio de horarios
- [ ] Crear servicio de horarios y disponibilidad
- [ ] Crear controlador y rutas
- [ ] Implementar cálculo de slots disponibles
- [ ] Crear tests completos

---

## 📋 Pasos Detallados

### **Paso 1: Actualizar Schema de Prisma**

Actualizar `prisma/schema.prisma` para agregar modelos de horarios:

```prisma
// Horario regular de negocio
model BusinessHours {
  id          String   @id @default(uuid())
  businessId  String   @map("business_id")
  dayOfWeek   Int      @map("day_of_week") // 0 = Domingo, 1 = Lunes, ..., 6 = Sábado
  openTime    String   @map("open_time") // HH:mm formato
  closeTime   String   @map("close_time") // HH:mm formato
  isClosed    Boolean  @default(false) @map("is_closed")
  createdAt   DateTime @default(now()) @map("created_at")
  updatedAt   DateTime @updatedAt @map("updated_at")

  // Relaciones
  business    Business @relation(fields: [businessId], references: [id], onDelete: Cascade)

  @@unique([businessId, dayOfWeek])
  @@map("business_hours")
  @@index([businessId])
}

// Excepciones de horario (vacaciones, días especiales)
model BusinessHoursException {
  id          String   @id @default(uuid())
  businessId  String   @map("business_id")
  date        DateTime @db.Date // Fecha específica
  openTime    String?  @map("open_time") // null = cerrado todo el día
  closeTime   String?  @map("close_time")
  reason      String?  // Razón de la excepción (ej: "Vacaciones", "Día festivo")
  createdAt   DateTime @default(now()) @map("created_at")
  updatedAt   DateTime @updatedAt @map("updated_at")

  // Relaciones
  business    Business @relation(fields: [businessId], references: [id], onDelete: Cascade)

  @@unique([businessId, date])
  @@map("business_hours_exceptions")
  @@index([businessId])
  @@index([date])
}

// Pausas/descansos durante el día
model BusinessBreak {
  id          String   @id @default(uuid())
  businessId  String   @map("business_id")
  dayOfWeek   Int      @map("day_of_week")
  startTime   String   @map("start_time") // HH:mm formato
  endTime     String   @map("end_time") // HH:mm formato
  createdAt   DateTime @default(now()) @map("created_at")
  updatedAt   DateTime @updatedAt @map("updated_at")

  // Relaciones
  business    Business @relation(fields: [businessId], references: [id], onDelete: Cascade)

  @@map("business_breaks")
  @@index([businessId, dayOfWeek])
}
```

Actualizar modelo Business para agregar relaciones:

```prisma
model Business {
  // ... existing fields ...
  
  businessHours        BusinessHours[]
  businessHoursExceptions BusinessHoursException[]
  businessBreaks      BusinessBreak[]
  
  // ... rest of model ...
}
```

Ejecutar migración:

```bash
npx prisma migrate dev --name add_business_hours
npx prisma generate
```

### **Paso 2: Crear DTOs de Horarios**

Crear archivo `src/dto/business-hours/create-business-hours.dto.ts`:

```typescript
export interface CreateBusinessHoursDto {
  businessId: string;
  dayOfWeek: number; // 0-6
  openTime: string; // HH:mm
  closeTime: string; // HH:mm
  isClosed?: boolean;
}
```

Crear archivo `src/dto/business-hours/bulk-business-hours.dto.ts`:

```typescript
export interface BulkBusinessHoursDto {
  businessId: string;
  hours: {
    dayOfWeek: number;
    openTime: string;
    closeTime: string;
    isClosed?: boolean;
  }[];
}
```

Crear archivo `src/dto/business-hours/create-exception.dto.ts`:

```typescript
export interface CreateBusinessHoursExceptionDto {
  businessId: string;
  date: string; // ISO date string
  openTime?: string; // HH:mm, null = cerrado
  closeTime?: string; // HH:mm
  reason?: string;
}
```

Crear archivo `src/dto/business-hours/create-break.dto.ts`:

```typescript
export interface CreateBusinessBreakDto {
  businessId: string;
  dayOfWeek: number;
  startTime: string; // HH:mm
  endTime: string; // HH:mm
}
```

Crear archivo `src/dto/business-hours/availability-query.dto.ts`:

```typescript
export interface AvailabilityQueryDto {
  businessId: string;
  serviceId: string;
  date: string; // ISO date string
  duration?: number; // Duración en minutos (opcional, se obtiene del servicio)
}
```

### **Paso 3: Crear Utilidad de Horarios**

Crear archivo `src/utils/business-hours.util.ts`:

```typescript
export class BusinessHoursUtil {
  /**
   * Convierte hora en formato HH:mm a minutos desde medianoche
   */
  static timeToMinutes(time: string): number {
    const [hours, minutes] = time.split(":").map(Number);
    return hours * 60 + minutes;
  }

  /**
   * Convierte minutos desde medianoche a formato HH:mm
   */
  static minutesToTime(minutes: number): string {
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;
    return `${String(hours).padStart(2, "0")}:${String(mins).padStart(2, "0")}`;
  }

  /**
   * Valida formato de hora HH:mm
   */
  static isValidTime(time: string): boolean {
    const regex = /^([0-1][0-9]|2[0-3]):[0-5][0-9]$/;
    return regex.test(time);
  }

  /**
   * Valida que openTime < closeTime
   */
  static isValidTimeRange(openTime: string, closeTime: string): boolean {
    if (!this.isValidTime(openTime) || !this.isValidTime(closeTime)) {
      return false;
    }
    return this.timeToMinutes(openTime) < this.timeToMinutes(closeTime);
  }

  /**
   * Obtiene el día de la semana (0-6) de una fecha
   */
  static getDayOfWeek(date: Date): number {
    return date.getDay();
  }

  /**
   * Formatea una fecha a string YYYY-MM-DD
   */
  static formatDate(date: Date): string {
    return date.toISOString().split("T")[0];
  }

  /**
   * Parsea string YYYY-MM-DD a Date
   */
  static parseDate(dateString: string): Date {
    return new Date(dateString + "T00:00:00");
  }

  /**
   * Genera slots de tiempo entre openTime y closeTime
   */
  static generateTimeSlots(
    openTime: string,
    closeTime: string,
    slotDurationMinutes: number,
    breaks: Array<{ startTime: string; endTime: string }> = []
  ): string[] {
    const slots: string[] = [];
    const openMinutes = this.timeToMinutes(openTime);
    const closeMinutes = this.timeToMinutes(closeTime);

    let currentMinutes = openMinutes;

    while (currentMinutes + slotDurationMinutes <= closeMinutes) {
      const slotStart = this.minutesToTime(currentMinutes);
      const slotEnd = this.minutesToTime(currentMinutes + slotDurationMinutes);

      // Verificar si el slot está dentro de un break
      const isInBreak = breaks.some((breakItem) => {
        const breakStart = this.timeToMinutes(breakItem.startTime);
        const breakEnd = this.timeToMinutes(breakItem.endTime);
        return (
          (currentMinutes >= breakStart && currentMinutes < breakEnd) ||
          (currentMinutes + slotDurationMinutes > breakStart &&
            currentMinutes + slotDurationMinutes <= breakEnd) ||
          (currentMinutes < breakStart &&
            currentMinutes + slotDurationMinutes > breakEnd)
        );
      });

      if (!isInBreak) {
        slots.push(slotStart);
      }

      currentMinutes += slotDurationMinutes;
    }

    return slots;
  }
}
```

### **Paso 4: Crear Repositorio de Horarios**

Crear archivo `src/repositories/business-hours.repository.ts`:

```typescript
import prisma from "../config/database";
import { BusinessHours, BusinessHoursException, BusinessBreak } from "@prisma/client";
import { BaseRepository } from "./base.repository";

export class BusinessHoursRepository extends BaseRepository<BusinessHours> {
  protected getModel() {
    return prisma.businessHours;
  }

  async findByBusinessId(businessId: string): Promise<BusinessHours[]> {
    return await prisma.businessHours.findMany({
      where: { businessId },
      orderBy: { dayOfWeek: "asc" },
    });
  }

  async findByBusinessAndDay(
    businessId: string,
    dayOfWeek: number
  ): Promise<BusinessHours | null> {
    return await prisma.businessHours.findUnique({
      where: {
        businessId_dayOfWeek: {
          businessId,
          dayOfWeek,
        },
      },
    });
  }

  async upsertMany(
    businessId: string,
    hours: Array<{
      dayOfWeek: number;
      openTime: string;
      closeTime: string;
      isClosed: boolean;
    }>
  ): Promise<BusinessHours[]> {
    const operations = hours.map((hour) =>
      prisma.businessHours.upsert({
        where: {
          businessId_dayOfWeek: {
            businessId,
            dayOfWeek: hour.dayOfWeek,
          },
        },
        update: {
          openTime: hour.openTime,
          closeTime: hour.closeTime,
          isClosed: hour.isClosed,
        },
        create: {
          businessId,
          ...hour,
        },
      })
    );

    return await Promise.all(operations);
  }
}

export class BusinessHoursExceptionRepository extends BaseRepository<BusinessHoursException> {
  protected getModel() {
    return prisma.businessHoursException;
  }

  async findByBusinessId(businessId: string): Promise<BusinessHoursException[]> {
    return await prisma.businessHoursException.findMany({
      where: { businessId },
      orderBy: { date: "asc" },
    });
  }

  async findByBusinessAndDate(
    businessId: string,
    date: Date
  ): Promise<BusinessHoursException | null> {
    const dateString = date.toISOString().split("T")[0];
    return await prisma.businessHoursException.findUnique({
      where: {
        businessId_date: {
          businessId,
          date: new Date(dateString),
        },
      },
    });
  }

  async findByDateRange(
    businessId: string,
    startDate: Date,
    endDate: Date
  ): Promise<BusinessHoursException[]> {
    return await prisma.businessHoursException.findMany({
      where: {
        businessId,
        date: {
          gte: startDate,
          lte: endDate,
        },
      },
    });
  }
}

export class BusinessBreakRepository extends BaseRepository<BusinessBreak> {
  protected getModel() {
    return prisma.businessBreak;
  }

  async findByBusinessAndDay(
    businessId: string,
    dayOfWeek: number
  ): Promise<BusinessBreak[]> {
    return await prisma.businessBreak.findMany({
      where: {
        businessId,
        dayOfWeek,
      },
      orderBy: { startTime: "asc" },
    });
  }

  async deleteByBusinessAndDay(
    businessId: string,
    dayOfWeek: number
  ): Promise<void> {
    await prisma.businessBreak.deleteMany({
      where: {
        businessId,
        dayOfWeek,
      },
    });
  }
}

export const businessHoursRepository = new BusinessHoursRepository();
export const businessHoursExceptionRepository = new BusinessHoursExceptionRepository();
export const businessBreakRepository = new BusinessBreakRepository();
```

### **Paso 5: Crear Servicio de Horarios y Disponibilidad**

Crear archivo `src/services/business-hours.service.ts`:

```typescript
import { businessHoursRepository } from "../repositories/business-hours.repository";
import { businessHoursExceptionRepository } from "../repositories/business-hours.repository";
import { businessBreakRepository } from "../repositories/business-hours.repository";
import { businessRepository } from "../repositories/business.repository";
import { serviceRepository } from "../repositories/service.repository";
import { appointmentRepository } from "../repositories/appointment.repository";
import { BulkBusinessHoursDto } from "../dto/business-hours/bulk-business-hours.dto";
import { CreateBusinessHoursExceptionDto } from "../dto/business-hours/create-exception.dto";
import { CreateBusinessBreakDto } from "../dto/business-hours/create-break.dto";
import { AvailabilityQueryDto } from "../dto/business-hours/availability-query.dto";
import { BusinessHoursUtil } from "../utils/business-hours.util";
import { AppError } from "../middleware/error.middleware";
import { logger } from "../config/logger";

export class BusinessHoursService {
  async setBusinessHours(data: BulkBusinessHoursDto, ownerId: string): Promise<void> {
    // Verificar permisos
    const business = await businessRepository.findById(data.businessId);
    if (!business || business.ownerId !== ownerId) {
      throw new AppError(403, "You do not have permission to set business hours");
    }

    // Validar horarios
    for (const hour of data.hours) {
      if (!hour.isClosed) {
        if (!BusinessHoursUtil.isValidTime(hour.openTime)) {
          throw new AppError(400, `Invalid openTime: ${hour.openTime}`);
        }
        if (!BusinessHoursUtil.isValidTime(hour.closeTime)) {
          throw new AppError(400, `Invalid closeTime: ${hour.closeTime}`);
        }
        if (!BusinessHoursUtil.isValidTimeRange(hour.openTime, hour.closeTime)) {
          throw new AppError(
            400,
            `Invalid time range: ${hour.openTime} - ${hour.closeTime}`
          );
        }
      }
    }

    await businessHoursRepository.upsertMany(data.businessId, data.hours);

    logger.info(`Business hours set for business: ${data.businessId}`);
  }

  async getBusinessHours(businessId: string): Promise<any[]> {
    return await businessHoursRepository.findByBusinessId(businessId);
  }

  async createException(
    data: CreateBusinessHoursExceptionDto,
    ownerId: string
  ): Promise<void> {
    // Verificar permisos
    const business = await businessRepository.findById(data.businessId);
    if (!business || business.ownerId !== ownerId) {
      throw new AppError(403, "You do not have permission");
    }

    const date = BusinessHoursUtil.parseDate(data.date);

    // Si tiene openTime y closeTime, validar
    if (data.openTime && data.closeTime) {
      if (!BusinessHoursUtil.isValidTimeRange(data.openTime, data.closeTime)) {
        throw new AppError(400, "Invalid time range");
      }
    }

    await businessHoursExceptionRepository.create({
      businessId: data.businessId,
      date,
      openTime: data.openTime || null,
      closeTime: data.closeTime || null,
      reason: data.reason || null,
    });

    logger.info(`Exception created for business: ${data.businessId}, date: ${data.date}`);
  }

  async createBreak(
    data: CreateBusinessBreakDto,
    ownerId: string
  ): Promise<void> {
    // Verificar permisos
    const business = await businessRepository.findById(data.businessId);
    if (!business || business.ownerId !== ownerId) {
      throw new AppError(403, "You do not have permission");
    }

    if (!BusinessHoursUtil.isValidTimeRange(data.startTime, data.endTime)) {
      throw new AppError(400, "Invalid break time range");
    }

    await businessBreakRepository.create({
      businessId: data.businessId,
      dayOfWeek: data.dayOfWeek,
      startTime: data.startTime,
      endTime: data.endTime,
    });

    logger.info(`Break created for business: ${data.businessId}, day: ${data.dayOfWeek}`);
  }

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

    // Verificar si hay excepción para esta fecha
    const exception = await businessHoursExceptionRepository.findByBusinessAndDate(
      businessId,
      targetDate
    );

    // Si hay excepción y está cerrado, retornar array vacío
    if (exception && !exception.openTime) {
      return [];
    }

    // Obtener horario del día
    const businessHours = await businessHoursRepository.findByBusinessAndDay(
      businessId,
      dayOfWeek
    );

    if (!businessHours || businessHours.isClosed) {
      return [];
    }

    // Usar horario de excepción si existe, sino usar horario regular
    const openTime = exception?.openTime || businessHours.openTime;
    const closeTime = exception?.closeTime || businessHours.closeTime;

    // Obtener breaks del día
    const breaks = await businessBreakRepository.findByBusinessAndDay(
      businessId,
      dayOfWeek
    );

    // Generar slots disponibles
    const allSlots = BusinessHoursUtil.generateTimeSlots(
      openTime,
      closeTime,
      slotDuration,
      breaks.map((b) => ({ startTime: b.startTime, endTime: b.endTime }))
    );

    // Obtener citas existentes para esta fecha
    const existingAppointments = await appointmentRepository.findByBusinessIdAndDate(
      businessId,
      targetDate
    );

    // Filtrar slots que están ocupados
    const availableSlots = allSlots.filter((slot) => {
      const slotStartMinutes = BusinessHoursUtil.timeToMinutes(slot);
      const slotEndMinutes = slotStartMinutes + slotDuration;

      // Verificar si hay conflicto con alguna cita existente
      return !existingAppointments.some((apt) => {
        const aptStartMinutes = BusinessHoursUtil.timeToMinutes(
          BusinessHoursUtil.minutesToTime(apt.date.getHours() * 60 + apt.date.getMinutes())
        );
        const aptEndMinutes = aptStartMinutes + (service.durationMinutes || 60);

        // Verificar solapamiento
        return (
          (slotStartMinutes >= aptStartMinutes && slotStartMinutes < aptEndMinutes) ||
          (slotEndMinutes > aptStartMinutes && slotEndMinutes <= aptEndMinutes) ||
          (slotStartMinutes < aptStartMinutes && slotEndMinutes > aptEndMinutes)
        );
      });
    });

    return availableSlots;
  }
}

export const businessHoursService = new BusinessHoursService();
```

### **Paso 6: Actualizar Repositorio de Citas**

Actualizar `src/repositories/appointment.repository.ts`:

```typescript
// ... existing code ...

async findByBusinessIdAndDate(
  businessId: string,
  date: Date
): Promise<Appointment[]> {
  const startOfDay = new Date(date);
  startOfDay.setHours(0, 0, 0, 0);
  
  const endOfDay = new Date(date);
  endOfDay.setHours(23, 59, 59, 999);

  return await prisma.appointment.findMany({
    where: {
      businessId,
      date: {
        gte: startOfDay,
        lte: endOfDay,
      },
      status: {
        not: "CANCELLED", // Excluir citas canceladas
      },
    },
  });
}

// ... existing code ...
```

### **Paso 7: Crear Controlador de Horarios**

Crear archivo `src/controllers/business-hours.controller.ts`:

```typescript
import { Request, Response } from "express";
import { businessHoursService } from "../services/business-hours.service";
import { BulkBusinessHoursDto } from "../dto/business-hours/bulk-business-hours.dto";
import { CreateBusinessHoursExceptionDto } from "../dto/business-hours/create-exception.dto";
import { CreateBusinessBreakDto } from "../dto/business-hours/create-break.dto";
import { AvailabilityQueryDto } from "../dto/business-hours/availability-query.dto";
import { logger } from "../config/logger";

export class BusinessHoursController {
  async setBusinessHours(req: Request, res: Response): Promise<void> {
    try {
      const businessId = req.params.businessId;
      const userId = req.user!.id;

      const data: BulkBusinessHoursDto = {
        businessId,
        hours: req.body.hours,
      };

      await businessHoursService.setBusinessHours(data, userId);

      res.json({
        success: true,
        message: "Business hours set successfully",
      });
    } catch (error: any) {
      logger.error("Error setting business hours:", error);
      res.status(error.statusCode || 500).json({
        success: false,
        message: error.message || "Error setting business hours",
      });
    }
  }

  async getBusinessHours(req: Request, res: Response): Promise<void> {
    try {
      const businessId = req.params.businessId;
      const hours = await businessHoursService.getBusinessHours(businessId);

      res.json({
        success: true,
        data: hours,
      });
    } catch (error: any) {
      logger.error("Error getting business hours:", error);
      res.status(error.statusCode || 500).json({
        success: false,
        message: error.message || "Error getting business hours",
      });
    }
  }

  async createException(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.id;
      const data: CreateBusinessHoursExceptionDto = {
        businessId: req.params.businessId,
        ...req.body,
      };

      await businessHoursService.createException(data, userId);

      res.json({
        success: true,
        message: "Exception created successfully",
      });
    } catch (error: any) {
      logger.error("Error creating exception:", error);
      res.status(error.statusCode || 500).json({
        success: false,
        message: error.message || "Error creating exception",
      });
    }
  }

  async createBreak(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.id;
      const data: CreateBusinessBreakDto = {
        businessId: req.params.businessId,
        ...req.body,
      };

      await businessHoursService.createBreak(data, userId);

      res.json({
        success: true,
        message: "Break created successfully",
      });
    } catch (error: any) {
      logger.error("Error creating break:", error);
      res.status(error.statusCode || 500).json({
        success: false,
        message: error.message || "Error creating break",
      });
    }
  }

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
      logger.error("Error getting available slots:", error);
      res.status(error.statusCode || 500).json({
        success: false,
        message: error.message || "Error getting available slots",
      });
    }
  }
}

export const businessHoursController = new BusinessHoursController();
```

### **Paso 8: Crear Rutas de Horarios**

Crear archivo `src/routes/business-hours.routes.ts`:

```typescript
import { Router } from "express";
import { businessHoursController } from "../controllers/business-hours.controller";
import { authMiddleware } from "../middleware/auth.middleware";

const router = Router();

// GET /api/business-hours/:businessId/available-slots (público)
router.get(
  "/:businessId/available-slots",
  businessHoursController.getAvailableSlots.bind(businessHoursController)
);

// GET /api/business-hours/:businessId (público)
router.get(
  "/:businessId",
  businessHoursController.getBusinessHours.bind(businessHoursController)
);

// Rutas que requieren autenticación
router.use(authMiddleware);

// PUT /api/business-hours/:businessId
router.put(
  "/:businessId",
  businessHoursController.setBusinessHours.bind(businessHoursController)
);

// POST /api/business-hours/:businessId/exceptions
router.post(
  "/:businessId/exceptions",
  businessHoursController.createException.bind(businessHoursController)
);

// POST /api/business-hours/:businessId/breaks
router.post(
  "/:businessId/breaks",
  businessHoursController.createBreak.bind(businessHoursController)
);

export default router;
```

### **Paso 9: Registrar Rutas en App**

Actualizar `src/app.ts`:

```typescript
// ... existing imports ...
import businessHoursRoutes from "./routes/business-hours.routes";

// ... existing code ...

app.use("/api/business-hours", businessHoursRoutes);

// ... existing code ...
```

---

## ✅ Verificación Final

- [ ] Horarios de negocio funcionando
- [ ] Excepciones de horario funcionando
- [ ] Pausas/breaks funcionando
- [ ] Cálculo de disponibilidad funcionando
- [ ] Tests pasando

---

## 📝 Entregables del Día

1. ✅ Sistema de horarios regulares
2. ✅ Sistema de excepciones (vacaciones, días especiales)
3. ✅ Sistema de pausas/breaks
4. ✅ Cálculo de slots disponibles
5. ✅ Integración con sistema de citas
6. ✅ Tests completos

---

## 🎯 Próximo Día

**Día 14**: Refinamiento y Testing Final

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_

