# 📅 US-034: Ver Detalle de una Cita

## 📋 Información General

- **Épica**: Sistema de Citas
- **Prioridad**: P0 (Crítica)
- **Story Points**: 1
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-005 (Agenda de Citas)

---

## 📖 Historia de Usuario

**Como** usuario (cliente o dueño de negocio)  
**Quiero** ver el detalle completo de una cita  
**Para** conocer toda la información relevante

---

## ✅ Criterios de Aceptación

- [ ] Puedo ver información completa de la cita
- [ ] Puedo ver información del negocio
- [ ] Puedo ver información del servicio
- [ ] Puedo ver información del cliente (si soy dueño)
- [ ] Puedo ver fecha, hora y estado
- [ ] Puedo ver notas adicionales
- [ ] Solo puedo ver citas de mis negocios o mis propias citas

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Agregar Método al Servicio**

**Archivo**: `src/services/appointment.service.ts`

```typescript
async findById(id: string, userId: string): Promise<Appointment> {
  const appointment = await appointmentRepository.findByIdWithRelations(id);
  if (!appointment) {
    throw new AppError(404, "Appointment not found");
  }

  // Verificar permisos
  if (
    appointment.userId !== userId &&
    appointment.business.ownerId !== userId
  ) {
    throw new AppError(403, "You do not have permission");
  }

  return appointment;
}
```

**Criterios de verificación**:
- [ ] Método implementado
- [ ] Permisos verificados

---

### **Tarea 2: Crear Endpoint GET /api/appointments/:id**

**Archivo**: `src/controllers/appointment.controller.ts`

```typescript
async findById(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id;
    const userId = req.user!.id;

    const appointment = await appointmentService.findById(id, userId);

    res.json({
      success: true,
      data: appointment,
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
- [ ] Tests pasando

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_

