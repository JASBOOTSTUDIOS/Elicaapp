# 🔍 US-019: Buscar Servicios

## 📋 Información General

- **Épica**: Búsqueda y Filtros
- **Prioridad**: P0 (Crítica)
- **Story Points**: 3
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-004 (Gestión de Servicios)

---

## 📖 Historia de Usuario

**Como** cliente  
**Quiero** buscar servicios por nombre, precio o duración  
**Para** encontrar el servicio que mejor se adapte a mis necesidades

---

## ✅ Criterios de Aceptación

- [ ] Puedo buscar servicios por texto (nombre, descripción)
- [ ] Puedo filtrar por negocio
- [ ] Puedo filtrar por categoría
- [ ] Puedo filtrar por rango de precio
- [ ] Puedo filtrar por duración
- [ ] Puedo ordenar por nombre, precio, duración
- [ ] Los resultados están paginados
- [ ] Solo se muestran servicios activos

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear DTO de Búsqueda**

**Archivo**: `src/dto/search/service-search.dto.ts`

```typescript
export interface ServiceSearchDto {
  search?: string;
  businessId?: string;
  category?: string;
  minPrice?: number;
  maxPrice?: number;
  minDuration?: number;
  maxDuration?: number;
  isActive?: boolean;
  sortBy?: "name" | "price" | "duration" | "createdAt";
  sortOrder?: "asc" | "desc";
  page?: number;
  limit?: number;
}
```

**Criterios de verificación**:
- [ ] DTO creado

---

### **Tarea 2: Agregar Método de Búsqueda al Repositorio**

**Archivo**: `src/repositories/service.repository.ts`

```typescript
async search(query: ServiceSearchDto) {
  const {
    page = 1,
    limit = 10,
    search,
    businessId,
    category,
    minPrice,
    maxPrice,
    // ... otros filtros
  } = query;

  const skip = (page - 1) * limit;
  const where: Prisma.ServiceWhereInput = {};

  // Búsqueda de texto
  if (search) {
    const textSearch = SearchUtil.createTextSearchFilter(search, [
      "name",
      "description",
      "category",
    ]);
    if (textSearch) {
      where.AND = where.AND || [];
      where.AND.push(textSearch);
    }
  }

  // Filtros específicos
  if (businessId) where.businessId = businessId;
  if (category) where.category = category;

  // Filtro de precio
  if (minPrice !== undefined || maxPrice !== undefined) {
    const priceFilter = SearchUtil.createRangeFilter(minPrice, maxPrice);
    if (priceFilter) {
      where.price = priceFilter;
    }
  }

  // ... resto de filtros

  const [services, total] = await Promise.all([
    prisma.service.findMany({
      where,
      skip,
      take: limit,
      orderBy,
      include: {
        business: {
          select: {
            id: true,
            name: true,
            city: true,
          },
        },
      },
    }),
    prisma.service.count({ where }),
  ]);

  return {
    data: services,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  };
}
```

**Criterios de verificación**:
- [ ] Método implementado
- [ ] Búsqueda y filtros funcionando

---

### **Tarea 3: Crear Endpoint GET /api/search/services**

**Archivo**: `src/controllers/search.controller.ts`

```typescript
async searchServices(req: Request, res: Response): Promise<void> {
  try {
    const query: ServiceSearchDto = {
      search: req.query.search as string,
      businessId: req.query.businessId as string,
      category: req.query.category as string,
      minPrice: req.query.minPrice
        ? parseFloat(req.query.minPrice as string)
        : undefined,
      maxPrice: req.query.maxPrice
        ? parseFloat(req.query.maxPrice as string)
        : undefined,
      // ... otros parámetros
      page: req.query.page ? parseInt(req.query.page as string) : 1,
      limit: req.query.limit ? parseInt(req.query.limit as string) : 10,
    };

    const result = await searchService.searchServices(query);

    res.json({
      success: true,
      data: result.data,
      pagination: result.pagination,
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

- [ ] Búsqueda funcionando
- [ ] Filtros funcionando
- [ ] Paginación funcionando
- [ ] Tests pasando

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_

