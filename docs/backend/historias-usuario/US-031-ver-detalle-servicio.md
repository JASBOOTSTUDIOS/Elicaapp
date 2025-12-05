# 💇 US-031: Ver Detalle de un Servicio

## 📋 Información General

- **Épica**: Servicios
- **Prioridad**: P0 (Crítica)
- **Story Points**: 1
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-004 (Gestión de Servicios)

---

## 📖 Historia de Usuario

**Como** cliente  
**Quiero** ver el detalle completo de un servicio  
**Para** conocer precio, duración y descripción antes de reservar

---

## ✅ Criterios de Aceptación

- [ ] Puedo ver información completa del servicio
- [ ] Puedo ver precio y duración
- [ ] Puedo ver descripción detallada
- [ ] Puedo ver imagen del servicio
- [ ] Puedo ver información del negocio que lo ofrece
- [ ] El endpoint es público (no requiere autenticación)
- [ ] Solo se muestran servicios activos

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Agregar Método al Repositorio**

**Archivo**: `src/repositories/service.repository.ts`

```typescript
async findByIdPublic(id: string): Promise<Service | null> {
  return await prisma.service.findUnique({
    where: {
      id,
      isActive: true,
    },
    include: {
      business: {
        select: {
          id: true,
          name: true,
          logoUrl: true,
          city: true,
          state: true,
        },
      },
    },
  });
}
```

**Criterios de verificación**:
- [ ] Método implementado
- [ ] Solo servicios activos

---

### **Tarea 2: Crear Endpoint GET /api/services/:id**

**Archivo**: `src/controllers/service.controller.ts`

```typescript
async findByIdPublic(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id;
    const service = await serviceRepository.findByIdPublic(id);

    if (!service) {
      res.status(404).json({
        success: false,
        message: "Service not found",
      });
      return;
    }

    res.json({
      success: true,
      data: service,
    });
  } catch (error: any) {
    // ... manejo de errores
  }
}
```

**Criterios de verificación**:
- [ ] Endpoint creado
- [ ] Ruta registrada (pública)

---

## 🔍 Definition of Done

- [ ] Endpoint funcionando
- [ ] Solo servicios activos
- [ ] Tests pasando

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_

