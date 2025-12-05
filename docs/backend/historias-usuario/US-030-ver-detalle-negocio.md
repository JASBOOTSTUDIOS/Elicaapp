# 🏢 US-030: Ver Detalle de un Negocio

## 📋 Información General

- **Épica**: Negocios
- **Prioridad**: P0 (Crítica)
- **Story Points**: 1
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-003 (Crear Negocio)

---

## 📖 Historia de Usuario

**Como** cliente  
**Quiero** ver el detalle completo de un negocio  
**Para** conocer más información antes de reservar

---

## ✅ Criterios de Aceptación

- [ ] Puedo ver información completa del negocio
- [ ] Puedo ver servicios disponibles del negocio
- [ ] Puedo ver horarios de atención
- [ ] Puedo ver logo del negocio
- [ ] Puedo ver información de contacto
- [ ] Puedo ver dirección completa
- [ ] El endpoint es público (no requiere autenticación)

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Agregar Método al Repositorio**

**Archivo**: `src/repositories/business.repository.ts`

```typescript
async findByIdWithDetails(id: string): Promise<Business | null> {
  return await prisma.business.findUnique({
    where: { id },
    include: {
      services: {
        where: { isActive: true },
        select: {
          id: true,
          name: true,
          description: true,
          price: true,
          durationMinutes: true,
          imageUrl: true,
        },
      },
      businessHours: {
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
- [ ] Relaciones incluidas

---

### **Tarea 2: Crear Endpoint GET /api/businesses/:id**

**Archivo**: `src/controllers/business.controller.ts`

```typescript
async findById(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id;
    const business = await businessService.findById(id);

    if (!business || !business.isActive) {
      res.status(404).json({
        success: false,
        message: "Business not found",
      });
      return;
    }

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
- [ ] Ruta registrada (pública)

---

## 🔍 Definition of Done

- [ ] Endpoint funcionando
- [ ] Información completa retornada
- [ ] Tests pasando

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_

