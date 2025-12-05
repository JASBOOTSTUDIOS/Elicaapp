# 🏢 ISSUE-003: Implementar Creación de Negocio

**Labels**: `priority:P0` `epic:negocios` `type:feature` `sprint:sprint-01`  
**Story Points**: 8  
**Sprint**: Sprint 1 - Semana 2  
**Dependencias**: ISSUE-002 (Login de Usuario)

---

## 📖 Descripción

Implementar el endpoint para crear negocios, permitiendo a usuarios autenticados registrar sus negocios con información completa (nombre, descripción, categoría, dirección, contacto).

**Historia de Usuario**: [US-003](../historias-usuario/US-003-crear-negocio.md)

---

## ✅ Criterios de Aceptación

- [ ] Endpoint `POST /api/businesses` funcionando
- [ ] Requiere autenticación (JWT token)
- [ ] Validación de datos de entrada (nombre, categoría, dirección)
- [ ] Negocio creado con `ownerId` del usuario autenticado
- [ ] Negocio creado con `isActive: true` por defecto
- [ ] Tema por defecto creado automáticamente
- [ ] Respuesta incluye información completa del negocio creado
- [ ] Evento registrado en logs
- [ ] Tests unitarios pasando (>80% coverage)
- [ ] Tests de integración pasando
- [ ] Documentación Swagger actualizada

---

## 📋 Checklist de Tareas

### **Backend**

- [ ] Crear DTO `CreateBusinessDto` en `src/dto/business/create-business.dto.ts`
- [ ] Crear validador Zod `createBusinessSchema` en `src/validators/business.validator.ts`
- [ ] Implementar método `create()` en `BusinessService`
  - [ ] Validar datos
  - [ ] Crear negocio
  - [ ] Crear tema por defecto
- [ ] Crear endpoint `POST /api/businesses` en `BusinessController`
- [ ] Registrar ruta en `src/routes/business.routes.ts`
- [ ] Aplicar middleware de autenticación
- [ ] Crear tests unitarios para `BusinessService.create()`
- [ ] Crear tests de integración para endpoint
- [ ] Actualizar documentación Swagger

### **Testing**

- [ ] Test: Crear negocio exitosamente
- [ ] Test: Error con datos inválidos
- [ ] Test: Error sin autenticación
- [ ] Test: Tema por defecto creado
- [ ] Test: OwnerId asignado correctamente

---

## 🔗 Enlaces

- **Historia de Usuario**: [US-003](../historias-usuario/US-003-crear-negocio.md)
- **Sprint**: [Sprint 1 - Semana 2](../sprints/sprint-01/semana-02/dia-06-api-usuarios.md)
- **Dependencia**: [ISSUE-002](./ISSUE-002-login-usuario.md)

---

## 🎯 Definition of Done

- [ ] Código implementado y revisado
- [ ] Tests unitarios pasando (>80% coverage)
- [ ] Tests de integración pasando
- [ ] Validaciones funcionando
- [ ] Documentación Swagger actualizada
- [ ] Logs implementados
- [ ] Manejo de errores correcto
- [ ] Code review aprobado

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_

