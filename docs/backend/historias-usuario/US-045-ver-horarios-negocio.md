# 🕐 US-045: Ver Horarios de un Negocio

## 📋 Información General

- **Épica**: Horarios y Disponibilidad
- **Prioridad**: P0 (Crítica)
- **Story Points**: 1
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-013 (Configurar Horarios)

---

## 📖 Historia de Usuario

**Como** cliente  
**Quiero** ver los horarios de atención de un negocio  
**Para** saber cuándo puedo reservar citas

---

## ✅ Criterios de Aceptación

- [ ] Puedo ver horarios de todos los días de la semana
- [ ] Puedo ver días cerrados
- [ ] Puedo ver pausas/descansos configurados
- [ ] Puedo ver excepciones (vacaciones, días especiales)
- [ ] El endpoint es público (no requiere autenticación)

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Agregar Método al Servicio**

**Archivo**: `src/services/business-hours.service.ts`

```typescript
async getBusinessHours(businessId: string): Promise<{
  regularHours: BusinessHour[];
  breaks: BusinessBreak[];
  exceptions: BusinessHoursException[];
}> {
  // Verificar que el negocio existe y está activo
  const business = await businessRepository.findById(businessId);
  if (!business || !business.isActive) {
    throw new AppError(404, "Business not found");
  }

  const [regularHours, breaks, exceptions] = await Promise.all([
    businessHoursRepository.findByBusinessId(businessId),
    businessBreakRepository.findByBusinessId(businessId),
    businessHoursExceptionRepository.findByBusinessId(businessId),
  ]);

  return {
    regularHours,
    breaks,
    exceptions,
  };
}
```

**Criterios de verificación**:
- [ ] Método implementado

---

### **Tarea 2: Crear Endpoint GET /api/business-hours/:businessId**

**Archivo**: `src/controllers/business-hours.controller.ts`

```typescript
async getBusinessHours(req: Request, res: Response): Promise<void> {
  try {
    const businessId = req.params.businessId;
    const hours = await businessHoursService.getBusinessHours(businessId);

    res.json({
      success: true,
      data: hours,
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

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_

