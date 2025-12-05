# 📧 US-029: Enviar Notificaciones por Email

## 📋 Información General

- **Épica**: Notificaciones
- **Prioridad**: P0 (Crítica)
- **Story Points**: 3
- **Sprint**: Sprint 1 - Semana 2
- **Estado**: To Do
- **Dependencias**: US-008 (Recibir Notificación)

---

## 📖 Historia de Usuario

**Como** usuario  
**Quiero** recibir notificaciones por email  
**Para** estar informado incluso cuando no estoy en la app

---

## ✅ Criterios de Aceptación

- [ ] Recibo email cuando se crea una cita
- [ ] Recibo email cuando se confirma una cita
- [ ] Recibo email cuando se cancela una cita
- [ ] Recibo email cuando se completa una cita
- [ ] El email tiene formato HTML profesional
- [ ] El email incluye información relevante de la cita

---

## 📝 Tareas Técnicas Detalladas

### **Tarea 1: Crear Servicio de Email**

**Archivo**: `src/services/email.service.ts`

```typescript
import { logger } from "../config/logger";
import { env } from "../config/env";
import { NotificationType } from "@prisma/client";
import { NotificationTemplates } from "../utils/notification-templates.util";

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
      // Ejemplo con SendGrid o similar:
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
          <title>${template.title}</title>
        </head>
        <body style="font-family: Arial, sans-serif;">
          <h2>${template.title}</h2>
          <p>${template.message}</p>
        </body>
      </html>
    `;
  }
}

export const emailService = new EmailService();
```

**Criterios de verificación**:
- [ ] Servicio creado
- [ ] Template HTML generado

---

### **Tarea 2: Integrar en NotificationService**

**Archivo**: `src/services/notification.service.ts`

En el método `create`, agregar:

```typescript
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
```

Y llamar después de crear la notificación:

```typescript
// Enviar email de notificación (asíncrono, no bloquea)
this.sendEmailNotification(notification).catch((error) => {
  logger.error("Error sending email notification:", error);
});
```

**Criterios de verificación**:
- [ ] Integración funcionando
- [ ] No bloquea el flujo principal

---

## 🔍 Definition of Done

- [ ] Emails se envían correctamente
- [ ] Templates HTML funcionando
- [ ] No bloquea el flujo principal
- [ ] Tests pasando

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_

