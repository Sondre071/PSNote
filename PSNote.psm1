Import-Module PSModuleManager
Import-Module Read-Menu

[PSObject]$NoteManager = (PSModuleManager -ScriptRoot $PSScriptRoot -FileName 'notes')
$Notes = $NoteManager.FileContent

function Note([string]$Parameter, [switch]$Info, [switch]$Edit) {

    if ($Info) {
        Write-Host "Hi!`nEnter 'PSNote -Edit' to edit your notes manually." -ForegroundColor Yellow
        return
    }

    if ($Edit) { Start-Process -FilePath $NoteManager.FilePath; return }

    $action = Read-Menu -Header 'PSNote' -Options ('Categories', 'Add category') -ExitOption 'Exit' -CleanUpAfter

    switch ($action) {
        'Add category' {
            Add-Category
        }

        default {
            Open-CategoryMenu
        }
        
        'Exit' {
            return
        }
    }
}

function Add-Category {
    $newCategoryName = Read-Input -Header 'New category' -Instruction 'Enter new category name' -CleanUpAfter

    $NoteManager.Set(($newCategoryName), @{})
            
    Write-Host "Added new PSNote category: $newCategoryName."`n -ForegroundColor Green        
}

function Open-CategoryMenu {
    $categoryOptions = ($Notes.PSObject.Properties.Name) + 'Add new category'

    $category = Read-Menu -Header 'Select note category' -Options $categoryOptions -ExitOption 'Exit' -CleanUpAfter

    switch ($category) {
        'Exit' {
            return
        }

        default {
            Open-NoteMenu -Category $category
        }
    }
}

function Open-NoteMenu([string]$Category) {
    $currentCategory = $Notes.$Category.PSObject.Properties.Name
    $noteOptions = @()

    if ($currentCategory) { $noteOptions += $currentCategory}

    $noteOptions += ('Add new note', 'All')

    $note = Read-Menu -Header "$category notes" -Options $noteOptions -ExitOption 'Exit' -CleanUpAfter

    switch ($note) {
        'Add new note' {
            $newNoteName = Read-Input -Header 'New note' -Instruction 'Enter note name' -CleanUpAfter
            $newNoteContent = Read-Input -Header 'New note' -Instruction 'Enter note content' -CleanUpAfter

            $NoteManager.Set(@($category, $newNoteName), $newNoteContent)

            Write-Host "$newNoteName saved."`n -ForegroundColor Cyan
        }

        'Exit' {
            return
        }

        'All' {
            $Notes.$category.PSObject.Properties | ForEach-Object {
                Write-Host $_.Name -ForegroundColor Cyan
            }
        }

        default {
            $noteContent = $Notes.$category.$note

            Write-MenuHeader -Header "$($category): $note"

            Write-Host $noteContent`n -ForegroundColor Cyan
        }
    }
}

Export-ModuleMember -Function Note