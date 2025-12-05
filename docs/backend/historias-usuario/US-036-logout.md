# 🚪 US-036: Cerrar Sesión (Logout)

## 📋 Información General

- **Épica**: Autenticación
- **Prioridad**: P0 (Crítica)
- **Story Points**: 1
- **Sprint**: Sprint 1 - Semana 1
- **Estado**: To Do
- **Dependencias**: US-002 (Login)

---

## 📖 Historia de Usuario

**Como** usuario autenticado  
**Quiero** cerrar mi sesión  
**Para** proteger mi cuenta cuando termine de usar la aplicación

---

## ✅ Criterios de Aceptación

- [ ] Puedo cerrar mi sesión
- [ ] El token se invalida (si se implementa blacklist)
- [ ] Se registra el evento en logs
- [ ] Recibo confirmación de logout exitoso

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear Endpoint POST /api/auth/logout**

**Archivo**: `src/controllers/auth.controller.ts`

```typescript
async logout(req: Request, res: Response): Promise<void> {
  try {
    const userId = req.user!.id;
    
    logger.info(`User logged out: ${userId}`);

    // Si se implementa blacklist de tokens, agregar aquí
    // await tokenBlacklistService.add(req.token);

    res.json({
      success: true,
      message: "Logged out successfully",
    });
  } catch (error: any) {
    // ... manejo de errores
  }
}
```

**Criterios de verificación**:
- [ ] Endpoint creado
- [ ] Ruta registrada
- [ ] Logs implementados

---

## 🔍 Definition of Done

- [ ] Endpoint funcionando
- [ ] Logs implementados
- [ ] Tests pasando

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_

