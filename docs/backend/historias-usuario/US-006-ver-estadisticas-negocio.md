# 📊 US-006: Ver Estadísticas de mi Negocio

## 📋 Información General

- **Épica**: Dashboard y Métricas
- **Prioridad**: P0 (Crítica)
- **Story Points**: 3
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-003 (Crear Negocio), US-005 (Agenda de Citas)

---

## 📖 Historia de Usuario

**Como** propietario de negocio  
**Quiero** ver estadísticas de mi negocio (citas totales, ingresos, servicios más populares)  
**Para** entender el rendimiento de mi negocio y tomar decisiones informadas

---

## ✅ Criterios de Aceptación

- [ ] Puedo ver el total de citas en un período seleccionado
- [ ] Puedo ver citas por estado (pendientes, confirmadas, completadas, canceladas)
- [ ] Puedo ver ingresos totales del período
- [ ] Puedo ver ingresos agrupados por mes
- [ ] Puedo ver los servicios más populares
- [ ] Puedo ver las citas recientes
- [ ] Puedo filtrar por período (hoy, semana, mes, año, personalizado)
- [ ] Solo puedo ver estadísticas de mis propios negocios

---

## 🎯 Reglas de Negocio

1. **Permisos**: Solo el dueño del negocio puede ver sus estadísticas
2. **Período por defecto**: Si no se especifica, mostrar mes actual
3. **Ingresos**: Solo contar citas con estado COMPLETED
4. **Servicios populares**: Ordenar por cantidad de citas completadas
5. **Citas recientes**: Mostrar las últimas 10 citas

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear DTO de Estadísticas de Negocio**

**Archivo**: `src/dto/dashboard/business-stats.dto.ts`

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
  period: string; // "2025-01", "2025-02", etc.
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

**Criterios de verificación**:

- [ ] Archivo creado
- [ ] Todas las interfaces definidas
- [ ] Tipos correctos

---

### **Tarea 2: Crear Utilidad de Períodos**

**Archivo**: `src/utils/period.util.ts`

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

**Criterios de verificación**:

- [ ] Utilidad creada
- [ ] Todos los casos de período implementados
- [ ] Validación de período personalizado funcionando

**Tests a escribir**:

```typescript
describe("PeriodUtil", () => {
  it("should return today period", () => {
    const period = PeriodUtil.getPeriod("today");
    expect(period.start.getHours()).toBe(0);
    expect(period.end.getHours()).toBe(23);
  });

  it("should return month period", () => {
    const period = PeriodUtil.getPeriod("month");
    expect(period.start.getDate()).toBe(1);
  });

  it("should throw error for custom period without dates", () => {
    expect(() => PeriodUtil.getPeriod("custom")).toThrow();
  });
});
```

---

### **Tarea 3: Agregar Método al Repositorio de Citas**

**Archivo**: `src/repositories/appointment.repository.ts`

Agregar método:

```typescript
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
```

**Criterios de verificación**:

- [ ] Método agregado
- [ ] Query correcta con filtros de fecha

---

### **Tarea 4: Implementar Método getBusinessStats en DashboardService**

**Archivo**: `src/services/dashboard.service.ts`

```typescript
async getBusinessStats(
  businessId: string,
  ownerId: string,
  query: DashboardQueryDto
): Promise<BusinessStatsDto> {
  // 1. Verificar permisos
  const business = await businessRepository.findById(businessId);
  if (!business || business.ownerId !== ownerId) {
    throw new AppError(
      403,
      "You do not have permission to view this business stats"
    );
  }

  // 2. Obtener período
  const period = PeriodUtil.getPeriod(
    query.period || "month",
    query.startDate,
    query.endDate
  );

  // 3. Obtener citas del período
  const appointments = await appointmentRepository.findByBusinessIdAndPeriod(
    businessId,
    period.start,
    period.end
  );

  // 4. Calcular estadísticas básicas
  const totalAppointments = appointments.length;
  const pendingAppointments = appointments.filter(
    (a) => a.status === AppointmentStatus.PENDING
  ).length;
  // ... resto de cálculos

  // 5. Calcular ingresos
  const totalRevenue = await this.calculateTotalRevenue(businessId, period);

  // 6. Retornar estadísticas
  return {
    totalAppointments,
    pendingAppointments,
    // ... resto de datos
  };
}
```

**Pasos detallados**:

1. **Verificar permisos** (5 minutos):

   - Buscar negocio por ID
   - Verificar que el ownerId coincida
   - Si no coincide, lanzar error 403

2. **Obtener período** (5 minutos):

   - Usar PeriodUtil.getPeriod()
   - Manejar período por defecto (mes)

3. **Obtener citas** (5 minutos):

   - Llamar a findByBusinessIdAndPeriod()
   - Filtrar por fechas del período

4. **Calcular estadísticas básicas** (10 minutos):

   - Contar total de citas
   - Contar por cada estado
   - Usar filter() para agrupar

5. **Calcular ingresos** (10 minutos):

   - Agregar método calculateTotalRevenue()
   - Filtrar solo citas COMPLETED
   - Sumar amounts

6. **Calcular ingresos por período** (15 minutos):

   - Agregar método calculateRevenueByPeriod()
   - Agrupar por mes
   - Usar Map para acumular

7. **Obtener servicios populares** (15 minutos):

   - Agregar método getTopServices()
   - Contar citas por servicio
   - Ordenar por cantidad

8. **Obtener citas recientes** (10 minutos):
   - Agregar método getRecentAppointments()
   - Ordenar por fecha descendente
   - Limitar a 10

**Criterios de verificación**:

- [ ] Método implementado
- [ ] Permisos verificados
- [ ] Todas las estadísticas calculadas
- [ ] Logs implementados

**Tests unitarios**:

```typescript
describe("DashboardService.getBusinessStats", () => {
  it("should return stats for valid owner", async () => {
    // Arrange
    const mockBusiness = { id: "b1", ownerId: "u1" };
    (businessRepository.findById as jest.Mock).mockResolvedValue(mockBusiness);
    (
      appointmentRepository.findByBusinessIdAndPeriod as jest.Mock
    ).mockResolvedValue([]);

    // Act
    const stats = await dashboardService.getBusinessStats("b1", "u1", {
      period: "month",
    });

    // Assert
    expect(stats.totalAppointments).toBe(0);
  });

  it("should throw error for non-owner", async () => {
    // Arrange
    const mockBusiness = { id: "b1", ownerId: "u2" };
    (businessRepository.findById as jest.Mock).mockResolvedValue(mockBusiness);

    // Act & Assert
    await expect(
      dashboardService.getBusinessStats("b1", "u1", { period: "month" })
    ).rejects.toThrow("permission");
  });
});
```

---

### **Tarea 5: Crear Controlador**

**Archivo**: `src/controllers/dashboard.controller.ts`

```typescript
async getBusinessStats(req: Request, res: Response): Promise<void> {
  try {
    const businessId = req.params.businessId;
    const userId = req.user!.id;
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
```

**Criterios de verificación**:

- [ ] Controlador creado
- [ ] Manejo de errores correcto
- [ ] Respuesta con formato correcto

---

### **Tarea 6: Crear Ruta**

**Archivo**: `src/routes/dashboard.routes.ts`

```typescript
router.get(
  "/business/:businessId/stats",
  authMiddleware,
  dashboardController.getBusinessStats.bind(dashboardController)
);
```

**Criterios de verificación**:

- [ ] Ruta creada
- [ ] Middleware de autenticación aplicado
- [ ] Registrada en app.ts

---

## 🧪 Checklist de Testing

### **Tests Unitarios**

- [ ] Test de cálculo de estadísticas básicas
- [ ] Test de cálculo de ingresos
- [ ] Test de verificación de permisos
- [ ] Test de períodos (hoy, semana, mes, año)

### **Tests de Integración**

- [ ] Test de endpoint completo
- [ ] Test de filtros por período
- [ ] Test de permisos

---

## 📊 Métricas de Éxito

- **Response Time**: < 500ms
- **Success Rate**: > 99%
- **Code Coverage**: > 80%

---

## 🔍 Definition of Done

- [ ] Endpoint funcionando
- [ ] Todas las estadísticas calculadas correctamente
- [ ] Permisos verificados
- [ ] Tests pasando (>80% coverage)
- [ ] Documentación Swagger actualizada
- [ ] Code review aprobado

---

## 🎯 Próxima Historia

**US-007**: Ver Estadísticas de Usuario

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_
