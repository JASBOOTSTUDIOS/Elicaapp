# 🔍 US-011: Buscar Negocios

## 📋 Información General

- **Épica**: Búsqueda y Filtros
- **Prioridad**: P0 (Crítica)
- **Story Points**: 3
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-003 (Crear Negocio)

---

## 📖 Historia de Usuario

**Como** cliente  
**Quiero** buscar negocios por nombre, categoría o ubicación  
**Para** encontrar servicios que necesito

---

## ✅ Criterios de Aceptación

- [ ] Puedo buscar negocios por texto (nombre, descripción)
- [ ] Puedo filtrar por categoría
- [ ] Puedo filtrar por ciudad
- [ ] Puedo filtrar por estado/provincia
- [ ] Puedo filtrar por país
- [ ] Puedo ordenar por nombre, rating, fecha de creación
- [ ] Los resultados están paginados
- [ ] Solo se muestran negocios activos

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear DTO de Búsqueda**

**Archivo**: `src/dto/search/business-search.dto.ts`

```typescript
export interface BusinessSearchDto {
  search?: string;
  category?: string;
  city?: string;
  state?: string;
  country?: string;
  minRating?: number;
  maxRating?: number;
  isActive?: boolean;
  hasServices?: boolean;
  sortBy?: "name" | "rating" | "createdAt" | "appointmentCount";
  sortOrder?: "asc" | "desc";
  page?: number;
  limit?: number;
}
```

**Criterios de verificación**:
- [ ] DTO creado

---

### **Tarea 2: Crear Utilidad de Búsqueda**

**Archivo**: `src/utils/search.util.ts`

```typescript
export class SearchUtil {
  static createTextSearchFilter(
    search: string,
    fields: string[]
  ): { OR: Array<{ [key: string]: { contains: string; mode: "insensitive" } }> } | undefined {
    if (!search || search.trim() === "") {
      return undefined;
    }

    const searchTerm = search.trim();

    return {
      OR: fields.map((field) => ({
        [field]: {
          contains: searchTerm,
          mode: "insensitive" as const,
        },
      })),
    };
  }
}
```

**Criterios de verificación**:
- [ ] Utilidad creada
- [ ] Búsqueda case-insensitive funcionando

---

### **Tarea 3: Agregar Método de Búsqueda al Repositorio**

**Archivo**: `src/repositories/business.repository.ts`

```typescript
async search(query: BusinessSearchDto) {
  const {
    page = 1,
    limit = 10,
    search,
    category,
    city,
    // ... otros filtros
    sortBy = "createdAt",
    sortOrder = "desc",
  } = query;

  const skip = (page - 1) * limit;
  const where: Prisma.BusinessWhereInput = {};

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
  if (category) where.category = category;
  if (city) where.city = { contains: city, mode: "insensitive" };
  if (isActive !== undefined) where.isActive = isActive;

  // Ordenamiento
  const orderBy: Prisma.BusinessOrderByWithRelationInput = {};
  if (sortBy === "name") {
    orderBy.name = sortOrder;
  } else {
    orderBy.createdAt = sortOrder;
  }

  const [businesses, total] = await Promise.all([
    prisma.business.findMany({
      where,
      skip,
      take: limit,
      orderBy,
    }),
    prisma.business.count({ where }),
  ]);

  return {
    data: businesses,
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
- [ ] Búsqueda de texto funcionando
- [ ] Filtros funcionando
- [ ] Paginación funcionando

---

### **Tarea 4: Crear Endpoint GET /api/search/businesses**

**Archivo**: `src/controllers/search.controller.ts`

```typescript
async searchBusinesses(req: Request, res: Response): Promise<void> {
  try {
    const query: BusinessSearchDto = {
      search: req.query.search as string,
      category: req.query.category as string,
      city: req.query.city as string,
      // ... otros parámetros
      page: req.query.page ? parseInt(req.query.page as string) : 1,
      limit: req.query.limit ? parseInt(req.query.limit as string) : 10,
    };

    const result = await searchService.searchBusinesses(query);

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

