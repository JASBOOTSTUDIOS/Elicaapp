# 🎯 Funciones y Triggers en PostgreSQL

## 📚 Tabla de Contenidos

- [Introducción](#-introducción)
- [Funciones](#-funciones-en-postgresql)
  - [Conceptos Básicos](#-conceptos-básicos)
  - [Tipos de Funciones](#-tipos-de-funciones)
  - [Ejemplos Prácticos](#-ejemplos-prácticos)
- [Triggers](#-triggers-en-postgresql)
  - [¿Qué son los Triggers?](#-qué-son-los-triggers)
  - [Tipos de Triggers](#-tipos-de-triggers)
  - [Ejemplos Prácticos](#-ejemplos-prácticos-de-triggers)
- [Mejores Prácticas](#-mejores-prácticas)
- [Casos de Uso Comunes](#-casos-de-uso-comunes)
- [Troubleshooting](#-troubleshooting)

---

## 🎓 Introducción

Las **funciones** y **triggers** son herramientas poderosas en PostgreSQL que permiten:

- ✅ **Automatizar tareas** repetitivas en la base de datos
- ✅ **Validar datos** antes de insertar o actualizar
- ✅ **Mantener integridad** referencial y lógica
- ✅ **Auditar cambios** en las tablas
- ✅ **Calcular valores** automáticamente
- ✅ **Ejecutar lógica compleja** directamente en la base de datos

> 💡 **Nota**: Las funciones y triggers se ejecutan en el servidor de base de datos, lo que puede mejorar el rendimiento al reducir las idas y venidas entre la aplicación y la base de datos.

---

## 🔧 Funciones en PostgreSQL

### 📖 Conceptos Básicos

Una **función** en PostgreSQL es un bloque de código reutilizable que puede:

- Recibir parámetros de entrada
- Realizar operaciones complejas
- Retornar un valor o conjunto de valores
- Ser llamada desde queries SQL, otros procedimientos o triggers

#### 🏗️ Estructura Básica

```sql
CREATE [OR REPLACE] FUNCTION nombre_funcion(parametro1 TIPO, parametro2 TIPO)
RETURNS tipo_retorno
LANGUAGE lenguaje
AS $$
BEGIN
    -- Lógica de la función
    RETURN valor_retorno;
END;
$$;
```

**Componentes principales:**

| Componente        | Descripción                           | Ejemplo                                             |
| ----------------- | ------------------------------------- | --------------------------------------------------- |
| `CREATE FUNCTION` | Crea una nueva función                | `CREATE FUNCTION sumar(...)`                        |
| `OR REPLACE`      | Reemplaza función existente si existe | `CREATE OR REPLACE FUNCTION`                        |
| `RETURNS`         | Tipo de dato que retorna              | `RETURNS INT`, `RETURNS TEXT`, `RETURNS TABLE(...)` |
| `LANGUAGE`        | Lenguaje de programación              | `plpgsql`, `sql`, `python`                          |
| `AS $$ ... $$`    | Delimitador del cuerpo de la función  | Bloque de código                                    |

---

### 🎨 Tipos de Funciones

#### 1️⃣ **Funciones Escalares** (Retornan un solo valor)

```sql
CREATE FUNCTION sumar(a INT, b INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN a + b;
END;
$$;
```

**Uso:**

```sql
SELECT sumar(5, 3);  -- Retorna: 8
```

#### 2️⃣ **Funciones que Retornan Tablas** (RETURNS TABLE)

```sql
CREATE FUNCTION get_user_by_id(uid INT)
RETURNS TABLE(
    id INT,
    name TEXT,
    email TEXT,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT u.id, u.name, u.email, u.created_at
    FROM users u
    WHERE u.id = uid;
END;
$$;
```

**Uso:**

```sql
SELECT * FROM get_user_by_id(1);
```

#### 3️⃣ **Funciones que Retornan SETOF** (Múltiples filas)

```sql
CREATE FUNCTION get_active_users()
RETURNS SETOF users
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM users
    WHERE is_active = true;
END;
$$;
```

**Uso:**

```sql
SELECT * FROM get_active_users();
```

#### 4️⃣ **Funciones con VOID** (No retornan valor)

```sql
CREATE FUNCTION log_activity(message TEXT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO activity_logs(message, created_at)
    VALUES (message, NOW());
END;
$$;
```

**Uso:**

```sql
SELECT log_activity('Usuario inició sesión');
```

---

### 💡 Ejemplos Prácticos

#### ✨ Ejemplo 1: Función Simple para Sumar

```sql
CREATE OR REPLACE FUNCTION sumar(a INT, b INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    resultado INT;
BEGIN
    resultado := a + b;
    RETURN resultado;
END;
$$;
```

**Explicación paso a paso:**

1. **`CREATE OR REPLACE FUNCTION`**: Crea o reemplaza la función
2. **`sumar(a INT, b INT)`**: Nombre y parámetros de entrada
3. **`RETURNS INT`**: Tipo de dato que retorna
4. **`LANGUAGE plpgsql`**: Lenguaje de programación (PL/pgSQL)
5. **`DECLARE`**: Sección para declarar variables locales
6. **`BEGIN ... END`**: Bloque de código principal
7. **`RETURN`**: Retorna el valor calculado

**Uso:**

```sql
SELECT sumar(10, 20);  -- Resultado: 30
SELECT sumar(5, -3);    -- Resultado: 2
```

---

#### ✨ Ejemplo 2: Función para Obtener Usuario por ID

```sql
CREATE OR REPLACE FUNCTION get_user_by_id(uid INT)
RETURNS TABLE(
    id INT,
    name TEXT,
    email TEXT,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.id,
        u.name,
        u.email,
        u.created_at
    FROM users u
    WHERE u.id = uid;

    -- Si no se encuentra el usuario, retornar fila vacía
    IF NOT FOUND THEN
        RAISE NOTICE 'Usuario con ID % no encontrado', uid;
    END IF;
END;
$$;
```

**Características:**

- ✅ Retorna múltiples columnas usando `RETURNS TABLE`
- ✅ Usa `RETURN QUERY` para retornar resultados de un SELECT
- ✅ Incluye manejo de casos donde no se encuentra el registro
- ✅ Usa `RAISE NOTICE` para mensajes informativos

**Uso:**

```sql
-- Obtener usuario con ID 1
SELECT * FROM get_user_by_id(1);

-- Usar en un JOIN
SELECT
    o.id as order_id,
    u.name as user_name
FROM orders o
JOIN get_user_by_id(o.user_id) u ON true;
```

---

#### ✨ Ejemplo 3: Función para Crear Usuario

```sql
CREATE OR REPLACE FUNCTION create_user(
    p_name TEXT,
    p_email TEXT,
    p_password_hash TEXT
)
RETURNS TABLE(
    id INT,
    name TEXT,
    email TEXT,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    new_user_id INT;
BEGIN
    -- Validar que el email no exista
    IF EXISTS (SELECT 1 FROM users WHERE email = p_email) THEN
        RAISE EXCEPTION 'El email % ya está registrado', p_email;
    END IF;

    -- Insertar nuevo usuario
    INSERT INTO users(name, email, password_hash, created_at)
    VALUES (p_name, p_email, p_password_hash, NOW())
    RETURNING id INTO new_user_id;

    -- Retornar el usuario creado
    RETURN QUERY
    SELECT u.id, u.name, u.email, u.created_at
    FROM users u
    WHERE u.id = new_user_id;
END;
$$;
```

**Características:**

- ✅ Valida datos antes de insertar
- ✅ Usa `RAISE EXCEPTION` para errores
- ✅ Usa `RETURNING ... INTO` para capturar el ID generado
- ✅ Retorna el registro creado

**Uso:**

```sql
-- Crear usuario exitosamente
SELECT * FROM create_user(
    'Juan Pérez',
    'juan@example.com',
    '$2b$10$hashedpassword...'
);

-- Intentar crear usuario con email duplicado (genera error)
SELECT * FROM create_user(
    'Otro Usuario',
    'juan@example.com',  -- Email duplicado
    '$2b$10$hashedpassword...'
);
-- Error: El email juan@example.com ya está registrado
```

---

#### ✨ Ejemplo 4: Función con Validación (División Segura)

```sql
CREATE OR REPLACE FUNCTION safe_division(
    a NUMERIC,
    b NUMERIC
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    resultado NUMERIC;
BEGIN
    -- Validar que el divisor no sea cero
    IF b = 0 THEN
        RAISE EXCEPTION 'No se puede dividir entre 0. Intento de dividir % entre %', a, b;
    END IF;

    -- Realizar la división
    resultado := a / b;

    RETURN resultado;
END;
$$;
```

**Características:**

- ✅ Valida entrada antes de procesar
- ✅ Mensaje de error descriptivo con `RAISE EXCEPTION`
- ✅ Previene errores de división por cero

**Uso:**

```sql
SELECT safe_division(10, 2);   -- Resultado: 5.0
SELECT safe_division(10, 0);   -- Error: No se puede dividir entre 0
SELECT safe_division(15.5, 2); -- Resultado: 7.75
```

---

#### ✨ Ejemplo 5: Función para Actualizar Email

```sql
CREATE OR REPLACE FUNCTION update_user_email(
    p_id INT,
    p_new_email TEXT
)
RETURNS TABLE(
    id INT,
    old_email TEXT,
    new_email TEXT,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_old_email TEXT;
BEGIN
    -- Obtener email actual
    SELECT email INTO v_old_email
    FROM users
    WHERE id = p_id;

    -- Validar que el usuario existe
    IF v_old_email IS NULL THEN
        RAISE EXCEPTION 'Usuario con ID % no encontrado', p_id;
    END IF;

    -- Validar que el nuevo email no esté en uso
    IF EXISTS (SELECT 1 FROM users WHERE email = p_new_email AND id != p_id) THEN
        RAISE EXCEPTION 'El email % ya está en uso por otro usuario', p_new_email;
    END IF;

    -- Actualizar el email
    UPDATE users
    SET email = p_new_email,
        updated_at = NOW()
    WHERE id = p_id;

    -- Retornar información del cambio
    RETURN QUERY
    SELECT
        p_id,
        v_old_email,
        p_new_email,
        NOW() as updated_at;
END;
$$;
```

**Características:**

- ✅ Valida existencia del usuario
- ✅ Valida unicidad del nuevo email
- ✅ Retorna información del cambio realizado
- ✅ Actualiza timestamp automáticamente

**Uso:**

```sql
-- Actualizar email exitosamente
SELECT * FROM update_user_email(1, 'nuevo@example.com');

-- Intentar actualizar con email duplicado (genera error)
SELECT * FROM update_user_email(1, 'otro@example.com');
-- Error si otro@example.com ya está en uso
```

---

#### ✨ Ejemplo 6: Función con Múltiples Condiciones

```sql
CREATE OR REPLACE FUNCTION calculate_discount(
    p_price NUMERIC,
    p_user_type TEXT,
    p_purchase_amount NUMERIC
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    discount_percentage NUMERIC := 0;
    final_price NUMERIC;
BEGIN
    -- Calcular descuento basado en tipo de usuario
    CASE p_user_type
        WHEN 'VIP' THEN
            discount_percentage := 20;
        WHEN 'PREMIUM' THEN
            discount_percentage := 15;
        WHEN 'REGULAR' THEN
            discount_percentage := 5;
        ELSE
            discount_percentage := 0;
    END CASE;

    -- Descuento adicional por monto de compra
    IF p_purchase_amount > 1000 THEN
        discount_percentage := discount_percentage + 5;
    ELSIF p_purchase_amount > 500 THEN
        discount_percentage := discount_percentage + 2;
    END IF;

    -- Calcular precio final
    final_price := p_price * (1 - discount_percentage / 100);

    RETURN final_price;
END;
$$;
```

**Uso:**

```sql
SELECT calculate_discount(100, 'VIP', 1200);      -- Precio con 25% descuento
SELECT calculate_discount(100, 'REGULAR', 600);  -- Precio con 7% descuento
SELECT calculate_discount(100, 'GUEST', 200);    -- Sin descuento
```

---

## ⚡ Triggers en PostgreSQL

### 🤔 ¿Qué son los Triggers?

Un **trigger** (disparador) es una función especial que se ejecuta **automáticamente** cuando ocurre un evento específico en una tabla:

- ✅ **INSERT**: Cuando se inserta una nueva fila
- ✅ **UPDATE**: Cuando se actualiza una fila existente
- ✅ **DELETE**: Cuando se elimina una fila
- ✅ **TRUNCATE**: Cuando se vacía una tabla

**Características principales:**

- 🔄 Se ejecutan automáticamente (no necesitas llamarlos manualmente)
- 🎯 Se ejecutan antes o después del evento
- 📊 Pueden acceder a los datos antiguos (`OLD`) y nuevos (`NEW`)
- 🚫 Pueden prevenir operaciones (triggers `BEFORE`)
- 📝 Pueden registrar cambios (triggers `AFTER`)

---

### 🎯 Tipos de Triggers

#### 1️⃣ **BEFORE Trigger** (Antes del evento)

Se ejecuta **antes** de que ocurra la operación. Útil para:

- ✅ Validar datos antes de insertar/actualizar
- ✅ Modificar valores antes de guardarlos
- ✅ Prevenir operaciones no permitidas

```sql
CREATE TRIGGER nombre_trigger
BEFORE INSERT OR UPDATE ON tabla
FOR EACH ROW
EXECUTE FUNCTION nombre_funcion();
```

#### 2️⃣ **AFTER Trigger** (Después del evento)

Se ejecuta **después** de que ocurra la operación. Útil para:

- ✅ Registrar cambios en tablas de auditoría
- ✅ Actualizar otras tablas relacionadas
- ✅ Enviar notificaciones

```sql
CREATE TRIGGER nombre_trigger
AFTER INSERT OR UPDATE OR DELETE ON tabla
FOR EACH ROW
EXECUTE FUNCTION nombre_funcion();
```

#### 3️⃣ **INSTEAD OF Trigger** (En lugar de)

Solo funciona con **vistas** (views). Reemplaza la operación original.

```sql
CREATE TRIGGER nombre_trigger
INSTEAD OF INSERT OR UPDATE ON vista
FOR EACH ROW
EXECUTE FUNCTION nombre_funcion();
```

---

### 📝 Estructura de una Función para Trigger

```sql
CREATE OR REPLACE FUNCTION nombre_funcion_trigger()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Lógica del trigger
    -- Acceso a NEW (datos nuevos) y OLD (datos antiguos)
    RETURN NEW;  -- o RETURN OLD;
END;
$$;
```

**Variables especiales en triggers:**

| Variable        | Descripción                        | Disponible en  |
| --------------- | ---------------------------------- | -------------- |
| `NEW`           | Fila nueva (INSERT/UPDATE)         | INSERT, UPDATE |
| `OLD`           | Fila antigua (UPDATE/DELETE)       | UPDATE, DELETE |
| `TG_OP`         | Operación que disparó el trigger   | Todas          |
| `TG_TABLE_NAME` | Nombre de la tabla                 | Todas          |
| `TG_WHEN`       | Momento del trigger (BEFORE/AFTER) | Todas          |

---

### 💡 Ejemplos Prácticos de Triggers

#### ✨ Ejemplo 1: Log de Inserciones (AFTER INSERT)

**Función del trigger:**

```sql
CREATE OR REPLACE FUNCTION log_user_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Insertar registro en tabla de logs
    INSERT INTO user_logs(
        action,
        user_id,
        user_name,
        user_email,
        created_at
    )
    VALUES (
        'INSERT',
        NEW.id,
        NEW.name,
        NEW.email,
        NOW()
    );

    -- Retornar NEW para permitir que la inserción continúe
    RETURN NEW;
END;
$$;
```

**Crear el trigger:**

```sql
CREATE TRIGGER user_insert_trigger
AFTER INSERT ON users
FOR EACH ROW
EXECUTE FUNCTION log_user_insert();
```

**Cómo funciona:**

1. Usuario ejecuta: `INSERT INTO users(name, email) VALUES ('Juan', 'juan@example.com');`
2. PostgreSQL inserta la fila en `users`
3. **Después** de la inserción, se ejecuta el trigger
4. El trigger inserta un registro en `user_logs`
5. La operación completa exitosamente

**Tabla de logs (ejemplo):**

```sql
CREATE TABLE user_logs (
    id SERIAL PRIMARY KEY,
    action TEXT NOT NULL,
    user_id INT,
    user_name TEXT,
    user_email TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

---

#### ✨ Ejemplo 2: Prevenir Cambio de Email (BEFORE UPDATE)

**Función del trigger:**

```sql
CREATE OR REPLACE FUNCTION prevent_email_update()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Si el email está siendo cambiado, lanzar error
    IF NEW.email <> OLD.email THEN
        RAISE EXCEPTION 'No puedes cambiar el email. El email es inmutable.';
    END IF;

    -- Si no hay cambio, permitir la actualización
    RETURN NEW;
END;
$$;
```

**Crear el trigger:**

```sql
CREATE TRIGGER no_email_update
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION prevent_email_update();
```

**Cómo funciona:**

1. Usuario intenta: `UPDATE users SET email = 'nuevo@example.com' WHERE id = 1;`
2. **Antes** de la actualización, se ejecuta el trigger
3. El trigger compara `NEW.email` con `OLD.email`
4. Si son diferentes, lanza una excepción
5. La actualización se **cancela** y se muestra el error

**Uso:**

```sql
-- Esto funcionará (no cambia el email)
UPDATE users SET name = 'Nuevo Nombre' WHERE id = 1;

-- Esto fallará (intenta cambiar el email)
UPDATE users SET email = 'nuevo@example.com' WHERE id = 1;
-- Error: No puedes cambiar el email. El email es inmutable.
```

---

#### ✨ Ejemplo 3: Actualizar Timestamp Automáticamente (BEFORE UPDATE)

**Función del trigger:**

```sql
CREATE OR REPLACE FUNCTION auto_update_timestamp()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Actualizar el campo updated_at automáticamente
    NEW.updated_at = NOW();

    -- Retornar NEW con el timestamp actualizado
    RETURN NEW;
END;
$$;
```

**Crear el trigger:**

```sql
CREATE TRIGGER update_timestamp_trigger
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION auto_update_timestamp();
```

**Cómo funciona:**

1. Usuario ejecuta: `UPDATE users SET name = 'Nuevo Nombre' WHERE id = 1;`
2. **Antes** de la actualización, se ejecuta el trigger
3. El trigger establece `NEW.updated_at = NOW()`
4. PostgreSQL actualiza la fila con el nuevo nombre **y** el timestamp actualizado
5. No necesitas especificar `updated_at` manualmente

**Uso:**

```sql
-- No necesitas incluir updated_at, se actualiza automáticamente
UPDATE users SET name = 'Juan Pérez' WHERE id = 1;

-- Verificar que updated_at se actualizó
SELECT name, updated_at FROM users WHERE id = 1;
```

**Aplicar a múltiples tablas:**

```sql
-- Aplicar el mismo trigger a diferentes tablas
CREATE TRIGGER update_timestamp_business
BEFORE UPDATE ON businesses
FOR EACH ROW
EXECUTE FUNCTION auto_update_timestamp();

CREATE TRIGGER update_timestamp_services
BEFORE UPDATE ON services
FOR EACH ROW
EXECUTE FUNCTION auto_update_timestamp();
```

---

#### ✨ Ejemplo 4: Eliminar Datos Relacionados (AFTER DELETE)

**Función del trigger:**

```sql
CREATE OR REPLACE FUNCTION delete_user_related()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Eliminar posts del usuario
    DELETE FROM user_posts
    WHERE user_id = OLD.id;

    -- Eliminar logs del usuario
    DELETE FROM user_logs
    WHERE user_id = OLD.id;

    -- Eliminar preferencias del usuario
    DELETE FROM user_preferences
    WHERE user_id = OLD.id;

    -- Retornar OLD para indicar que la eliminación fue exitosa
    RETURN OLD;
END;
$$;
```

**Crear el trigger:**

```sql
CREATE TRIGGER on_user_delete
AFTER DELETE ON users
FOR EACH ROW
EXECUTE FUNCTION delete_user_related();
```

**Cómo funciona:**

1. Usuario ejecuta: `DELETE FROM users WHERE id = 1;`
2. PostgreSQL elimina la fila de `users`
3. **Después** de la eliminación, se ejecuta el trigger
4. El trigger elimina todas las filas relacionadas en otras tablas
5. Se mantiene la integridad referencial

**⚠️ Nota importante:** Este patrón puede ser peligroso. Considera usar `ON DELETE CASCADE` en las claves foráneas en su lugar:

```sql
-- Alternativa más segura usando CASCADE
ALTER TABLE user_posts
ADD CONSTRAINT fk_user_posts_user
FOREIGN KEY (user_id) REFERENCES users(id)
ON DELETE CASCADE;
```

---

#### ✨ Ejemplo 5: Validar Datos Antes de Insertar (BEFORE INSERT)

**Función del trigger:**

```sql
CREATE OR REPLACE FUNCTION validate_user_data()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar que el email tenga formato correcto
    IF NEW.email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Email inválido: %', NEW.email;
    END IF;

    -- Validar que el nombre no esté vacío
    IF TRIM(NEW.name) = '' THEN
        RAISE EXCEPTION 'El nombre no puede estar vacío';
    END IF;

    -- Validar que el nombre tenga al menos 2 caracteres
    IF LENGTH(TRIM(NEW.name)) < 2 THEN
        RAISE EXCEPTION 'El nombre debe tener al menos 2 caracteres';
    END IF;

    -- Convertir email a minúsculas automáticamente
    NEW.email = LOWER(NEW.email);

    -- Capitalizar nombre (primera letra mayúscula)
    NEW.name = INITCAP(NEW.name);

    RETURN NEW;
END;
$$;
```

**Crear el trigger:**

```sql
CREATE TRIGGER validate_user_before_insert
BEFORE INSERT ON users
FOR EACH ROW
EXECUTE FUNCTION validate_user_data();
```

**Cómo funciona:**

1. Usuario ejecuta: `INSERT INTO users(name, email) VALUES ('juan pérez', 'JUAN@EXAMPLE.COM');`
2. **Antes** de la inserción, se ejecuta el trigger
3. El trigger valida el formato del email
4. El trigger valida que el nombre no esté vacío
5. El trigger normaliza los datos (email a minúsculas, nombre capitalizado)
6. PostgreSQL inserta la fila con los datos normalizados

**Uso:**

```sql
-- Esto se normalizará automáticamente
INSERT INTO users(name, email) VALUES ('juan pérez', 'JUAN@EXAMPLE.COM');
-- Se guardará como: 'Juan Pérez', 'juan@example.com'

-- Esto fallará por validación
INSERT INTO users(name, email) VALUES ('A', 'email-invalido');
-- Error: El nombre debe tener al menos 2 caracteres
```

---

#### ✨ Ejemplo 6: Auditoría Completa (AFTER INSERT/UPDATE/DELETE)

**Tabla de auditoría:**

```sql
CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    table_name TEXT NOT NULL,
    action TEXT NOT NULL,  -- INSERT, UPDATE, DELETE
    record_id INT,
    old_data JSONB,
    new_data JSONB,
    changed_by INT,
    changed_at TIMESTAMP DEFAULT NOW()
);
```

**Función del trigger:**

```sql
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_logs(
            table_name,
            action,
            record_id,
            new_data,
            changed_at
        )
        VALUES (
            TG_TABLE_NAME,
            'INSERT',
            NEW.id,
            row_to_json(NEW),
            NOW()
        );
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_logs(
            table_name,
            action,
            record_id,
            old_data,
            new_data,
            changed_at
        )
        VALUES (
            TG_TABLE_NAME,
            'UPDATE',
            NEW.id,
            row_to_json(OLD),
            row_to_json(NEW),
            NOW()
        );
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_logs(
            table_name,
            action,
            record_id,
            old_data,
            changed_at
        )
        VALUES (
            TG_TABLE_NAME,
            'DELETE',
            OLD.id,
            row_to_json(OLD),
            NOW()
        );
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;
```

**Crear triggers:**

```sql
CREATE TRIGGER audit_users_trigger
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW
EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_businesses_trigger
AFTER INSERT OR UPDATE OR DELETE ON businesses
FOR EACH ROW
EXECUTE FUNCTION audit_trigger_function();
```

**Cómo funciona:**

- Registra **todos** los cambios en las tablas monitoreadas
- Guarda los datos **antiguos** y **nuevos** en formato JSON
- Permite auditoría completa de cambios en la base de datos

**Consultar auditoría:**

```sql
-- Ver todos los cambios en users
SELECT * FROM audit_logs WHERE table_name = 'users' ORDER BY changed_at DESC;

-- Ver solo actualizaciones
SELECT * FROM audit_logs WHERE action = 'UPDATE';

-- Ver cambios de un registro específico
SELECT * FROM audit_logs WHERE table_name = 'users' AND record_id = 1;
```

---

## 🎯 Mejores Prácticas

### ✅ **Para Funciones**

1. **Usa nombres descriptivos**

   ```sql
   -- ✅ Bueno
   CREATE FUNCTION calculate_user_discount(...)

   -- ❌ Malo
   CREATE FUNCTION calc(...)
   ```

2. **Documenta tus funciones**

   ```sql
   CREATE FUNCTION calculate_total(...)
   RETURNS NUMERIC
   LANGUAGE plpgsql
   AS $$
   -- Calcula el total incluyendo impuestos y descuentos
   -- Parámetros:
   --   p_subtotal: Precio base
   --   p_tax_rate: Porcentaje de impuesto (0-100)
   --   p_discount: Descuento aplicado
   BEGIN
       ...
   END;
   $$;
   ```

3. **Valida parámetros de entrada**

   ```sql
   IF p_value < 0 THEN
       RAISE EXCEPTION 'El valor no puede ser negativo';
   END IF;
   ```

4. **Maneja errores apropiadamente**

   ```sql
   BEGIN
       -- Código que puede fallar
   EXCEPTION
       WHEN OTHERS THEN
           RAISE EXCEPTION 'Error en función: %', SQLERRM;
   END;
   ```

5. **Usa tipos de datos apropiados**

   ```sql
   -- ✅ Usa NUMERIC para dinero
   RETURNS NUMERIC(10, 2)

   -- ❌ No uses FLOAT para dinero
   RETURNS FLOAT
   ```

### ✅ **Para Triggers**

1. **Mantén los triggers simples**

   - Un trigger debe hacer una cosa bien
   - Si necesitas lógica compleja, ponla en una función

2. **Usa BEFORE para validaciones**

   ```sql
   -- ✅ Validar antes de insertar
   CREATE TRIGGER validate_before_insert
   BEFORE INSERT ON users
   ...
   ```

3. **Usa AFTER para auditoría**

   ```sql
   -- ✅ Registrar después de actualizar
   CREATE TRIGGER audit_after_update
   AFTER UPDATE ON users
   ...
   ```

4. **Evita triggers recursivos**

   ```sql
   -- ⚠️ Peligro: Trigger que actualiza la misma tabla
   CREATE TRIGGER update_users
   AFTER UPDATE ON users
   FOR EACH ROW
   EXECUTE FUNCTION update_users();  -- Puede causar loop infinito
   ```

5. **Considera el rendimiento**
   - Los triggers se ejecutan en cada fila afectada
   - Evita operaciones costosas en triggers
   - Usa índices apropiados

---

## 🔍 Casos de Uso Comunes

### 📊 **1. Mantener Estadísticas Actualizadas**

```sql
-- Función para actualizar contador de citas
CREATE OR REPLACE FUNCTION update_appointment_count()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE businesses
        SET total_appointments = total_appointments + 1
        WHERE id = NEW.business_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE businesses
        SET total_appointments = total_appointments - 1
        WHERE id = OLD.business_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER update_appointment_stats
AFTER INSERT OR DELETE ON appointments
FOR EACH ROW
EXECUTE FUNCTION update_appointment_count();
```

### 🔐 **2. Encriptar Datos Sensibles**

```sql
-- Función para encriptar contraseñas antes de guardar
CREATE OR REPLACE FUNCTION encrypt_password()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Encriptar contraseña antes de insertar/actualizar
    NEW.password_hash = crypt(NEW.password_hash, gen_salt('bf'));
    RETURN NEW;
END;
$$;

CREATE TRIGGER encrypt_password_trigger
BEFORE INSERT OR UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION encrypt_password();
```

### 📧 **3. Enviar Notificaciones**

```sql
-- Función para crear notificación cuando se crea una cita
CREATE OR REPLACE FUNCTION notify_appointment_created()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Crear notificación para el negocio
    INSERT INTO notifications(
        user_id,
        type,
        title,
        message,
        created_at
    )
    VALUES (
        (SELECT owner_id FROM businesses WHERE id = NEW.business_id),
        'APPOINTMENT_CREATED',
        'Nueva cita creada',
        'Se ha creado una nueva cita para el ' || NEW.date,
        NOW()
    );

    RETURN NEW;
END;
$$;

CREATE TRIGGER notify_on_appointment
AFTER INSERT ON appointments
FOR EACH ROW
EXECUTE FUNCTION notify_appointment_created();
```

---

## 🐛 Troubleshooting

### ❌ **Error: Función no existe**

```sql
-- Error: function nombre_funcion() does not exist
-- Solución: Verificar que la función existe
SELECT proname FROM pg_proc WHERE proname = 'nombre_funcion';
```

### ❌ **Error: Trigger no se ejecuta**

```sql
-- Verificar que el trigger existe
SELECT * FROM pg_trigger WHERE tgname = 'nombre_trigger';

-- Verificar que la función del trigger existe
SELECT * FROM pg_proc WHERE proname = 'nombre_funcion_trigger';
```

### ❌ **Error: Loop infinito en trigger**

```sql
-- Si un trigger actualiza la misma tabla, puede causar loop
-- Solución: Usar una bandera o condición para evitar recursión
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Solo actualizar si realmente cambió algo
    IF NEW.updated_at = OLD.updated_at THEN
        NEW.updated_at = NOW();
    END IF;
    RETURN NEW;
END;
$$;
```

### ❌ **Error: Variable NEW/OLD no disponible**

```sql
-- NEW solo está disponible en INSERT y UPDATE
-- OLD solo está disponible en UPDATE y DELETE
-- Solución: Verificar TG_OP antes de usar
IF TG_OP = 'INSERT' THEN
    -- Usar NEW
ELSIF TG_OP = 'UPDATE' THEN
    -- Usar NEW y OLD
ELSIF TG_OP = 'DELETE' THEN
    -- Usar OLD
END IF;
```

---

## 📚 Recursos Adicionales

- 📖 [Documentación oficial de PostgreSQL - Funciones](https://www.postgresql.org/docs/current/xfunc.html)
- 📖 [Documentación oficial de PostgreSQL - Triggers](https://www.postgresql.org/docs/current/triggers.html)
- 📖 [PL/pgSQL Documentation](https://www.postgresql.org/docs/current/plpgsql.html)

---

## 🎓 Resumen

### **Funciones**

- ✅ Bloque de código reutilizable
- ✅ Pueden recibir parámetros y retornar valores
- ✅ Útiles para lógica compleja y cálculos

### **Triggers**

- ✅ Se ejecutan automáticamente ante eventos
- ✅ BEFORE: Validación y modificación de datos
- ✅ AFTER: Auditoría y efectos secundarios

### **Mejores Prácticas**

- ✅ Mantén el código simple y documentado
- ✅ Valida datos de entrada
- ✅ Maneja errores apropiadamente
- ✅ Considera el rendimiento

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_
