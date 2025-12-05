# 📅 Día 2: Conexión a Base de Datos (Supabase + Prisma)

## 🎯 Objetivo del Día

Configurar la conexión a Supabase usando Prisma como ORM, crear el esquema inicial de base de datos y establecer las migraciones.

---

## ✅ Checklist de Tareas

- [ ] Instalar Prisma y dependencias
- [ ] Inicializar Prisma
- [ ] Configurar conexión a Supabase
- [ ] Crear modelos base (User, Business)
- [ ] Configurar relaciones
- [ ] Crear migración inicial
- [ ] Aplicar migración a Supabase
- [ ] Generar cliente Prisma
- [ ] Crear repositorio base
- [ ] Testear conexión

---

## 📋 Pasos Detallados

### **Paso 1: Instalar Prisma**

```bash
npm install prisma @prisma/client
npm install -D @types/node
```

**Verificación**:

- [ ] Prisma instalado correctamente
- [ ] `@prisma/client` disponible

---

### **Paso 2: Inicializar Prisma**

```bash
npx prisma init
```

Este comando crea:

- Carpeta `prisma/` con `schema.prisma`
- Archivo `.env` (si no existe) con `DATABASE_URL`

**Verificación**:

- [ ] Carpeta `prisma/` creada
- [ ] Archivo `prisma/schema.prisma` creado

---

### **Paso 3: Configurar Schema de Prisma**

Editar `prisma/schema.prisma`:

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// Modelo Base (para campos comunes)
model BaseModel {
  id        String   @id @default(uuid())
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  @@map("_base")
}

// Usuario del sistema
model User {
  id        String   @id @default(uuid())
  email     String   @unique
  password  String   @map("password_hash")
  fullName  String?  @map("full_name")
  phone     String?
  role      UserRole @default(CUSTOMER)
  isActive  Boolean  @default(true) @map("is_active")
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  // Relaciones
  businesses Business[] @relation("BusinessOwner")
  appointments Appointment[]

  @@map("users")
}

enum UserRole {
  ADMIN
  BUSINESS_OWNER
  SERVICE_PROVIDER
  CUSTOMER
}

// Negocio
model Business {
  id          String   @id @default(uuid())
  name        String
  description String?
  type        BusinessType @default(OTHER)
  address     String?
  phone       String?
  email       String?
  ownerId     String   @map("owner_id")
  isActive    Boolean  @default(true) @map("is_active")
  createdAt   DateTime @default(now()) @map("created_at")
  updatedAt   DateTime @updatedAt @map("updated_at")

  // Relaciones
  owner     User       @relation("BusinessOwner", fields: [ownerId], references: [id])
  services  Service[]
  appointments Appointment[]
  theme     BusinessTheme?

  @@map("businesses")
}

enum BusinessType {
  SALON
  RESTAURANT
  SPA
  OTHER
}

// Tema del negocio (personalización visual)
model BusinessTheme {
  id         String   @id @default(uuid())
  businessId String   @unique @map("business_id")
  primaryColor   String   @default("#3B82F6") @map("primary_color")
  secondaryColor String   @default("#10B981") @map("secondary_color")
  accentColor    String   @default("#F59E0B") @map("accent_color")
  logoUrl        String?  @map("logo_url")
  fontFamily     String?  @default("Inter") @map("font_family")
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  business Business @relation(fields: [businessId], references: [id], onDelete: Cascade)

  @@map("business_themes")
}

// Servicio ofrecido por el negocio
model Service {
  id          String   @id @default(uuid())
  businessId  String   @map("business_id")
  name        String
  description String?
  durationMinutes Int   @map("duration_minutes")
  price       Decimal  @db.Decimal(10, 2)
  category    String?
  isActive    Boolean  @default(true) @map("is_active")
  createdAt   DateTime @default(now()) @map("created_at")
  updatedAt   DateTime @updatedAt @map("updated_at")

  // Relaciones
  business     Business      @relation(fields: [businessId], references: [id], onDelete: Cascade)
  appointments Appointment[]

  @@map("services")
}

// Cita/Reserva
model Appointment {
  id          String   @id @default(uuid())
  businessId  String   @map("business_id")
  userId      String   @map("user_id")
  serviceId   String   @map("service_id")
  date        DateTime
  status      AppointmentStatus @default(PENDING)
  notes       String?
  createdAt   DateTime @default(now()) @map("created_at")
  updatedAt   DateTime @updatedAt @map("updated_at")

  // Relaciones
  business Business @relation(fields: [businessId], references: [id], onDelete: Cascade)
  user     User     @relation(fields: [userId], references: [id])
  service  Service  @relation(fields: [serviceId], references: [id])

  @@map("appointments")
}

enum AppointmentStatus {
  PENDING
  CONFIRMED
  IN_PROGRESS
  COMPLETED
  CANCELLED
}
```

**Verificación**:

- [ ] Schema creado correctamente
- [ ] Sin errores de sintaxis
- [ ] Relaciones definidas

---

### **Paso 4: Configurar DATABASE_URL en .env**

Asegurar que `.env` tenga:

```env
DATABASE_URL="postgresql://postgres:TU_PASSWORD@db.TU_PROYECTO.supabase.co:5432/postgres?sslmode=require"
```

**Obtener la URL de conexión desde Supabase Dashboard**:

1. Ir a Settings > Database
2. Copiar "Connection string" (URI)
3. Reemplazar `[YOUR-PASSWORD]` con tu contraseña

**Verificación**:

- [ ] `DATABASE_URL` configurado correctamente
- [ ] URL incluye `sslmode=require`

---

### **Paso 5: Crear Migración Inicial**

```bash
npx prisma migrate dev --name init
```

Este comando:

- Crea la carpeta `prisma/migrations/`
- Genera el SQL de migración
- Aplica la migración a la base de datos
- Genera el cliente Prisma

**Verificación**:

- [ ] Migración creada en `prisma/migrations/`
- [ ] Tablas creadas en Supabase
- [ ] Cliente Prisma generado

---

### **Paso 6: Generar Cliente Prisma**

```bash
npx prisma generate
```

Esto genera el cliente TypeScript en `node_modules/.prisma/client/`

**Verificación**:

- [ ] Cliente generado sin errores
- [ ] Tipos TypeScript disponibles

---

### **Paso 7: Crear Configuración de Base de Datos**

Crear archivo `src/config/database.ts`:

```typescript
import { PrismaClient } from "@prisma/client";
import { logger } from "./logger";

const prisma = new PrismaClient({
  log: [
    { level: "query", emit: "event" },
    { level: "error", emit: "stdout" },
    { level: "warn", emit: "stdout" },
  ],
});

// Log queries en desarrollo
if (process.env.NODE_ENV === "development") {
  prisma.$on("query" as never, (e: any) => {
    logger.debug("Query: " + e.query);
    logger.debug("Params: " + e.params);
    logger.debug("Duration: " + e.duration + "ms");
  });
}

// Manejo de desconexión graceful
process.on("beforeExit", async () => {
  await prisma.$disconnect();
});

export default prisma;
```

**Verificación**:

- [ ] Archivo creado
- [ ] Cliente Prisma exportado
- [ ] Logging configurado

---

### **Paso 8: Crear Repositorio Base**

Crear archivo `src/repositories/base.repository.ts`:

```typescript
import prisma from "../config/database";

export abstract class BaseRepository<T> {
  protected abstract getModel(): any;

  async findById(id: string): Promise<T | null> {
    return await this.getModel().findUnique({
      where: { id },
    });
  }

  async findAll(): Promise<T[]> {
    return await this.getModel().findMany();
  }

  async create(data: Partial<T>): Promise<T> {
    return await this.getModel().create({
      data,
    });
  }

  async update(id: string, data: Partial<T>): Promise<T> {
    return await this.getModel().update({
      where: { id },
      data,
    });
  }

  async delete(id: string): Promise<void> {
    await this.getModel().delete({
      where: { id },
    });
  }
}
```

**Verificación**:

- [ ] Repositorio base creado
- [ ] Métodos CRUD básicos implementados

---

### **Paso 9: Crear Repositorio de Usuario**

Crear archivo `src/repositories/user.repository.ts`:

```typescript
import prisma from "../config/database";
import { User, Prisma } from "@prisma/client";
import { BaseRepository } from "./base.repository";

export class UserRepository extends BaseRepository<User> {
  protected getModel() {
    return prisma.user;
  }

  async findByEmail(email: string): Promise<User | null> {
    return await prisma.user.findUnique({
      where: { email },
    });
  }

  async findMany(args?: Prisma.UserFindManyArgs): Promise<User[]> {
    return await prisma.user.findMany(args);
  }
}

export const userRepository = new UserRepository();
```

**Verificación**:

- [ ] Repositorio de usuario creado
- [ ] Método `findByEmail` implementado

---

### **Paso 10: Crear Endpoint de Health Check con DB**

Actualizar `src/app.ts` para incluir health check de base de datos:

```typescript
import prisma from "./config/database";

// Actualizar el endpoint /health
app.get("/health", async (req: Request, res: Response) => {
  try {
    // Test de conexión a base de datos
    await prisma.$queryRaw`SELECT 1`;

    res.status(200).json({
      status: "ok",
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      environment: env.NODE_ENV,
      database: "connected",
    });
  } catch (error) {
    logger.error("Health check failed:", error);
    res.status(503).json({
      status: "error",
      timestamp: new Date().toISOString(),
      database: "disconnected",
      error:
        env.NODE_ENV === "production" ? undefined : (error as Error).message,
    });
  }
});
```

**Verificación**:

- [ ] Health check actualizado
- [ ] Conexión a DB verificada
- [ ] Endpoint responde correctamente

---

### **Paso 11: Crear Test de Conexión**

Crear archivo `tests/integration/database.test.ts`:

```typescript
import prisma from "../../src/config/database";

describe("Database Connection", () => {
  beforeAll(async () => {
    // Conectar a la base de datos
    await prisma.$connect();
  });

  afterAll(async () => {
    // Desconectar
    await prisma.$disconnect();
  });

  it("should connect to database", async () => {
    const result = await prisma.$queryRaw`SELECT 1 as value`;
    expect(result).toBeDefined();
  });

  it("should query users table", async () => {
    const users = await prisma.user.findMany();
    expect(Array.isArray(users)).toBe(true);
  });
});
```

**Verificación**:

- [ ] Test creado
- [ ] `npm test` pasa correctamente
- [ ] Conexión verificada

---

### **Paso 12: Verificar en Supabase Dashboard**

1. Ir a Supabase Dashboard > Table Editor
2. Verificar que las tablas estén creadas:
   - `users`
   - `businesses`
   - `business_themes`
   - `services`
   - `appointments`

**Verificación**:

- [ ] Todas las tablas visibles
- [ ] Estructura correcta
- [ ] Relaciones configuradas

---

## ✅ Verificación Final

```bash
# 1. Verificar migraciones
npx prisma migrate status

# 2. Generar cliente
npx prisma generate

# 3. Abrir Prisma Studio (opcional)
npx prisma studio

# 4. Ejecutar tests
npm test

# 5. Iniciar servidor y probar health check
npm run dev
# Visitar: http://localhost:3000/health
```

**Verificaciones**:

- [ ] Migraciones aplicadas correctamente
- [ ] Cliente Prisma generado
- [ ] Tests pasando
- [ ] Health check muestra "database: connected"
- [ ] Tablas visibles en Supabase Dashboard

---

## 📝 Entregables del Día

1. ✅ Prisma instalado y configurado
2. ✅ Schema de base de datos creado
3. ✅ Migración inicial aplicada
4. ✅ Cliente Prisma generado
5. ✅ Configuración de base de datos creada
6. ✅ Repositorio base implementado
7. ✅ Repositorio de usuario creado
8. ✅ Health check con verificación de DB
9. ✅ Tests de conexión pasando
10. ✅ Tablas creadas en Supabase

---

## 🐛 Troubleshooting

### **Error: P1001 - Can't reach database server**

- Verificar que `DATABASE_URL` sea correcta
- Verificar que Supabase esté activo
- Verificar firewall/red

### **Error: P2002 - Unique constraint failed**

- Verificar que no haya datos duplicados
- Revisar constraints en el schema

### **Error: Migration failed**

- Revisar logs de Prisma
- Verificar que la base de datos esté vacía o usar `--create-only`
- Revisar sintaxis del schema

---

## 📚 Recursos Adicionales

- [Prisma Documentation](https://www.prisma.io/docs)
- [Supabase PostgreSQL Guide](https://supabase.com/docs/guides/database)
- [Prisma Migrate](https://www.prisma.io/docs/concepts/components/prisma-migrate)

---

## 🎯 Próximo Día

**Día 3**: Autenticación JWT y Endpoints de Auth

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_
