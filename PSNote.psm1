Import-Module Read-Menu
Import-Module ModuleData

[PSObject]$ModuleData = (ModuleData -ScriptRoot $PSScriptRoot -FileName 'notes')
$Data = $ModuleData.FileContent

function Note([string]$Parameter, [switch]$Info, [switch]$Edit) {

    if ($Info) {
        Write-Host "Hi!`nEnter 'PSNote -Edit' to edit your notes manually." -ForegroundColor Yellow
        return
    }

    if ($Edit) { Start-Process -FilePath $ModuleData.FilePath; return }

    $action = Read-Menu -MenuTitle 'PSNote' -Options ('Categories', 'Add category') ($Data.Categories.PSObject.Properties.Name) -ExitOption 'Exit' -CleanUpAfter

    switch ($action) {
        'Add category' {
            Add-CategoryMenu
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
    $newCategoryName = Read-Input -Title 'New category' -Instruction 'Enter new category name' -CleanUpAfter

    $ModuleData.SetValue(($newCategoryName), @{})
    $ModuleData.Save()
            
    Write-Host "Added new PSNote category: $newCategoryName."`n -ForegroundColor Green        
}

function Open-CategoryMenu {
    $category = Read-Menu -MenuTitle 'Select note category' -Options $Data.PSObject.Properties.Name -ExitOption 'Exit' -CleanUpAfter

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
    $note = Read-Menu -MenuTitle "$category notes" -FirstOptions ('Add new note') -Options $Data.$category.PSObject.Properties.Name -LastOptions ('All') -ExitOption 'Exit' -CleanUpAfter

    switch ($note) {

        'Add new note' {
            $newNoteName = Read-Input -Title 'New note' -Instruction 'Enter note name' -CleanUpAfter
            $newNoteContent = Read-Input -Title 'New note' -Instruction 'Enter note content' -CleanUpAfter

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

            Write-MenuTitle -Title "$($category): $note" -TitleWidth 40

            Write-Host $noteContent`n -ForegroundColor Cyan
        }
    }
}

Export-ModuleMember -Function Note