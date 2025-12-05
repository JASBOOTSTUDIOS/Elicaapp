# 📋 US-043: Listar Mis Negocios

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
**Quiero** ver lista de todos mis negocios  
**Para** gestionar múltiples negocios desde un solo lugar

---

## ✅ Criterios de Aceptación

- [ ] Puedo ver lista de todos mis negocios
- [ ] La lista está paginada
- [ ] Puedo filtrar por estado (activo/inactivo)
- [ ] Puedo buscar por nombre
- [ ] Puedo ordenar por nombre o fecha de creación
- [ ] Solo veo mis propios negocios

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Agregar Método al Repositorio**

**Archivo**: `src/repositories/business.repository.ts`

```typescript
async findByOwnerId(
  ownerId: string,
  query: {
    page?: number;
    limit?: number;
    search?: string;
    isActive?: boolean;
    sortBy?: string;
    sortOrder?: "asc" | "desc";
  }
) {
  const normalized = PaginationUtil.normalizeQuery({
    page: query.page,
    limit: query.limit,
  });

  const where: Prisma.BusinessWhereInput = {
    ownerId,
    ...(query.search && {
      OR: [
        { name: { contains: query.search, mode: "insensitive" } },
        { description: { contains: query.search, mode: "insensitive" } },
      ],
    }),
    ...(query.isActive !== undefined && { isActive: query.isActive }),
  };

  const orderBy: Prisma.BusinessOrderByWithRelationInput = {};
  if (query.sortBy === "name") {
    orderBy.name = query.sortOrder || "asc";
  } else {
    orderBy.createdAt = query.sortOrder || "desc";
  }

  const [businesses, total] = await Promise.all([
    prisma.business.findMany({
      where,
      skip: normalized.skip,
      take: normalized.limit,
      orderBy,
    }),
    prisma.business.count({ where }),
  ]);

  return {
    data: businesses,
    pagination: PaginationUtil.createPaginationInfo(
      normalized.page,
      normalized.limit,
      total
    ),
  };
}
```

**Criterios de verificación**:
- [ ] Método implementado
- [ ] Filtros funcionando

---

### **Tarea 2: Crear Endpoint GET /api/businesses/my-businesses**

**Archivo**: `src/controllers/business.controller.ts`

```typescript
async getMyBusinesses(req: Request, res: Response): Promise<void> {
  try {
    const userId = req.user!.id;
    const query = {
      page: req.query.page ? parseInt(req.query.page as string) : 1,
      limit: req.query.limit ? parseInt(req.query.limit as string) : 10,
      search: req.query.search as string,
      isActive:
        req.query.isActive === "true"
          ? true
          : req.query.isActive === "false"
          ? false
          : undefined,
      sortBy: (req.query.sortBy as any) || "createdAt",
      sortOrder: (req.query.sortOrder as any) || "desc",
    };

    const result = await businessService.findByOwnerId(userId, query);

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
- [ ] Ruta registrada

---

## 🔍 Definition of Done

- [ ] Endpoint funcionando
- [ ] Filtros funcionando
- [ ] Paginación funcionando
- [ ] Tests pasando

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_

