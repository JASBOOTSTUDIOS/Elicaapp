# 🔄 US-027: Activar/Desactivar mi Negocio

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
**Quiero** activar o desactivar mi negocio temporalmente  
**Para** controlar cuando acepto nuevas reservas

---

## ✅ Criterios de Aceptación

- [ ] Puedo desactivar mi negocio
- [ ] Puedo reactivar mi negocio
- [ ] Cuando está desactivado, no se pueden crear nuevas citas
- [ ] Las citas existentes no se afectan
- [ ] Solo puedo activar/desactivar mis propios negocios

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Agregar Método al Servicio**

**Archivo**: `src/services/business.service.ts`

```typescript
async toggleActive(
  id: string,
  ownerId: string
): Promise<Business> {
  // Verificar permisos
  const business = await businessRepository.findById(id);
  if (!business || business.ownerId !== ownerId) {
    throw new AppError(403, "You do not have permission");
  }

  return await businessRepository.update(id, {
    isActive: !business.isActive,
  });
}
```

**Criterios de verificación**:
- [ ] Método implementado

---

### **Tarea 2: Crear Endpoint PATCH /api/businesses/:id/toggle-active**

**Archivo**: `src/controllers/business.controller.ts`

```typescript
async toggleActive(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id;
    const userId = req.user!.id;

    const business = await businessService.toggleActive(id, userId);

    res.json({
      success: true,
      data: business,
      message: business.isActive
        ? "Business activated"
        : "Business deactivated",
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
- [ ] Validación en creación de citas funcionando
- [ ] Tests pasando

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_

