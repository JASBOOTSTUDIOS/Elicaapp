# 📅 Día 7: API de Servicios Completa

## 🎯 Objetivo del Día

Implementar CRUD completo de servicios con relación a negocios, validaciones de negocio y endpoints protegidos.

---

## ✅ Checklist de Tareas

- [ ] Crear DTOs de servicio
- [ ] Crear validadores de servicio
- [ ] Crear repositorio de servicio
- [ ] Crear servicio de negocio
- [ ] Crear controlador de servicio
- [ ] Crear rutas de servicio
- [ ] Implementar validaciones de negocio
- [ ] Crear tests completos

---

## 📋 Pasos Detallados

### **Paso 1: Crear DTOs de Servicio**

Crear archivo `src/dto/service/create-service.dto.ts`:

```typescript
export interface CreateServiceDto {
  businessId: string;
  name: string;
  description?: string;
  durationMinutes: number;
  price: number;
  category?: string;
}
```

Crear archivo `src/dto/service/update-service.dto.ts`:

```typescript
export interface UpdateServiceDto {
  name?: string;
  description?: string;
  durationMinutes?: number;
  price?: number;
  category?: string;
  isActive?: boolean;
}
```

**Verificación**:

- [ ] DTOs creados

---

### **Paso 2: Crear Validadores**

Crear archivo `src/validators/service.validator.ts`:

```typescript
import { z } from "zod";

export const createServiceSchema = z.object({
  businessId: z.string().uuid("Invalid business ID"),
  name: z.string().min(2, "Name must be at least 2 characters").max(100),
  description: z.string().max(500).optional(),
  durationMinutes: z.number().int().positive("Duration must be positive"),
  price: z.number().nonnegative("Price cannot be negative"),
  category: z.string().max(50).optional(),
});

export const updateServiceSchema = createServiceSchema
  .partial()
  .omit({ businessId: true });
```

---

### **Paso 3: Crear Repositorio de Servicio**

Crear archivo `src/repositories/service.repository.ts`:

```typescript
import prisma from "../config/database";
import { Service, Prisma } from "@prisma/client";
import { BaseRepository } from "./base.repository";

export class ServiceRepository extends BaseRepository<Service> {
  protected getModel() {
    return prisma.service;
  }

  async findByBusinessId(
    businessId: string,
    includeInactive = false
  ): Promise<Service[]> {
    return await prisma.service.findMany({
      where: {
        businessId,
        ...(includeInactive ? {} : { isActive: true }),
      },
      orderBy: {
        createdAt: "desc",
      },
    });
  }

  async findByIdWithBusiness(id: string): Promise<Service | null> {
    return await prisma.service.findUnique({
      where: { id },
      include: {
        business: {
          select: {
            id: true,
            name: true,
            ownerId: true,
          },
        },
      },
    });
  }
}

export const serviceRepository = new ServiceRepository();
```

---

### **Paso 4: Crear Servicio de Negocio**

Crear archivo `src/services/service.service.ts`:

```typescript
import { serviceRepository } from "../repositories/service.repository";
import { businessRepository } from "../repositories/business.repository";
import { CreateServiceDto, UpdateServiceDto } from "../dto/service";
import { AppError } from "../middleware/error.middleware";
import { logger } from "../config/logger";
import { Service } from "@prisma/client";

export class ServiceService {
  async create(ownerId: string, data: CreateServiceDto): Promise<Service> {
    // Verificar que el negocio existe y pertenece al usuario
    const business = await businessRepository.findById(data.businessId);
    if (!business) {
      throw new AppError(404, "Business not found");
    }

    if (business.ownerId !== ownerId) {
      throw new AppError(
        403,
        "You do not have permission to create services for this business"
      );
    }

    logger.info(
      `Creating service: ${data.name} for business: ${data.businessId}`
    );

    const service = await serviceRepository.create({
      ...data,
      isActive: true,
    });

    logger.info(`Service created: ${service.id}`);
    return service;
  }

  async findByBusinessId(
    businessId: string,
    ownerId: string
  ): Promise<Service[]> {
    // Verificar permisos
    const business = await businessRepository.findById(businessId);
    if (!business || business.ownerId !== ownerId) {
      throw new AppError(
        403,
        "You do not have permission to access these services"
      );
    }

    return await serviceRepository.findByBusinessId(businessId);
  }

  async findById(id: string, ownerId: string): Promise<Service> {
    const service = await serviceRepository.findByIdWithBusiness(id);
    if (!service) {
      throw new AppError(404, "Service not found");
    }

    if (service.business.ownerId !== ownerId) {
      throw new AppError(
        403,
        "You do not have permission to access this service"
      );
    }

    return service;
  }

  async update(
    id: string,
    ownerId: string,
    data: UpdateServiceDto
  ): Promise<Service> {
    await this.findById(id, ownerId); // Verifica permisos

    logger.info(`Updating service: ${id}`);
    const updated = await serviceRepository.update(id, data);
    logger.info(`Service updated: ${id}`);

    return updated;
  }

  async delete(id: string, ownerId: string): Promise<void> {
    const service = await this.findById(id, ownerId);

    // Verificar si tiene citas futuras
    const futureAppointments = await prisma.appointment.count({
      where: {
        serviceId: id,
        date: { gte: new Date() },
        status: { not: "CANCELLED" },
      },
    });

    if (futureAppointments > 0) {
      throw new AppError(
        400,
        "Cannot delete service with future appointments. Deactivate it instead."
      );
    }

    logger.info(`Deleting service: ${id}`);
    await serviceRepository.update(id, { isActive: false });
  }
}

export const serviceService = new ServiceService();
```

**Nota**: Agregar import de prisma al inicio del archivo.

---

### **Paso 5: Crear Controlador y Rutas**

Crear archivo `src/controllers/service.controller.ts` y `src/routes/service.routes.ts` siguiendo el mismo patrón que Business.

---

## ✅ Verificación Final

- [ ] CRUD completo funcionando
- [ ] Validaciones de negocio implementadas
- [ ] Tests pasando

---

## 📝 Entregables del Día

1. ✅ CRUD completo de servicios
2. ✅ Validaciones de permisos
3. ✅ Relación con negocios
4. ✅ Tests completos

---

## 🎯 Próximo Día

**Día 8**: API de Citas (Appointments)

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_
