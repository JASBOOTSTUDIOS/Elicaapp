# Script mejorado para generar issues desde historias de usuario
# PowerShell Script con UTF-8 encoding

$historiasPath = "../historias-usuario"
$issuesPath = "."

# Mapeo de épicas a carpetas
$epicas = @{
    "Autenticación y Usuarios" = "epic-autenticacion"
    "Negocios y Servicios" = "epic-negocios"
    "Negocios" = "epic-negocios"
    "Servicios" = "epic-servicios"
    "Sistema de Citas" = "epic-citas"
    "Citas" = "epic-citas"
    "Dashboard y Métricas" = "epic-dashboard"
    "Notificaciones" = "epic-notificaciones"
    "Búsqueda y Filtros" = "epic-busqueda"
    "Búsqueda" = "epic-busqueda"
    "Búsqueda Avanzada" = "epic-busqueda"
    "Upload de Archivos" = "epic-upload"
    "Upload Avanzado" = "epic-upload"
    "Horarios y Disponibilidad" = "epic-horarios"
    "Horarios Avanzados" = "epic-horarios"
    "Gestión de Usuario" = "epic-usuario"
    "Seguridad" = "epic-seguridad"
    "Infraestructura" = "epic-infraestructura"
    "Validaciones y Filtros" = "epic-validaciones"
    "Validaciones" = "epic-validaciones"
}

# Mapeo de prioridades
$prioridades = @{
    "P0 (Crítica)" = "P0"
    "P1 (Alta)" = "P1"
    "P2 (Media)" = "P2"
    "P3 (Baja)" = "P3"
}

# Obtener todas las historias
$historias = Get-ChildItem -Path $historiasPath -Filter "US-*.md" | Sort-Object { [int]($_.Name -replace "US-(\d+)-.*", '$1') }

foreach ($historia in $historias) {
    $contenido = Get-Content $historia.FullName -Raw -Encoding UTF8
    
    # Extraer número
    $numero = ""
    if ($historia.Name -match "US-(\d+)-") {
        $numero = $matches[1]
    }
    
    # Extraer título
    $titulo = ""
    if ($contenido -match "# .*US-\d+: (.+)") {
        $titulo = $matches[1].Trim()
    } else {
        $titulo = $historia.Name -replace "US-\d+-", "" -replace "\.md", "" -replace "-", " "
        $titulo = (Get-Culture).TextInfo.ToTitleCase($titulo)
    }
    
    # Extraer épica
    $epica = ""
    if ($contenido -match "\*\*Épica\*\*: (.+)") {
        $epica = $matches[1].Trim()
    }
    
    # Extraer prioridad
    $prioridad = "P0"
    if ($contenido -match "\*\*Prioridad\*\*: (.+)") {
        $prioridadRaw = $matches[1].Trim()
        if ($prioridades.ContainsKey($prioridadRaw)) {
            $prioridad = $prioridades[$prioridadRaw]
        } elseif ($prioridadRaw -match "P\d+") {
            $prioridad = $prioridadRaw -replace " \(.*\)", ""
        }
    }
    
    # Extraer story points
    $storyPoints = "0"
    if ($contenido -match "\*\*Story Points\*\*: (\d+)") {
        $storyPoints = $matches[1].Trim()
    }
    
    # Extraer sprint
    $sprint = ""
    if ($contenido -match "\*\*Sprint\*\*: (.+)") {
        $sprint = $matches[1].Trim()
    }
    
    # Extraer dependencias
    $dependencias = "Ninguna"
    if ($contenido -match "\*\*Dependencias\*\*: (.+)") {
        $dependencias = $matches[1].Trim()
    }
    
    # Extraer historia de usuario completa
    $historiaUsuario = ""
    if ($contenido -match "## 📖 Historia de Usuario\s+[\s\S]+?\*\*Como\*\* (.+?)\s+\*\*Quiero\*\* (.+?)\s+\*\*Para\*\* (.+)") {
        $historiaUsuario = "**Como** $($matches[1])`n**Quiero** $($matches[2])`n**Para** $($matches[3])"
    }
    
    # Extraer criterios de aceptación
    $criterios = ""
    if ($contenido -match "## ✅ Criterios de Aceptación\s+([\s\S]+?)(?=---|## 🎯|## 📝)") {
        $criterios = $matches[1].Trim()
    }
    
    # Extraer reglas de negocio
    $reglas = ""
    if ($contenido -match "## 🎯 Reglas de Negocio\s+([\s\S]+?)(?=---|## 📝)") {
        $reglas = $matches[1].Trim()
    }
    
    # Determinar carpeta de épica
    $epicaFolder = "epic-otros"
    foreach ($key in $epicas.Keys) {
        if ($epica -like "*$key*") {
            $epicaFolder = $epicas[$key]
            break
        }
    }
    
    # Crear carpeta si no existe
    $carpetaEpica = Join-Path $issuesPath $epicaFolder
    if (-not (Test-Path $carpetaEpica)) {
        New-Item -ItemType Directory -Path $carpetaEpica | Out-Null
    }
    
    # Formatear dependencias para links
    $dependenciasLinks = $dependencias
    if ($dependencias -ne "Ninguna" -and $dependencias -match "US-(\d+)") {
        $depNum = $matches[1]
        $dependenciasLinks = "[$dependencias](./ISSUE-$($depNum.PadLeft(3, '0'))-*.md)"
    }
    
    # Generar contenido del issue
    $issueContent = @"
# 👤 ISSUE-$($numero.PadLeft(3, '0')): $titulo

**Labels**: `priority:$prioridad` `epic:$epicaFolder` `type:feature` `sprint:$sprint`  
**Story Points**: $storyPoints  
**Sprint**: $sprint  
**Dependencias**: $dependenciasLinks

---

## 📖 Descripción

$historiaUsuario

**Historia de Usuario Completa**: [US-$numero](../historias-usuario/$($historia.Name))

---

## ✅ Criterios de Aceptación

$criterios

---

## 🎯 Reglas de Negocio

$reglas

---

## 📋 Checklist de Tareas

Ver la [historia de usuario completa](../historias-usuario/$($historia.Name)) para las tareas técnicas detalladas paso a paso.

### **Tareas Principales**

- [ ] Revisar historia de usuario completa
- [ ] Implementar DTOs necesarios
- [ ] Crear validadores Zod
- [ ] Implementar repositorio
- [ ] Implementar servicio
- [ ] Crear controlador
- [ ] Crear rutas
- [ ] Escribir tests unitarios
- [ ] Escribir tests de integración
- [ ] Actualizar documentación Swagger

---

## 🔗 Enlaces

- **Historia de Usuario**: [US-$numero](../historias-usuario/$($historia.Name))
- **Sprint**: Ver [Sprints Detallados](../sprints/)
- **Arquitectura**: [ARQUITECTURA.md](../ARQUITECTURA.md)

---

## 📝 Notas Técnicas

- Todas las tareas técnicas detalladas están en la historia de usuario
- Seguir el orden de las tareas especificado
- Verificar cada paso antes de continuar
- Escribir tests después de cada funcionalidad

---

## 🎯 Definition of Done

- [ ] Código implementado y revisado
- [ ] Tests unitarios pasando (>80% coverage)
- [ ] Tests de integración pasando
- [ ] Validaciones funcionando
- [ ] Documentación Swagger actualizada
- [ ] Logs implementados
- [ ] Manejo de errores correcto
- [ ] Code review aprobado
- [ ] Criterios de aceptación cumplidos

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_
"@
    
    # Guardar issue con encoding UTF-8
    $issueFileName = "ISSUE-$($numero.PadLeft(3, '0'))-$($historia.Name -replace 'US-\d+-', '')"
    $issueFile = Join-Path $carpetaEpica $issueFileName
    
    # Guardar con UTF-8 encoding
    [System.IO.File]::WriteAllText($issueFile, $issueContent, [System.Text.Encoding]::UTF8)
    
    Write-Host "✅ Creado: $issueFile"
}

Write-Host "`n🎉 Issues generados exitosamente!"

