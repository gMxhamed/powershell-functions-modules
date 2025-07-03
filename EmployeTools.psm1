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

function Filtrer-Employes {
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject[]]$Donnees,
        
        [Parameter(Mandatory=$true)]
        [string]$Service
    )
    
    return $Donnees | Where-Object { $_.Service -eq $Service }
}

Export-ModuleMember -Function Afficher-Employe, Filtrer-Employes
