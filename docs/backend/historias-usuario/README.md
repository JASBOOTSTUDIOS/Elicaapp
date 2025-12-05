# 👥 Historias de Usuario Detalladas - Backend

## 🎯 Propósito

Este directorio contiene historias de usuario detalladas con instrucciones paso a paso para desarrolladores junior. Cada historia incluye:

- ✅ Criterios de aceptación claros
- 📝 Tareas técnicas detalladas
- 💻 Ejemplos de código
- 🧪 Tests a escribir
- ✅ Checklists de verificación

---

## 📁 Estructura

Cada historia de usuario está en un archivo separado con el formato:

```
US-XXX-nombre-historia.md
```

---

## 📋 Historias Disponibles

### **🔴 P0 - Críticas (MVP) - Autenticación y Usuarios**

1. **[US-001: Registro de Usuario](./US-001-registro-usuario.md)**

   - Story Points: 5
   - Sprint: Sprint 1 - Semana 1
   - Dependencias: Ninguna

2. **[US-002: Login de Usuario](./US-002-login-usuario.md)**
   - Story Points: 3
   - Sprint: Sprint 1 - Semana 1
   - Dependencias: US-001

### **🔴 P0 - Críticas (MVP) - Negocios y Servicios**

3. **[US-003: Crear Negocio](./US-003-crear-negocio.md)**

   - Story Points: 8
   - Sprint: Sprint 1 - Semana 2
   - Dependencias: US-002

4. **[US-004: Gestión de Servicios](./US-004-gestion-servicios.md)**
   - Story Points: 5
   - Sprint: Sprint 1 - Semana 2
   - Dependencias: US-003

### **🔴 P0 - Críticas (MVP) - Citas**

5. **[US-005: Agenda de Citas](./US-005-agenda-citas.md)**
   - Story Points: 8
   - Sprint: Sprint 1 - Semana 2
   - Dependencias: US-004

### **🔴 P0 - Críticas (MVP) - Dashboard y Métricas**

6. **[US-006: Ver Estadísticas de mi Negocio](./US-006-ver-estadisticas-negocio.md)**

   - Story Points: 3
   - Sprint: Sprint 1 - Semana 2
   - Dependencias: US-003, US-005

7. **[US-007: Ver Mis Estadísticas como Usuario](./US-007-ver-estadisticas-usuario.md)**
   - Story Points: 2
   - Sprint: Sprint 1 - Semana 2
   - Dependencias: US-002, US-005

### **🔴 P0 - Críticas (MVP) - Notificaciones**

8. **[US-008: Recibir Notificación cuando se Crea una Cita](./US-008-recibir-notificacion-cita.md)**

   - Story Points: 2
   - Sprint: Sprint 1 - Semana 2
   - Dependencias: US-005

9. **[US-009: Ver Mis Notificaciones](./US-009-ver-mis-notificaciones.md)**

   - Story Points: 2
   - Sprint: Sprint 1 - Semana 2
   - Dependencias: US-008

10. **[US-010: Marcar Notificación como Leída](./US-010-marcar-notificacion-leida.md)**
    - Story Points: 1
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-009

### **🔴 P0 - Críticas (MVP) - Búsqueda**

11. **[US-011: Buscar Negocios](./US-011-buscar-negocios.md)**
    - Story Points: 3
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-003

### **🔴 P0 - Críticas (MVP) - Upload de Archivos**

12. **[US-012: Subir Logo de mi Negocio](./US-012-subir-logo-negocio.md)**
    - Story Points: 3
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-003

### **🔴 P0 - Críticas (MVP) - Horarios y Disponibilidad**

13. **[US-013: Configurar Horarios de mi Negocio](./US-013-configurar-horarios-negocio.md)**

    - Story Points: 5
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-003

14. **[US-014: Ver Horarios Disponibles para Reservar](./US-014-ver-horarios-disponibles.md)**
    - Story Points: 3
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-013, US-004

### **🔴 P0 - Críticas (MVP) - Gestión de Usuario**

15. **[US-015: Actualizar Mi Perfil](./US-015-actualizar-mi-perfil.md)**

    - Story Points: 2
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-002

16. **[US-016: Cambiar Mi Contraseña](./US-016-cambiar-contrasena.md)**
    - Story Points: 2
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-002

### **🔴 P0 - Críticas (MVP) - Horarios Avanzados**

17. **[US-017: Configurar Excepción de Horario (Vacaciones)](./US-017-configurar-excepcion-horario.md)**

    - Story Points: 2
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-013

18. **[US-018: Configurar Pausas en Horario de Trabajo](./US-018-configurar-pausas-horario.md)**
    - Story Points: 2
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-013

### **🔴 P0 - Críticas (MVP) - Búsqueda Avanzada**

19. **[US-019: Buscar Servicios](./US-019-buscar-servicios.md)**

    - Story Points: 3
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-004

20. **[US-020: Búsqueda Global](./US-020-busqueda-global.md)**
    - Story Points: 2
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-011, US-019

### **🔴 P0 - Críticas (MVP) - Upload Avanzado**

21. **[US-021: Subir Imagen de Servicio](./US-021-subir-imagen-servicio.md)**

    - Story Points: 2
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-004, US-012

22. **[US-022: Subir Mi Avatar](./US-022-subir-avatar-usuario.md)**
    - Story Points: 2
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-002

### **🔴 P0 - Críticas (MVP) - Gestión de Citas**

23. **[US-023: Cambiar Estado de una Cita](./US-023-cambiar-estado-cita.md)**

    - Story Points: 3
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-005

24. **[US-024: Ver Mis Citas](./US-024-ver-mis-citas.md)**

    - Story Points: 2
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-005

25. **[US-025: Ver Citas de mi Negocio](./US-025-ver-citas-negocio.md)**
    - Story Points: 2
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-003, US-005

### **🔴 P0 - Críticas (MVP) - Gestión de Negocios**

26. **[US-026: Actualizar Información de mi Negocio](./US-026-actualizar-mi-negocio.md)**

    - Story Points: 3
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-003

27. **[US-027: Activar/Desactivar mi Negocio](./US-027-activar-desactivar-negocio.md)**

    - Story Points: 1
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-003

28. **[US-028: Activar/Desactivar Servicio](./US-028-activar-desactivar-servicio.md)**

    - Story Points: 1
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-004

29. **[US-030: Ver Detalle de un Negocio](./US-030-ver-detalle-negocio.md)**

    - Story Points: 1
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-003

30. **[US-032: Listar Negocios Públicos](./US-032-listar-negocios-publicos.md)**
    - Story Points: 2
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-003

### **🔴 P0 - Críticas (MVP) - Gestión de Servicios**

31. **[US-031: Ver Detalle de un Servicio](./US-031-ver-detalle-servicio.md)**

    - Story Points: 1
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-004

32. **[US-033: Listar Servicios de un Negocio](./US-033-listar-servicios-negocio.md)**
    - Story Points: 1
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-004

### **🔴 P0 - Críticas (MVP) - Notificaciones Avanzadas**

33. **[US-029: Enviar Notificaciones por Email](./US-029-enviar-notificacion-email.md)**
    - Story Points: 3
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-008

### **🔴 P0 - Críticas (MVP) - Autenticación Avanzada**

34. **[US-035: Renovar Token de Acceso (Refresh Token)](./US-035-refresh-token.md)**

    - Story Points: 2
    - Sprint: Sprint 1 - Semana 1
    - Dependencias: US-002

35. **[US-036: Cerrar Sesión (Logout)](./US-036-logout.md)**
    - Story Points: 1
    - Sprint: Sprint 1 - Semana 1
    - Dependencias: US-002

### **🔴 P0 - Críticas (MVP) - Infraestructura**

36. **[US-037: Health Check del API](./US-037-health-check.md)**

    - Story Points: 1
    - Sprint: Sprint 1 - Semana 1
    - Dependencias: Ninguna

37. **[US-040: Implementar Paginación Estándar](./US-040-paginacion-estandar.md)**
    - Story Points: 2
    - Sprint: Sprint 1 - Semana 1
    - Dependencias: Ninguna

### **🔴 P0 - Críticas (MVP) - Validaciones y Filtros**

38. **[US-034: Ver Detalle de una Cita](./US-034-ver-detalle-cita.md)**

    - Story Points: 1
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-005

39. **[US-038: Validar Disponibilidad al Crear Cita](./US-038-validar-disponibilidad-cita.md)**

    - Story Points: 2
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-005, US-013

40. **[US-039: Filtrar Citas por Rango de Fechas](./US-039-filtrar-citas-por-fecha.md)**
    - Story Points: 1
    - Sprint: Sprint 1 - Semana 2
    - Dependencias: US-024, US-025

---

## 🎯 Cómo Trabajar con las Historias

### **Paso 1: Leer la Historia Completa**

- Entender el objetivo
- Revisar criterios de aceptación
- Identificar dependencias

### **Paso 2: Revisar Tareas Técnicas**

- Leer cada tarea en orden
- Entender el código de ejemplo
- Identificar archivos a crear/modificar

### **Paso 3: Implementar**

- Seguir los pasos detallados
- Verificar cada paso antes de continuar
- Escribir los tests indicados

### **Paso 4: Verificar**

- Ejecutar todos los tests
- Verificar criterios de aceptación
- Completar Definition of Done

---

## 📊 Estado de las Historias

| Historia | Estado | Desarrollador | Sprint   | Story Points |
| -------- | ------ | ------------- | -------- | ------------ |
| US-001   | To Do  | -             | Sprint 1 | 5            |
| US-002   | To Do  | -             | Sprint 1 | 3            |
| US-003   | To Do  | -             | Sprint 1 | 8            |
| US-004   | To Do  | -             | Sprint 1 | 5            |
| US-005   | To Do  | -             | Sprint 1 | 8            |
| US-006   | To Do  | -             | Sprint 1 | 3            |
| US-007   | To Do  | -             | Sprint 1 | 2            |
| US-008   | To Do  | -             | Sprint 1 | 2            |
| US-009   | To Do  | -             | Sprint 1 | 2            |
| US-010   | To Do  | -             | Sprint 1 | 1            |
| US-011   | To Do  | -             | Sprint 1 | 3            |
| US-012   | To Do  | -             | Sprint 1 | 3            |
| US-013   | To Do  | -             | Sprint 1 | 5            |
| US-014   | To Do  | -             | Sprint 1 | 3            |
| US-015   | To Do  | -             | Sprint 1 | 2            |
| US-016   | To Do  | -             | Sprint 1 | 2            |
| US-017   | To Do  | -             | Sprint 1 | 2            |
| US-018   | To Do  | -             | Sprint 1 | 2            |
| US-019   | To Do  | -             | Sprint 1 | 3            |
| US-020   | To Do  | -             | Sprint 1 | 2            |
| US-021   | To Do  | -             | Sprint 1 | 2            |
| US-022   | To Do  | -             | Sprint 1 | 2            |
| US-023   | To Do  | -             | Sprint 1 | 3            |
| US-024   | To Do  | -             | Sprint 1 | 2            |
| US-025   | To Do  | -             | Sprint 1 | 2            |
| US-026   | To Do  | -             | Sprint 1 | 3            |
| US-027   | To Do  | -             | Sprint 1 | 1            |
| US-028   | To Do  | -             | Sprint 1 | 1            |
| US-029   | To Do  | -             | Sprint 1 | 3            |
| US-030   | To Do  | -             | Sprint 1 | 1            |
| US-031   | To Do  | -             | Sprint 1 | 1            |
| US-032   | To Do  | -             | Sprint 1 | 2            |
| US-033   | To Do  | -             | Sprint 1 | 1            |
| US-034   | To Do  | -             | Sprint 1 | 1            |
| US-035   | To Do  | -             | Sprint 1 | 2            |
| US-036   | To Do  | -             | Sprint 1 | 1            |
| US-037   | To Do  | -             | Sprint 1 | 1            |
| US-038   | To Do  | -             | Sprint 1 | 2            |
| US-039   | To Do  | -             | Sprint 1 | 1            |
| US-040   | To Do  | -             | Sprint 1 | 2            |

**Total Story Points**: 93 puntos

---

## 🔗 Enlaces Relacionados

- [Sprints Detallados](../sprints/)
- [Arquitectura](../ARQUITECTURA.md)
- [Stack Tecnológico](../../tecnica/STACK_TECNOLOGICO.md)

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_
