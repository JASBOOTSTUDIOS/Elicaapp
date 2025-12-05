# 🗄️ **Stack de Supabase para ElicaApp**

## 📋 **Resumen Ejecutivo**

**Supabase** es la base de datos elegida para ElicaApp, proporcionando una solución PostgreSQL completamente gestionada con características adicionales como autenticación, real-time subscriptions, y una interfaz de administración intuitiva.

---

## 🏗️ **Arquitectura de Supabase**

### **Componentes Principales**

- **PostgreSQL 15+**: Motor de base de datos principal
- **Supabase Auth**: Sistema de autenticación integrado
- **Supabase Storage**: Almacenamiento de archivos
- **Supabase Edge Functions**: Funciones serverless
- **Supabase Dashboard**: Interfaz de administración web
- **Supabase CLI**: Herramientas de línea de comandos

### **Ventajas para ElicaApp**

- **Escalabilidad**: Crecimiento automático según demanda
- **Seguridad**: Certificaciones SOC2, GDPR, HIPAA
- **Performance**: Optimizaciones automáticas de PostgreSQL
- **Desarrollo Rápido**: APIs automáticas y herramientas integradas
- **Costos**: Plan gratuito generoso, precios predecibles

---

## 🔧 **Configuración Técnica**

### **Requisitos del Sistema**

- **Versión**: Supabase Cloud (PostgreSQL 15+)
- **Región**: Closest to target users (Latam)
- **Plan**: Pro plan para producción
- **Backup**: Automático cada 24 horas
- **Retención**: 7 días de backups

### **Variables de Entorno**

```bash
# .env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
SUPABASE_DB_PASSWORD=your-db-password
```

### **🔗 Connection String para Express.js + TypeScript**

#### **Prisma**

```env
# .env
DATABASE_URL="postgresql://postgres:your-password@db.your-project.supabase.co:5432/postgres?sslmode=require"
```

#### **TypeORM**

```typescript
// src/config/database.ts
export const databaseConfig = {
  type: "postgres",
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT || "5432"),
  username: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  ssl: { rejectUnauthorized: false },
};
```

---

## 🚀 **Integración con Express.js + TypeScript**

### **📦 Prisma**

```typescript
// src/config/database.ts
import { PrismaClient } from '@prisma/client';

export const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DATABASE_URL
    }
  }
});

// Migrations
npx prisma migrate dev --name InitialCreate
npx prisma generate
```

### **🗄️ TypeORM**

```typescript
// src/config/database.ts
import { DataSource } from 'typeorm';

export const AppDataSource = new DataSource({
  type: 'postgres',
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT || '5432'),
  username: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  entities: [__dirname + '/../models/**/*.ts'],
  migrations: [__dirname + '/../migrations/**/*.ts'],
  synchronize: false
});

// Migrations
npm run typeorm migration:create -- -n InitialCreate
npm run typeorm migration:run
```

### **🔌 Supabase Client**

```typescript
// src/config/supabase.ts
import { createClient } from "@supabase/supabase-js";

export const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_ANON_KEY!
);
```

### **📝 Configuración de Migraciones**

#### **Con Prisma**

```prisma
// prisma/schema.prisma
model User {
  id        String   @id @default(uuid())
  email     String   @unique
  fullName  String   @map("full_name")
  phone     String?
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  @@map("users")
}
```

#### **Con TypeORM**

```typescript
// src/models/User.model.ts
import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from "typeorm";

@Entity("users")
export class User {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @Column({ unique: true })
  email: string;

  @Column({ name: "full_name" })
  fullName: string;

  @Column({ nullable: true })
  phone?: string;

  @CreateDateColumn({ name: "created_at" })
  createdAt: Date;

  @UpdateDateColumn({ name: "updated_at" })
  updatedAt: Date;
}
```

---

## 📊 **Esquemas de Base de Datos**

### **Tablas Principales**

```sql
-- Usuarios del sistema
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    phone TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Negocios
CREATE TABLE businesses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    name TEXT NOT NULL,
    description TEXT,
    address TEXT,
    phone TEXT,
    email TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Servicios
CREATE TABLE services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business_id UUID REFERENCES businesses(id),
    name TEXT NOT NULL,
    description TEXT,
    duration_minutes INTEGER NOT NULL,
    price DECIMAL(10,2),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Citas
CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_id UUID REFERENCES services(id),
    user_id UUID REFERENCES users(id),
    business_id UUID REFERENCES businesses(id),
    appointment_date TIMESTAMPTZ NOT NULL,
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### **Índices de Performance**

```sql
-- Índices para consultas frecuentes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_businesses_user_id ON businesses(user_id);
CREATE INDEX idx_services_business_id ON services(business_id);
CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_appointments_business_date ON appointments(business_id, appointment_date);
```

---

## 🔐 **Seguridad y Autenticación**

### **Row Level Security (RLS)**

```sql
-- Habilitar RLS en todas las tablas
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;

-- Políticas de seguridad
CREATE POLICY "Users can view own data" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Business owners can manage their business" ON businesses
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view public business info" ON businesses
    FOR SELECT USING (true);
```

### **Autenticación con Supabase Auth**

```csharp
// AuthController.cs
[HttpPost("login")]
public async Task<IActionResult> Login([FromBody] LoginRequest request)
{
    // Integración con Supabase Auth
    var authResponse = await _supabaseClient.Auth.SignIn(request.Email, request.Password);

    if (authResponse.User != null)
    {
        var token = authResponse.AccessToken;
        return Ok(new { token, user = authResponse.User });
    }

    return Unauthorized();
}
```

---

## 📈 **Performance y Optimización**

### **⚙️ Configuración de Pool de Conexiones**

#### **Con Prisma**

```typescript
// src/config/database.ts
import { PrismaClient } from "@prisma/client";

export const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DATABASE_URL,
    },
  },
  log: ["query", "error", "warn"],
});
```

#### **Con TypeORM**

```typescript
// src/config/database.ts
export const AppDataSource = new DataSource({
  type: "postgres",
  // ... otras configuraciones
  extra: {
    max: 20, // Máximo de conexiones en el pool
    min: 5, // Mínimo de conexiones en el pool
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
  },
});
```

### **🚀 Query Optimization**

#### **Con Prisma**

```typescript
// Repository pattern con queries optimizadas
export async function getAppointmentsByBusiness(
  businessId: string,
  date: Date
): Promise<Appointment[]> {
  return await prisma.appointment.findMany({
    where: {
      businessId,
      appointmentDate: {
        gte: new Date(date.setHours(0, 0, 0, 0)),
        lt: new Date(date.setHours(23, 59, 59, 999)),
      },
    },
    include: {
      service: true,
      user: true,
    },
    orderBy: {
      appointmentDate: "asc",
    },
  });
}
```

#### **Con TypeORM**

```typescript
export async function getAppointmentsByBusiness(
  businessId: string,
  date: Date
): Promise<Appointment[]> {
  return await AppDataSource.getRepository(Appointment)
    .createQueryBuilder("appointment")
    .leftJoinAndSelect("appointment.service", "service")
    .leftJoinAndSelect("appointment.user", "user")
    .where("appointment.businessId = :businessId", { businessId })
    .andWhere("DATE(appointment.appointmentDate) = DATE(:date)", { date })
    .orderBy("appointment.appointmentDate", "ASC")
    .getMany();
}
```

### **💾 Caching Strategy**

```typescript
// Redis + Supabase para cache
import Redis from "ioredis";

const redis = new Redis(process.env.REDIS_URL);

export async function getBusiness(id: string): Promise<Business | null> {
  const cacheKey = `business:${id}`;
  const cached = await redis.get(cacheKey);

  if (cached) {
    return JSON.parse(cached);
  }

  const business = await prisma.business.findUnique({
    where: { id },
    include: { services: true },
  });

  if (business) {
    await redis.setex(cacheKey, 1800, JSON.stringify(business)); // 30 minutos
  }

  return business;
}
```

---

## 🔄 **Migraciones y Deployment**

### **Supabase Migrations**

```bash
# Instalar Supabase CLI
npm install -g supabase

# Login
supabase login

# Inicializar proyecto
supabase init

# Crear migración
supabase migration new create_initial_schema

# Aplicar migraciones
supabase db push

# Reset local
supabase db reset
```

### **📦 Prisma Migrations**

```bash
# Crear migración
npx prisma migrate dev --name InitialSchema

# Aplicar migración
npx prisma migrate deploy

# Generar script SQL
npx prisma migrate diff --from-schema-datamodel prisma/schema.prisma --to-schema-datasource prisma/schema.prisma --script
```

### **🗄️ TypeORM Migrations**

```bash
# Crear migración
npm run typeorm migration:create -- -n InitialSchema

# Aplicar migración
npm run typeorm migration:run

# Revertir migración
npm run typeorm migration:revert
```

### **🔄 CI/CD Integration**

```yaml
# .github/workflows/database.yml
name: Database Migration
on:
  push:
    branches: [main]
jobs:
  migrate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18.x"
      - name: Install dependencies
        run: npm ci
      - name: Run migrations
        run: |
          npx prisma migrate deploy
        env:
          DATABASE_URL: ${{ secrets.SUPABASE_CONNECTION_STRING }}
```

---

## 📊 **Monitoreo y Observabilidad**

### **Supabase Dashboard**

- **Database**: Monitoreo de queries, performance, conexiones
- **Auth**: Logs de autenticación, usuarios activos
- **Storage**: Uso de almacenamiento, archivos
- **Edge Functions**: Logs y métricas de funciones

### **📝 Logs y Métricas**

```typescript
// src/config/logger.ts
import winston from "winston";

export const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || "info",
  format: winston.format.json(),
  defaultMeta: { service: "elicaapp-backend" },
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({
      filename: "logs/supabase-error.log",
      level: "error",
    }),
    new winston.transports.File({ filename: "logs/supabase-combined.log" }),
  ],
});
```

### **🏥 Health Checks**

```typescript
// src/routes/health.routes.ts
import { Router } from "express";
import { prisma } from "../config/database";

const healthRouter = Router();

healthRouter.get("/health", async (req, res) => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    res.status(200).json({
      status: "ok",
      database: "connected",
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    res.status(503).json({
      status: "error",
      database: "disconnected",
      error: error.message,
    });
  }
});

export default healthRouter;
```

---

## 🚨 **Backup y Recovery**

### **Backup Automático**

- **Frecuencia**: Cada 24 horas
- **Retención**: 7 días
- **Tipo**: Point-in-time recovery
- **Región**: Multi-region backup

### **Recovery Procedures**

```sql
-- Restaurar desde backup
-- Usar Supabase Dashboard o CLI

-- Verificar integridad
SELECT schemaname, tablename, attname, n_distinct, correlation
FROM pg_stats
WHERE schemaname NOT IN ('information_schema', 'pg_catalog');
```

---

## 🔮 **Roadmap de Supabase para ElicaApp**

### **MVP (Etapa 1)**

- [x] Configuración básica de PostgreSQL
- [x] Esquemas base de datos
- [x] Autenticación básica
- [x] Migraciones Prisma/TypeORM

### **Optimización (Etapa 2)**

- [ ] Row Level Security avanzado
- [ ] Índices optimizados
- [ ] Particionamiento de tablas
- [ ] Backup automatizado

### **Escalabilidad (Etapa 3)**

- [ ] Read replicas
- [ ] Sharding horizontal
- [ ] Cache distribuido
- [ ] Monitoreo avanzado

### **Innovación (Etapa 4)**

- [ ] Machine Learning con pgvector
- [ ] GraphQL con PostGraphile
- [ ] Real-time subscriptions
- [ ] Edge Functions

---

## 📚 **Recursos y Documentación**

### **Documentación Oficial**

- [Supabase Documentation](https://supabase.com/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Prisma Documentation](https://www.prisma.io/docs)
- [TypeORM Documentation](https://typeorm.io/)

### **Herramientas Recomendadas**

- **Supabase CLI**: Para migraciones y gestión
- **pgAdmin**: Para administración avanzada
- **DBeaver**: Cliente universal de base de datos
- **Postman**: Para testing de APIs

### **Comunidad y Soporte**

- [Supabase Discord](https://discord.supabase.com/)
- [GitHub Issues](https://github.com/supabase/supabase/issues)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/supabase)

---

## ✅ **Checklist de Implementación**

### **Configuración Inicial**

- [ ] Crear proyecto en Supabase Cloud
- [ ] Configurar variables de entorno
- [ ] Configurar connection string en Express.js + TypeScript
- [ ] Probar conexión a base de datos

### **Desarrollo**

- [ ] Crear modelos Prisma/TypeORM
- [ ] Implementar migraciones iniciales
- [ ] Configurar RLS policies
- [ ] Implementar autenticación

### **Testing**

- [ ] Tests de conexión a base de datos
- [ ] Tests de migraciones
- [ ] Tests de performance
- [ ] Tests de seguridad

### **Producción**

- [ ] Configurar backup automático
- [ ] Configurar monitoreo
- [ ] Configurar alertas
- [ ] Documentar procedimientos de recovery

---

_Última actualización: Diciembre 2024_
_Versión: v1.0.0_
