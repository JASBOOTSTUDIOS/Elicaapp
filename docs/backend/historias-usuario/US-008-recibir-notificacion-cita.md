# 🔔 US-008: Recibir Notificación cuando se Crea una Cita

## 📋 Información General

- **Épica**: Notificaciones
- **Prioridad**: P0 (Crítica)
- **Story Points**: 2
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-005 (Agenda de Citas)

---

## 📖 Historia de Usuario

**Como** propietario de negocio  
**Quiero** recibir una notificación cuando un cliente reserva una cita  
**Para** estar informado de nuevas reservas y poder confirmarlas

---

## ✅ Criterios de Aceptación

- [ ] Recibo una notificación cuando se crea una cita en mi negocio
- [ ] La notificación incluye nombre del cliente
- [ ] La notificación incluye nombre del servicio
- [ ] La notificación incluye fecha y hora de la cita
- [ ] La notificación se marca como no leída por defecto
- [ ] Puedo ver la notificación en mi lista de notificaciones

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear Modelo de Notificación en Prisma**

**Archivo**: `prisma/schema.prisma`

Agregar modelo:

```prisma
model Notification {
  id        String             @id @default(uuid())
  userId    String             @map("user_id")
  type      NotificationType
  title     String
  message   String
  isRead    Boolean            @default(false) @map("is_read")
  metadata  Json?
  createdAt DateTime           @default(now()) @map("created_at")
  readAt    DateTime?          @map("read_at")

  user      User               @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("notifications")
  @@index([userId, isRead])
}

enum NotificationType {
  APPOINTMENT_CREATED
  APPOINTMENT_CONFIRMED
  APPOINTMENT_CANCELLED
  APPOINTMENT_REMINDER
  APPOINTMENT_COMPLETED
}
```

Ejecutar migración:

```bash
npx prisma migrate dev --name add_notifications
npx prisma generate
```

**Criterios de verificación**:
- [ ] Modelo creado
- [ ] Migración aplicada
- [ ] Relación con User establecida

---

### **Tarea 2: Crear Template de Notificación**

**Archivo**: `src/utils/notification-templates.util.ts`

```typescript
export class NotificationTemplates {
  static getTemplate(
    type: NotificationType,
    data: Record<string, any>
  ): { title: string; message: string } {
    switch (type) {
      case NotificationType.APPOINTMENT_CREATED:
        return {
          title: "Nueva Cita Creada",
          message: `${data.customerName} ha reservado ${data.serviceName} para el ${data.date}.`,
        };
      // ... otros casos
    }
  }
}
```

**Criterios de verificación**:
- [ ] Templates creados
- [ ] Formato de fecha correcto

---

### **Tarea 3: Crear Servicio de Notificaciones**

**Archivo**: `src/services/notification.service.ts`

```typescript
async createFromTemplate(
  userId: string,
  type: NotificationType,
  metadata: Record<string, any>
): Promise<Notification> {
  const template = NotificationTemplates.getTemplate(type, metadata);

  return await this.create({
    userId,
    type,
    title: template.title,
    message: template.message,
    metadata,
  });
}
```

**Criterios de verificación**:
- [ ] Servicio creado
- [ ] Método createFromTemplate implementado

---

### **Tarea 4: Integrar en AppointmentService**

**Archivo**: `src/services/appointment.service.ts`

En el método `create`, después de crear la cita:

```typescript
// Crear notificación para el dueño del negocio
await notificationService.createFromTemplate(
  service.business.ownerId,
  NotificationType.APPOINTMENT_CREATED,
  {
    appointmentId: appointment.id,
    serviceName: service.name,
    businessName: service.business.name,
    date: NotificationTemplates.formatDate(appointment.date),
    customerName: user.fullName || user.email,
  }
);
```

**Criterios de verificación**:
- [ ] Notificación creada al crear cita
- [ ] Datos correctos en metadata

---

## 🔍 Definition of Done

- [ ] Notificación se crea automáticamente
- [ ] Datos correctos en la notificación
- [ ] Tests pasando
- [ ] Integración funcionando

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_

