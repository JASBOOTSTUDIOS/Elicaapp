# 📋 US-032: Listar Negocios Públicos

## 📋 Información General

- **Épica**: Negocios
- **Prioridad**: P0 (Crítica)
- **Story Points**: 2
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-003 (Crear Negocio)

---

## 📖 Historia de Usuario

**Como** cliente  
**Quiero** ver una lista de negocios disponibles  
**Para** explorar opciones antes de reservar

---

## ✅ Criterios de Aceptación

- [ ] Puedo ver lista de negocios activos
- [ ] La lista está paginada
- [ ] Puedo filtrar por categoría
- [ ] Puedo filtrar por ciudad
- [ ] Puedo ordenar por nombre, fecha de creación
- [ ] Solo se muestran negocios activos
- [ ] El endpoint es público (no requiere autenticación)

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear Endpoint GET /api/businesses**

**Archivo**: `src/controllers/business.controller.ts`

```typescript
async findAll(req: Request, res: Response): Promise<void> {
  try {
    const query: BusinessQueryDto = {
      page: req.query.page ? parseInt(req.query.page as string) : 1,
      limit: req.query.limit ? parseInt(req.query.limit as string) : 10,
      category: req.query.category as string,
      city: req.query.city as string,
      isActive: true, // Solo activos
      sortBy: (req.query.sortBy as any) || "createdAt",
      sortOrder: (req.query.sortOrder as any) || "desc",
    };

    const result = await businessService.findAll(query);

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
- [ ] Solo negocios activos

---

## 🔍 Definition of Done

- [ ] Endpoint funcionando
- [ ] Paginación funcionando
- [ ] Filtros funcionando
- [ ] Tests pasando

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_

