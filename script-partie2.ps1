[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Partie 2 : Fonctions, erreurs, parametres et modules

Write-Host "=== PARTIE 2 - FONCTIONS, ERREURS, PARAMETRES ET MODULES ===" -ForegroundColor Magenta

# Preparation des donnees
if (-not (Test-Path "employes.csv")) {
    Write-Host "Creation du fichier employes.csv..." -ForegroundColor Yellow
    @"
Nom,Age,Service,Salaire
Dupont,45,Informatique,42000
Martin,29,Marketing,36000
Durand,34,Informatique,40000
Bernard,51,Comptabilite,38000
Petit,41,RH,37000
"@ | Out-File -FilePath "employes.csv" -Encoding UTF8
    Write-Host "Fichier cree" -ForegroundColor Green
}

$donnees = Import-Csv -Path "employes.csv"
Write-Host "Donnees chargees : $($donnees.Count) employes" -ForegroundColor Green

# ETAPE 1 - CREER ET UTILISER DES FONCTIONS
Write-Host "`n--- ETAPE 1 - CREER ET UTILISER DES FONCTIONS ---" -ForegroundColor Cyan

function Afficher-Employe {
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Employe
    )
    
    Write-Host "$($Employe.Nom) travaille dans le service $($Employe.Service) avec un salaire de $($Employe.Salaire) euros"
}

Write-Host "`n1. Fonction Afficher-Employe creee"
Write-Host "`n2. Affichage de tous les employes avec la fonction :"
foreach ($employe in $donnees) {
    Afficher-Employe -Employe $employe
}

# ETAPE 2 - AJOUTER DES PARAMETRES AVEC VALEURS PAR DEFAUT
Write-Host "`n--- ETAPE 2 - PARAMETRES AVEC VALEURS PAR DEFAUT ---" -ForegroundColor Cyan

function Afficher-Employe {
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Employe,
        
        [Parameter(Mandatory=$false)]
        [string]$Prefix = ""
    )
    
    if ($Prefix -ne "") {
        Write-Host "$Prefix $($Employe.Nom) travaille dans le service $($Employe.Service) avec un salaire de $($Employe.Salaire) euros"
    } else {
        Write-Host "$($Employe.Nom) travaille dans le service $($Employe.Service) avec un salaire de $($Employe.Salaire) euros"
    }
}

Write-Host "`n1. Fonction modifiee avec parametre -Prefix (par defaut vide)"
Write-Host "`n2. Test avec prefixe :"
foreach ($employe in $donnees) {
    Afficher-Employe -Employe $employe -Prefix "[EMPLOYE]"
}

# ETAPE 3 - GESTION DES ERREURS
Write-Host "`n--- ETAPE 3 - GESTION DES ERREURS ---" -ForegroundColor Cyan

function Calculer-RatioSalaire {
    param(
        [Parameter(Mandatory=$true)]
        [decimal]$Salaire1,
        
        [Parameter(Mandatory=$true)]
        [decimal]$Salaire2
    )
    
    try {
        if ($Salaire2 -eq 0) {
            throw "Le deuxieme salaire ne peut pas etre nul (division par zero)"
        }
        
        $ratio = $Salaire1 / $Salaire2
        return [math]::Round($ratio, 2)
    }
    catch {
        Write-Host "ERREUR : $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

Write-Host "`n1. Fonction Calculer-RatioSalaire creee avec gestion try/catch"
Write-Host "`n2. Tests de la fonction :"

Write-Host "`n   Test valide (42000 / 36000) :"
$ratio1 = Calculer-RatioSalaire -Salaire1 42000 -Salaire2 36000
if ($ratio1 -ne $null) {
    Write-Host "   Ratio calcule : $ratio1" -ForegroundColor Green
}

Write-Host "`n   Test division par zero (42000 / 0) :"
$ratio2 = Calculer-RatioSalaire -Salaire1 42000 -Salaire2 0
Write-Host "   La fonction a gere l'erreur correctement" -ForegroundColor Green

# ETAPE 4 - FONCTION FILTRANT LES EMPLOYES
Write-Host "`n--- ETAPE 4 - FONCTION FILTRANT LES EMPLOYES ---" -ForegroundColor Cyan

function Filtrer-Employes {
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject[]]$Donnees,
        
        [Parameter(Mandatory=$true)]
        [string]$Service
    )
    
    return $Donnees | Where-Object { $_.Service -eq $Service }
}

Write-Host "`n1. Fonction Filtrer-Employes creee"
Write-Host "`n2. Tests de filtrage :"

Write-Host "`n   Employes du service Informatique :"
$employesInformatique = Filtrer-Employes -Donnees $donnees -Service "Informatique"
foreach ($emp in $employesInformatique) {
    Write-Host "   $($emp.Nom)" -ForegroundColor Green
}

Write-Host "`n   Employes du service Marketing :"
$employesMarketing = Filtrer-Employes -Donnees $donnees -Service "Marketing"
foreach ($emp in $employesMarketing) {
    Write-Host "   $($emp.Nom)" -ForegroundColor Green
}

# ETAPE 5 - INTRODUCTION AUX MODULES
Write-Host "`n--- ETAPE 5 - INTRODUCTION AUX MODULES ---" -ForegroundColor Cyan

Write-Host "`n1. Verification de la presence du module EmployeTools.psm1"
if (Test-Path "EmployeTools.psm1") {
    Write-Host "   Module trouve" -ForegroundColor Green
    
    Write-Host "`n2. Import du module EmployeTools.psm1 :"
    try {
        Import-Module ".\EmployeTools.psm1" -Force
        Write-Host "   Module importe avec succes" -ForegroundColor Green
        
        Write-Host "`n3. Utilisation des fonctions du module pour le service RH :"
        $employesRH = Filtrer-Employes -Donnees $donnees -Service "RH"
        foreach ($emp in $employesRH) {
            Afficher-Employe -Employe $emp -Prefix "[MODULE-RH]"
        }
        
    } catch {
        Write-Host "   Erreur lors de l'import du module : $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "   Module EmployeTools.psm1 non trouve dans le repertoire courant" -ForegroundColor Red
    Write-Host "   Verification des fichiers presents :" -ForegroundColor Yellow
    Get-ChildItem | ForEach-Object { Write-Host "   - $($_.Name)" }
}

# ETAPE 6 - VALIDATION FINALE
Write-Host "`n--- ETAPE 6 - VALIDATION FINALE ---" -ForegroundColor Cyan

Write-Host "`nToutes les etapes de la Partie 2 ont ete completees !"
Write-Host "`nPour l'etape finale, executez le script rapport-employes.ps1 :"
Write-Host "   .\rapport-employes.ps1 -Service 'Informatique'" -ForegroundColor Yellow
Write-Host "   .\rapport-employes.ps1 -Service 'Marketing'" -ForegroundColor Yellow
Write-Host "   .\rapport-employes.ps1 -Service 'RH'" -ForegroundColor Yellow

Write-Host "`n=== FIN DE LA PARTIE 2 ===" -ForegroundColor Magenta
