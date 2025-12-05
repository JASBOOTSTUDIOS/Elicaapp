# Script para organizar issues en carpetas correctas
$mapping = @{
    "001" = "epic-autenticacion"
    "002" = "epic-autenticacion"
    "003" = "epic-negocios"
    "004" = "epic-servicios"
    "005" = "epic-citas"
    "006" = "epic-dashboard"
    "007" = "epic-dashboard"
    "008" = "epic-notificaciones"
    "009" = "epic-notificaciones"
    "010" = "epic-notificaciones"
    "011" = "epic-busqueda"
    "012" = "epic-upload"
    "013" = "epic-horarios"
    "014" = "epic-horarios"
    "015" = "epic-usuario"
    "016" = "epic-seguridad"
    "017" = "epic-horarios"
    "018" = "epic-horarios"
    "019" = "epic-busqueda"
    "020" = "epic-busqueda"
    "021" = "epic-upload"
    "022" = "epic-upload"
    "023" = "epic-citas"
    "024" = "epic-citas"
    "025" = "epic-citas"
    "026" = "epic-negocios"
    "027" = "epic-negocios"
    "028" = "epic-servicios"
    "029" = "epic-notificaciones"
    "030" = "epic-negocios"
    "031" = "epic-servicios"
    "032" = "epic-negocios"
    "033" = "epic-servicios"
    "034" = "epic-citas"
    "035" = "epic-autenticacion"
    "036" = "epic-autenticacion"
    "037" = "epic-infraestructura"
    "038" = "epic-citas"
    "039" = "epic-citas"
    "040" = "epic-infraestructura"
    "041" = "epic-usuario"
    "042" = "epic-negocios"
    "043" = "epic-negocios"
    "044" = "epic-servicios"
    "045" = "epic-horarios"
    "046" = "epic-horarios"
    "047" = "epic-horarios"
    "048" = "epic-horarios"
    "049" = "epic-horarios"
    "050" = "epic-autenticacion"
}

$sourceDir = "epic-otros"
$files = Get-ChildItem -Path $sourceDir -Filter "ISSUE-*.md"

foreach ($file in $files) {
    if ($file.Name -match "ISSUE-(\d+)-") {
        $num = $matches[1]
        if ($mapping.ContainsKey($num)) {
            $targetDir = $mapping[$num]
            $targetPath = Join-Path $targetDir $file.Name
            Move-Item -Path $file.FullName -Destination $targetPath -Force
            Write-Host "Movido: $($file.Name) -> $targetDir"
        }
    }
}

Write-Host "Organizacion completada!"

