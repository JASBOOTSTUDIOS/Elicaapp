# 🚀 ElicaApp - Documentación Principal

¡Bienvenido a la documentación central de **ElicaApp**! Este repositorio contiene toda la información esencial sobre el proyecto, desde su concepción y lógica de negocio hasta los detalles técnicos de implementación. Nuestro objetivo es proporcionar una guía clara y completa para desarrolladores, stakeholders y cualquier persona interesada en el ecosistema de ElicaApp.

## ✨ Visión General del Proyecto

**ElicaApp** es una solución innovadora diseñada para la gestión integral de negocios de servicios (salones de belleza, peluquerías, restaurantes, etc.). Nos enfocamos en pequeños y medianos negocios ofreciendo una plataforma completamente personalizable que refleja la identidad visual de cada negocio.

### 🏗️ Stack Tecnológico

- **🚀 Backend**: Express.js 4.18+ con TypeScript 5.0+
- **📱 Frontend**: React Native 0.73+ con Expo y TypeScript
- **🗄️ Base de Datos**: Supabase (PostgreSQL 15+) con Prisma/TypeORM
- **🔐 Autenticación**: JWT + Supabase Auth
- **🧪 Testing**: Jest + Supertest
- **🐳 DevOps**: Docker + GitHub Actions + CI/CD

## 📚 Índice de Contenidos Detallado

Para facilitar la navegación y el acceso a la información, la documentación está organizada en las siguientes secciones principales:

### 📄 Documentación General

Esta sección abarca los aspectos fundamentales del proyecto, incluyendo la visión, el alcance y los objetivos generales.

- [**Índice Principal de Documentación**](./docs/INDICE_PRINCIPAL.md): Un resumen de alto nivel de toda la documentación disponible.

### 🛠️ Documentación Técnica

Aquí encontrarás todos los detalles relacionados con la arquitectura, las tecnologías utilizadas y las decisiones de diseño técnico.

- [**Visión General Técnica**](./docs/tecnica/): Accede a la documentación técnica completa.

### 📊 Documentación de Negocio

Esta sección se centra en la lógica de negocio, los requisitos funcionales, las historias de usuario y la estrategia del producto.

- [**Visión General de Negocio**](./docs/negocio/): Explora la documentación relacionada con el negocio.

## 🚀 Primeros Pasos (Para Contribuidores)

Si deseas contribuir al proyecto o configurar tu entorno de desarrollo, consulta la siguiente guía:

1.  **Clonar el Repositorio:**

    ```bash
    git clone https://github.com/tu-usuario/elicaapp.git
    cd elicapp
    ```

2.  **Instalación de Dependencias:**

    ```bash
    # Backend
    cd backend && npm install

    # Frontend
    cd mobile && npm install
    ```

3.  **Configuración del Entorno:**

    ```bash
    # Copiar archivos de ejemplo
    cp backend/.env.example backend/.env
    cp mobile/.env.example mobile/.env

    # Configurar variables de entorno (ver documentación)
    ```

4.  **Ejecutar la Aplicación:**

    ```bash
    # Backend (desarrollo)
    cd backend && npm run dev

    # Frontend (desarrollo)
    cd mobile && npm start
    ```

## 🤝 Contribuciones

¡Tus contribuciones son bienvenidas! Si encuentras un error, tienes una sugerencia o quieres añadir una nueva característica, por favor, abre un _issue_ o envía un _pull request_. Consulta nuestra [**Guía de Contribución**](LINK_A_GUIA_DE_CONTRIBUCION_SI_EXISTE) para más detalles.

## 📞 Contacto

Para preguntas o soporte, puedes contactar a [**Tu Nombre/Equipo**] en [**tu_email@ejemplo.com**].

---

_Este `README.md` es el punto de entrada unificado para toda la documentación del proyecto ElicaApp. Asegúrate de explorar los enlaces internos para obtener información más detallada._
