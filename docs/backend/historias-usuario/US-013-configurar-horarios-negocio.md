# 🕐 US-013: Configurar Horarios de mi Negocio

## 📋 Información General

- **Épica**: Horarios y Disponibilidad
- **Prioridad**: P0 (Crítica)
- **Story Points**: 5
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-003 (Crear Negocio)

---

## 📖 Historia de Usuario

**Como** propietario de negocio  
**Quiero** configurar los horarios de atención de mi negocio  
**Para** que los clientes sepan cuándo pueden reservar citas

---

## ✅ Criterios de Aceptación

- [ ] Puedo configurar horarios para cada día de la semana
- [ ] Puedo marcar días como cerrados
- [ ] Puedo configurar hora de apertura y cierre
- [ ] Puedo configurar múltiples horarios por día (ej: 9-13 y 15-19)
- [ ] Puedo configurar excepciones (vacaciones, días especiales)
- [ ] Solo puedo configurar horarios de mis propios negocios

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear Modelo de Horarios en Prisma**

**Archivo**: `prisma/schema.prisma`

```prisma
model BusinessHours {
  id          String   @id @default(uuid())
  businessId  String   @map("business_id")
  dayOfWeek   Int      @map("day_of_week") // 0 = Domingo, 1 = Lunes, etc.
  openTime    String   @map("open_time") // HH:mm
  closeTime   String   @map("close_time") // HH:mm
  isClosed    Boolean  @default(false) @map("is_closed")
  createdAt   DateTime @default(now()) @map("created_at")
  updatedAt   DateTime @updatedAt @map("updated_at")

  business    Business @relation(fields: [businessId], references: [id], onDelete: Cascade)

  @@unique([businessId, dayOfWeek])
  @@map("business_hours")
}
```

Ejecutar migración:

```bash
npx prisma migrate dev --name add_business_hours
npx prisma generate
```

**Criterios de verificación**:
- [ ] Modelo creado
- [ ] Migración aplicada

---

### **Tarea 2: Crear DTOs**

**Archivo**: `src/dto/business-hours/bulk-business-hours.dto.ts`

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

**Criterios de verificación**:
- [ ] DTOs creados

---

### **Tarea 3: Crear Utilidad de Validación de Horarios**

**Archivo**: `src/utils/business-hours.util.ts`

```typescript
export class BusinessHoursUtil {
  static isValidTime(time: string): boolean {
    const regex = /^([0-1][0-9]|2[0-3]):[0-5][0-9]$/;
    return regex.test(time);
  }

  static isValidTimeRange(openTime: string, closeTime: string): boolean {
    if (!this.isValidTime(openTime) || !this.isValidTime(closeTime)) {
      return false;
    }
    return this.timeToMinutes(openTime) < this.timeToMinutes(closeTime);
  }

  static timeToMinutes(time: string): number {
    const [hours, minutes] = time.split(":").map(Number);
    return hours * 60 + minutes;
  }
}
```

**Criterios de verificación**:
- [ ] Utilidad creada
- [ ] Validaciones funcionando

---

### **Tarea 4: Crear Servicio**

**Archivo**: `src/services/business-hours.service.ts`

```typescript
async setBusinessHours(data: BulkBusinessHoursDto, ownerId: string): Promise<void> {
  // Verificar permisos
  const business = await businessRepository.findById(data.businessId);
  if (!business || business.ownerId !== ownerId) {
    throw new AppError(403, "You do not have permission");
  }

  // Validar horarios
  for (const hour of data.hours) {
    if (!hour.isClosed) {
      if (!BusinessHoursUtil.isValidTimeRange(hour.openTime, hour.closeTime)) {
        throw new AppError(400, `Invalid time range for day ${hour.dayOfWeek}`);
      }
    }
  }

  // Guardar horarios
  await businessHoursRepository.upsertMany(data.businessId, data.hours);
}
```

**Criterios de verificación**:
- [ ] Servicio creado
- [ ] Validaciones funcionando
- [ ] Permisos verificados

---

### **Tarea 5: Crear Endpoint PUT /api/business-hours/:businessId**

**Archivo**: `src/controllers/business-hours.controller.ts`

```typescript
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
    // ... manejo de errores
  }
}
```

**Criterios de verificación**:
- [ ] Endpoint creado
- [ ] Ruta registrada

---

## 🔍 Definition of Done

- [ ] Horarios se pueden configurar
- [ ] Validaciones funcionando
- [ ] Permisos verificados
- [ ] Tests pasando

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_

