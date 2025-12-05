# 📅 US-017: Configurar Excepción de Horario (Vacaciones)

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
**Quiero** configurar excepciones de horario (vacaciones, días festivos)  
**Para** que los clientes no puedan reservar en esos días

---

## ✅ Criterios de Aceptación

- [ ] Puedo marcar un día específico como cerrado
- [ ] Puedo configurar horario especial para un día específico
- [ ] Puedo agregar una razón para la excepción
- [ ] Las excepciones sobrescriben el horario regular
- [ ] Solo puedo configurar excepciones de mis propios negocios

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear Modelo de Excepción**

**Archivo**: `prisma/schema.prisma`

```prisma
model BusinessHoursException {
  id          String   @id @default(uuid())
  businessId  String   @map("business_id")
  date        DateTime @db.Date
  openTime    String?  @map("open_time") // null = cerrado todo el día
  closeTime   String?  @map("close_time")
  reason      String?
  createdAt   DateTime @default(now()) @map("created_at")
  updatedAt   DateTime @updatedAt @map("updated_at")

  business    Business @relation(fields: [businessId], references: [id], onDelete: Cascade)

  @@unique([businessId, date])
  @@map("business_hours_exceptions")
}
```

Ejecutar migración:

```bash
npx prisma migrate dev --name add_business_hours_exceptions
npx prisma generate
```

**Criterios de verificación**:
- [ ] Modelo creado
- [ ] Migración aplicada

---

### **Tarea 2: Crear DTO**

**Archivo**: `src/dto/business-hours/create-exception.dto.ts`

```typescript
export interface CreateBusinessHoursExceptionDto {
  businessId: string;
  date: string; // ISO date string
  openTime?: string; // HH:mm, null = cerrado
  closeTime?: string; // HH:mm
  reason?: string;
}
```

**Criterios de verificación**:
- [ ] DTO creado

---

### **Tarea 3: Agregar Método al Servicio**

**Archivo**: `src/services/business-hours.service.ts`

```typescript
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
}
```

**Criterios de verificación**:
- [ ] Método implementado
- [ ] Validaciones funcionando

---

### **Tarea 4: Crear Endpoint POST /api/business-hours/:businessId/exceptions**

**Archivo**: `src/controllers/business-hours.controller.ts`

```typescript
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
- [ ] Excepciones se guardan correctamente
- [ ] Validaciones funcionando
- [ ] Tests pasando

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_

