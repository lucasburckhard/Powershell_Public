$destination="f:\CSNAP\win-x64\"
if(!(Test-Path $destination)){mkdir $destination}
else{
    #Remove all old files
    if((Get-ChildItem $destination -Recurse) | ?{$_.Name -like "*_old"}){(Get-ChildItem $destination -Recurse | ?{$_.Name -like "*_old"}) | ForEach-Object {Remove-Item $_.FullName -Force}}
    #Rename all current files to old
    if((Get-ChildItem $destination -Recurse) | ?{$_.Name -notlike "*_old"}){(Get-ChildItem $destination -Recurse) | ForEach-Object {Rename-Item $_.FullName -NewName "$($_.FullName)_old" -Force}}
}
#Copy new current files
(Get-ChildItem F:\temp\ -File -Recurse) | ForEach-Object {Copy-Item $_.FullName -Destination "$destination\$($_.Name)" -Force}
