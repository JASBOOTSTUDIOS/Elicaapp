# 📊 US-025: Ver Citas de mi Negocio

## 📋 Información General

- **Épica**: Sistema de Citas
- **Prioridad**: P0 (Crítica)
- **Story Points**: 2
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-003 (Crear Negocio), US-005 (Agenda de Citas)

---

## 📖 Historia de Usuario

**Como** propietario de negocio  
**Quiero** ver todas las citas de mi negocio  
**Para** gestionar las reservas y planificar mi trabajo

---

## ✅ Criterios de Aceptación

- [ ] Puedo ver lista de citas de mi negocio
- [ ] Las citas están ordenadas por fecha
- [ ] Puedo filtrar por estado
- [ ] Puedo filtrar por servicio
- [ ] Puedo filtrar por fecha (rango)
- [ ] Puedo buscar por nombre de cliente
- [ ] La lista está paginada
- [ ] Solo puedo ver citas de mis propios negocios

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Agregar Método al Servicio**

**Archivo**: `src/services/appointment.service.ts`

```typescript
async findByBusiness(
  businessId: string,
  ownerId: string,
  query: AppointmentSearchDto
): Promise<{
  data: Appointment[];
  pagination: PaginationInfo;
}> {
  // Verificar permisos
  const business = await businessRepository.findById(businessId);
  if (!business || business.ownerId !== ownerId) {
    throw new AppError(403, "You do not have permission");
  }

  // Buscar citas con filtros
  const result = await appointmentRepository.search({
    ...query,
    businessId,
  });

  return result;
}
```

**Criterios de verificación**:

- [ ] Método implementado
- [ ] Permisos verificados

---

### **Tarea 2: Crear Endpoint GET /api/appointments/business/:businessId**

**Archivo**: `src/controllers/appointment.controller.ts`

```typescript
async getBusinessAppointments(req: Request, res: Response): Promise<void> {
  try {
    const businessId = req.params.businessId;
    const userId = req.user!.id;
    const query: AppointmentSearchDto = {
      businessId,
      search: req.query.search as string,
      serviceId: req.query.serviceId as string,
      status: req.query.status as string,
      startDate: req.query.startDate as string,
      endDate: req.query.endDate as string,
      sortBy: (req.query.sortBy as any) || "date",
      sortOrder: (req.query.sortOrder as any) || "asc",
      page: req.query.page ? parseInt(req.query.page as string) : 1,
      limit: req.query.limit ? parseInt(req.query.limit as string) : 10,
    };

    const result = await appointmentService.findByBusiness(
      businessId,
      userId,
      query
    );

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
- [ ] Permisos verificados
- [ ] Filtros funcionando
- [ ] Tests pasando

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_
