# ☕ US-018: Configurar Pausas en Horario de Trabajo

## 📋 Información General

- **Épica**: Horarios y Disponibilidad
- **Prioridad**: P0 (Crítica)
- **Story Points**: 2
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-013 (Configurar Horarios)

---

## 📖 Historia de Usuario

**Como** propietario de negocio  
**Quiero** configurar pausas/descansos en mi horario de trabajo  
**Para** que los clientes no puedan reservar durante esos períodos

---

## ✅ Criterios de Aceptación

- [ ] Puedo configurar pausas para cada día de la semana
- [ ] Puedo configurar múltiples pausas por día
- [ ] Puedo especificar hora de inicio y fin de cada pausa
- [ ] Las pausas se excluyen de los horarios disponibles
- [ ] Solo puedo configurar pausas de mis propios negocios

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear Modelo de Pausas**

**Archivo**: `prisma/schema.prisma`

```prisma
model BusinessBreak {
  id          String   @id @default(uuid())
  businessId  String   @map("business_id")
  dayOfWeek   Int      @map("day_of_week")
  startTime   String   @map("start_time") // HH:mm
  endTime     String   @map("end_time") // HH:mm
  createdAt   DateTime @default(now()) @map("created_at")
  updatedAt   DateTime @updatedAt @map("updated_at")

  business    Business @relation(fields: [businessId], references: [id], onDelete: Cascade)

  @@map("business_breaks")
  @@index([businessId, dayOfWeek])
}
```

Ejecutar migración:

```bash
npx prisma migrate dev --name add_business_breaks
npx prisma generate
```

**Criterios de verificación**:
- [ ] Modelo creado
- [ ] Migración aplicada

---

### **Tarea 2: Crear DTO**

**Archivo**: `src/dto/business-hours/create-break.dto.ts`

```typescript
export interface CreateBusinessBreakDto {
  businessId: string;
  dayOfWeek: number;
  startTime: string; // HH:mm
  endTime: string; // HH:mm
}
```

**Criterios de verificación**:
- [ ] DTO creado

---

### **Tarea 3: Agregar Método al Servicio**

**Archivo**: `src/services/business-hours.service.ts`

```typescript
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
}
```

**Criterios de verificación**:
- [ ] Método implementado
- [ ] Validaciones funcionando

---

### **Tarea 4: Crear Endpoint POST /api/business-hours/:businessId/breaks**

**Archivo**: `src/controllers/business-hours.controller.ts`

```typescript
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
- [ ] Pausas se guardan correctamente
- [ ] Pausas se excluyen de horarios disponibles
- [ ] Tests pasando

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_

