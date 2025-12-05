# ✅ US-050: Validar Email Único al Registrar

## 📋 Información General

- **Épica**: Autenticación
- **Prioridad**: P0 (Crítica)
- **Story Points**: 1
- **Sprint**: Sprint 1 - Semana 1
- **Estado**: To Do
- **Dependencias**: US-001 (Registro de Usuario)

---

## 📖 Historia de Usuario

**Como** sistema  
**Quiero** validar que el email sea único al registrar  
**Para** evitar duplicados y problemas de autenticación

---

## ✅ Criterios de Aceptación

- [ ] El sistema verifica que el email no exista antes de crear usuario
- [ ] Si el email ya existe, se retorna error 400
- [ ] El mensaje de error es claro y específico
- [ ] La validación es case-insensitive

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Mejorar Validación en AuthService**

**Archivo**: `src/services/auth.service.ts`

El método `register` ya incluye esta validación, pero asegurarse de que:

```typescript
async register(data: RegisterDto): Promise<AuthResponseDto> {
  // Normalizar email a lowercase
  const normalizedEmail = data.email.toLowerCase().trim();

  // Verificar si el usuario ya existe
  const existingUser = await userRepository.findByEmail(normalizedEmail);
  if (existingUser) {
    throw new AppError(400, "User with this email already exists");
  }

  // ... resto del código usando normalizedEmail
}
```

**Criterios de verificación**:
- [ ] Email normalizado
- [ ] Validación case-insensitive
- [ ] Error claro retornado

---

### **Tarea 2: Agregar Test de Integración**

**Archivo**: `tests/integration/auth.integration.test.ts`

```typescript
describe("POST /api/auth/register", () => {
  it("should reject duplicate email", async () => {
    // Crear primer usuario
    await request(app).post("/api/auth/register").send({
      email: "test@example.com",
      password: "Password123!",
    });

    // Intentar crear segundo usuario con mismo email
    const response = await request(app).post("/api/auth/register").send({
      email: "test@example.com",
      password: "Password123!",
    });

    expect(response.status).toBe(400);
    expect(response.body.message).toContain("already exists");
  });

  it("should reject duplicate email case-insensitive", async () => {
    // Crear primer usuario
    await request(app).post("/api/auth/register").send({
      email: "test@example.com",
      password: "Password123!",
    });

    // Intentar crear con email en mayúsculas
    const response = await request(app).post("/api/auth/register").send({
      email: "TEST@EXAMPLE.COM",
      password: "Password123!",
    });

    expect(response.status).toBe(400);
    expect(response.body.message).toContain("already exists");
  });
});
```

**Criterios de verificación**:
- [ ] Tests creados
- [ ] Tests pasando

---

## 🔍 Definition of Done

- [ ] Validación funcionando
- [ ] Case-insensitive funcionando
- [ ] Tests pasando

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_

