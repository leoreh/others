
# get path from user
Add-Type -AssemblyName System.Windows.Forms
$basepath = New-Object System.Windows.Forms.FolderBrowserDialog
$basepath.RootFolder = "MyComputer"
$basepath.ShowDialog()
cd $basepath.SelectedPath

# get filenames
$filenames = ls *txt*
$fout = -join($basepath.SelectedPath, "\FsecData.xls")

# open new excel file
$xl = New-Object -ComObject Excel.Application
$xl.Workbooks.Add()
$xlFixedFormat = [Microsoft.Office.Interop.Excel.XlFileFormat]::xlWorkbookDefault

# for debugging
# $xl.visible = $true

# go through files
for ($i = 0; $i -lt $filenames.Count; $i++){

    # find start and end of data
    $startline = Select-String -path $filenames[$i].name -pattern "EM. wavelength" -list
    $endline = Select-String -path $filenames[$i].name -pattern "LC Status Trace" -list
    $range = (($startline.LineNumber + 1)..$endline.LineNumber)

    # get data and separate it by tab indents
    $data = (Get-Content $filenames[$i])[$range] -split "`t" 

    # write time as first column 
    if ($i -ieq 0){
    $xl.Cells.Item(1, $i + 1) = "R.time [min]"
    $xl.Cells.Item(1, $i + 1).Font.Bold = $true
    $j = 0
    $k = 2;
        while ($j -lt $data.Count){
            $xl.Cells.Item($k, $i + 1) = $data[$j]
            $j = $j + 2
            $k++
        }

        $firstrow = $xl.Range("A1").EntireRow
        $firstrow.WrapText = $true
        $xl.columns.item(1).columnWidth = 15

    }

    # write header to file
    $hline = Select-String -path $filenames[$i].name -pattern "Sample Name" -list
    $h = (Get-Content $filenames[$i])[($hline.LineNumber)] -split "`t" 
    $xl.Cells.Item(1, $i + 2) = $h[1]
    $xl.Cells.Item(1, $i + 2).Font.Bold = $true
    $xl.columns.item(($i + 2)).columnWidth = 15

    # write intensity of each file as subsequent columns
    $j = 1
    $k = 2
        while ($j -lt $data.Count){
            $xl.Cells.Item($k, $i + 2) = $data[$j]
            $j = $j + 2
            $k++
        }
}

# save and exit excel
$xl.ActiveWorkbook.SaveAs($fout, $xlFixedFormat)
$xl.Quit()
