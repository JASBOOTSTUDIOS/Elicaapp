# 📬 US-009: Ver Mis Notificaciones

## 📋 Información General

- **Épica**: Notificaciones
- **Prioridad**: P0 (Crítica)
- **Story Points**: 2
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-008 (Recibir Notificación)

---

## 📖 Historia de Usuario

**Como** usuario  
**Quiero** ver mis notificaciones  
**Para** estar al día con los eventos importantes de mi cuenta

---

## ✅ Criterios de Aceptación

- [ ] Puedo ver lista de mis notificaciones
- [ ] Las notificaciones están ordenadas por fecha (más recientes primero)
- [ ] Puedo filtrar por estado (leídas/no leídas)
- [ ] Puedo filtrar por tipo de notificación
- [ ] Puedo ver contador de notificaciones no leídas
- [ ] La lista está paginada

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear DTOs de Notificación**

**Archivo**: `src/dto/notification/notification-response.dto.ts`

```typescript
export interface NotificationResponseDto {
  id: string;
  userId: string;
  type: NotificationType;
  title: string;
  message: string;
  isRead: boolean;
  metadata?: Record<string, any>;
  createdAt: string;
  readAt?: string;
}
```

**Archivo**: `src/dto/notification/notification-query.dto.ts`

```typescript
export interface NotificationQueryDto {
  page?: number;
  limit?: number;
  isRead?: boolean;
  type?: string;
}
```

**Criterios de verificación**:
- [ ] DTOs creados

---

### **Tarea 2: Crear Repositorio de Notificaciones**

**Archivo**: `src/repositories/notification.repository.ts`

```typescript
async findManyWithPagination(
  userId: string,
  query: NotificationQueryDto
) {
  const { page = 1, limit = 10, isRead, type } = query;
  const skip = (page - 1) * limit;

  const where: Prisma.NotificationWhereInput = {
    userId,
    ...(isRead !== undefined && { isRead }),
    ...(type && { type: type as NotificationType }),
  };

  const [notifications, total] = await Promise.all([
    prisma.notification.findMany({
      where,
      skip,
      take: limit,
      orderBy: { createdAt: "desc" },
    }),
    prisma.notification.count({ where }),
  ]);

  return {
    data: notifications,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  };
}

async getUnreadCount(userId: string): Promise<number> {
  return await prisma.notification.count({
    where: {
      userId,
      isRead: false,
    },
  });
}
```

**Criterios de verificación**:
- [ ] Repositorio creado
- [ ] Paginación implementada
- [ ] Filtros funcionando

---

### **Tarea 3: Crear Servicio**

**Archivo**: `src/services/notification.service.ts`

```typescript
async findByUser(
  userId: string,
  query: NotificationQueryDto
): Promise<{
  data: NotificationResponseDto[];
  pagination: PaginationInfo;
}> {
  const result = await notificationRepository.findManyWithPagination(
    userId,
    query
  );

  return {
    data: result.data.map(this.mapToResponseDto),
    pagination: result.pagination,
  };
}

async getUnreadCount(userId: string): Promise<{ count: number }> {
  const count = await notificationRepository.getUnreadCount(userId);
  return { count };
}
```

**Criterios de verificación**:
- [ ] Servicio creado
- [ ] Métodos implementados

---

### **Tarea 4: Crear Endpoints**

**Archivo**: `src/controllers/notification.controller.ts`

```typescript
async getNotifications(req: Request, res: Response): Promise<void> {
  try {
    const userId = req.user!.id;
    const query: NotificationQueryDto = {
      page: req.query.page ? parseInt(req.query.page as string) : 1,
      limit: req.query.limit ? parseInt(req.query.limit as string) : 10,
      isRead: req.query.isRead === "true" ? true : req.query.isRead === "false" ? false : undefined,
      type: req.query.type as string,
    };

    const result = await notificationService.findByUser(userId, query);

    res.json({
      success: true,
      data: result.data,
      pagination: result.pagination,
    });
  } catch (error: any) {
    // ... manejo de errores
  }
}

async getUnreadCount(req: Request, res: Response): Promise<void> {
  try {
    const userId = req.user!.id;
    const result = await notificationService.getUnreadCount(userId);

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
- [ ] Rutas registradas

---

## 🔍 Definition of Done

- [ ] Endpoints funcionando
- [ ] Paginación funcionando
- [ ] Filtros funcionando
- [ ] Tests pasando

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_

