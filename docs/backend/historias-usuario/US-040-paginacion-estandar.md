# 📄 US-040: Implementar Paginación Estándar

## 📋 Información General

- **Épica**: Infraestructura
- **Prioridad**: P0 (Crítica)
- **Story Points**: 2
- **Sprint**: Sprint 1 - Semana 1
- **Estado**: To Do
- **Dependencias**: Ninguna

---

## 📖 Historia de Usuario

**Como** desarrollador  
**Quiero** tener un sistema de paginación estándar  
**Para** mantener consistencia en todas las listas

---

## ✅ Criterios de Aceptación

- [ ] Todas las listas usan el mismo formato de paginación
- [ ] La paginación incluye: page, limit, total, totalPages
- [ ] El límite por defecto es 10
- [ ] El límite máximo es 100
- [ ] La página por defecto es 1

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear DTO de Paginación**

**Archivo**: `src/dto/common/pagination.dto.ts`

```typescript
export interface PaginationQueryDto {
  page?: number;
  limit?: number;
}

export interface PaginationInfo {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: PaginationInfo;
}
```

**Criterios de verificación**:
- [ ] DTOs creados

---

### **Tarea 2: Crear Utilidad de Paginación**

**Archivo**: `src/utils/pagination.util.ts`

```typescript
export class PaginationUtil {
  static normalizeQuery(query: {
    page?: number;
    limit?: number;
  }): { page: number; limit: number; skip: number } {
    const page = Math.max(1, query.page || 1);
    const limit = Math.min(100, Math.max(1, query.limit || 10));
    const skip = (page - 1) * limit;

    return { page, limit, skip };
  }

  static createPaginationInfo(
    page: number,
    limit: number,
    total: number
  ): PaginationInfo {
    return {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    };
  }
}
```

**Criterios de verificación**:
- [ ] Utilidad creada
- [ ] Validaciones funcionando

---

### **Tarea 3: Usar en Todos los Repositorios**

Actualizar todos los repositorios para usar esta utilidad:

**Ejemplo en `src/repositories/business.repository.ts`**:

```typescript
async search(query: BusinessSearchDto) {
  const normalized = PaginationUtil.normalizeQuery({
    page: query.page,
    limit: query.limit,
  });

  // ... resto del código ...

  const [data, total] = await Promise.all([
    prisma.business.findMany({
      where,
      skip: normalized.skip,
      take: normalized.limit,
      orderBy,
    }),
    prisma.business.count({ where }),
  ]);

  return {
    data,
    pagination: PaginationUtil.createPaginationInfo(
      normalized.page,
      normalized.limit,
      total
    ),
  };
}
```

**Criterios de verificación**:
- [ ] Todos los repositorios actualizados
- [ ] Paginación consistente

---

## 🔍 Definition of Done

- [ ] Paginación estándar implementada
- [ ] Todos los endpoints usan el mismo formato
- [ ] Tests pasando

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_

