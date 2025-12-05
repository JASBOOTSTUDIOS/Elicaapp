# ✅ US-010: Marcar Notificación como Leída

## 📋 Información General

- **Épica**: Notificaciones
- **Prioridad**: P0 (Crítica)
- **Story Points**: 1
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-009 (Ver Notificaciones)

---

## 📖 Historia de Usuario

**Como** usuario  
**Quiero** marcar notificaciones como leídas  
**Para** mantener mi lista de notificaciones organizada

---

## ✅ Criterios de Aceptación

- [ ] Puedo marcar una notificación individual como leída
- [ ] Puedo marcar todas mis notificaciones como leídas
- [ ] Al marcar como leída, se guarda la fecha de lectura
- [ ] Solo puedo marcar mis propias notificaciones como leídas
- [ ] El contador de no leídas se actualiza automáticamente

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Agregar Métodos al Repositorio**

**Archivo**: `src/repositories/notification.repository.ts`

```typescript
async markAsRead(id: string, userId: string): Promise<Notification> {
  return await prisma.notification.update({
    where: {
      id,
      userId, // Asegurar que solo el dueño puede marcar como leído
    },
    data: {
      isRead: true,
      readAt: new Date(),
    },
  });
}

async markAllAsRead(userId: string): Promise<number> {
  const result = await prisma.notification.updateMany({
    where: {
      userId,
      isRead: false,
    },
    data: {
      isRead: true,
      readAt: new Date(),
    },
  });

  return result.count;
}
```

**Criterios de verificación**:
- [ ] Métodos agregados
- [ ] Validación de userId implementada

---

### **Tarea 2: Agregar Métodos al Servicio**

**Archivo**: `src/services/notification.service.ts`

```typescript
async markAsRead(id: string, userId: string): Promise<NotificationResponseDto> {
  const notification = await notificationRepository.findById(id);
  if (!notification) {
    throw new AppError(404, "Notification not found");
  }

  if (notification.userId !== userId) {
    throw new AppError(403, "You do not have permission");
  }

  const updated = await notificationRepository.markAsRead(id, userId);
  return this.mapToResponseDto(updated);
}

async markAllAsRead(userId: string): Promise<{ count: number }> {
  const count = await notificationRepository.markAllAsRead(userId);
  return { count };
}
```

**Criterios de verificación**:
- [ ] Métodos implementados
- [ ] Validación de permisos funcionando

---

### **Tarea 3: Crear Endpoints**

**Archivo**: `src/controllers/notification.controller.ts`

```typescript
async markAsRead(req: Request, res: Response): Promise<void> {
  try {
    const id = req.params.id;
    const userId = req.user!.id;

    const notification = await notificationService.markAsRead(id, userId);

    res.json({
      success: true,
      data: notification,
    });
  } catch (error: any) {
    // ... manejo de errores
  }
}

async markAllAsRead(req: Request, res: Response): Promise<void> {
  try {
    const userId = req.user!.id;
    const result = await notificationService.markAllAsRead(userId);

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
- [ ] Endpoints creados
- [ ] Rutas registradas: PUT /api/notifications/:id/read y PUT /api/notifications/read-all

---

## 🔍 Definition of Done

- [ ] Endpoints funcionando
- [ ] Validación de permisos funcionando
- [ ] Tests pasando

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_

