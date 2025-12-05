# 🗑️ US-047: Eliminar Pausa de Horario

## 📋 Información General

- **Épica**: Horarios y Disponibilidad
- **Prioridad**: P0 (Crítica)
- **Story Points**: 1
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-018 (Configurar Pausas)

---

## 📖 Historia de Usuario

**Como** propietario de negocio  
**Quiero** eliminar pausas de horario  
**Para** ajustar los períodos de descanso

---

## ✅ Criterios de Aceptación

- [ ] Puedo eliminar una pausa específica
- [ ] Solo puedo eliminar pausas de mis negocios
- [ ] Al eliminar, el horario queda disponible para citas

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Agregar Método al Repositorio**

**Archivo**: `src/repositories/business-break.repository.ts`

```typescript
async delete(id: string): Promise<void> {
  await prisma.businessBreak.delete({
    where: { id },
  });
}
```

**Criterios de verificación**:
- [ ] Método implementado

---

### **Tarea 2: Agregar Método al Servicio**

**Archivo**: `src/services/business-hours.service.ts`

```typescript
async deleteBreak(id: string, ownerId: string): Promise<void> {
  const breakItem = await businessBreakRepository.findById(id);
  if (!breakItem) {
    throw new AppError(404, "Break not found");
  }

  // Verificar permisos
  const business = await businessRepository.findById(breakItem.businessId);
  if (!business || business.ownerId !== ownerId) {
    throw new AppError(403, "You do not have permission");
  }

  await businessBreakRepository.delete(id);
}
```

**Criterios de verificación**:
- [ ] Método implementado
- [ ] Permisos verificados

---

### **Tarea 3: Crear Endpoint DELETE /api/business-hours/breaks/:id**

**Archivo**: `src/controllers/business-hours.controller.ts`

```typescript
async deleteBreak(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id;
    const userId = req.user!.id;

    await businessHoursService.deleteBreak(id, userId);

    res.json({
      success: true,
      message: "Break deleted successfully",
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

