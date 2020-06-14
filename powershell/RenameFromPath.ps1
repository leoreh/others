$basepath = 'F:\Daniel IIS 11.6.20\IIS\APPKi\New analysis'
cd($basepath) # path to files

# rename by adding path name
#Get-ChildItem $basepath -Filter *.wcp -Recurse | Rename-Item -NewName { $_.Directory.Name+'.abf'}

# rename by replacing one string with another
Get-ChildItem $basepath | Rename-Item -NewName {$_.name -replace '.lfp.bs','.bs'}
Get-ChildItem $basepath | Rename-Item -NewName {$_.name -replace '.lfp.ep','.ep'}
Get-ChildItem $basepath | Rename-Item -NewName {$_.name -replace '.lfp.iis','.iis'}
Get-ChildItem $basepath | Rename-Item -NewName {$_.name -replace '.lfp.lfp','.lfp'}

# rename by adding string to filename
# Get-ChildItem $basepath | Rename-Item -NewName {"lh49_200319" + $_.name}

# replace date formate in filenames
# $filenames = Get-ChildItem $basepath
# for ($i = 0; $i -lt $filenames.Count; $i++){
#    $prefix = '.' + $filenames.name[$i].Split('.', 2)[-1]
#    $oldDate = $filenames.name[$i].Split('_', 3)[-1].TrimEnd($prefix)
#    $newDate = [datetime]::parseexact($oldDate, 'ddMMMyy', $null).ToString('yyMMdd')    
#    Get-ChildItem $filenames[$i] | Rename-Item -NewName {$filenames.name[$i] -replace $oldDate, $newDate}   
#}
