# 📤 Día 12: Upload de Archivos e Imágenes

## 🎯 Objetivo del Día

Implementar sistema completo de upload de archivos e imágenes para logos de negocios, imágenes de servicios y avatares de usuarios, incluyendo validación, almacenamiento y optimización.

---

## ✅ Checklist de Tareas

- [ ] Configurar almacenamiento de archivos (Supabase Storage o S3)
- [ ] Crear servicio de upload
- [ ] Implementar validación de archivos
- [ ] Crear endpoints de upload
- [ ] Implementar optimización de imágenes
- [ ] Crear sistema de thumbnails
- [ ] Crear tests completos

---

## 📋 Pasos Detallados

### **Paso 1: Instalar Dependencias**

```bash
npm install multer @types/multer
npm install sharp
npm install uuid
npm install @supabase/supabase-js
```

### **Paso 2: Configurar Supabase Storage**

Crear archivo `src/config/storage.ts`:

```typescript
import { createClient } from "@supabase/supabase-js";
import { env } from "./env";

export const supabaseStorage = createClient(
  env.SUPABASE_URL,
  env.SUPABASE_SERVICE_ROLE_KEY // Usar service role key para operaciones del servidor
);

export const STORAGE_BUCKETS = {
  BUSINESS_LOGOS: "business-logos",
  SERVICE_IMAGES: "service-images",
  USER_AVATARS: "user-avatars",
  BUSINESS_IMAGES: "business-images",
} as const;

export type StorageBucket =
  (typeof STORAGE_BUCKETS)[keyof typeof STORAGE_BUCKETS];
```

Actualizar `.env`:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

### **Paso 3: Crear Utilidad de Validación de Archivos**

Crear archivo `src/utils/file-validation.util.ts`:

```typescript
import { Request } from "express";

export interface FileValidationOptions {
  maxSize?: number; // en bytes
  allowedMimeTypes?: string[];
  allowedExtensions?: string[];
}

export interface FileValidationResult {
  valid: boolean;
  errors: string[];
}

export class FileValidationUtil {
  static validateFile(
    file: Express.Multer.File,
    options: FileValidationOptions = {}
  ): FileValidationResult {
    const errors: string[] = [];
    const {
      maxSize = 5 * 1024 * 1024, // 5MB por defecto
      allowedMimeTypes = ["image/jpeg", "image/png", "image/webp"],
      allowedExtensions = [".jpg", ".jpeg", ".png", ".webp"],
    } = options;

    // Validar tamaño
    if (file.size > maxSize) {
      errors.push(
        `File size exceeds maximum allowed size of ${maxSize / 1024 / 1024}MB`
      );
    }

    // Validar tipo MIME
    if (!allowedMimeTypes.includes(file.mimetype)) {
      errors.push(
        `File type ${
          file.mimetype
        } is not allowed. Allowed types: ${allowedMimeTypes.join(", ")}`
      );
    }

    // Validar extensión
    const extension = file.originalname
      .toLowerCase()
      .substring(file.originalname.lastIndexOf("."));
    if (!allowedExtensions.includes(extension)) {
      errors.push(
        `File extension ${extension} is not allowed. Allowed extensions: ${allowedExtensions.join(
          ", "
        )}`
      );
    }

    return {
      valid: errors.length === 0,
      errors,
    };
  }

  static validateImage(file: Express.Multer.File): FileValidationResult {
    return this.validateFile(file, {
      maxSize: 5 * 1024 * 1024, // 5MB
      allowedMimeTypes: ["image/jpeg", "image/png", "image/webp"],
      allowedExtensions: [".jpg", ".jpeg", ".png", ".webp"],
    });
  }

  static validateLogo(file: Express.Multer.File): FileValidationResult {
    return this.validateFile(file, {
      maxSize: 2 * 1024 * 1024, // 2MB para logos
      allowedMimeTypes: [
        "image/jpeg",
        "image/png",
        "image/webp",
        "image/svg+xml",
      ],
      allowedExtensions: [".jpg", ".jpeg", ".png", ".webp", ".svg"],
    });
  }
}
```

### **Paso 4: Crear Utilidad de Optimización de Imágenes**

Crear archivo `src/utils/image-optimization.util.ts`:

```typescript
import sharp from "sharp";
import { logger } from "../config/logger";

export interface ImageOptimizationOptions {
  width?: number;
  height?: number;
  quality?: number;
  format?: "jpeg" | "png" | "webp";
}

export class ImageOptimizationUtil {
  /**
   * Optimiza una imagen y devuelve el buffer optimizado
   */
  static async optimizeImage(
    buffer: Buffer,
    options: ImageOptimizationOptions = {}
  ): Promise<Buffer> {
    const {
      width = 1920,
      height = 1080,
      quality = 80,
      format = "webp",
    } = options;

    try {
      let pipeline = sharp(buffer);

      // Redimensionar manteniendo aspect ratio
      pipeline = pipeline.resize(width, height, {
        fit: "inside",
        withoutEnlargement: true,
      });

      // Aplicar formato y calidad
      if (format === "jpeg") {
        pipeline = pipeline.jpeg({ quality });
      } else if (format === "png") {
        pipeline = pipeline.png({ quality });
      } else {
        pipeline = pipeline.webp({ quality });
      }

      return await pipeline.toBuffer();
    } catch (error) {
      logger.error("Error optimizing image:", error);
      throw new Error("Failed to optimize image");
    }
  }

  /**
   * Crea un thumbnail de una imagen
   */
  static async createThumbnail(
    buffer: Buffer,
    size: number = 300
  ): Promise<Buffer> {
    try {
      return await sharp(buffer)
        .resize(size, size, {
          fit: "cover",
          position: "center",
        })
        .webp({ quality: 80 })
        .toBuffer();
    } catch (error) {
      logger.error("Error creating thumbnail:", error);
      throw new Error("Failed to create thumbnail");
    }
  }

  /**
   * Obtiene metadatos de una imagen
   */
  static async getImageMetadata(buffer: Buffer) {
    try {
      const metadata = await sharp(buffer).metadata();
      return {
        width: metadata.width,
        height: metadata.height,
        format: metadata.format,
        size: buffer.length,
      };
    } catch (error) {
      logger.error("Error getting image metadata:", error);
      throw new Error("Failed to get image metadata");
    }
  }
}
```

### **Paso 5: Crear Servicio de Storage**

Crear archivo `src/services/storage.service.ts`:

```typescript
import {
  supabaseStorage,
  STORAGE_BUCKETS,
  StorageBucket,
} from "../config/storage";
import { ImageOptimizationUtil } from "../utils/image-optimization.util";
import { logger } from "../config/logger";
import { v4 as uuidv4 } from "uuid";

export interface UploadResult {
  url: string;
  path: string;
  thumbnailUrl?: string;
  metadata?: {
    width?: number;
    height?: number;
    size: number;
    format?: string;
  };
}

export class StorageService {
  /**
   * Sube un archivo a Supabase Storage
   */
  async uploadFile(
    file: Express.Multer.File,
    bucket: StorageBucket,
    folder?: string,
    optimize: boolean = true
  ): Promise<UploadResult> {
    try {
      // Generar nombre único
      const fileExtension = file.originalname.substring(
        file.originalname.lastIndexOf(".")
      );
      const fileName = `${uuidv4()}${fileExtension}`;
      const filePath = folder ? `${folder}/${fileName}` : fileName;

      let fileBuffer = file.buffer;

      // Optimizar imagen si es necesario
      if (optimize && file.mimetype.startsWith("image/")) {
        fileBuffer = await ImageOptimizationUtil.optimizeImage(fileBuffer);
      }

      // Subir archivo principal
      const { data, error } = await supabaseStorage.storage
        .from(bucket)
        .upload(filePath, fileBuffer, {
          contentType: file.mimetype,
          upsert: false,
        });

      if (error) {
        logger.error("Error uploading file:", error);
        throw new Error(`Failed to upload file: ${error.message}`);
      }

      // Obtener URL pública
      const {
        data: { publicUrl },
      } = supabaseStorage.storage.from(bucket).getPublicUrl(filePath);

      const result: UploadResult = {
        url: publicUrl,
        path: filePath,
      };

      // Crear thumbnail si es imagen
      if (file.mimetype.startsWith("image/")) {
        try {
          const thumbnailBuffer = await ImageOptimizationUtil.createThumbnail(
            file.buffer
          );
          const thumbnailPath = folder
            ? `${folder}/thumbnails/${fileName}`
            : `thumbnails/${fileName}`;

          await supabaseStorage.storage
            .from(bucket)
            .upload(thumbnailPath, thumbnailBuffer, {
              contentType: "image/webp",
              upsert: false,
            });

          const {
            data: { publicUrl: thumbnailUrl },
          } = supabaseStorage.storage.from(bucket).getPublicUrl(thumbnailPath);

          result.thumbnailUrl = thumbnailUrl;
        } catch (error) {
          logger.warn("Failed to create thumbnail:", error);
          // No fallar si el thumbnail falla
        }

        // Obtener metadatos
        try {
          const metadata = await ImageOptimizationUtil.getImageMetadata(
            fileBuffer
          );
          result.metadata = metadata;
        } catch (error) {
          logger.warn("Failed to get image metadata:", error);
        }
      }

      logger.info(`File uploaded successfully: ${filePath}`);
      return result;
    } catch (error: any) {
      logger.error("Error in uploadFile:", error);
      throw error;
    }
  }

  /**
   * Elimina un archivo de Supabase Storage
   */
  async deleteFile(bucket: StorageBucket, path: string): Promise<void> {
    try {
      const { error } = await supabaseStorage.storage
        .from(bucket)
        .remove([path]);

      if (error) {
        logger.error("Error deleting file:", error);
        throw new Error(`Failed to delete file: ${error.message}`);
      }

      logger.info(`File deleted successfully: ${path}`);
    } catch (error: any) {
      logger.error("Error in deleteFile:", error);
      throw error;
    }
  }

  /**
   * Obtiene la URL pública de un archivo
   */
  getPublicUrl(bucket: StorageBucket, path: string): string {
    const {
      data: { publicUrl },
    } = supabaseStorage.storage.from(bucket).getPublicUrl(path);
    return publicUrl;
  }
}

export const storageService = new StorageService();
```

### **Paso 6: Configurar Multer**

Crear archivo `src/middleware/upload.middleware.ts`:

```typescript
import multer from "multer";
import { Request } from "express";

// Configurar multer para usar memoria (buffer) en lugar de disco
const storage = multer.memoryStorage();

const fileFilter = (
  req: Request,
  file: Express.Multer.File,
  cb: multer.FileFilterCallback
) => {
  // Permitir solo imágenes
  if (file.mimetype.startsWith("image/")) {
    cb(null, true);
  } else {
    cb(new Error("Only image files are allowed"));
  }
};

export const upload = multer({
  storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB
  },
  fileFilter,
});

// Middleware específico para logos (más pequeño)
export const uploadLogo = multer({
  storage,
  limits: {
    fileSize: 2 * 1024 * 1024, // 2MB
  },
  fileFilter,
});
```

### **Paso 7: Crear Servicio de Upload**

Crear archivo `src/services/upload.service.ts`:

```typescript
import { storageService, STORAGE_BUCKETS } from "../config/storage";
import { FileValidationUtil } from "../utils/file-validation.util";
import { AppError } from "../middleware/error.middleware";
import { logger } from "../config/logger";

export class UploadService {
  async uploadBusinessLogo(
    file: Express.Multer.File,
    businessId: string
  ): Promise<{ url: string; thumbnailUrl?: string }> {
    // Validar archivo
    const validation = FileValidationUtil.validateLogo(file);
    if (!validation.valid) {
      throw new AppError(400, validation.errors.join(", "));
    }

    // Subir archivo
    const result = await storageService.uploadFile(
      file,
      STORAGE_BUCKETS.BUSINESS_LOGOS,
      businessId,
      true // optimizar
    );

    logger.info(`Business logo uploaded: ${businessId}`);

    return {
      url: result.url,
      thumbnailUrl: result.thumbnailUrl,
    };
  }

  async uploadServiceImage(
    file: Express.Multer.File,
    serviceId: string,
    businessId: string
  ): Promise<{ url: string; thumbnailUrl?: string }> {
    // Validar archivo
    const validation = FileValidationUtil.validateImage(file);
    if (!validation.valid) {
      throw new AppError(400, validation.errors.join(", "));
    }

    // Subir archivo
    const result = await storageService.uploadFile(
      file,
      STORAGE_BUCKETS.SERVICE_IMAGES,
      `${businessId}/${serviceId}`,
      true // optimizar
    );

    logger.info(`Service image uploaded: ${serviceId}`);

    return {
      url: result.url,
      thumbnailUrl: result.thumbnailUrl,
    };
  }

  async uploadUserAvatar(
    file: Express.Multer.File,
    userId: string
  ): Promise<{ url: string; thumbnailUrl?: string }> {
    // Validar archivo
    const validation = FileValidationUtil.validateImage(file);
    if (!validation.valid) {
      throw new AppError(400, validation.errors.join(", "));
    }

    // Subir archivo
    const result = await storageService.uploadFile(
      file,
      STORAGE_BUCKETS.USER_AVATARS,
      userId,
      true // optimizar
    );

    logger.info(`User avatar uploaded: ${userId}`);

    return {
      url: result.url,
      thumbnailUrl: result.thumbnailUrl,
    };
  }

  async deleteFile(bucket: string, path: string): Promise<void> {
    await storageService.deleteFile(bucket as any, path);
  }
}

export const uploadService = new UploadService();
```

### **Paso 8: Crear Controlador de Upload**

Crear archivo `src/controllers/upload.controller.ts`:

```typescript
import { Request, Response } from "express";
import { uploadService } from "../services/upload.service";
import { logger } from "../config/logger";
import { AppError } from "../middleware/error.middleware";

export class UploadController {
  async uploadBusinessLogo(req: Request, res: Response): Promise<void> {
    try {
      const file = req.file;
      if (!file) {
        throw new AppError(400, "No file provided");
      }

      const businessId = req.params.businessId;
      const userId = req.user!.id;

      // Verificar permisos (el usuario debe ser dueño del negocio)
      // Esto debería estar en un middleware, pero por simplicidad lo ponemos aquí
      // En producción, crear un middleware específico

      const result = await uploadService.uploadBusinessLogo(file, businessId);

      res.json({
        success: true,
        data: result,
      });
    } catch (error: any) {
      logger.error("Error uploading business logo:", error);
      res.status(error.statusCode || 500).json({
        success: false,
        message: error.message || "Error uploading business logo",
      });
    }
  }

  async uploadServiceImage(req: Request, res: Response): Promise<void> {
    try {
      const file = req.file;
      if (!file) {
        throw new AppError(400, "No file provided");
      }

      const serviceId = req.params.serviceId;
      const businessId = req.body.businessId || req.params.businessId;

      const result = await uploadService.uploadServiceImage(
        file,
        serviceId,
        businessId
      );

      res.json({
        success: true,
        data: result,
      });
    } catch (error: any) {
      logger.error("Error uploading service image:", error);
      res.status(error.statusCode || 500).json({
        success: false,
        message: error.message || "Error uploading service image",
      });
    }
  }

  async uploadUserAvatar(req: Request, res: Response): Promise<void> {
    try {
      const file = req.file;
      if (!file) {
        throw new AppError(400, "No file provided");
      }

      const userId = req.user!.id;

      const result = await uploadService.uploadUserAvatar(file, userId);

      res.json({
        success: true,
        data: result,
      });
    } catch (error: any) {
      logger.error("Error uploading user avatar:", error);
      res.status(error.statusCode || 500).json({
        success: false,
        message: error.message || "Error uploading user avatar",
      });
    }
  }
}

export const uploadController = new UploadController();
```

### **Paso 9: Crear Rutas de Upload**

Crear archivo `src/routes/upload.routes.ts`:

```typescript
import { Router } from "express";
import { uploadController } from "../controllers/upload.controller";
import { authMiddleware } from "../middleware/auth.middleware";
import { upload, uploadLogo } from "../middleware/upload.middleware";

const router = Router();

// Todas las rutas requieren autenticación
router.use(authMiddleware);

// POST /api/upload/business/:businessId/logo
router.post(
  "/business/:businessId/logo",
  uploadLogo.single("logo"),
  uploadController.uploadBusinessLogo.bind(uploadController)
);

// POST /api/upload/service/:serviceId/image
router.post(
  "/service/:serviceId/image",
  upload.single("image"),
  uploadController.uploadServiceImage.bind(uploadController)
);

// POST /api/upload/user/avatar
router.post(
  "/user/avatar",
  upload.single("avatar"),
  uploadController.uploadUserAvatar.bind(uploadController)
);

export default router;
```

### **Paso 10: Registrar Rutas en App**

Actualizar `src/app.ts`:

```typescript
// ... existing imports ...
import uploadRoutes from "./routes/upload.routes";

// ... existing code ...

app.use("/api/upload", uploadRoutes);

// ... existing code ...
```

### **Paso 11: Actualizar Modelos para Incluir URLs de Imágenes**

Actualizar `prisma/schema.prisma`:

```prisma
model Business {
  // ... existing fields ...
  logoUrl      String?  @map("logo_url")
  logoThumbnailUrl String? @map("logo_thumbnail_url")
  // ... rest of model ...
}

model Service {
  // ... existing fields ...
  imageUrl     String?  @map("image_url")
  imageThumbnailUrl String? @map("image_thumbnail_url")
  // ... rest of model ...
}

model User {
  // ... existing fields ...
  avatarUrl    String?  @map("avatar_url")
  avatarThumbnailUrl String? @map("avatar_thumbnail_url")
  // ... rest of model ...
}
```

Ejecutar migración:

```bash
npx prisma migrate dev --name add_image_urls
npx prisma generate
```

### **Paso 12: Actualizar Servicios para Guardar URLs**

Actualizar `src/services/business.service.ts`:

```typescript
// ... existing code ...

async updateLogo(businessId: string, logoUrl: string, thumbnailUrl?: string): Promise<Business> {
  return await businessRepository.update(businessId, {
    logoUrl,
    logoThumbnailUrl: thumbnailUrl,
  });
}

// ... existing code ...
```

### **Paso 13: Crear Tests**

Crear archivo `tests/services/upload.service.test.ts`:

```typescript
import { UploadService } from "../../src/services/upload.service";
import { storageService } from "../../src/services/storage.service";

jest.mock("../../src/services/storage.service");

describe("UploadService", () => {
  let uploadService: UploadService;

  beforeEach(() => {
    uploadService = new UploadService();
    jest.clearAllMocks();
  });

  describe("uploadBusinessLogo", () => {
    it("should upload business logo successfully", async () => {
      // Arrange
      const mockFile = {
        buffer: Buffer.from("test"),
        originalname: "logo.jpg",
        mimetype: "image/jpeg",
        size: 1024,
      } as Express.Multer.File;

      const mockResult = {
        url: "https://example.com/logo.jpg",
        thumbnailUrl: "https://example.com/logo-thumb.jpg",
      };

      (storageService.uploadFile as jest.Mock).mockResolvedValue(mockResult);

      // Act
      const result = await uploadService.uploadBusinessLogo(
        mockFile,
        "business-1"
      );

      // Assert
      expect(result).toEqual(mockResult);
      expect(storageService.uploadFile).toHaveBeenCalled();
    });
  });
});
```

---

## ✅ Verificación Final

- [ ] Upload de archivos funcionando
- [ ] Validación de archivos implementada
- [ ] Optimización de imágenes funcionando
- [ ] Thumbnails generándose correctamente
- [ ] Tests pasando

---

## 📝 Entregables del Día

1. ✅ Sistema de upload de archivos
2. ✅ Validación de archivos
3. ✅ Optimización de imágenes
4. ✅ Generación de thumbnails
5. ✅ Integración con Supabase Storage
6. ✅ Tests completos

---

## 🎯 Próximo Día

**Día 13**: Horarios de Negocio y Disponibilidad

---

_Última actualización: Diciembre 2024_  
_Versión: 1.0.0_
