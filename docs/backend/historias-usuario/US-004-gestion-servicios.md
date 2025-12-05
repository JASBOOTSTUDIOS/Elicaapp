# 💇 US-004: Gestión de Servicios

## 📋 Información General

- **Épica**: Servicios
- **Prioridad**: P0 (Crítica)
- **Story Points**: 5
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-003 (Crear Negocio)

---

## 📖 Historia de Usuario

**Como** propietario de negocio  
**Quiero** poder crear, editar y eliminar servicios con precio y duración  
**Para** que mis clientes puedan reservar citas

---

## ✅ Criterios de Aceptación

- [ ] Puedo crear un servicio con nombre, precio, duración y categoría
- [ ] Puedo editar un servicio existente
- [ ] Puedo desactivar un servicio sin borrarlo
- [ ] Las validaciones de precio y duración funcionan
- [ ] Puedo listar servicios filtrados por estado/categoría
- [ ] Solo el dueño del negocio puede gestionar sus servicios
- [ ] No se puede borrar un servicio usado en citas futuras

---

## 🎯 Reglas de Negocio

1. **Precio**: Debe ser >= 0
2. **Duración**: Debe ser > 0 (en minutos)
3. **Soft Delete**: Los servicios se desactivan, no se borran
4. **Protección**: No se puede borrar servicio con citas futuras
5. **Permisos**: Solo el owner del negocio puede gestionar servicios

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear DTOs**

**Archivo**: `src/dto/service/create-service.dto.ts`

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

**Archivo**: `src/dto/service/update-service.dto.ts`

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

**Criterios de verificación**:
- [ ] DTOs creados
- [ ] Campos opcionales marcados correctamente

---

### **Tarea 2: Crear Validador**

**Archivo**: `src/validators/service.validator.ts`

```typescript
import { z } from 'zod';

export const createServiceSchema = z.object({
  businessId: z.string().uuid('Invalid business ID'),
  name: z.string().min(2, 'Name must be at least 2 characters').max(100),
  description: z.string().max(500).optional(),
  durationMinutes: z.number().int().positive('Duration must be positive'),
  price: z.number().nonnegative('Price cannot be negative'),
  category: z.string().max(50).optional(),
});

export const updateServiceSchema = createServiceSchema
  .partial()
  .omit({ businessId: true });

export type CreateServiceInput = z.infer<typeof createServiceSchema>;
export type UpdateServiceInput = z.infer<typeof updateServiceSchema>;
```

**Tests del validador**:

```typescript
describe('createServiceSchema', () => {
  it('should validate correct service data', () => {
    const validData = {
      businessId: '123e4567-e89b-12d3-a456-426614174000',
      name: 'Haircut',
      durationMinutes: 30,
      price: 25.00,
      category: 'Hair',
    };
    expect(() => createServiceSchema.parse(validData)).not.toThrow();
  });

  it('should reject negative price', () => {
    const invalidData = {
      businessId: '123e4567-e89b-12d3-a456-426614174000',
      name: 'Haircut',
      durationMinutes: 30,
      price: -10,
    };
    expect(() => createServiceSchema.parse(invalidData)).toThrow();
  });

  it('should reject zero duration', () => {
    const invalidData = {
      businessId: '123e4567-e89b-12d3-a456-426614174000',
      name: 'Haircut',
      durationMinutes: 0,
      price: 25.00,
    };
    expect(() => createServiceSchema.parse(invalidData)).toThrow();
  });
});
```

---

### **Tarea 3: Crear Repositorio de Servicio**

**Archivo**: `src/repositories/service.repository.ts`

```typescript
import prisma from '../config/database';
import { Service, Prisma } from '@prisma/client';
import { BaseRepository } from './base.repository';

export class ServiceRepository extends BaseRepository<Service> {
  protected getModel() {
    return prisma.service;
  }

  async findByBusinessId(businessId: string, includeInactive = false): Promise<Service[]> {
    return await prisma.service.findMany({
      where: {
        businessId,
        ...(includeInactive ? {} : { isActive: true }),
      },
      orderBy: {
        createdAt: 'desc',
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

  async findActiveByBusinessId(businessId: string): Promise<Service[]> {
    return await prisma.service.findMany({
      where: {
        businessId,
        isActive: true,
      },
      orderBy: {
        name: 'asc',
      },
    });
  }

  async countFutureAppointments(serviceId: string): Promise<number> {
    return await prisma.appointment.count({
      where: {
        serviceId,
        date: { gte: new Date() },
        status: { not: 'CANCELLED' },
      },
    });
  }
}

export const serviceRepository = new ServiceRepository();
```

**Criterios de verificación**:
- [ ] Repositorio creado
- [ ] Métodos con relaciones implementados
- [ ] Método de conteo de citas futuras implementado

---

### **Tarea 4: Crear Servicio de Negocio**

**Archivo**: `src/services/service.service.ts`

```typescript
import { serviceRepository } from '../repositories/service.repository';
import { businessRepository } from '../repositories/business.repository';
import { CreateServiceDto, UpdateServiceDto } from '../dto/service';
import { AppError } from '../middleware/error.middleware';
import { logger } from '../config/logger';
import { Service } from '@prisma/client';
import prisma from '../config/database';

export class ServiceService {
  async create(ownerId: string, data: CreateServiceDto): Promise<Service> {
    logger.info(`Creating service: ${data.name} for business: ${data.businessId}`);

    // 1. Verificar que el negocio existe y pertenece al usuario
    const business = await businessRepository.findById(data.businessId);
    if (!business) {
      throw new AppError(404, 'Business not found');
    }

    if (business.ownerId !== ownerId) {
      throw new AppError(
        403,
        'You do not have permission to create services for this business'
      );
    }

    // 2. Verificar que el negocio está activo
    if (!business.isActive) {
      throw new AppError(400, 'Cannot create services for inactive business');
    }

    // 3. Crear servicio
    const service = await serviceRepository.create({
      ...data,
      isActive: true,
    });

    logger.info(`Service created: ${service.id}`);
    return service;
  }

  async findByBusinessId(businessId: string, ownerId: string): Promise<Service[]> {
    // Verificar permisos
    const business = await businessRepository.findById(businessId);
    if (!business || business.ownerId !== ownerId) {
      throw new AppError(403, 'You do not have permission to access these services');
    }

    return await serviceRepository.findActiveByBusinessId(businessId);
  }

  async findById(id: string, ownerId: string): Promise<Service> {
    const service = await serviceRepository.findByIdWithBusiness(id);
    if (!service) {
      throw new AppError(404, 'Service not found');
    }

    // Verificar permisos
    if (service.business.ownerId !== ownerId) {
      throw new AppError(403, 'You do not have permission to access this service');
    }

    return service;
  }

  async update(id: string, ownerId: string, data: UpdateServiceDto): Promise<Service> {
    // Verificar permisos
    await this.findById(id, ownerId);

    logger.info(`Updating service: ${id}`);
    const updated = await serviceRepository.update(id, data);
    logger.info(`Service updated: ${id}`);

    return updated;
  }

  async delete(id: string, ownerId: string): Promise<void> {
    // Verificar permisos
    const service = await this.findById(id, ownerId);

    // Verificar si tiene citas futuras
    const futureAppointments = await serviceRepository.countFutureAppointments(id);

    if (futureAppointments > 0) {
      throw new AppError(
        400,
        'Cannot delete service with future appointments. Deactivate it instead.'
      );
    }

    logger.info(`Deleting service: ${id}`);
    // Soft delete
    await serviceRepository.update(id, { isActive: false });
    logger.info(`Service deleted: ${id}`);
  }

  async deactivate(id: string, ownerId: string): Promise<Service> {
    // Verificar permisos
    await this.findById(id, ownerId);

    logger.info(`Deactivating service: ${id}`);
    const updated = await serviceRepository.update(id, { isActive: false });
    logger.info(`Service deactivated: ${id}`);

    return updated;
  }
}

export const serviceService = new ServiceService();
```

**Pasos detallados**:

1. **Crear servicio**:
   - Verificar que el negocio existe
   - Verificar permisos (ownerId)
   - Verificar que el negocio está activo
   - Crear servicio con `isActive: true`

2. **Listar servicios**:
   - Verificar permisos
   - Retornar solo servicios activos del negocio

3. **Actualizar servicio**:
   - Verificar permisos
   - Actualizar campos permitidos

4. **Eliminar servicio**:
   - Verificar permisos
   - Verificar que no tenga citas futuras
   - Soft delete (isActive: false)

**Criterios de verificación**:
- [ ] Todos los métodos implementados
- [ ] Validaciones de permisos funcionando
- [ ] Protección contra borrado con citas futuras
- [ ] Logs implementados

---

### **Tarea 5: Crear Controlador**

**Archivo**: `src/controllers/service.controller.ts`

```typescript
import { Request, Response, NextFunction } from 'express';
import { serviceService } from '../services/service.service';
import { logger } from '../config/logger';

export class ServiceController {
  async create(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ success: false, message: 'Unauthorized' });
        return;
      }

      const service = await serviceService.create(req.user.id, req.body);

      res.status(201).json({
        success: true,
        data: service,
        message: 'Service created successfully',
      });
    } catch (error) {
      logger.error('Create service error:', error);
      next(error);
    }
  }

  async findByBusiness(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ success: false, message: 'Unauthorized' });
        return;
      }

      const { businessId } = req.params;
      const services = await serviceService.findByBusinessId(businessId, req.user.id);

      res.status(200).json({
        success: true,
        data: services,
      });
    } catch (error) {
      logger.error('Find services by business error:', error);
      next(error);
    }
  }

  async findById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ success: false, message: 'Unauthorized' });
        return;
      }

      const { id } = req.params;
      const service = await serviceService.findById(id, req.user.id);

      res.status(200).json({
        success: true,
        data: service,
      });
    } catch (error) {
      logger.error('Find service by id error:', error);
      next(error);
    }
  }

  async update(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ success: false, message: 'Unauthorized' });
        return;
      }

      const { id } = req.params;
      const service = await serviceService.update(id, req.user.id, req.body);

      res.status(200).json({
        success: true,
        data: service,
        message: 'Service updated successfully',
      });
    } catch (error) {
      logger.error('Update service error:', error);
      next(error);
    }
  }

  async delete(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ success: false, message: 'Unauthorized' });
        return;
      }

      const { id } = req.params;
      await serviceService.delete(id, req.user.id);

      res.status(200).json({
        success: true,
        message: 'Service deleted successfully',
      });
    } catch (error) {
      logger.error('Delete service error:', error);
      next(error);
    }
  }

  async deactivate(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({ success: false, message: 'Unauthorized' });
        return;
      }

      const { id } = req.params;
      const service = await serviceService.deactivate(id, req.user.id);

      res.status(200).json({
        success: true,
        data: service,
        message: 'Service deactivated successfully',
      });
    } catch (error) {
      logger.error('Deactivate service error:', error);
      next(error);
    }
  }
}

export const serviceController = new ServiceController();
```

---

### **Tarea 6: Crear Rutas**

**Archivo**: `src/routes/service.routes.ts`

```typescript
import { Router } from 'express';
import { serviceController } from '../controllers/service.controller';
import { authMiddleware } from '../middleware/auth.middleware';
import { validate } from '../middleware/validation.middleware';
import {
  createServiceSchema,
  updateServiceSchema,
} from '../validators/service.validator';

const router = Router();

// Todas las rutas requieren autenticación
router.use(authMiddleware);

// Crear servicio
router.post(
  '/',
  validate(createServiceSchema),
  serviceController.create.bind(serviceController)
);

// Listar servicios de un negocio
router.get(
  '/business/:businessId',
  serviceController.findByBusiness.bind(serviceController)
);

// Obtener servicio por ID
router.get(
  '/:id',
  serviceController.findById.bind(serviceController)
);

// Actualizar servicio
router.put(
  '/:id',
  validate(updateServiceSchema),
  serviceController.update.bind(serviceController)
);

// Desactivar servicio
router.patch(
  '/:id/deactivate',
  serviceController.deactivate.bind(serviceController)
);

// Eliminar servicio
router.delete(
  '/:id',
  serviceController.delete.bind(serviceController)
);

export default router;
```

Registrar en `src/app.ts`:

```typescript
import serviceRoutes from './routes/service.routes';

app.use('/api/services', serviceRoutes);
```

---

### **Tarea 7: Crear Tests Completos**

**Archivo**: `tests/integration/service.integration.test.ts`

```typescript
import request from 'supertest';
import app from '../../src/app';
import prisma from '../../src/config/database';
import { passwordUtil } from '../../src/utils/password.util';
import { jwtUtil } from '../../src/utils/jwt.util';

describe('Service API Integration Tests', () => {
  let authToken: string;
  let userId: string;
  let businessId: string;

  beforeAll(async () => {
    await prisma.$connect();
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  beforeEach(async () => {
    // Limpiar BD
    await prisma.appointment.deleteMany();
    await prisma.service.deleteMany();
    await prisma.businessTheme.deleteMany();
    await prisma.business.deleteMany();
    await prisma.user.deleteMany();

    // Crear usuario y negocio
    const user = await prisma.user.create({
      data: {
        email: 'service-owner@example.com',
        password: await passwordUtil.hash('Password123!'),
        role: 'BUSINESS_OWNER',
        isActive: true,
      },
    });

    userId = user.id;
    authToken = jwtUtil.generateAccessToken({
      userId: user.id,
      email: user.email,
      role: user.role,
    });

    const business = await prisma.business.create({
      data: {
        name: 'Test Business',
        type: 'SALON',
        ownerId: userId,
        isActive: true,
      },
    });

    businessId = business.id;
  });

  describe('POST /api/services', () => {
    it('should create a service', async () => {
      const response = await request(app)
        .post('/api/services')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          businessId,
          name: 'Haircut',
          durationMinutes: 30,
          price: 25.00,
          category: 'Hair',
        });

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data.name).toBe('Haircut');
      expect(response.body.data.businessId).toBe(businessId);
    });

    it('should return error for invalid business', async () => {
      const response = await request(app)
        .post('/api/services')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          businessId: 'nonexistent-id',
          name: 'Haircut',
          durationMinutes: 30,
          price: 25.00,
        });

      expect(response.status).toBe(404);
    });
  });

  describe('GET /api/services/business/:businessId', () => {
    beforeEach(async () => {
      await prisma.service.createMany({
        data: [
          {
            businessId,
            name: 'Service 1',
            durationMinutes: 30,
            price: 25.00,
            isActive: true,
          },
          {
            businessId,
            name: 'Service 2',
            durationMinutes: 60,
            price: 50.00,
            isActive: false, // Inactivo
          },
        ],
      });
    });

    it('should return only active services', async () => {
      const response = await request(app)
        .get(`/api/services/business/${businessId}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.length).toBe(1);
      expect(response.body.data[0].isActive).toBe(true);
    });
  });

  describe('DELETE /api/services/:id', () => {
    let serviceId: string;

    beforeEach(async () => {
      const service = await prisma.service.create({
        data: {
          businessId,
          name: 'To Delete',
          durationMinutes: 30,
          price: 25.00,
          isActive: true,
        },
      });
      serviceId = service.id;
    });

    it('should soft delete service without future appointments', async () => {
      const response = await request(app)
        .delete(`/api/services/${serviceId}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);

      // Verificar que está desactivado
      const service = await prisma.service.findUnique({
        where: { id: serviceId },
      });
      expect(service?.isActive).toBe(false);
    });

    it('should return error if service has future appointments', async () => {
      // Crear cita futura
      await prisma.appointment.create({
        data: {
          businessId,
          userId,
          serviceId,
          date: new Date(Date.now() + 86400000), // Mañana
          status: 'CONFIRMED',
        },
      });

      const response = await request(app)
        .delete(`/api/services/${serviceId}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(400);
      expect(response.body.message).toContain('future appointments');
    });
  });
});
```

---

## ✅ Definition of Done

- [ ] CRUD completo implementado
- [ ] Validaciones funcionando
- [ ] Permisos verificados
- [ ] Protección contra borrado con citas futuras
- [ ] Tests unitarios pasando (>80% coverage)
- [ ] Tests de integración pasando
- [ ] Documentación Swagger actualizada
- [ ] Code review aprobado

---

## 🎯 Próxima Historia

**US-005**: Agenda de Citas

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_

