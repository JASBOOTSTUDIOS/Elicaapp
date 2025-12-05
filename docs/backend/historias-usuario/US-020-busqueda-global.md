# 🌐 US-020: Búsqueda Global

## 📋 Información General

- **Épica**: Búsqueda y Filtros
- **Prioridad**: P0 (Crítica)
- **Story Points**: 2
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-011 (Buscar Negocios), US-019 (Buscar Servicios)

---

## 📖 Historia de Usuario

**Como** cliente  
**Quiero** hacer una búsqueda global que busque en negocios, servicios y citas  
**Para** encontrar rápidamente lo que necesito

---

## ✅ Criterios de Aceptación

- [ ] Puedo buscar con un término único
- [ ] La búsqueda retorna resultados de negocios
- [ ] La búsqueda retorna resultados de servicios
- [ ] La búsqueda retorna resultados de mis citas (si estoy autenticado)
- [ ] Los resultados están limitados (top 5 de cada tipo)
- [ ] Los resultados están ordenados por relevancia

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear Método de Búsqueda Global**

**Archivo**: `src/services/search.service.ts`

```typescript
async globalSearch(searchTerm: string, userId?: string) {
  const [businesses, services, appointments] = await Promise.all([
    businessRepository.search({
      search: searchTerm,
      limit: 5,
    }),
    serviceRepository.search({
      search: searchTerm,
      limit: 5,
    }),
    userId
      ? appointmentRepository.search({
          search: searchTerm,
          userId,
          limit: 5,
        })
      : Promise.resolve({ data: [], pagination: {} }),
  ]);

  return {
    businesses: businesses.data,
    services: services.data,
    appointments: appointments.data,
  };
}
```

**Criterios de verificación**:
- [ ] Método implementado
- [ ] Búsqueda paralela funcionando

---

### **Tarea 2: Crear Endpoint GET /api/search/global?q=term**

**Archivo**: `src/controllers/search.controller.ts`

```typescript
async globalSearch(req: Request, res: Response): Promise<void> {
  try {
    const searchTerm = req.query.q as string;
    const userId = req.user?.id;

    if (!searchTerm || searchTerm.trim() === "") {
      res.status(400).json({
        success: false,
        message: "Search term is required",
      });
      return;
    }

    const result = await searchService.globalSearch(searchTerm, userId);

    res.json({
      success: true,
      data: result,
    });
  } catch (error: any) {
    // ... manejo de errores
  }
}
```

**Criterios de verificación**:
- [ ] Endpoint creado
- [ ] Ruta registrada (pública, opcionalmente autenticada)

---

## 🔍 Definition of Done

- [ ] Búsqueda global funcionando
- [ ] Retorna resultados de múltiples entidades
- [ ] Tests pasando

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_

