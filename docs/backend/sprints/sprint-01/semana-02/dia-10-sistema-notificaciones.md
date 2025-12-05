# 🔔 Día 10: Sistema de Notificaciones

## 🎯 Objetivo del Día

Implementar sistema completo de notificaciones para citas, incluyendo creación, lectura, marcado como leído y envío de notificaciones por email.

---

## ✅ Checklist de Tareas

- [ ] Crear modelo de notificaciones en Prisma
- [ ] Crear DTOs de notificaciones
- [ ] Crear repositorio de notificaciones
- [ ] Crear servicio de notificaciones
- [ ] Crear servicio de email
- [ ] Crear controlador y rutas
- [ ] Implementar templates de notificaciones
- [ ] Crear tests completos

---

## 📋 Pasos Detallados

### **Paso 1: Actualizar Schema de Prisma**

Actualizar `prisma/schema.prisma` para agregar modelo de notificaciones:

```prisma
// Notificación del sistema
model Notification {
  id        String             @id @default(uuid())
  userId    String             @map("user_id")
  type      NotificationType
  title     String
  message   String
  isRead    Boolean            @default(false) @map("is_read")
  metadata  Json?              // Datos adicionales (ej: appointmentId, businessId)
  createdAt DateTime           @default(now()) @map("created_at")
  readAt    DateTime?          @map("read_at")

  // Relaciones
  user      User               @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("notifications")
  @@index([userId, isRead])
  @@index([userId, createdAt])
}

enum NotificationType {
  APPOINTMENT_CREATED
  APPOINTMENT_CONFIRMED
  APPOINTMENT_CANCELLED
  APPOINTMENT_REMINDER
  APPOINTMENT_COMPLETED
  BUSINESS_CREATED
  SERVICE_CREATED
  WELCOME
  PASSWORD_CHANGED
}
```

Actualizar modelo User para agregar relación:

```prisma
model User {
  // ... existing fields ...
  
  notifications Notification[]
  
  // ... rest of model ...
}
```

Ejecutar migración:

```bash
npx prisma migrate dev --name add_notifications
npx prisma generate
```

### **Paso 2: Crear DTOs de Notificaciones**

Crear archivo `src/dto/notification/create-notification.dto.ts`:

```typescript
import { NotificationType } from "@prisma/client";

export interface CreateNotificationDto {
  userId: string;
  type: NotificationType;
  title: string;
  message: string;
  metadata?: Record<string, any>;
}
```

Crear archivo `src/dto/notification/notification-response.dto.ts`:

```typescript
import { NotificationType } from "@prisma/client";

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

Crear archivo `src/dto/notification/notification-query.dto.ts`:

```typescript
export interface NotificationQueryDto {
  page?: number;
  limit?: number;
  isRead?: boolean;
  type?: string;
}
```

### **Paso 3: Crear Repositorio de Notificaciones**

Crear archivo `src/repositories/notification.repository.ts`:

```typescript
import prisma from "../config/database";
import { Notification, NotificationType, Prisma } from "@prisma/client";
import { BaseRepository } from "./base.repository";
import { NotificationQueryDto } from "../dto/notification/notification-query.dto";

export class NotificationRepository extends BaseRepository<Notification> {
  protected getModel() {
    return prisma.notification;
  }

  async findByUserId(userId: string): Promise<Notification[]> {
    return await prisma.notification.findMany({
      where: { userId },
      orderBy: { createdAt: "desc" },
    });
  }

  async findManyWithPagination(
    userId: string,
    query: NotificationQueryDto
  ) {
    const {
      page = 1,
      limit = 10,
      isRead,
      type,
    } = query;

    const skip = (page - 1) * limit;

    const where: Prisma.NotificationWhereInput = {
      userId,
    };

    if (isRead !== undefined) {
      where.isRead = isRead;
    }

    if (type) {
      where.type = type as NotificationType;
    }

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

  async getUnreadCount(userId: string): Promise<number> {
    return await prisma.notification.count({
      where: {
        userId,
        isRead: false,
      },
    });
  }
}

export const notificationRepository = new NotificationRepository();
```

### **Paso 4: Crear Templates de Notificaciones**

Crear archivo `src/utils/notification-templates.util.ts`:

```typescript
import { NotificationType } from "@prisma/client";

export interface NotificationTemplate {
  title: string;
  message: string;
}

export class NotificationTemplates {
  static getTemplate(
    type: NotificationType,
    data: Record<string, any>
  ): NotificationTemplate {
    switch (type) {
      case NotificationType.APPOINTMENT_CREATED:
        return {
          title: "Cita Creada",
          message: `Tu cita para ${data.serviceName} en ${data.businessName} ha sido creada para el ${data.date}.`,
        };

      case NotificationType.APPOINTMENT_CONFIRMED:
        return {
          title: "Cita Confirmada",
          message: `Tu cita para ${data.serviceName} en ${data.businessName} ha sido confirmada para el ${data.date}.`,
        };

      case NotificationType.APPOINTMENT_CANCELLED:
        return {
          title: "Cita Cancelada",
          message: `Tu cita para ${data.serviceName} en ${data.businessName} programada para el ${data.date} ha sido cancelada.`,
        };

      case NotificationType.APPOINTMENT_REMINDER:
        return {
          title: "Recordatorio de Cita",
          message: `Recordatorio: Tienes una cita para ${data.serviceName} en ${data.businessName} mañana a las ${data.time}.`,
        };

      case NotificationType.APPOINTMENT_COMPLETED:
        return {
          title: "Cita Completada",
          message: `Tu cita para ${data.serviceName} en ${data.businessName} ha sido completada. ¡Gracias por tu visita!`,
        };

      case NotificationType.BUSINESS_CREATED:
        return {
          title: "Negocio Creado",
          message: `Tu negocio "${data.businessName}" ha sido creado exitosamente. ¡Comienza a configurar tus servicios!`,
        };

      case NotificationType.SERVICE_CREATED:
        return {
          title: "Servicio Creado",
          message: `El servicio "${data.serviceName}" ha sido creado en tu negocio "${data.businessName}".`,
        };

      case NotificationType.WELCOME:
        return {
          title: "¡Bienvenido a ElicaApp!",
          message: `Hola ${data.userName}, gracias por unirte a ElicaApp. ¡Comienza a explorar nuestros servicios!`,
        };

      case NotificationType.PASSWORD_CHANGED:
        return {
          title: "Contraseña Cambiada",
          message: `Tu contraseña ha sido cambiada exitosamente. Si no realizaste este cambio, contacta a soporte inmediatamente.`,
        };

      default:
        return {
          title: "Notificación",
          message: "Tienes una nueva notificación.",
        };
    }
  }

  static formatDate(date: Date | string): string {
    const d = typeof date === "string" ? new Date(date) : date;
    return d.toLocaleDateString("es-ES", {
      year: "numeric",
      month: "long",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  }
}
```

### **Paso 5: Crear Servicio de Email**

Crear archivo `src/services/email.service.ts`:

```typescript
import { logger } from "../config/logger";
import { env } from "../config/env";
import { NotificationType } from "@prisma/client";
import { NotificationTemplates } from "../utils/notification-templates.util";

// Nota: En producción, usar un servicio como SendGrid, AWS SES, o Resend
// Por ahora, solo logueamos el email

export class EmailService {
  async sendNotificationEmail(
    email: string,
    type: NotificationType,
    data: Record<string, any>
  ): Promise<void> {
    try {
      const template = NotificationTemplates.getTemplate(type, data);

      // En desarrollo, solo logueamos
      if (env.NODE_ENV === "development") {
        logger.info("Email notification (dev mode):", {
          to: email,
          subject: template.title,
          body: template.message,
        });
        return;
      }

      // En producción, enviar email real
      // Ejemplo con SendGrid:
      // await sgMail.send({
      //   to: email,
      //   from: env.EMAIL_FROM,
      //   subject: template.title,
      //   text: template.message,
      //   html: this.generateHtmlEmail(template),
      // });

      logger.info(`Email sent to ${email}: ${template.title}`);
    } catch (error) {
      logger.error("Error sending email:", error);
      // No lanzar error para no interrumpir el flujo principal
    }
  }

  private generateHtmlEmail(template: { title: string; message: string }): string {
    return `
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>${template.title}</title>
        </head>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
          <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
            <h2 style="color: #3B82F6;">${template.title}</h2>
            <p>${template.message}</p>
            <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
            <p style="font-size: 12px; color: #666;">
              Este es un email automático de ElicaApp. Por favor no respondas a este mensaje.
            </p>
          </div>
        </body>
      </html>
    `;
  }
}

export const emailService = new EmailService();
```

### **Paso 6: Crear Servicio de Notificaciones**

Crear archivo `src/services/notification.service.ts`:

```typescript
import { notificationRepository } from "../repositories/notification.repository";
import { userRepository } from "../repositories/user.repository";
import { CreateNotificationDto } from "../dto/notification/create-notification.dto";
import { NotificationQueryDto } from "../dto/notification/notification-query.dto";
import { NotificationResponseDto } from "../dto/notification/notification-response.dto";
import { NotificationTemplates } from "../utils/notification-templates.util";
import { emailService } from "./email.service";
import { AppError } from "../middleware/error.middleware";
import { logger } from "../config/logger";
import { Notification, NotificationType } from "@prisma/client";

export class NotificationService {
  async create(data: CreateNotificationDto): Promise<Notification> {
    logger.info(`Creating notification for user: ${data.userId}, type: ${data.type}`);

    const notification = await notificationRepository.create({
      userId: data.userId,
      type: data.type,
      title: data.title,
      message: data.message,
      metadata: data.metadata || {},
      isRead: false,
    });

    // Enviar email de notificación (asíncrono, no bloquea)
    this.sendEmailNotification(notification).catch((error) => {
      logger.error("Error sending email notification:", error);
    });

    logger.info(`Notification created: ${notification.id}`);
    return notification;
  }

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

  async findByUser(
    userId: string,
    query: NotificationQueryDto
  ): Promise<{
    data: NotificationResponseDto[];
    pagination: {
      page: number;
      limit: number;
      total: number;
      totalPages: number;
    };
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

  async markAsRead(id: string, userId: string): Promise<NotificationResponseDto> {
    const notification = await notificationRepository.findById(id);
    if (!notification) {
      throw new AppError(404, "Notification not found");
    }

    if (notification.userId !== userId) {
      throw new AppError(403, "You do not have permission to mark this notification as read");
    }

    const updated = await notificationRepository.markAsRead(id, userId);
    return this.mapToResponseDto(updated);
  }

  async markAllAsRead(userId: string): Promise<{ count: number }> {
    const count = await notificationRepository.markAllAsRead(userId);
    return { count };
  }

  async getUnreadCount(userId: string): Promise<{ count: number }> {
    const count = await notificationRepository.getUnreadCount(userId);
    return { count };
  }

  private async sendEmailNotification(notification: Notification): Promise<void> {
    const user = await userRepository.findById(notification.userId);
    if (!user || !user.email) {
      return;
    }

    await emailService.sendNotificationEmail(
      user.email,
      notification.type,
      notification.metadata as Record<string, any> || {}
    );
  }

  private mapToResponseDto(notification: Notification): NotificationResponseDto {
    return {
      id: notification.id,
      userId: notification.userId,
      type: notification.type,
      title: notification.title,
      message: notification.message,
      isRead: notification.isRead,
      metadata: notification.metadata as Record<string, any> || undefined,
      createdAt: notification.createdAt.toISOString(),
      readAt: notification.readAt?.toISOString(),
    };
  }
}

export const notificationService = new NotificationService();
```

### **Paso 7: Integrar Notificaciones en Servicios Existentes**

Actualizar `src/services/appointment.service.ts` para crear notificaciones:

```typescript
// ... existing imports ...
import { notificationService } from "./notification.service";
import { NotificationType } from "@prisma/client";

export class AppointmentService {
  // ... existing methods ...

  async create(
    userId: string,
    data: CreateAppointmentDto
  ): Promise<Appointment> {
    // ... existing validation code ...

    const appointment = await appointmentRepository.create({
      // ... existing code ...
    });

    // Crear notificación para el cliente
    await notificationService.createFromTemplate(
      userId,
      NotificationType.APPOINTMENT_CREATED,
      {
        appointmentId: appointment.id,
        serviceName: service.name,
        businessName: service.business.name,
        date: NotificationTemplates.formatDate(appointment.date),
      }
    );

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

    logger.info(`Appointment created: ${appointment.id}`);
    return appointment;
  }

  async updateStatus(
    id: string,
    status: AppointmentStatus,
    userId: string
  ): Promise<Appointment> {
    // ... existing code ...

    const updated = await appointmentRepository.update(id, { status });

    // Crear notificación según el nuevo estado
    let notificationType: NotificationType;
    switch (status) {
      case AppointmentStatus.CONFIRMED:
        notificationType = NotificationType.APPOINTMENT_CONFIRMED;
        break;
      case AppointmentStatus.CANCELLED:
        notificationType = NotificationType.APPOINTMENT_CANCELLED;
        break;
      case AppointmentStatus.COMPLETED:
        notificationType = NotificationType.APPOINTMENT_COMPLETED;
        break;
      default:
        return updated;
    }

    await notificationService.createFromTemplate(
      appointment.userId,
      notificationType,
      {
        appointmentId: updated.id,
        serviceName: appointment.service.name,
        businessName: appointment.business.name,
        date: NotificationTemplates.formatDate(updated.date),
      }
    );

    return updated;
  }
}
```

### **Paso 8: Crear Controlador de Notificaciones**

Crear archivo `src/controllers/notification.controller.ts`:

```typescript
import { Request, Response } from "express";
import { notificationService } from "../services/notification.service";
import { NotificationQueryDto } from "../dto/notification/notification-query.dto";
import { logger } from "../config/logger";

export class NotificationController {
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
      logger.error("Error getting notifications:", error);
      res.status(error.statusCode || 500).json({
        success: false,
        message: error.message || "Error getting notifications",
      });
    }
  }

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
      logger.error("Error marking notification as read:", error);
      res.status(error.statusCode || 500).json({
        success: false,
        message: error.message || "Error marking notification as read",
      });
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
      logger.error("Error marking all notifications as read:", error);
      res.status(error.statusCode || 500).json({
        success: false,
        message: error.message || "Error marking all notifications as read",
      });
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
      logger.error("Error getting unread count:", error);
      res.status(error.statusCode || 500).json({
        success: false,
        message: error.message || "Error getting unread count",
      });
    }
  }
}

export const notificationController = new NotificationController();
```

### **Paso 9: Crear Rutas de Notificaciones**

Crear archivo `src/routes/notification.routes.ts`:

```typescript
import { Router } from "express";
import { notificationController } from "../controllers/notification.controller";
import { authMiddleware } from "../middleware/auth.middleware";

const router = Router();

// Todas las rutas requieren autenticación
router.use(authMiddleware);

// GET /api/notifications
router.get(
  "/",
  notificationController.getNotifications.bind(notificationController)
);

// GET /api/notifications/unread-count
router.get(
  "/unread-count",
  notificationController.getUnreadCount.bind(notificationController)
);

// PUT /api/notifications/:id/read
router.put(
  "/:id/read",
  notificationController.markAsRead.bind(notificationController)
);

// PUT /api/notifications/read-all
router.put(
  "/read-all",
  notificationController.markAllAsRead.bind(notificationController)
);

export default router;
```

### **Paso 10: Registrar Rutas en App**

Actualizar `src/app.ts`:

```typescript
// ... existing imports ...
import notificationRoutes from "./routes/notification.routes";

// ... existing code ...

app.use("/api/notifications", notificationRoutes);

// ... existing code ...
```

### **Paso 11: Crear Tests**

Crear archivo `tests/services/notification.service.test.ts`:

```typescript
import { NotificationService } from "../../src/services/notification.service";
import { notificationRepository } from "../../src/repositories/notification.repository";
import { NotificationType } from "@prisma/client";

jest.mock("../../src/repositories/notification.repository");
jest.mock("../../src/services/email.service");

describe("NotificationService", () => {
  let notificationService: NotificationService;

  beforeEach(() => {
    notificationService = new NotificationService();
    jest.clearAllMocks();
  });

  describe("create", () => {
    it("should create a notification", async () => {
      // Arrange
      const createDto = {
        userId: "user-1",
        type: NotificationType.APPOINTMENT_CREATED,
        title: "Test Title",
        message: "Test Message",
      };

      const mockNotification = {
        id: "notif-1",
        ...createDto,
        isRead: false,
        createdAt: new Date(),
      };

      (notificationRepository.create as jest.Mock).mockResolvedValue(mockNotification);

      // Act
      const result = await notificationService.create(createDto);

      // Assert
      expect(result).toEqual(mockNotification);
      expect(notificationRepository.create).toHaveBeenCalledWith(
        expect.objectContaining({
          userId: createDto.userId,
          type: createDto.type,
          title: createDto.title,
          message: createDto.message,
        })
      );
    });
  });

  describe("markAsRead", () => {
    it("should mark notification as read", async () => {
      // Arrange
      const notificationId = "notif-1";
      const userId = "user-1";

      const mockNotification = {
        id: notificationId,
        userId,
        isRead: false,
      };

      const mockUpdated = {
        ...mockNotification,
        isRead: true,
        readAt: new Date(),
      };

      (notificationRepository.findById as jest.Mock).mockResolvedValue(mockNotification);
      (notificationRepository.markAsRead as jest.Mock).mockResolvedValue(mockUpdated);

      // Act
      const result = await notificationService.markAsRead(notificationId, userId);

      // Assert
      expect(result.isRead).toBe(true);
      expect(notificationRepository.markAsRead).toHaveBeenCalledWith(notificationId, userId);
    });
  });
});
```

---

## ✅ Verificación Final

- [ ] Sistema de notificaciones funcionando
- [ ] Templates de notificaciones implementados
- [ ] Envío de emails configurado
- [ ] Integración con servicios existentes
- [ ] Tests pasando

---

## 📝 Entregables del Día

1. ✅ Modelo de notificaciones en base de datos
2. ✅ CRUD completo de notificaciones
3. ✅ Sistema de templates
4. ✅ Servicio de email básico
5. ✅ Integración con servicios existentes
6. ✅ Tests completos

---

## 🎯 Próximo Día

**Día 11**: Búsqueda y Filtros Avanzados

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_

