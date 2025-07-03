function Afficher-Employe {
    <#
    .SYNOPSIS
    Affiche les informations d'un employé
    
    .PARAMETER Employe
    L'objet employé à afficher
    
    .PARAMETER Prefix
    Préfixe optionnel à afficher avant les informations
    #>
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Employe,
        
        [Parameter(Mandatory=$false)]
        [string]$Prefix = ""
    )
    
    $message = "$($Employe.Nom) travaille dans le service $($Employe.Service) avec un salaire de $($Employe.Salaire) euros"
    
    if ($Prefix -ne "") {
        Write-Host "$Prefix $message"
    } else {
        Write-Host $message
    }
}

function Filtrer-Employes {
    <#
    .SYNOPSIS
    Filtre les employés par service
    
    .PARAMETER Donnees
    La liste des employés
    
    .PARAMETER Service
    Le service à filtrer
    #>
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject[]]$Donnees,
        
        [Parameter(Mandatory=$true)]
        [string]$Service
    )
    
    return $Donnees | Where-Object { $_.Service.Trim() -eq $Service }
}

function Calculer-RatioSalaire {
    <#
    .SYNOPSIS
    Calcule le ratio entre deux salaires
    
    .PARAMETER Salaire1
    Premier salaire (numérateur)
    
    .PARAMETER Salaire2
    Deuxième salaire (dénominateur)
    #>
    param(
        [Parameter(Mandatory=$true)]
        [decimal]$Salaire1,
        
        [Parameter(Mandatory=$true)]
        [decimal]$Salaire2
    )
    
    try {
        if ($Salaire2 -eq 0) {
            throw "Division par zéro : le deuxième salaire ne peut pas être nul"
        }
        
        $ratio = $Salaire1 / $Salaire2
        return [math]::Round($ratio, 2)
    }
    catch {
        Write-Error "Erreur lors du calcul du ratio : $($_.Exception.Message)"
        return $null
    }
}

# Export des fonctions
Export-ModuleMember -Function Afficher-Employe, Filtrer-Employes, Calculer-RatioSalaire
