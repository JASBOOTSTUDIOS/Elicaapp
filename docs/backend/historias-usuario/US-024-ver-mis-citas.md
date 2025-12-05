# 📋 US-024: Ver Mis Citas

## 📋 Información General

- **Épica**: Sistema de Citas
- **Prioridad**: P0 (Crítica)
- **Story Points**: 2
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-005 (Agenda de Citas)

---

## 📖 Historia de Usuario

**Como** cliente  
**Quiero** ver todas mis citas  
**Para** tener un resumen de mis reservas

---

## ✅ Criterios de Aceptación

- [ ] Puedo ver lista de mis citas
- [ ] Las citas están ordenadas por fecha (más recientes primero)
- [ ] Puedo filtrar por estado
- [ ] Puedo filtrar por fecha (rango)
- [ ] Puedo buscar por nombre de negocio o servicio
- [ ] La lista está paginada
- [ ] Cada cita muestra información completa (negocio, servicio, fecha, estado)

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear DTO de Búsqueda de Citas**

**Archivo**: `src/dto/search/appointment-search.dto.ts`

```typescript
export interface AppointmentSearchDto {
  search?: string;
  businessId?: string;
  serviceId?: string;
  status?: string;
  startDate?: string;
  endDate?: string;
  sortBy?: "date" | "amount" | "createdAt";
  sortOrder?: "asc" | "desc";
  page?: number;
  limit?: number;
}
```

**Criterios de verificación**:
- [ ] DTO creado

---

### **Tarea 2: Agregar Método de Búsqueda al Repositorio**

**Archivo**: `src/repositories/appointment.repository.ts`

```typescript
async search(query: AppointmentSearchDto) {
  const {
    page = 1,
    limit = 10,
    search,
    businessId,
    serviceId,
    status,
    startDate,
    endDate,
    sortBy = "date",
    sortOrder = "desc",
  } = query;

  const skip = (page - 1) * limit;
  const where: Prisma.AppointmentWhereInput = {};

  // Búsqueda de texto
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
  if (businessId) where.businessId = businessId;
  if (serviceId) where.serviceId = serviceId;
  if (status) where.status = status as any;

  // Filtro de rango de fechas
  if (startDate || endDate) {
    const dateFilter = SearchUtil.createDateRangeFilter(startDate, endDate);
    if (dateFilter) {
      where.date = dateFilter;
    }
  }

  // Ordenamiento
  const orderBy: Prisma.AppointmentOrderByWithRelationInput = {};
  if (sortBy === "date") {
    orderBy.date = sortOrder;
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
```

**Criterios de verificación**:
- [ ] Método implementado
- [ ] Búsqueda y filtros funcionando

---

### **Tarea 3: Crear Endpoint GET /api/appointments**

**Archivo**: `src/controllers/appointment.controller.ts`

```typescript
async getMyAppointments(req: Request, res: Response): Promise<void> {
  try {
    const userId = req.user!.id;
    const query: AppointmentSearchDto = {
      userId,
      search: req.query.search as string,
      businessId: req.query.businessId as string,
      serviceId: req.query.serviceId as string,
      status: req.query.status as string,
      startDate: req.query.startDate as string,
      endDate: req.query.endDate as string,
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
- [ ] Filtros funcionando
- [ ] Búsqueda funcionando
- [ ] Paginación funcionando
- [ ] Tests pasando

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_

