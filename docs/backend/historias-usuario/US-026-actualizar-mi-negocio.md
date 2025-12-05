# ✏️ US-026: Actualizar Información de mi Negocio

## 📋 Información General

- **Épica**: Negocios
- **Prioridad**: P0 (Crítica)
- **Story Points**: 3
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-003 (Crear Negocio)

---

## 📖 Historia de Usuario

**Como** propietario de negocio  
**Quiero** actualizar la información de mi negocio  
**Para** mantener los datos actualizados

---

## ✅ Criterios de Aceptación

- [ ] Puedo actualizar nombre del negocio
- [ ] Puedo actualizar descripción
- [ ] Puedo actualizar categoría
- [ ] Puedo actualizar información de contacto (teléfono, email)
- [ ] Puedo actualizar dirección
- [ ] Solo puedo actualizar mis propios negocios

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear DTO de Actualización**

**Archivo**: `src/dto/business/update-business.dto.ts`

```typescript
export interface UpdateBusinessDto {
  name?: string;
  description?: string;
  category?: string;
  phone?: string;
  email?: string;
  address?: string;
  city?: string;
  state?: string;
  country?: string;
  zipCode?: string;
}
```

**Criterios de verificación**:
- [ ] DTO creado

---

### **Tarea 2: Crear Validador**

**Archivo**: `src/validators/business.validator.ts`

```typescript
export const updateBusinessSchema = z.object({
  name: z.string().min(2).max(100).optional(),
  description: z.string().max(1000).optional(),
  category: z.string().max(50).optional(),
  phone: z.string().regex(/^\+?[1-9]\d{1,14}$/).optional(),
  email: z.string().email().optional(),
  // ... otros campos
});
```

**Criterios de verificación**:
- [ ] Validador creado

---

### **Tarea 3: Agregar Método al Servicio**

**Archivo**: `src/services/business.service.ts`

```typescript
async update(
  id: string,
  ownerId: string,
  data: UpdateBusinessDto
): Promise<Business> {
  // Verificar permisos
  const business = await businessRepository.findById(id);
  if (!business || business.ownerId !== ownerId) {
    throw new AppError(403, "You do not have permission");
  }

  return await businessRepository.update(id, data);
}
```

**Criterios de verificación**:
- [ ] Método implementado
- [ ] Permisos verificados

---

### **Tarea 4: Crear Endpoint PUT /api/businesses/:id**

**Archivo**: `src/controllers/business.controller.ts`

```typescript
async update(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id;
    const userId = req.user!.id;
    const validatedData = updateBusinessSchema.parse(req.body);

    const business = await businessService.update(id, userId, validatedData);

    res.json({
      success: true,
      data: business,
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
- [ ] Validaciones funcionando
- [ ] Permisos verificados
- [ ] Tests pasando

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_

