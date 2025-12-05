# 📊 Día 9: Dashboard y Métricas

## 🎯 Objetivo del Día

Implementar endpoints de dashboard con métricas y estadísticas para diferentes roles (dueños de negocio, empleados, clientes).

---

## ✅ Checklist de Tareas

- [ ] Crear DTOs de métricas y estadísticas
- [ ] Crear servicio de dashboard con agregaciones
- [ ] Implementar endpoints por rol
- [ ] Crear controlador y rutas
- [ ] Implementar filtros por período
- [ ] Crear tests completos

---

## 📋 Pasos Detallados

### **Paso 1: Crear DTOs de Dashboard**

Crear archivo `src/dto/dashboard/business-stats.dto.ts`:

```typescript
export interface BusinessStatsDto {
  totalAppointments: number;
  pendingAppointments: number;
  confirmedAppointments: number;
  completedAppointments: number;
  cancelledAppointments: number;
  totalRevenue: number;
  revenueByPeriod: RevenueByPeriod[];
  appointmentsByStatus: AppointmentsByStatus[];
  topServices: TopService[];
  recentAppointments: RecentAppointment[];
  period: {
    start: string;
    end: string;
  };
}

export interface RevenueByPeriod {
  period: string; // "2024-01", "2024-02", etc.
  revenue: number;
  count: number;
}

export interface AppointmentsByStatus {
  status: string;
  count: number;
  percentage: number;
}

export interface TopService {
  serviceId: string;
  serviceName: string;
  count: number;
  revenue: number;
}

export interface RecentAppointment {
  id: string;
  customerName: string;
  serviceName: string;
  date: string;
  status: string;
  amount: number;
}
```

Crear archivo `src/dto/dashboard/user-stats.dto.ts`:

```typescript
export interface UserStatsDto {
  totalAppointments: number;
  upcomingAppointments: number;
  completedAppointments: number;
  cancelledAppointments: number;
  favoriteBusinesses: FavoriteBusiness[];
  upcomingAppointmentsList: UpcomingAppointment[];
  period: {
    start: string;
    end: string;
  };
}

export interface FavoriteBusiness {
  businessId: string;
  businessName: string;
  appointmentCount: number;
  lastAppointmentDate: string;
}

export interface UpcomingAppointment {
  id: string;
  businessName: string;
  serviceName: string;
  date: string;
  status: string;
}
```

Crear archivo `src/dto/dashboard/dashboard-query.dto.ts`:

```typescript
export interface DashboardQueryDto {
  startDate?: string; // ISO string
  endDate?: string; // ISO string
  period?: "today" | "week" | "month" | "year" | "custom";
}
```

### **Paso 2: Crear Utilidad para Períodos**

Crear archivo `src/utils/period.util.ts`:

```typescript
export interface Period {
  start: Date;
  end: Date;
}

export class PeriodUtil {
  static getPeriod(
    periodType: string,
    startDate?: string,
    endDate?: string
  ): Period {
    const now = new Date();
    let start: Date;
    let end: Date = new Date(now);

    switch (periodType) {
      case "today":
        start = new Date(now);
        start.setHours(0, 0, 0, 0);
        end.setHours(23, 59, 59, 999);
        break;

      case "week":
        start = new Date(now);
        start.setDate(now.getDate() - 7);
        start.setHours(0, 0, 0, 0);
        break;

      case "month":
        start = new Date(now.getFullYear(), now.getMonth(), 1);
        start.setHours(0, 0, 0, 0);
        end = new Date(now.getFullYear(), now.getMonth() + 1, 0);
        end.setHours(23, 59, 59, 999);
        break;

      case "year":
        start = new Date(now.getFullYear(), 0, 1);
        start.setHours(0, 0, 0, 0);
        end = new Date(now.getFullYear(), 11, 31);
        end.setHours(23, 59, 59, 999);
        break;

      case "custom":
        if (!startDate || !endDate) {
          throw new Error(
            "Start date and end date are required for custom period"
          );
        }
        start = new Date(startDate);
        end = new Date(endDate);
        break;

      default:
        // Default to current month
        start = new Date(now.getFullYear(), now.getMonth(), 1);
        start.setHours(0, 0, 0, 0);
        end = new Date(now.getFullYear(), now.getMonth() + 1, 0);
        end.setHours(23, 59, 59, 999);
    }

    return { start, end };
  }

  static formatPeriodForRevenue(period: Period): string {
    const year = period.start.getFullYear();
    const month = String(period.start.getMonth() + 1).padStart(2, "0");
    return `${year}-${month}`;
  }
}
```

### **Paso 3: Crear Servicio de Dashboard**

Crear archivo `src/services/dashboard.service.ts`:

```typescript
import { appointmentRepository } from "../repositories/appointment.repository";
import { businessRepository } from "../repositories/business.repository";
import { serviceRepository } from "../repositories/service.repository";
import { userRepository } from "../repositories/user.repository";
import {
  BusinessStatsDto,
  RevenueByPeriod,
  AppointmentsByStatus,
  TopService,
  RecentAppointment,
} from "../dto/dashboard/business-stats.dto";
import {
  UserStatsDto,
  FavoriteBusiness,
  UpcomingAppointment,
} from "../dto/dashboard/user-stats.dto";
import { DashboardQueryDto } from "../dto/dashboard/dashboard-query.dto";
import { PeriodUtil, Period } from "../utils/period.util";
import { AppError } from "../middleware/error.middleware";
import { logger } from "../config/logger";
import { AppointmentStatus } from "@prisma/client";
import prisma from "../config/database";

export class DashboardService {
  async getBusinessStats(
    businessId: string,
    ownerId: string,
    query: DashboardQueryDto
  ): Promise<BusinessStatsDto> {
    // Verificar permisos
    const business = await businessRepository.findById(businessId);
    if (!business || business.ownerId !== ownerId) {
      throw new AppError(
        403,
        "You do not have permission to view this business stats"
      );
    }

    const period = PeriodUtil.getPeriod(
      query.period || "month",
      query.startDate,
      query.endDate
    );

    logger.info(
      `Getting business stats for business: ${businessId}, period: ${query.period}`
    );

    // Obtener todas las citas del negocio en el período
    const appointments = await appointmentRepository.findByBusinessIdAndPeriod(
      businessId,
      period.start,
      period.end
    );

    // Calcular estadísticas básicas
    const totalAppointments = appointments.length;
    const pendingAppointments = appointments.filter(
      (a) => a.status === AppointmentStatus.PENDING
    ).length;
    const confirmedAppointments = appointments.filter(
      (a) => a.status === AppointmentStatus.CONFIRMED
    ).length;
    const completedAppointments = appointments.filter(
      (a) => a.status === AppointmentStatus.COMPLETED
    ).length;
    const cancelledAppointments = appointments.filter(
      (a) => a.status === AppointmentStatus.CANCELLED
    ).length;

    // Calcular ingresos totales
    const totalRevenue = await this.calculateTotalRevenue(businessId, period);

    // Calcular ingresos por período
    const revenueByPeriod = await this.calculateRevenueByPeriod(
      businessId,
      period
    );

    // Calcular citas por estado
    const appointmentsByStatus =
      this.calculateAppointmentsByStatus(appointments);

    // Obtener servicios más populares
    const topServices = await this.getTopServices(businessId, period, 5);

    // Obtener citas recientes
    const recentAppointments = await this.getRecentAppointments(businessId, 10);

    return {
      totalAppointments,
      pendingAppointments,
      confirmedAppointments,
      completedAppointments,
      cancelledAppointments,
      totalRevenue,
      revenueByPeriod,
      appointmentsByStatus,
      topServices,
      recentAppointments,
      period: {
        start: period.start.toISOString(),
        end: period.end.toISOString(),
      },
    };
  }

  async getUserStats(
    userId: string,
    query: DashboardQueryDto
  ): Promise<UserStatsDto> {
    const period = PeriodUtil.getPeriod(
      query.period || "month",
      query.startDate,
      query.endDate
    );

    logger.info(
      `Getting user stats for user: ${userId}, period: ${query.period}`
    );

    // Obtener todas las citas del usuario en el período
    const appointments = await appointmentRepository.findByUserIdAndPeriod(
      userId,
      period.start,
      period.end
    );

    // Calcular estadísticas básicas
    const totalAppointments = appointments.length;
    const upcomingAppointments = appointments.filter(
      (a) =>
        (a.status === AppointmentStatus.PENDING ||
          a.status === AppointmentStatus.CONFIRMED) &&
        new Date(a.date) >= new Date()
    ).length;
    const completedAppointments = appointments.filter(
      (a) => a.status === AppointmentStatus.COMPLETED
    ).length;
    const cancelledAppointments = appointments.filter(
      (a) => a.status === AppointmentStatus.CANCELLED
    ).length;

    // Obtener negocios favoritos
    const favoriteBusinesses = await this.getFavoriteBusinesses(userId);

    // Obtener próximas citas
    const upcomingAppointmentsList = await this.getUpcomingAppointments(
      userId,
      5
    );

    return {
      totalAppointments,
      upcomingAppointments,
      completedAppointments,
      cancelledAppointments,
      favoriteBusinesses,
      upcomingAppointmentsList,
      period: {
        start: period.start.toISOString(),
        end: period.end.toISOString(),
      },
    };
  }

  private async calculateTotalRevenue(
    businessId: string,
    period: Period
  ): Promise<number> {
    const result = await prisma.appointment.aggregate({
      where: {
        businessId,
        date: {
          gte: period.start,
          lte: period.end,
        },
        status: AppointmentStatus.COMPLETED,
      },
      _sum: {
        amount: true,
      },
    });

    return result._sum.amount || 0;
  }

  private async calculateRevenueByPeriod(
    businessId: string,
    period: Period
  ): Promise<RevenueByPeriod[]> {
    // Agrupar por mes
    const appointments = await prisma.appointment.findMany({
      where: {
        businessId,
        date: {
          gte: period.start,
          lte: period.end,
        },
        status: AppointmentStatus.COMPLETED,
      },
      select: {
        date: true,
        amount: true,
      },
    });

    // Agrupar por mes
    const revenueMap = new Map<string, { revenue: number; count: number }>();

    appointments.forEach((appointment) => {
      const periodKey = PeriodUtil.formatPeriodForRevenue({
        start: appointment.date,
        end: appointment.date,
      });

      const current = revenueMap.get(periodKey) || { revenue: 0, count: 0 };
      revenueMap.set(periodKey, {
        revenue: current.revenue + (appointment.amount || 0),
        count: current.count + 1,
      });
    });

    return Array.from(revenueMap.entries()).map(([period, data]) => ({
      period,
      revenue: data.revenue,
      count: data.count,
    }));
  }

  private calculateAppointmentsByStatus(
    appointments: any[]
  ): AppointmentsByStatus[] {
    const total = appointments.length;
    if (total === 0) {
      return [];
    }

    const statusCounts = new Map<string, number>();

    appointments.forEach((appointment) => {
      const count = statusCounts.get(appointment.status) || 0;
      statusCounts.set(appointment.status, count + 1);
    });

    return Array.from(statusCounts.entries()).map(([status, count]) => ({
      status,
      count,
      percentage: Math.round((count / total) * 100),
    }));
  }

  private async getTopServices(
    businessId: string,
    period: Period,
    limit: number
  ): Promise<TopService[]> {
    const services = await prisma.service.findMany({
      where: {
        businessId,
        isActive: true,
      },
      include: {
        appointments: {
          where: {
            date: {
              gte: period.start,
              lte: period.end,
            },
            status: AppointmentStatus.COMPLETED,
          },
        },
      },
    });

    return services
      .map((service) => ({
        serviceId: service.id,
        serviceName: service.name,
        count: service.appointments.length,
        revenue:
          service.appointments.reduce(
            (sum, apt) => sum + (apt.amount || 0),
            0
          ) || 0,
      }))
      .sort((a, b) => b.count - a.count)
      .slice(0, limit);
  }

  private async getRecentAppointments(
    businessId: string,
    limit: number
  ): Promise<RecentAppointment[]> {
    const appointments = await prisma.appointment.findMany({
      where: {
        businessId,
      },
      include: {
        user: {
          select: {
            fullName: true,
          },
        },
        service: {
          select: {
            name: true,
          },
        },
      },
      orderBy: {
        date: "desc",
      },
      take: limit,
    });

    return appointments.map((apt) => ({
      id: apt.id,
      customerName: apt.user.fullName || "Unknown",
      serviceName: apt.service.name,
      date: apt.date.toISOString(),
      status: apt.status,
      amount: apt.amount || 0,
    }));
  }

  private async getFavoriteBusinesses(
    userId: string
  ): Promise<FavoriteBusiness[]> {
    const appointments = await prisma.appointment.groupBy({
      by: ["businessId"],
      where: {
        userId,
      },
      _count: {
        id: true,
      },
      _max: {
        date: true,
      },
    });

    const businesses = await Promise.all(
      appointments.map(async (apt) => {
        const business = await businessRepository.findById(apt.businessId);
        return {
          businessId: apt.businessId,
          businessName: business?.name || "Unknown",
          appointmentCount: apt._count.id,
          lastAppointmentDate: apt._max.date?.toISOString() || "",
        };
      })
    );

    return businesses.sort((a, b) => b.appointmentCount - a.appointmentCount);
  }

  private async getUpcomingAppointments(
    userId: string,
    limit: number
  ): Promise<UpcomingAppointment[]> {
    const appointments = await prisma.appointment.findMany({
      where: {
        userId,
        date: {
          gte: new Date(),
        },
        status: {
          in: [AppointmentStatus.PENDING, AppointmentStatus.CONFIRMED],
        },
      },
      include: {
        business: {
          select: {
            name: true,
          },
        },
        service: {
          select: {
            name: true,
          },
        },
      },
      orderBy: {
        date: "asc",
      },
      take: limit,
    });

    return appointments.map((apt) => ({
      id: apt.id,
      businessName: apt.business.name,
      serviceName: apt.service.name,
      date: apt.date.toISOString(),
      status: apt.status,
    }));
  }
}

export const dashboardService = new DashboardService();
```

### **Paso 4: Actualizar Repositorio de Citas**

Actualizar `src/repositories/appointment.repository.ts` para agregar métodos necesarios:

```typescript
// ... existing code ...

async findByBusinessIdAndPeriod(
  businessId: string,
  startDate: Date,
  endDate: Date
): Promise<Appointment[]> {
  return await prisma.appointment.findMany({
    where: {
      businessId,
      date: {
        gte: startDate,
        lte: endDate,
      },
    },
  });
}

async findByUserIdAndPeriod(
  userId: string,
  startDate: Date,
  endDate: Date
): Promise<Appointment[]> {
  return await prisma.appointment.findMany({
    where: {
      userId,
      date: {
        gte: startDate,
        lte: endDate,
      },
    },
  });
}

// ... existing code ...
```

### **Paso 5: Crear Controlador de Dashboard**

Crear archivo `src/controllers/dashboard.controller.ts`:

```typescript
import { Request, Response } from "express";
import { dashboardService } from "../services/dashboard.service";
import { DashboardQueryDto } from "../dto/dashboard/dashboard-query.dto";
import { logger } from "../config/logger";

export class DashboardController {
  async getBusinessStats(req: Request, res: Response): Promise<void> {
    try {
      const businessId = req.params.businessId;
      const userId = req.user!.id; // Del middleware de autenticación
      const query: DashboardQueryDto = {
        period: (req.query.period as any) || "month",
        startDate: req.query.startDate as string,
        endDate: req.query.endDate as string,
      };

      const stats = await dashboardService.getBusinessStats(
        businessId,
        userId,
        query
      );

      res.json({
        success: true,
        data: stats,
      });
    } catch (error: any) {
      logger.error("Error getting business stats:", error);
      res.status(error.statusCode || 500).json({
        success: false,
        message: error.message || "Error getting business stats",
      });
    }
  }

  async getUserStats(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user!.id; // Del middleware de autenticación
      const query: DashboardQueryDto = {
        period: (req.query.period as any) || "month",
        startDate: req.query.startDate as string,
        endDate: req.query.endDate as string,
      };

      const stats = await dashboardService.getUserStats(userId, query);

      res.json({
        success: true,
        data: stats,
      });
    } catch (error: any) {
      logger.error("Error getting user stats:", error);
      res.status(error.statusCode || 500).json({
        success: false,
        message: error.message || "Error getting user stats",
      });
    }
  }
}

export const dashboardController = new DashboardController();
```

### **Paso 6: Crear Rutas de Dashboard**

Crear archivo `src/routes/dashboard.routes.ts`:

```typescript
import { Router } from "express";
import { dashboardController } from "../controllers/dashboard.controller";
import { authMiddleware } from "../middleware/auth.middleware";

const router = Router();

// Todas las rutas requieren autenticación
router.use(authMiddleware);

// GET /api/dashboard/business/:businessId/stats
router.get(
  "/business/:businessId/stats",
  dashboardController.getBusinessStats.bind(dashboardController)
);

// GET /api/dashboard/user/stats
router.get(
  "/user/stats",
  dashboardController.getUserStats.bind(dashboardController)
);

export default router;
```

### **Paso 7: Registrar Rutas en App**

Actualizar `src/app.ts`:

```typescript
// ... existing imports ...
import dashboardRoutes from "./routes/dashboard.routes";

// ... existing code ...

app.use("/api/dashboard", dashboardRoutes);

// ... existing code ...
```

### **Paso 8: Crear Validadores Zod**

Crear archivo `src/validators/dashboard.validator.ts`:

```typescript
import { z } from "zod";

export const dashboardQuerySchema = z
  .object({
    period: z.enum(["today", "week", "month", "year", "custom"]).optional(),
    startDate: z.string().datetime().optional(),
    endDate: z.string().datetime().optional(),
  })
  .refine(
    (data) => {
      if (data.period === "custom") {
        return data.startDate && data.endDate;
      }
      return true;
    },
    {
      message: "Start date and end date are required for custom period",
    }
  );
```

### **Paso 9: Crear Tests**

Crear archivo `tests/services/dashboard.service.test.ts`:

```typescript
import { DashboardService } from "../../src/services/dashboard.service";
import { appointmentRepository } from "../../src/repositories/appointment.repository";
import { businessRepository } from "../../src/repositories/business.repository";

jest.mock("../../src/repositories/appointment.repository");
jest.mock("../../src/repositories/business.repository");

describe("DashboardService", () => {
  let dashboardService: DashboardService;

  beforeEach(() => {
    dashboardService = new DashboardService();
    jest.clearAllMocks();
  });

  describe("getBusinessStats", () => {
    it("should return business stats for valid business owner", async () => {
      // Arrange
      const businessId = "business-1";
      const ownerId = "owner-1";
      const query = { period: "month" as const };

      const mockBusiness = {
        id: businessId,
        ownerId,
        name: "Test Business",
      };

      (businessRepository.findById as jest.Mock).mockResolvedValue(
        mockBusiness
      );
      (
        appointmentRepository.findByBusinessIdAndPeriod as jest.Mock
      ).mockResolvedValue([]);

      // Act
      const stats = await dashboardService.getBusinessStats(
        businessId,
        ownerId,
        query
      );

      // Assert
      expect(stats).toBeDefined();
      expect(stats.totalAppointments).toBe(0);
      expect(businessRepository.findById).toHaveBeenCalledWith(businessId);
    });

    it("should throw error if user is not business owner", async () => {
      // Arrange
      const businessId = "business-1";
      const ownerId = "owner-1";
      const query = { period: "month" as const };

      const mockBusiness = {
        id: businessId,
        ownerId: "different-owner",
        name: "Test Business",
      };

      (businessRepository.findById as jest.Mock).mockResolvedValue(
        mockBusiness
      );

      // Act & Assert
      await expect(
        dashboardService.getBusinessStats(businessId, ownerId, query)
      ).rejects.toThrow("You do not have permission");
    });
  });

  describe("getUserStats", () => {
    it("should return user stats", async () => {
      // Arrange
      const userId = "user-1";
      const query = { period: "month" as const };

      (
        appointmentRepository.findByUserIdAndPeriod as jest.Mock
      ).mockResolvedValue([]);

      // Act
      const stats = await dashboardService.getUserStats(userId, query);

      // Assert
      expect(stats).toBeDefined();
      expect(stats.totalAppointments).toBe(0);
    });
  });
});
```

---

## ✅ Verificación Final

- [ ] Endpoints de dashboard funcionando
- [ ] Métricas calculadas correctamente
- [ ] Filtros por período funcionando
- [ ] Permisos validados correctamente
- [ ] Tests pasando

---

## 📝 Entregables del Día

1. ✅ Endpoints de dashboard para negocios
2. ✅ Endpoints de dashboard para usuarios
3. ✅ Cálculo de métricas y estadísticas
4. ✅ Filtros por período (hoy, semana, mes, año, personalizado)
5. ✅ Tests completos

---

## 🎯 Próximo Día

**Día 10**: Sistema de Notificaciones

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_
