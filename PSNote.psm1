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

    while ($true) {

        $action = Read-Menu -Header 'PSNote' -Options ('Categories', 'Add category') -ExitOption 'Exit'

        switch ($action) {
            'Add category' {
                Add-Category
            }

            default {
                Open-CategoryMenu
            }
        
            'Exit' { return }
        }
    }
}

function Add-Category {
    $newCategoryName = Read-Input -Header 'New category' -Instruction 'Enter new category name'

    $NoteManager.Set(($newCategoryName), @{})
            
    Write-Host "Added new PSNote category: $newCategoryName."`n -ForegroundColor Green        
}

function Open-CategoryMenu {
    $categoryOptions = ($Notes.PSObject.Properties.Name)

    $category = Read-Menu -Header 'Select note category' -Options $categoryOptions -ExitOption 'Back'

    switch ($category) {
        default {
            Open-NoteMenu -Category $category
            break
        }

        'Back' { return }
    }
}

function Open-NoteMenu([string]$Category) {
    $currentCategory = $Notes.$Category.PSObject.Properties.Name
    $noteOptions = @()

    if ($currentCategory) { $noteOptions += $currentCategory }

    $noteOptions += ('Add new note', 'All')

    $note = Read-Menu -Header "$category notes" -Options $noteOptions -ExitOption 'Exit'

    switch ($note) {
        'Add new note' {
            $newNoteName = Read-Input -Header 'New note' -Instruction 'Enter note name'
            $newNoteContent = Read-Input -Header 'New note' -Instruction 'Enter note content'

            $NoteManager.Set(@($category, $newNoteName), $newNoteContent)

            Write-Host "$newNoteName saved."`n -ForegroundColor Cyan
        }

        'All' {
            $Notes.$category.PSObject.Properties | ForEach-Object {
                Write-Host $_.Name -ForegroundColor Cyan
            }
        }

        default {
            $noteContent = $Notes.$category.$note

            Write-MenuHeader -Header "$($category): $note"

            foreach ($noteLine in $noteContent) {
                Write-Host $noteLine -ForegroundColor Cyan

            }
        }

        'Exit' { return }
    }
}

Export-ModuleMember -Function Note