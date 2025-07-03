param(
    [Parameter(Mandatory=$true, HelpMessage="Service à filtrer")]
    [string]$Service
)

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "    RAPPORT EMPLOYES - SERVICE: $Service" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# Import du module
Write-Host "`nImport du module EmployeTools..." -ForegroundColor Yellow

try {
    Import-Module "./EmployeTools.psm1" -Force
    Write-Host "Module EmployeTools importe avec succes" -ForegroundColor Green
}
catch {
    Write-Host "Erreur lors de l'import du module : $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Assurez-vous que le fichier EmployeTools.psm1 est present dans le repertoire courant" -ForegroundColor Yellow
    exit 1
}

# Chargement du fichier CSV
Write-Host "`nChargement du fichier employes.csv..." -ForegroundColor Yellow

try {
    if (-not (Test-Path "employes.csv")) {
        throw "Le fichier employes.csv n'existe pas dans le repertoire courant"
    }
    
    $donnees = Import-Csv -Path "employes.csv"
    Write-Host "Fichier charge - $($donnees.Count) employes trouves" -ForegroundColor Green
}
catch {
    Write-Host "Erreur lors du chargement : $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Filtrage des employés du service demandé
Write-Host "`nFiltrage des employes du service '$Service'..." -ForegroundColor Yellow

try {
    $employesFiltres = Filtrer-Employes -Donnees $donnees -Service $Service
    
    if ($employesFiltres.Count -eq 0) {
        Write-Host "Aucun employe trouve pour le service '$Service'" -ForegroundColor Red
        Write-Host "`nServices disponibles dans le fichier :" -ForegroundColor Yellow
        $servicesDisponibles = $donnees | Select-Object -ExpandProperty Service | Sort-Object -Unique
        foreach ($s in $servicesDisponibles) {
            Write-Host "  $s" -ForegroundColor Gray
        }
        exit 0
    }
    
    Write-Host "$($employesFiltres.Count) employe(s) trouve(s) pour le service '$Service'" -ForegroundColor Green
}
catch {
    Write-Host "Erreur lors du filtrage : $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Affichage des informations avec le préfixe [Employé]
Write-Host "`nDETAILS DES EMPLOYES DU SERVICE $Service" -ForegroundColor Cyan
Write-Host "---------------------------------------------" -ForegroundColor Cyan

foreach ($employe in $employesFiltres) {
    Afficher-Employe -Employe $employe -Prefix "[Employe]"
}

# Statistiques supplémentaires
Write-Host "`nSTATISTIQUES DU SERVICE" -ForegroundColor Green
Write-Host "----------------------------" -ForegroundColor Green

$ages = $employesFiltres | ForEach-Object { [int]$_.Age }
$salaires = $employesFiltres | ForEach-Object { [int]$_.Salaire }

$ageMoyen = ($ages | Measure-Object -Average).Average
$salaireMoyen = ($salaires | Measure-Object -Average).Average

Write-Host "Nombre d'employes : $($employesFiltres.Count)"
Write-Host "Age moyen : $([math]::Round($ageMoyen, 1)) ans"
Write-Host "Salaire moyen : $([math]::Round($salaireMoyen, 0)) euros"

Write-Host "`nRapport termine avec succes !" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Cyan
