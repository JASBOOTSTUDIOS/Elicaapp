# 👤 US-007: Ver Mis Estadísticas como Usuario

## 📋 Información General

- **Épica**: Dashboard y Métricas
- **Prioridad**: P0 (Crítica)
- **Story Points**: 2
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-002 (Login), US-005 (Agenda de Citas)

---

## 📖 Historia de Usuario

**Como** cliente  
**Quiero** ver mis estadísticas personales (citas totales, próximas citas, negocios favoritos)  
**Para** tener un resumen de mi actividad en la plataforma

---

## ✅ Criterios de Aceptación

- [ ] Puedo ver el total de mis citas
- [ ] Puedo ver mis próximas citas
- [ ] Puedo ver mis citas completadas
- [ ] Puedo ver mis citas canceladas
- [ ] Puedo ver mis negocios favoritos (por cantidad de citas)
- [ ] Puedo ver lista de próximas citas con detalles
- [ ] Puedo filtrar por período

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear DTO de Estadísticas de Usuario**

**Archivo**: `src/dto/dashboard/user-stats.dto.ts`

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

**Criterios de verificación**:

- [ ] DTOs creados
- [ ] Interfaces definidas

---

### **Tarea 2: Agregar Método al Repositorio de Citas**

**Archivo**: `src/repositories/appointment.repository.ts`

```typescript
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
```

**Criterios de verificación**:

- [ ] Método agregado
- [ ] Query correcta

---

### **Tarea 3: Implementar Método getUserStats**

**Archivo**: `src/services/dashboard.service.ts`

```typescript
async getUserStats(
  userId: string,
  query: DashboardQueryDto
): Promise<UserStatsDto> {
  const period = PeriodUtil.getPeriod(
    query.period || "month",
    query.startDate,
    query.endDate
  );

  // Obtener citas del período
  const appointments = await appointmentRepository.findByUserIdAndPeriod(
    userId,
    period.start,
    period.end
  );

  // Calcular estadísticas
  const totalAppointments = appointments.length;
  const upcomingAppointments = appointments.filter(
    (a) =>
      (a.status === AppointmentStatus.PENDING ||
        a.status === AppointmentStatus.CONFIRMED) &&
      new Date(a.date) >= new Date()
  ).length;

  // Obtener negocios favoritos
  const favoriteBusinesses = await this.getFavoriteBusinesses(userId);

  // Obtener próximas citas
  const upcomingAppointmentsList = await this.getUpcomingAppointments(userId, 5);

  return {
    totalAppointments,
    upcomingAppointments,
    completedAppointments: appointments.filter(
      (a) => a.status === AppointmentStatus.COMPLETED
    ).length,
    cancelledAppointments: appointments.filter(
      (a) => a.status === AppointmentStatus.CANCELLED
    ).length,
    favoriteBusinesses,
    upcomingAppointmentsList,
    period: {
      start: period.start.toISOString(),
      end: period.end.toISOString(),
    },
  };
}
```

**Criterios de verificación**:

- [ ] Método implementado
- [ ] Estadísticas calculadas correctamente

---

### **Tarea 4: Crear Endpoint GET /api/dashboard/user/stats**

**Archivo**: `src/controllers/dashboard.controller.ts`

```typescript
async getUserStats(req: Request, res: Response): Promise<void> {
  try {
    const userId = req.user!.id;
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
```

**Criterios de verificación**:

- [ ] Endpoint creado
- [ ] Ruta registrada

---

## 🔍 Definition of Done

- [ ] Endpoint funcionando
- [ ] Estadísticas calculadas correctamente
- [ ] Tests pasando
- [ ] Documentación Swagger actualizada

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_
