# 🔐 ISSUE-002: Implementar Login de Usuario

**Labels**: `priority:P0` `epic:autenticacion` `type:feature` `sprint:sprint-01`  
**Story Points**: 3  
**Sprint**: Sprint 1 - Semana 1  
**Dependencias**: ISSUE-001 (Registro de Usuario)

---

## 📖 Descripción

Implementar el endpoint de login que permita a usuarios registrados autenticarse con email y contraseña, recibiendo tokens JWT para acceder a las funcionalidades protegidas.

**Historia de Usuario**: [US-002](../historias-usuario/US-002-login-usuario.md)

---

## ✅ Criterios de Aceptación

- [ ] Endpoint `POST /api/auth/login` funcionando
- [ ] Validación de email y contraseña implementada
- [ ] Verificación de existencia de usuario
- [ ] Verificación de contraseña correcta usando bcrypt.compare()
- [ ] Verificación de usuario activo (`isActive: true`)
- [ ] JWT access token generado (expiración: 1h)
- [ ] Refresh token generado (expiración: 7d)
- [ ] Respuesta incluye información del usuario
- [ ] Evento de login registrado en logs
- [ ] Mensaje de error genérico para credenciales inválidas (no revelar si email existe)
- [ ] Tests unitarios pasando (>80% coverage)
- [ ] Tests de integración pasando
- [ ] Documentación Swagger actualizada

---

## 📋 Checklist de Tareas

### **Backend**

- [ ] Crear DTO `LoginDto` en `src/dto/auth/login.dto.ts`
- [ ] Crear validador Zod `loginSchema` en `src/validators/auth.validator.ts`
- [ ] Implementar método `login()` en `AuthService`
  - [ ] Buscar usuario por email
  - [ ] Verificar contraseña con bcrypt.compare()
  - [ ] Verificar usuario activo
  - [ ] Generar tokens
- [ ] Crear endpoint `POST /api/auth/login` en `AuthController`
- [ ] Registrar ruta en `src/routes/auth.routes.ts`
- [ ] Crear tests unitarios para `AuthService.login()`
- [ ] Crear tests de integración para endpoint
- [ ] Actualizar documentación Swagger

### **Testing**

- [ ] Test: Login exitoso con credenciales válidas
- [ ] Test: Error con email inexistente
- [ ] Test: Error con contraseña incorrecta
- [ ] Test: Error con usuario inactivo
- [ ] Test: Tokens generados correctamente
- [ ] Test: Mensaje de error genérico para credenciales inválidas

---

## 🔗 Enlaces

- **Historia de Usuario**: [US-002](../historias-usuario/US-002-login-usuario.md)
- **Sprint**: [Sprint 1 - Semana 1](../sprints/sprint-01/semana-01/dia-03-autenticacion-jwt.md)
- **Dependencia**: [ISSUE-001](./ISSUE-001-registro-usuario.md)

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

