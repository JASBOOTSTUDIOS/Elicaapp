# 👤 ISSUE-001: Implementar Registro de Usuario

**Labels**: `priority:P0` `epic:autenticacion` `type:feature` `sprint:sprint-01`  
**Story Points**: 5  
**Sprint**: Sprint 1 - Semana 1  
**Dependencias**: Ninguna

---

## 📖 Descripción

Implementar el endpoint de registro de usuarios que permita crear nuevas cuentas con email y contraseña, generando tokens JWT para autenticación.

**Historia de Usuario**: [US-001](../historias-usuario/US-001-registro-usuario.md)

---

## ✅ Criterios de Aceptación

- [ ] Endpoint `POST /api/auth/register` funcionando
- [ ] Validación de email único implementada
- [ ] Validación de contraseña segura (mínimo 8 caracteres, mayúsculas, números, caracteres especiales)
- [ ] Contraseña hasheada con bcrypt (10 salt rounds) antes de guardar
- [ ] Usuario creado con rol `CUSTOMER` por defecto
- [ ] Usuario creado con `isActive: true`
- [ ] JWT access token generado (expiración: 1h)
- [ ] Refresh token generado (expiración: 7d)
- [ ] Respuesta incluye información del usuario (sin contraseña)
- [ ] Evento registrado en logs
- [ ] Tests unitarios pasando (>80% coverage)
- [ ] Tests de integración pasando
- [ ] Documentación Swagger actualizada

---

## 📋 Checklist de Tareas

### **Backend**

- [ ] Crear DTO `RegisterDto` en `src/dto/auth/register.dto.ts`
- [ ] Crear validador Zod `registerSchema` en `src/validators/auth.validator.ts`
- [ ] Implementar método `register()` en `AuthService`
  - [ ] Verificar email único
  - [ ] Validar contraseña
  - [ ] Hash de contraseña
  - [ ] Crear usuario
  - [ ] Generar tokens
- [ ] Crear endpoint `POST /api/auth/register` en `AuthController`
- [ ] Registrar ruta en `src/routes/auth.routes.ts`
- [ ] Crear tests unitarios para `AuthService.register()`
- [ ] Crear tests de integración para endpoint
- [ ] Actualizar documentación Swagger

### **Testing**

- [ ] Test: Registro exitoso con datos válidos
- [ ] Test: Error al registrar email duplicado
- [ ] Test: Error con contraseña inválida
- [ ] Test: Error con email inválido
- [ ] Test: Contraseña hasheada correctamente
- [ ] Test: Tokens generados correctamente
- [ ] Test: Respuesta no incluye contraseña

---

## 🔗 Enlaces

- **Historia de Usuario**: [US-001](../historias-usuario/US-001-registro-usuario.md)
- **Sprint**: [Sprint 1 - Semana 1](../sprints/sprint-01/semana-01/dia-03-autenticacion-jwt.md)
- **Arquitectura**: [ARQUITECTURA.md](../ARQUITECTURA.md)

---

## 📝 Notas

- El email debe ser único en toda la aplicación
- La contraseña nunca debe ser retornada en respuestas
- Los tokens deben tener tiempo de expiración configurado
- Todos los errores deben ser logueados

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