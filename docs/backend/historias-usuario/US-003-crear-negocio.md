# 🏢 US-003: Crear Negocio

## 📋 Información General

- **Épica**: Gestión de Negocios
- **Prioridad**: P0 (Crítica)
- **Story Points**: 8
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-002 (Login)

---

## 📖 Historia de Usuario

**Como** usuario autenticado  
**Quiero** poder crear un nuevo negocio  
**Para** gestionar mis servicios y citas

---

## ✅ Criterios de Aceptación

- [ ] Solo usuarios autenticados pueden crear negocios
- [ ] Se valida que todos los campos requeridos estén presentes
- [ ] Se asigna automáticamente el usuario como owner
- [ ] Se crea configuración por defecto del negocio
- [ ] Se crea tema por defecto para el negocio
- [ ] Se retorna el negocio creado con relaciones
- [ ] Se registra el evento en logs

---

## 🎯 Reglas de Negocio

1. **Un usuario puede tener múltiples negocios**
2. **El usuario creador se asigna como owner automáticamente**
3. **El negocio se crea como activo por defecto**
4. **Se debe crear un BusinessTheme por defecto**
5. **El nombre del negocio debe ser único por usuario** (opcional)

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear DTOs**

**Archivo**: `src/dto/business/create-business.dto.ts`

```typescript
export interface CreateBusinessDto {
  name: string;
  description?: string;
  type: "SALON" | "RESTAURANT" | "SPA" | "OTHER";
  address?: string;
  phone?: string;
  email?: string;
}
```

---

### **Tarea 2: Crear Validador**

**Archivo**: `src/validators/business.validator.ts`

```typescript
export const createBusinessSchema = z.object({
  name: z.string().min(2, "Name must be at least 2 characters").max(100),
  description: z.string().max(500).optional(),
  type: z.enum(["SALON", "RESTAURANT", "SPA", "OTHER"]),
  address: z.string().max(200).optional(),
  phone: z
    .string()
    .regex(/^\+?[1-9]\d{1,14}$/)
    .optional(),
  email: z.string().email().optional(),
});
```

---

### **Tarea 3: Implementar Servicio**

**Archivo**: `src/services/business.service.ts`

```typescript
async create(ownerId: string, data: CreateBusinessDto): Promise<Business> {
  logger.info(`Creating business: ${data.name} for owner: ${ownerId}`);

  // Crear negocio
  const business = await businessRepository.create({
    ...data,
    ownerId,
    isActive: true,
  });

  // Crear tema por defecto
  await prisma.businessTheme.create({
    data: {
      businessId: business.id,
      primaryColor: '#3B82F6',
      secondaryColor: '#10B981',
      accentColor: '#F59E0B',
      fontFamily: 'Inter',
    },
  });

  logger.info(`Business created: ${business.id}`);
  return business;
}
```

---

### **Tarea 4: Crear Endpoint**

**Archivo**: `src/controllers/business.controller.ts`

```typescript
async create(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) {
      res.status(401).json({ success: false, message: 'Unauthorized' });
      return;
    }

    const business = await businessService.create(req.user.id, req.body);

    res.status(201).json({
      success: true,
      data: business,
      message: 'Business created successfully',
    });
  } catch (error) {
    logger.error('Create business error:', error);
    next(error);
  }
}
```

---

## 🧪 Tests

```typescript
describe("POST /api/businesses", () => {
  it("should create a business with valid token", async () => {
    const response = await request(app)
      .post("/api/businesses")
      .set("Authorization", `Bearer ${authToken}`)
      .send({
        name: "My Salon",
        type: "SALON",
        description: "A beautiful salon",
      });

    expect(response.status).toBe(201);
    expect(response.body.success).toBe(true);
    expect(response.body.data).toHaveProperty("id");
    expect(response.body.data.name).toBe("My Salon");
  });
});
```

---

## ✅ Definition of Done

- [ ] Endpoint funcionando
- [ ] Validaciones implementadas
- [ ] Tema por defecto creado
- [ ] Tests pasando
- [ ] Documentación Swagger actualizada

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_
