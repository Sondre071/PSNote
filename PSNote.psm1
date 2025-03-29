Import-Module Read-Menu
Import-Module ModuleData

[PSObject]$ModuleData = (ModuleData -ScriptRoot $PSScriptRoot -FileName 'notes')
[PSObject]$Data = $ModuleData.FileContent

function Note($Parameter) {
    if (-not $Data.Categories.PSObject.Properties.Length) {
        Write-Host "No categories found."
        return
    }

    $CategoryKey = if ($Parameter) { $Parameter } else { Read-Menu -Options ($Data.Categories.PSObject.Properties.Name) -ExitOption 'Exit' }

    if (-not $CategoryKey) {
        Write-Host "Category not found."`n
        return
    }

    if ($CategoryKey -eq 'Exit') {
        Write-Host
        return
    }

    $Category = $Data.Categories.$CategoryKey

    Write-Host

    $NoteKey = Read-Menu -Options ($Category.PSObject.Properties.Name) -WithExit

    if (-not $NoteKey) {
        Write-Host "Note not found."`n
        return
    }

    if ($NoteKey -eq 'Exit') {
        Write-Host
        return
    }

    $Note = $Category.$NoteKey

    Write-Host

    $Note | ForEach-Object { Write-Host $($_) -ForegroundColor 'White' }

    Write-Host

    return
}

Export-ModuleMember -Function Note