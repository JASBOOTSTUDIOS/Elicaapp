# 🔍 Día 11: Búsqueda y Filtros Avanzados

## 🎯 Objetivo del Día

Implementar sistema completo de búsqueda y filtros avanzados para negocios, servicios y citas, incluyendo búsqueda por texto, filtros múltiples y ordenamiento.

---

## ✅ Checklist de Tareas

- [ ] Crear DTOs de búsqueda y filtros
- [ ] Implementar búsqueda de texto completo
- [ ] Crear filtros avanzados para negocios
- [ ] Crear filtros avanzados para servicios
- [ ] Crear filtros avanzados para citas
- [ ] Implementar ordenamiento dinámico
- [ ] Crear tests completos

---

## 📋 Pasos Detallados

### **Paso 1: Crear DTOs de Búsqueda**

Crear archivo `src/dto/search/business-search.dto.ts`:

```typescript
export interface BusinessSearchDto {
  search?: string; // Búsqueda por texto (nombre, descripción, categoría)
  category?: string;
  city?: string;
  state?: string;
  country?: string;
  minRating?: number;
  maxRating?: number;
  isActive?: boolean;
  hasServices?: boolean;
  sortBy?: "name" | "rating" | "createdAt" | "appointmentCount";
  sortOrder?: "asc" | "desc";
  page?: number;
  limit?: number;
}
```

Crear archivo `src/dto/search/service-search.dto.ts`:

```typescript
export interface ServiceSearchDto {
  search?: string; // Búsqueda por texto (nombre, descripción)
  businessId?: string;
  category?: string;
  minPrice?: number;
  maxPrice?: number;
  minDuration?: number; // en minutos
  maxDuration?: number; // en minutos
  isActive?: boolean;
  sortBy?: "name" | "price" | "duration" | "createdAt";
  sortOrder?: "asc" | "desc";
  page?: number;
  limit?: number;
}
```

Crear archivo `src/dto/search/appointment-search.dto.ts`:

```typescript
export interface AppointmentSearchDto {
  search?: string; // Búsqueda por nombre de cliente, servicio, negocio
  businessId?: string;
  userId?: string;
  serviceId?: string;
  status?: string;
  startDate?: string; // ISO string
  endDate?: string; // ISO string
  minAmount?: number;
  maxAmount?: number;
  sortBy?: "date" | "amount" | "createdAt";
  sortOrder?: "asc" | "desc";
  page?: number;
  limit?: number;
}
```

### **Paso 2: Crear Utilidad de Búsqueda**

Crear archivo `src/utils/search.util.ts`:

```typescript
export class SearchUtil {
  /**
   * Crea un filtro de búsqueda de texto para Prisma
   * Busca en múltiples campos usando OR
   */
  static createTextSearchFilter(
    search: string,
    fields: string[]
  ): { OR: Array<{ [key: string]: { contains: string; mode: "insensitive" } }> } | undefined {
    if (!search || search.trim() === "") {
      return undefined;
    }

    const searchTerm = search.trim();

    return {
      OR: fields.map((field) => ({
        [field]: {
          contains: searchTerm,
          mode: "insensitive" as const,
        },
      })),
    };
  }

  /**
   * Crea un filtro de rango numérico
   */
  static createRangeFilter(
    min?: number,
    max?: number
  ): { gte?: number; lte?: number } | undefined {
    if (min === undefined && max === undefined) {
      return undefined;
    }

    const filter: { gte?: number; lte?: number } = {};
    if (min !== undefined) filter.gte = min;
    if (max !== undefined) filter.lte = max;

    return filter;
  }

  /**
   * Crea un filtro de rango de fechas
   */
  static createDateRangeFilter(
    startDate?: string,
    endDate?: string
  ): { gte?: Date; lte?: Date } | undefined {
    if (!startDate && !endDate) {
      return undefined;
    }

    const filter: { gte?: Date; lte?: Date } = {};
    if (startDate) filter.gte = new Date(startDate);
    if (endDate) {
      const end = new Date(endDate);
      end.setHours(23, 59, 59, 999); // Incluir todo el día
      filter.lte = end;
    }

    return filter;
  }

  /**
   * Normaliza el término de búsqueda (elimina caracteres especiales, etc.)
   */
  static normalizeSearchTerm(search: string): string {
    return search
      .trim()
      .replace(/[^\w\s]/gi, "") // Eliminar caracteres especiales
      .replace(/\s+/g, " "); // Normalizar espacios
  }
}
```

### **Paso 3: Actualizar Repositorio de Negocios**

Actualizar `src/repositories/business.repository.ts`:

```typescript
// ... existing imports ...
import { BusinessSearchDto } from "../dto/search/business-search.dto";
import { SearchUtil } from "../utils/search.util";
import { Prisma } from "@prisma/client";

export class BusinessRepository extends BaseRepository<Business> {
  // ... existing methods ...

  async search(query: BusinessSearchDto) {
    const {
      page = 1,
      limit = 10,
      search,
      category,
      city,
      state,
      country,
      minRating,
      maxRating,
      isActive,
      hasServices,
      sortBy = "createdAt",
      sortOrder = "desc",
    } = query;

    const skip = (page - 1) * limit;

    // Construir filtros
    const where: Prisma.BusinessWhereInput = {};

    // Búsqueda de texto
    if (search) {
      const textSearch = SearchUtil.createTextSearchFilter(search, [
        "name",
        "description",
        "category",
      ]);
      if (textSearch) {
        where.AND = where.AND || [];
        where.AND.push(textSearch);
      }
    }

    // Filtros específicos
    if (category) {
      where.category = category;
    }

    if (city) {
      where.city = { contains: city, mode: "insensitive" };
    }

    if (state) {
      where.state = { contains: state, mode: "insensitive" };
    }

    if (country) {
      where.country = { contains: country, mode: "insensitive" };
    }

    if (minRating !== undefined || maxRating !== undefined) {
      // Nota: Si tienes un campo de rating calculado, ajusta esto
      // Por ahora, asumimos que hay un campo rating en el modelo
      const ratingFilter = SearchUtil.createRangeFilter(minRating, maxRating);
      if (ratingFilter) {
        where.rating = ratingFilter as any;
      }
    }

    if (isActive !== undefined) {
      where.isActive = isActive;
    }

    // Filtro de servicios disponibles
    if (hasServices === true) {
      where.services = {
        some: {
          isActive: true,
        },
      };
    }

    // Ordenamiento
    const orderBy: Prisma.BusinessOrderByWithRelationInput = {};
    if (sortBy === "name") {
      orderBy.name = sortOrder;
    } else if (sortBy === "rating") {
      orderBy.rating = sortOrder as any;
    } else if (sortBy === "appointmentCount") {
      // Ordenar por cantidad de citas (requiere agregación)
      orderBy.appointments = {
        _count: sortOrder,
      };
    } else {
      orderBy.createdAt = sortOrder;
    }

    // Ejecutar query
    const [businesses, total] = await Promise.all([
      prisma.business.findMany({
        where,
        skip,
        take: limit,
        orderBy,
        include: {
          owner: {
            select: {
              id: true,
              email: true,
              fullName: true,
            },
          },
          _count: {
            select: {
              services: true,
              appointments: true,
            },
          },
        },
      }),
      prisma.business.count({ where }),
    ]);

    return {
      data: businesses,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }
}
```

### **Paso 4: Actualizar Repositorio de Servicios**

Actualizar `src/repositories/service.repository.ts`:

```typescript
// ... existing imports ...
import { ServiceSearchDto } from "../dto/search/service-search.dto";
import { SearchUtil } from "../utils/search.util";
import { Prisma } from "@prisma/client";

export class ServiceRepository extends BaseRepository<Service> {
  // ... existing methods ...

  async search(query: ServiceSearchDto) {
    const {
      page = 1,
      limit = 10,
      search,
      businessId,
      category,
      minPrice,
      maxPrice,
      minDuration,
      maxDuration,
      isActive,
      sortBy = "createdAt",
      sortOrder = "desc",
    } = query;

    const skip = (page - 1) * limit;

    const where: Prisma.ServiceWhereInput = {};

    // Búsqueda de texto
    if (search) {
      const textSearch = SearchUtil.createTextSearchFilter(search, [
        "name",
        "description",
        "category",
      ]);
      if (textSearch) {
        where.AND = where.AND || [];
        where.AND.push(textSearch);
      }
    }

    // Filtros específicos
    if (businessId) {
      where.businessId = businessId;
    }

    if (category) {
      where.category = category;
    }

    // Filtro de precio
    if (minPrice !== undefined || maxPrice !== undefined) {
      const priceFilter = SearchUtil.createRangeFilter(minPrice, maxPrice);
      if (priceFilter) {
        where.price = priceFilter;
      }
    }

    // Filtro de duración
    if (minDuration !== undefined || maxDuration !== undefined) {
      const durationFilter = SearchUtil.createRangeFilter(
        minDuration,
        maxDuration
      );
      if (durationFilter) {
        where.durationMinutes = durationFilter;
      }
    }

    if (isActive !== undefined) {
      where.isActive = isActive;
    }

    // Ordenamiento
    const orderBy: Prisma.ServiceOrderByWithRelationInput = {};
    if (sortBy === "name") {
      orderBy.name = sortOrder;
    } else if (sortBy === "price") {
      orderBy.price = sortOrder;
    } else if (sortBy === "duration") {
      orderBy.durationMinutes = sortOrder;
    } else {
      orderBy.createdAt = sortOrder;
    }

    const [services, total] = await Promise.all([
      prisma.service.findMany({
        where,
        skip,
        take: limit,
        orderBy,
        include: {
          business: {
            select: {
              id: true,
              name: true,
              city: true,
              state: true,
            },
          },
        },
      }),
      prisma.service.count({ where }),
    ]);

    return {
      data: services,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }
}
```

### **Paso 5: Actualizar Repositorio de Citas**

Actualizar `src/repositories/appointment.repository.ts`:

```typescript
// ... existing imports ...
import { AppointmentSearchDto } from "../dto/search/appointment-search.dto";
import { SearchUtil } from "../utils/search.util";
import { Prisma } from "@prisma/client";

export class AppointmentRepository extends BaseRepository<Appointment> {
  // ... existing methods ...

  async search(query: AppointmentSearchDto) {
    const {
      page = 1,
      limit = 10,
      search,
      businessId,
      userId,
      serviceId,
      status,
      startDate,
      endDate,
      minAmount,
      maxAmount,
      sortBy = "date",
      sortOrder = "desc",
    } = query;

    const skip = (page - 1) * limit;

    const where: Prisma.AppointmentWhereInput = {};

    // Búsqueda de texto (buscar en relaciones)
    if (search) {
      where.OR = [
        {
          user: {
            OR: [
              { fullName: { contains: search, mode: "insensitive" } },
              { email: { contains: search, mode: "insensitive" } },
            ],
          },
        },
        {
          service: {
            name: { contains: search, mode: "insensitive" },
          },
        },
        {
          business: {
            name: { contains: search, mode: "insensitive" },
          },
        },
      ];
    }

    // Filtros específicos
    if (businessId) {
      where.businessId = businessId;
    }

    if (userId) {
      where.userId = userId;
    }

    if (serviceId) {
      where.serviceId = serviceId;
    }

    if (status) {
      where.status = status as any;
    }

    // Filtro de rango de fechas
    if (startDate || endDate) {
      const dateFilter = SearchUtil.createDateRangeFilter(startDate, endDate);
      if (dateFilter) {
        where.date = dateFilter;
      }
    }

    // Filtro de monto
    if (minAmount !== undefined || maxAmount !== undefined) {
      const amountFilter = SearchUtil.createRangeFilter(minAmount, maxAmount);
      if (amountFilter) {
        where.amount = amountFilter;
      }
    }

    // Ordenamiento
    const orderBy: Prisma.AppointmentOrderByWithRelationInput = {};
    if (sortBy === "date") {
      orderBy.date = sortOrder;
    } else if (sortBy === "amount") {
      orderBy.amount = sortOrder;
    } else {
      orderBy.createdAt = sortOrder;
    }

    const [appointments, total] = await Promise.all([
      prisma.appointment.findMany({
        where,
        skip,
        take: limit,
        orderBy,
        include: {
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
              price: true,
            },
          },
          business: {
            select: {
              id: true,
              name: true,
            },
          },
        },
      }),
      prisma.appointment.count({ where }),
    ]);

    return {
      data: appointments,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }
}
```

### **Paso 6: Crear Servicios de Búsqueda**

Crear archivo `src/services/search.service.ts`:

```typescript
import { businessRepository } from "../repositories/business.repository";
import { serviceRepository } from "../repositories/service.repository";
import { appointmentRepository } from "../repositories/appointment.repository";
import { BusinessSearchDto } from "../dto/search/business-search.dto";
import { ServiceSearchDto } from "../dto/search/service-search.dto";
import { AppointmentSearchDto } from "../dto/search/appointment-search.dto";
import { logger } from "../config/logger";

export class SearchService {
  async searchBusinesses(query: BusinessSearchDto) {
    logger.info("Searching businesses:", query);
    return await businessRepository.search(query);
  }

  async searchServices(query: ServiceSearchDto) {
    logger.info("Searching services:", query);
    return await serviceRepository.search(query);
  }

  async searchAppointments(query: AppointmentSearchDto) {
    logger.info("Searching appointments:", query);
    return await appointmentRepository.search(query);
  }

  /**
   * Búsqueda global que busca en negocios, servicios y citas
   */
  async globalSearch(searchTerm: string, userId?: string) {
    logger.info(`Global search: ${searchTerm}`);

    const [businesses, services, appointments] = await Promise.all([
      businessRepository.search({
        search: searchTerm,
        limit: 5,
      }),
      serviceRepository.search({
        search: searchTerm,
        limit: 5,
      }),
      appointmentRepository.search({
        search: searchTerm,
        userId,
        limit: 5,
      }),
    ]);

    return {
      businesses: businesses.data,
      services: services.data,
      appointments: appointments.data,
    };
  }
}

export const searchService = new SearchService();
```

### **Paso 7: Crear Controladores de Búsqueda**

Crear archivo `src/controllers/search.controller.ts`:

```typescript
import { Request, Response } from "express";
import { searchService } from "../services/search.service";
import { BusinessSearchDto } from "../dto/search/business-search.dto";
import { ServiceSearchDto } from "../dto/search/service-search.dto";
import { AppointmentSearchDto } from "../dto/search/appointment-search.dto";
import { logger } from "../config/logger";

export class SearchController {
  async searchBusinesses(req: Request, res: Response): Promise<void> {
    try {
      const query: BusinessSearchDto = {
        search: req.query.search as string,
        category: req.query.category as string,
        city: req.query.city as string,
        state: req.query.state as string,
        country: req.query.country as string,
        minRating: req.query.minRating
          ? parseFloat(req.query.minRating as string)
          : undefined,
        maxRating: req.query.maxRating
          ? parseFloat(req.query.maxRating as string)
          : undefined,
        isActive:
          req.query.isActive === "true"
            ? true
            : req.query.isActive === "false"
            ? false
            : undefined,
        hasServices:
          req.query.hasServices === "true"
            ? true
            : req.query.hasServices === "false"
            ? false
            : undefined,
        sortBy: (req.query.sortBy as any) || "createdAt",
        sortOrder: (req.query.sortOrder as any) || "desc",
        page: req.query.page ? parseInt(req.query.page as string) : 1,
        limit: req.query.limit ? parseInt(req.query.limit as string) : 10,
      };

      const result = await searchService.searchBusinesses(query);

      res.json({
        success: true,
        data: result.data,
        pagination: result.pagination,
      });
    } catch (error: any) {
      logger.error("Error searching businesses:", error);
      res.status(error.statusCode || 500).json({
        success: false,
        message: error.message || "Error searching businesses",
      });
    }
  }

  async searchServices(req: Request, res: Response): Promise<void> {
    try {
      const query: ServiceSearchDto = {
        search: req.query.search as string,
        businessId: req.query.businessId as string,
        category: req.query.category as string,
        minPrice: req.query.minPrice
          ? parseFloat(req.query.minPrice as string)
          : undefined,
        maxPrice: req.query.maxPrice
          ? parseFloat(req.query.maxPrice as string)
          : undefined,
        minDuration: req.query.minDuration
          ? parseInt(req.query.minDuration as string)
          : undefined,
        maxDuration: req.query.maxDuration
          ? parseInt(req.query.maxDuration as string)
          : undefined,
        isActive:
          req.query.isActive === "true"
            ? true
            : req.query.isActive === "false"
            ? false
            : undefined,
        sortBy: (req.query.sortBy as any) || "createdAt",
        sortOrder: (req.query.sortOrder as any) || "desc",
        page: req.query.page ? parseInt(req.query.page as string) : 1,
        limit: req.query.limit ? parseInt(req.query.limit as string) : 10,
      };

      const result = await searchService.searchServices(query);

      res.json({
        success: true,
        data: result.data,
        pagination: result.pagination,
      });
    } catch (error: any) {
      logger.error("Error searching services:", error);
      res.status(error.statusCode || 500).json({
        success: false,
        message: error.message || "Error searching services",
      });
    }
  }

  async searchAppointments(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user?.id; // Del middleware de autenticación

      const query: AppointmentSearchDto = {
        search: req.query.search as string,
        businessId: req.query.businessId as string,
        userId: req.query.userId as string || userId,
        serviceId: req.query.serviceId as string,
        status: req.query.status as string,
        startDate: req.query.startDate as string,
        endDate: req.query.endDate as string,
        minAmount: req.query.minAmount
          ? parseFloat(req.query.minAmount as string)
          : undefined,
        maxAmount: req.query.maxAmount
          ? parseFloat(req.query.maxAmount as string)
          : undefined,
        sortBy: (req.query.sortBy as any) || "date",
        sortOrder: (req.query.sortOrder as any) || "desc",
        page: req.query.page ? parseInt(req.query.page as string) : 1,
        limit: req.query.limit ? parseInt(req.query.limit as string) : 10,
      };

      const result = await searchService.searchAppointments(query);

      res.json({
        success: true,
        data: result.data,
        pagination: result.pagination,
      });
    } catch (error: any) {
      logger.error("Error searching appointments:", error);
      res.status(error.statusCode || 500).json({
        success: false,
        message: error.message || "Error searching appointments",
      });
    }
  }

  async globalSearch(req: Request, res: Response): Promise<void> {
    try {
      const searchTerm = req.query.q as string;
      const userId = req.user?.id;

      if (!searchTerm || searchTerm.trim() === "") {
        res.status(400).json({
          success: false,
          message: "Search term is required",
        });
        return;
      }

      const result = await searchService.globalSearch(searchTerm, userId);

      res.json({
        success: true,
        data: result,
      });
    } catch (error: any) {
      logger.error("Error in global search:", error);
      res.status(error.statusCode || 500).json({
        success: false,
        message: error.message || "Error in global search",
      });
    }
  }
}

export const searchController = new SearchController();
```

### **Paso 8: Crear Rutas de Búsqueda**

Crear archivo `src/routes/search.routes.ts`:

```typescript
import { Router } from "express";
import { searchController } from "../controllers/search.controller";
import { authMiddleware } from "../middleware/auth.middleware";

const router = Router();

// Búsqueda global (pública)
router.get("/global", searchController.globalSearch.bind(searchController));

// Búsqueda de negocios (pública)
router.get("/businesses", searchController.searchBusinesses.bind(searchController));

// Búsqueda de servicios (pública)
router.get("/services", searchController.searchServices.bind(searchController));

// Búsqueda de citas (requiere autenticación)
router.use(authMiddleware);
router.get("/appointments", searchController.searchAppointments.bind(searchController));

export default router;
```

### **Paso 9: Registrar Rutas en App**

Actualizar `src/app.ts`:

```typescript
// ... existing imports ...
import searchRoutes from "./routes/search.routes";

// ... existing code ...

app.use("/api/search", searchRoutes);

// ... existing code ...
```

### **Paso 10: Crear Validadores Zod**

Crear archivo `src/validators/search.validator.ts`:

```typescript
import { z } from "zod";

export const businessSearchSchema = z.object({
  search: z.string().optional(),
  category: z.string().optional(),
  city: z.string().optional(),
  state: z.string().optional(),
  country: z.string().optional(),
  minRating: z.number().min(0).max(5).optional(),
  maxRating: z.number().min(0).max(5).optional(),
  isActive: z.boolean().optional(),
  hasServices: z.boolean().optional(),
  sortBy: z.enum(["name", "rating", "createdAt", "appointmentCount"]).optional(),
  sortOrder: z.enum(["asc", "desc"]).optional(),
  page: z.number().int().positive().optional(),
  limit: z.number().int().positive().max(100).optional(),
});

export const serviceSearchSchema = z.object({
  search: z.string().optional(),
  businessId: z.string().uuid().optional(),
  category: z.string().optional(),
  minPrice: z.number().nonnegative().optional(),
  maxPrice: z.number().nonnegative().optional(),
  minDuration: z.number().int().positive().optional(),
  maxDuration: z.number().int().positive().optional(),
  isActive: z.boolean().optional(),
  sortBy: z.enum(["name", "price", "duration", "createdAt"]).optional(),
  sortOrder: z.enum(["asc", "desc"]).optional(),
  page: z.number().int().positive().optional(),
  limit: z.number().int().positive().max(100).optional(),
});

export const appointmentSearchSchema = z.object({
  search: z.string().optional(),
  businessId: z.string().uuid().optional(),
  userId: z.string().uuid().optional(),
  serviceId: z.string().uuid().optional(),
  status: z.string().optional(),
  startDate: z.string().datetime().optional(),
  endDate: z.string().datetime().optional(),
  minAmount: z.number().nonnegative().optional(),
  maxAmount: z.number().nonnegative().optional(),
  sortBy: z.enum(["date", "amount", "createdAt"]).optional(),
  sortOrder: z.enum(["asc", "desc"]).optional(),
  page: z.number().int().positive().optional(),
  limit: z.number().int().positive().max(100).optional(),
});
```

### **Paso 11: Crear Tests**

Crear archivo `tests/services/search.service.test.ts`:

```typescript
import { SearchService } from "../../src/services/search.service";
import { businessRepository } from "../../src/repositories/business.repository";
import { serviceRepository } from "../../src/repositories/service.repository";
import { appointmentRepository } from "../../src/repositories/appointment.repository";

jest.mock("../../src/repositories/business.repository");
jest.mock("../../src/repositories/service.repository");
jest.mock("../../src/repositories/appointment.repository");

describe("SearchService", () => {
  let searchService: SearchService;

  beforeEach(() => {
    searchService = new SearchService();
    jest.clearAllMocks();
  });

  describe("searchBusinesses", () => {
    it("should search businesses with filters", async () => {
      // Arrange
      const query = {
        search: "salon",
        city: "Madrid",
        page: 1,
        limit: 10,
      };

      const mockResult = {
        data: [],
        pagination: {
          page: 1,
          limit: 10,
          total: 0,
          totalPages: 0,
        },
      };

      (businessRepository.search as jest.Mock).mockResolvedValue(mockResult);

      // Act
      const result = await searchService.searchBusinesses(query);

      // Assert
      expect(result).toEqual(mockResult);
      expect(businessRepository.search).toHaveBeenCalledWith(query);
    });
  });

  describe("globalSearch", () => {
    it("should search across all entities", async () => {
      // Arrange
      const searchTerm = "test";

      (businessRepository.search as jest.Mock).mockResolvedValue({
        data: [],
        pagination: {},
      });
      (serviceRepository.search as jest.Mock).mockResolvedValue({
        data: [],
        pagination: {},
      });
      (appointmentRepository.search as jest.Mock).mockResolvedValue({
        data: [],
        pagination: {},
      });

      // Act
      const result = await searchService.globalSearch(searchTerm);

      // Assert
      expect(result).toHaveProperty("businesses");
      expect(result).toHaveProperty("services");
      expect(result).toHaveProperty("appointments");
    });
  });
});
```

---

## ✅ Verificación Final

- [ ] Búsqueda de texto funcionando
- [ ] Filtros múltiples funcionando
- [ ] Ordenamiento dinámico funcionando
- [ ] Búsqueda global implementada
- [ ] Tests pasando

---

## 📝 Entregables del Día

1. ✅ Sistema de búsqueda de texto completo
2. ✅ Filtros avanzados para negocios
3. ✅ Filtros avanzados para servicios
4. ✅ Filtros avanzados para citas
5. ✅ Búsqueda global
6. ✅ Ordenamiento dinámico
7. ✅ Tests completos

---

## 🎯 Próximo Día

**Día 12**: Upload de Archivos e Imágenes

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_

