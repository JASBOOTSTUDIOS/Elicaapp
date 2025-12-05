# 📅 US-039: Filtrar Citas por Rango de Fechas

## 📋 Información General

- **Épica**: Sistema de Citas
- **Prioridad**: P0 (Crítica)
- **Story Points**: 1
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-024 (Ver Mis Citas), US-025 (Ver Citas de Negocio)

---

## 📖 Historia de Usuario

**Como** usuario  
**Quiero** filtrar mis citas por rango de fechas  
**Para** ver solo las citas de un período específico

---

## ✅ Criterios de Aceptación

- [ ] Puedo filtrar citas por fecha de inicio
- [ ] Puedo filtrar citas por fecha de fin
- [ ] Puedo filtrar por rango de fechas (inicio y fin)
- [ ] El filtro funciona en mis citas personales
- [ ] El filtro funciona en citas de mi negocio

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Mejorar Utilidad de Búsqueda**

**Archivo**: `src/utils/search.util.ts`

El método `createDateRangeFilter` ya existe, solo asegurarse de que funciona correctamente:

```typescript
static createDateRangeFilter(
  startDate?: string,
  endDate?: string
): { gte?: Date; lte?: Date } | undefined {
  if (!startDate && !endDate) {
    return undefined;
  }

  const filter: { gte?: Date; lte?: Date } = {};
  if (startDate) {
    filter.gte = new Date(startDate);
    filter.gte.setHours(0, 0, 0, 0);
  }
  if (endDate) {
    filter.lte = new Date(endDate);
    filter.lte.setHours(23, 59, 59, 999);
  }

  return filter;
}
```

**Criterios de verificación**:
- [ ] Utilidad funcionando correctamente

---

### **Tarea 2: Integrar en Búsqueda de Citas**

Ya está integrado en `appointmentRepository.search()`, solo verificar que funciona:

**Archivo**: `src/repositories/appointment.repository.ts`

El método `search` ya incluye:

```typescript
// Filtro de rango de fechas
if (startDate || endDate) {
  const dateFilter = SearchUtil.createDateRangeFilter(startDate, endDate);
  if (dateFilter) {
    where.date = dateFilter;
  }
}
```

**Criterios de verificación**:
- [ ] Filtro funcionando en búsqueda

---

## 🔍 Definition of Done

- [ ] Filtro por fecha funcionando
- [ ] Tests pasando

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_

