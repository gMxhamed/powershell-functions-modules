Write-Host "=== PARTIE 2 - FONCTIONS, ERREURS, PARAMETRES ET MODULES ===" -ForegroundColor Magenta

# Chargement des données
Write-Host "`nChargement des données..." -ForegroundColor Cyan
try {
    $donnees = Import-Csv -Path "employes.csv"
    Write-Host ">>> Données chargées avec succès ($($donnees.Count) employés)" -ForegroundColor Green
}
catch {
    Write-Error "Erreur lors du chargement du fichier CSV : $($_.Exception.Message)"
    exit 1
}

# ÉTAPE 1 - Fonctions de base
Write-Host "`n--- ÉTAPE 1 - CRÉER ET UTILISER DES FONCTIONS ---" -ForegroundColor Cyan

function Afficher-Employe-Local {
    param([PSCustomObject]$Employe)
    Write-Host "$($Employe.Nom) travaille dans le service $($Employe.Service) avec un salaire de $($Employe.Salaire) euros"
}

Write-Host "`nAffichage de tous les employés avec fonction locale :" -ForegroundColor Yellow
foreach ($employe in $donnees) {
    Afficher-Employe-Local -Employe $employe
}

# ÉTAPE 2 - Paramètres avec valeurs par défaut
Write-Host "`n--- ÉTAPE 2 - PARAMÈTRES AVEC VALEURS PAR DÉFAUT ---" -ForegroundColor Cyan

function Afficher-Employe-Avec-Prefix {
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Employe,
        [string]$Prefix = ""
    )
    
    $message = "$($Employe.Nom) travaille dans le service $($Employe.Service) avec un salaire de $($Employe.Salaire) euros"
    if ($Prefix -ne "") {
        Write-Host "$Prefix $message"
    } else {
        Write-Host $message
    }
}

Write-Host "`nAffichage avec préfixe personnalisé :" -ForegroundColor Yellow
foreach ($employe in $donnees) {
    Afficher-Employe-Avec-Prefix -Employe $employe -Prefix "[EMPLOYÉ]"
}

# ÉTAPE 3 - Gestion des erreurs
Write-Host "`n--- ÉTAPE 3 - GESTION DES ERREURS ---" -ForegroundColor Cyan

function Calculer-RatioSalaire-Local {
    param(
        [decimal]$Salaire1,
        [decimal]$Salaire2
    )
    
    try {
        if ($Salaire2 -eq 0) {
            throw "Le deuxième salaire ne peut pas être nul (division par zéro)"
        }
        
        $ratio = $Salaire1 / $Salaire2
        return [math]::Round($ratio, 2)
    }
    catch {
        Write-Error "Erreur lors du calcul du ratio : $($_.Exception.Message)"
        return $null
    }
}

Write-Host "`nTest de la fonction de calcul de ratio :" -ForegroundColor Yellow

# Test avec valeurs valides
$ratio1 = Calculer-RatioSalaire-Local -Salaire1 42000 -Salaire2 36000
if ($ratio1 -ne $null) {
    Write-Host "Ratio 42000/36000 = $ratio1" -ForegroundColor Green
}

# Test avec division par zéro
Write-Host "`nTest avec division par zéro :" -ForegroundColor Yellow
$ratio2 = Calculer-RatioSalaire-Local -Salaire1 42000 -Salaire2 0

# ÉTAPE 4 - Fonction de filtrage
Write-Host "`n--- ÉTAPE 4 - FONCTION FILTRANT LES EMPLOYÉS ---" -ForegroundColor Cyan

function Filtrer-Employes-Local {
    param(
        [PSCustomObject[]]$Donnees,
        [string]$Service
    )
    
    return $Donnees | Where-Object { $_.Service.Trim() -eq $Service }
}

Write-Host "`nEmployés du service Informatique :" -ForegroundColor Yellow
$employesInfo = Filtrer-Employes-Local -Donnees $donnees -Service "Informatique"
$employesInfo | ForEach-Object { Write-Host "- $($_.Nom)" }

Write-Host "`nEmployés du service Marketing :" -ForegroundColor Yellow
$employesMarketing = Filtrer-Employes-Local -Donnees $donnees -Service "Marketing"
$employesMarketing | ForEach-Object { Write-Host "- $($_.Nom)" }

# ÉTAPE 5 - Introduction aux modules
Write-Host "`n--- ÉTAPE 5 - INTRODUCTION AUX MODULES ---" -ForegroundColor Cyan

try {
    # Import du module
    Import-Module "./EmployeTools.psm1" -Force
    Write-Host ">>> Module EmployeTools importé avec succès" -ForegroundColor Green
    
    # Utilisation des fonctions du module
    Write-Host "`nEmployés du service RH avec le module :" -ForegroundColor Yellow
    $employesRH = Filtrer-Employes -Donnees $donnees -Service "RH"
    
    foreach ($employe in $employesRH) {
        Afficher-Employe -Employe $employe -Prefix "[MODULE]"
    }
    
    # Test de la fonction de calcul de ratio du module
    Write-Host "`nTest de la fonction Calculer-RatioSalaire du module :" -ForegroundColor Yellow
    $ratioModule = Calculer-RatioSalaire -Salaire1 45000 -Salaire2 38000
    if ($ratioModule -ne $null) {
        Write-Host "Ratio calculé par le module : $ratioModule" -ForegroundColor Green
    }
}
catch {
    Write-Warning "Impossible de charger le module EmployeTools : $($_.Exception.Message)"
    Write-Host "Assurez-vous que le fichier EmployeTools.psm1 est présent dans le répertoire courant" -ForegroundColor Yellow
}

Write-Host "`n=== FIN DE LA PARTIE 2 ===" -ForegroundColor Magenta
Write-Host "Prochaine étape : créer le script rapport-employes.ps1" -ForegroundColor Yellow
