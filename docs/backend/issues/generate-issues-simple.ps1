# Script simple para generar issues
$historiasPath = "../historias-usuario"
$issuesPath = "."

$historias = Get-ChildItem -Path $historiasPath -Filter "US-*.md" | Sort-Object { [int]($_.Name -replace "US-(\d+)-.*", '$1') }

foreach ($historia in $historias) {
    $contenido = Get-Content $historia.FullName -Raw -Encoding UTF8
    
    $numero = if ($historia.Name -match "US-(\d+)-") { $matches[1] } else { "000" }
    
    $titulo = if ($contenido -match "# .*US-\d+: (.+)") { $matches[1].Trim() } else { "Titulo" }
    
    $epica = if ($contenido -match "Epica.*: (.+)") { $matches[1].Trim() } else { "Otros" }
    
    $prioridad = if ($contenido -match "Prioridad.*: (.+)") { 
        $p = $matches[1].Trim()
        if ($p -match "P0") { "P0" } elseif ($p -match "P1") { "P1" } else { "P0" }
    } else { "P0" }
    
    $storyPoints = if ($contenido -match "Story Points.*: (\d+)") { $matches[1].Trim() } else { "0" }
    
    $sprint = if ($contenido -match "Sprint.*: (.+)") { $matches[1].Trim() } else { "Sprint 1" }
    
    $dependencias = if ($contenido -match "Dependencias.*: (.+)") { $matches[1].Trim() } else { "Ninguna" }
    
    $epicaFolder = "epic-otros"
    if ($epica -like "*Autenticacion*" -or $epica -like "*Usuario*") { $epicaFolder = "epic-autenticacion" }
    elseif ($epica -like "*Negocio*") { $epicaFolder = "epic-negocios" }
    elseif ($epica -like "*Servicio*") { $epicaFolder = "epic-servicios" }
    elseif ($epica -like "*Cita*") { $epicaFolder = "epic-citas" }
    elseif ($epica -like "*Dashboard*" -or $epica -like "*Metrica*") { $epicaFolder = "epic-dashboard" }
    elseif ($epica -like "*Notificacion*") { $epicaFolder = "epic-notificaciones" }
    elseif ($epica -like "*Busqueda*") { $epicaFolder = "epic-busqueda" }
    elseif ($epica -like "*Upload*" -or $epica -like "*Archivo*") { $epicaFolder = "epic-upload" }
    elseif ($epica -like "*Horario*") { $epicaFolder = "epic-horarios" }
    elseif ($epica -like "*Usuario*" -or $epica -like "*Perfil*") { $epicaFolder = "epic-usuario" }
    elseif ($epica -like "*Seguridad*" -or $epica -like "*Contrasena*") { $epicaFolder = "epic-seguridad" }
    elseif ($epica -like "*Infraestructura*" -or $epica -like "*Health*") { $epicaFolder = "epic-infraestructura" }
    elseif ($epica -like "*Validacion*") { $epicaFolder = "epic-validaciones" }
    
    $carpetaEpica = Join-Path $issuesPath $epicaFolder
    if (-not (Test-Path $carpetaEpica)) {
        New-Item -ItemType Directory -Path $carpetaEpica | Out-Null
    }
    
    $issueContent = @"
# ISSUE-$($numero.PadLeft(3, '0')): $titulo

**Labels**: `priority:$prioridad` `epic:$epicaFolder` `type:feature` `sprint:$sprint`  
**Story Points**: $storyPoints  
**Sprint**: $sprint  
**Dependencias**: $dependencias

---

## Descripcion

$titulo

**Historia de Usuario Completa**: [US-$numero](../historias-usuario/$($historia.Name))

---

## Criterios de Aceptacion

Ver la [historia de usuario completa](../historias-usuario/$($historia.Name)) para los criterios de aceptacion detallados.

---

## Checklist de Tareas

Ver la [historia de usuario completa](../historias-usuario/$($historia.Name)) para las tareas tecnicas detalladas paso a paso.

- [ ] Revisar historia de usuario completa
- [ ] Implementar DTOs necesarios
- [ ] Crear validadores Zod
- [ ] Implementar repositorio
- [ ] Implementar servicio
- [ ] Crear controlador
- [ ] Crear rutas
- [ ] Escribir tests unitarios
- [ ] Escribir tests de integracion
- [ ] Actualizar documentacion Swagger

---

## Enlaces

- **Historia de Usuario**: [US-$numero](../historias-usuario/$($historia.Name))
- **Sprint**: Ver [Sprints Detallados](../sprints/)

---

## Definition of Done

- [ ] Codigo implementado y revisado
- [ ] Tests unitarios pasando (>80% coverage)
- [ ] Tests de integracion pasando
- [ ] Validaciones funcionando
- [ ] Documentacion Swagger actualizada
- [ ] Logs implementados
- [ ] Manejo de errores correcto
- [ ] Code review aprobado

---

_Ultima actualizacion: Diciembre 2025_  
_Version: 1.0.0_
"@
    
    $issueFileName = "ISSUE-$($numero.PadLeft(3, '0'))-$($historia.Name -replace 'US-\d+-', '')"
    $issueFile = Join-Path $carpetaEpica $issueFileName
    
    [System.IO.File]::WriteAllText($issueFile, $issueContent, [System.Text.Encoding]::UTF8)
    
    Write-Host "Creado: $issueFile"
}

Write-Host "Issues generados exitosamente!"

