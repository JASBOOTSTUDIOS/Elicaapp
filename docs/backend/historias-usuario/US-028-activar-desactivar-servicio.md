# 🔄 US-028: Activar/Desactivar Servicio

## 📋 Información General

- **Épica**: Servicios
- **Prioridad**: P0 (Crítica)
- **Story Points**: 1
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-004 (Gestión de Servicios)

---

## 📖 Historia de Usuario

**Como** propietario de negocio  
**Quiero** activar o desactivar servicios temporalmente  
**Para** controlar qué servicios están disponibles

---

## ✅ Criterios de Aceptación

- [ ] Puedo desactivar un servicio
- [ ] Puedo reactivar un servicio
- [ ] Cuando está desactivado, no aparece en búsquedas
- [ ] Cuando está desactivado, no se pueden crear nuevas citas
- [ ] Solo puedo activar/desactivar servicios de mis negocios

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Agregar Método al Servicio**

**Archivo**: `src/services/service.service.ts`

```typescript
async toggleActive(
  id: string,
  ownerId: string
): Promise<Service> {
  // Verificar permisos
  const service = await this.findById(id, ownerId);

  return await serviceRepository.update(id, {
    isActive: !service.isActive,
  });
}
```

**Criterios de verificación**:
- [ ] Método implementado

---

### **Tarea 2: Crear Endpoint PATCH /api/services/:id/toggle-active**

**Archivo**: `src/controllers/service.controller.ts`

```typescript
async toggleActive(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id;
    const userId = req.user!.id;

    const service = await serviceService.toggleActive(id, userId);

    res.json({
      success: true,
      data: service,
      message: service.isActive
        ? "Service activated"
        : "Service deactivated",
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
- [ ] Validación en búsquedas funcionando
- [ ] Tests pasando

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_

