# 📋 US-033: Listar Servicios de un Negocio

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
**Quiero** ver todos los servicios disponibles de un negocio  
**Para** elegir qué servicio reservar

---

## ✅ Criterios de Aceptación

- [ ] Puedo ver lista de servicios de un negocio
- [ ] Solo se muestran servicios activos
- [ ] La lista está ordenada por nombre
- [ ] Cada servicio muestra precio y duración
- [ ] El endpoint es público (no requiere autenticación)

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear Endpoint GET /api/services/business/:businessId**

**Archivo**: `src/controllers/service.controller.ts`

```typescript
async findByBusinessPublic(req: Request, res: Response): Promise<void> {
  try {
    const businessId = req.params.businessId;
    
    // Verificar que el negocio existe y está activo
    const business = await businessRepository.findById(businessId);
    if (!business || !business.isActive) {
      res.status(404).json({
        success: false,
        message: "Business not found",
      });
      return;
    }

    const services = await serviceRepository.findActiveByBusinessId(businessId);

    res.json({
      success: true,
      data: services,
    });
  } catch (error: any) {
    // ... manejo de errores
  }
}
```

**Criterios de verificación**:
- [ ] Endpoint creado
- [ ] Ruta registrada (pública)
- [ ] Solo servicios activos

---

## 🔍 Definition of Done

- [ ] Endpoint funcionando
- [ ] Solo servicios activos
- [ ] Tests pasando

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_

