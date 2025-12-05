# 🗑️ US-046: Eliminar Excepción de Horario

## 📋 Información General

- **Épica**: Horarios y Disponibilidad
- **Prioridad**: P0 (Crítica)
- **Story Points**: 1
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-017 (Configurar Excepción)

---

## 📖 Historia de Usuario

**Como** propietario de negocio  
**Quiero** eliminar excepciones de horario  
**Para** restaurar el horario regular después de vacaciones

---

## ✅ Criterios de Aceptación

- [ ] Puedo eliminar una excepción específica
- [ ] Solo puedo eliminar excepciones de mis negocios
- [ ] Al eliminar, se restaura el horario regular del día

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Agregar Método al Repositorio**

**Archivo**: `src/repositories/business-hours-exception.repository.ts`

```typescript
async delete(id: string): Promise<void> {
  await prisma.businessHoursException.delete({
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
async deleteException(
  id: string,
  ownerId: string
): Promise<void> {
  const exception = await businessHoursExceptionRepository.findById(id);
  if (!exception) {
    throw new AppError(404, "Exception not found");
  }

  // Verificar permisos
  const business = await businessRepository.findById(exception.businessId);
  if (!business || business.ownerId !== ownerId) {
    throw new AppError(403, "You do not have permission");
  }

  await businessHoursExceptionRepository.delete(id);
}
```

**Criterios de verificación**:
- [ ] Método implementado
- [ ] Permisos verificados

---

### **Tarea 3: Crear Endpoint DELETE /api/business-hours/exceptions/:id**

**Archivo**: `src/controllers/business-hours.controller.ts`

```typescript
async deleteException(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id;
    const userId = req.user!.id;

    await businessHoursService.deleteException(id, userId);

    res.json({
      success: true,
      message: "Exception deleted successfully",
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

