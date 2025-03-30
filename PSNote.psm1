Import-Module ModuleData
Import-Module Read-Menu

[PSObject]$ModuleData = (ModuleData -ScriptRoot $PSScriptRoot -FileName 'notes')
$Data = $ModuleData.FileContent

function Note([string]$Parameter, [switch]$Info, [switch]$Edit) {

    if ($Info) {
        Write-Host "Hi!`nEnter 'PSNote -Edit' to edit your notes manually." -ForegroundColor Yellow
        return
    }

    if ($Edit) { Start-Process -FilePath $ModuleData.FilePath; return }

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

    $ModuleData.SetValue(($newCategoryName), @{})
    $ModuleData.Save()
            
    Write-Host "Added new PSNote category: $newCategoryName."`n -ForegroundColor Green        
}

function Open-CategoryMenu {
    $categoryOptions = @($Data.PSObject.Properties.Name) + 'Add new category'

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
    $currentCategory = $Data.$Category.PSObject.Properties.Name
    $noteOptions = @()

    if ($currentCategory) { $noteOptions += $currentCategory}

    $noteOptions += ('Add new note', 'All')

    $note = Read-Menu -Header "$category notes" -Options $noteOptions -ExitOption 'Exit' -CleanUpAfter

    switch ($note) {
        'Add new note' {
            $newNoteName = Read-Input -Header 'New note' -Instruction 'Enter note name' -CleanUpAfter
            $newNoteContent = Read-Input -Header 'New note' -Instruction 'Enter note content' -CleanUpAfter

            $ModuleData.SetValue(@($category, $newNoteName), $newNoteContent)

            Write-Host "$newNoteName saved."`n -ForegroundColor Cyan
        }

        'Exit' {
            return
        }

        'All' {
            $Data.Categories.$category.PSObject.Properties | ForEach-Object {
                Write-Host $_.Name -ForegroundColor Cyan
            }
        }

        default {
            $noteContent = $Data.$category.$note

            Write-MenuTitle -MenuTitle "$($category): $note"

            Write-Host $noteContent`n -ForegroundColor Cyan
        }
    }
}

Export-ModuleMember -Function Note