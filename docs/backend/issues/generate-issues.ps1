# Script para generar issues desde historias de usuario
# PowerShell Script

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
    "Upload de Archivos" = "epic-upload"
    "Horarios y Disponibilidad" = "epic-horarios"
    "Horarios Avanzados" = "epic-horarios"
    "Gestión de Usuario" = "epic-usuario"
    "Seguridad" = "epic-seguridad"
    "Infraestructura" = "epic-infraestructura"
    "Validaciones y Filtros" = "epic-validaciones"
    "Validaciones" = "epic-validaciones"
}

# Obtener todas las historias
$historias = Get-ChildItem -Path $historiasPath -Filter "US-*.md" | Sort-Object Name

foreach ($historia in $historias) {
    $contenido = Get-Content $historia.FullName -Raw
    
    # Extraer información del issue
    $numero = $historia.Name -replace "US-(\d+)-.*", '$1'
    $titulo = $contenido -match "# .*US-\d+: (.+)" | Out-Null; $titulo = $matches[1]
    
    if (-not $titulo) {
        $titulo = $historia.Name -replace "US-\d+-", "" -replace "\.md", "" -replace "-", " "
        $titulo = (Get-Culture).TextInfo.ToTitleCase($titulo)
    }
    
    # Extraer épica
    $epica = ""
    if ($contenido -match "\*\*Épica\*\*: (.+)") {
        $epica = $matches[1].Trim()
    }
    
    # Extraer prioridad
    $prioridad = ""
    if ($contenido -match "\*\*Prioridad\*\*: (.+)") {
        $prioridad = $matches[1].Trim()
    }
    
    # Extraer story points
    $storyPoints = ""
    if ($contenido -match "\*\*Story Points\*\*: (\d+)") {
        $storyPoints = $matches[1].Trim()
    }
    
    # Extraer sprint
    $sprint = ""
    if ($contenido -match "\*\*Sprint\*\*: (.+)") {
        $sprint = $matches[1].Trim()
    }
    
    # Extraer dependencias
    $dependencias = ""
    if ($contenido -match "\*\*Dependencias\*\*: (.+)") {
        $dependencias = $matches[1].Trim()
    }
    
    # Extraer criterios de aceptación
    $criterios = ""
    if ($contenido -match "## ✅ Criterios de Aceptación\s+([\s\S]+?)(?=---|##)") {
        $criterios = $matches[1].Trim()
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
    
    # Generar contenido del issue
    $issueContent = @"
# $titulo

**Labels**: `priority:$prioridad` `epic:$epicaFolder` `type:feature` `sprint:$sprint`  
**Story Points**: $storyPoints  
**Sprint**: $sprint  
**Dependencias**: $dependencias

---

## 📖 Descripción

$titulo

**Historia de Usuario**: [US-$numero](../historias-usuario/$($historia.Name))

---

## ✅ Criterios de Aceptación

$criterios

---

## 📋 Checklist de Tareas

Ver la [historia de usuario completa](../historias-usuario/$($historia.Name)) para las tareas técnicas detalladas.

---

## 🔗 Enlaces

- **Historia de Usuario**: [US-$numero](../historias-usuario/$($historia.Name))
- **Sprint**: Ver [Sprints Detallados](../sprints/)

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

---

_Última actualización: Diciembre 2025_  
_Versión: 1.0.0_
"@
    
    # Guardar issue
    $issueFile = Join-Path $carpetaEpica "ISSUE-$($numero.PadLeft(3, '0'))-$($historia.Name -replace 'US-\d+-', '')"
    $issueContent | Out-File -FilePath $issueFile -Encoding UTF8
    
    Write-Host "✅ Creado: $issueFile"
}

Write-Host "`n🎉 Issues generados exitosamente!"

