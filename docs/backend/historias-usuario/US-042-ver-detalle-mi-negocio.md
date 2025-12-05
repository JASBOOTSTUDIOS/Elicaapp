# 🏢 US-042: Ver Detalle de Mi Negocio

## 📋 Información General

- **Épica**: Negocios
- **Prioridad**: P0 (Crítica)
- **Story Points**: 1
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-003 (Crear Negocio)

---

## 📖 Historia de Usuario

**Como** propietario de negocio  
**Quiero** ver el detalle completo de mi negocio  
**Para** revisar toda la información y configuración

---

## ✅ Criterios de Aceptación

- [ ] Puedo ver información completa del negocio
- [ ] Puedo ver todos los servicios (activos e inactivos)
- [ ] Puedo ver horarios configurados
- [ ] Puedo ver excepciones de horario
- [ ] Puedo ver pausas configuradas
- [ ] Solo puedo ver mis propios negocios

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Agregar Método al Repositorio**

**Archivo**: `src/repositories/business.repository.ts`

```typescript
async findByIdWithFullDetails(id: string): Promise<Business | null> {
  return await prisma.business.findUnique({
    where: { id },
    include: {
      services: {
        orderBy: { createdAt: "desc" },
      },
      businessHours: {
        orderBy: { dayOfWeek: "asc" },
      },
      businessHoursExceptions: {
        orderBy: { date: "desc" },
      },
      businessBreaks: {
        orderBy: { dayOfWeek: "asc" },
      },
      owner: {
        select: {
          id: true,
          email: true,
          fullName: true,
        },
      },
    },
  });
}
```

**Criterios de verificación**:
- [ ] Método implementado
- [ ] Todas las relaciones incluidas

---

### **Tarea 2: Agregar Método al Servicio**

**Archivo**: `src/services/business.service.ts`

```typescript
async findByIdWithDetails(
  id: string,
  ownerId: string
): Promise<Business> {
  const business = await businessRepository.findByIdWithFullDetails(id);
  if (!business) {
    throw new AppError(404, "Business not found");
  }

  if (business.ownerId !== ownerId) {
    throw new AppError(403, "You do not have permission");
  }

  return business;
}
```

**Criterios de verificación**:
- [ ] Método implementado
- [ ] Permisos verificados

---

### **Tarea 3: Crear Endpoint GET /api/businesses/:id/details**

**Archivo**: `src/controllers/business.controller.ts`

```typescript
async findByIdWithDetails(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id;
    const userId = req.user!.id;

    const business = await businessService.findByIdWithDetails(id, userId);

    res.json({
      success: true,
      data: business,
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
- [ ] Información completa retornada
- [ ] Permisos verificados
- [ ] Tests pasando

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_

