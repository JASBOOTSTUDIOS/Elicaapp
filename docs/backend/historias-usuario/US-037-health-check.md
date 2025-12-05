# 💚 US-037: Health Check del API

## 📋 Información General

- **Épica**: Infraestructura
- **Prioridad**: P0 (Crítica)
- **Story Points**: 1
- **Sprint**: Sprint 1 - Semana 1
- **Estado**: To Do
- **Dependencias**: Ninguna

---

## 📖 Historia de Usuario

**Como** sistema de monitoreo  
**Quiero** verificar el estado del API  
**Para** asegurar que el servicio está funcionando correctamente

---

## ✅ Criterios de Aceptación

- [ ] Existe endpoint GET /health
- [ ] El endpoint retorna estado del servidor
- [ ] El endpoint verifica conexión a base de datos
- [ ] El endpoint retorna información de versión
- [ ] El endpoint es público (no requiere autenticación)
- [ ] Response time < 100ms

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear Endpoint GET /health**

**Archivo**: `src/routes/health.routes.ts`

```typescript
import { Router, Request, Response } from "express";
import prisma from "../config/database";

const router = Router();

router.get("/", async (req: Request, res: Response) => {
  try {
    // Verificar conexión a base de datos
    await prisma.$queryRaw`SELECT 1`;

    res.json({
      status: "healthy",
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      environment: process.env.NODE_ENV,
      version: process.env.npm_package_version || "1.0.0",
    });
  } catch (error) {
    res.status(503).json({
      status: "unhealthy",
      timestamp: new Date().toISOString(),
      error: "Database connection failed",
    });
  }
});

export default router;
```

**Criterios de verificación**:
- [ ] Endpoint creado
- [ ] Ruta registrada en app.ts
- [ ] Verificación de BD funcionando

---

## 🔍 Definition of Done

- [ ] Endpoint funcionando
- [ ] Verificación de BD funcionando
- [ ] Tests pasando

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_

