Import-Module Read-Menu
Import-Module ModuleData

[PSObject]$ModuleData = (ModuleData -ScriptRoot $PSScriptRoot -FileName 'notes')
$Data = $ModuleData.FileContent

function Note([string]$Parameter, [switch]$Info) {

    $action = Read-Menu -MenuTitle 'PSNote' -Options ('Categories', 'Add category') ($Data.Categories.PSObject.Properties.Name) -ExitOption 'Exit' -CleanUpAfter

    switch ($action) {
        'Add category' {
            $newCategoryName = Read-Input -Title 'New category' -Instruction 'Enter new category name' -CleanUpAfter

            $ModuleData.SetValue(($newCategoryName), @{})
            $ModuleData.Save()
            
            Write-Host "Added new PSNote category: $newCategoryName."`n -ForegroundColor Green        
        }

        default {
            $category = Read-Menu -MenuTitle 'Select note category' -Options $Data.PSObject.Properties.Name -ExitOption 'Exit' -CleanUpAfter

            switch ($category) {
                'Exit' {
                    return
                }

                default {
                    $note = Read-Menu -MenuTitle "$category notes" -FirstOptions ('Add new note') -Options $Data.$category.PSObject.Properties.Name -ExitOption 'Exit' -LastOptions ('All') -CleanUpAfter

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
            }
        }
        
        'Exit' {
            return
        }
    }
}

Export-ModuleMember -Function Note