#作者：石涛
#链接：https://www.zhihu.com/question/21787232/answer/63774856
#来源：知乎
#著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

# create new excel instance
 $objExcel = New-Object -comobject Excel.Application
 $objExcel.Visible = $True
 $objWorkbook = $objExcel.Workbooks.Add()
 $objWorksheet = $objWorkbook.Worksheets.Item(1)

 # write information to the excel file
$i = 0
$first10 = (ps | sort cpu -Descending | select -first 10)
$first10 | foreach {$i++; $objWorksheet.Cells.Item($i,1) = $_.name; $objWorksheet.Cells.Item($i,2) = $_.ws}
$otherMem = (ps | measure ws -s).Sum - ($first10 | measure ws -s).Sum
$objWorksheet.Cells.Item(11,1) = "Others"; $objWorksheet.Cells.Item(11,2) = $otherMem

# draw the pie chart
$objCharts = $objWorksheet.ChartObjects()
$objChart = $objCharts.Add(0, 0, 500, 300)
$objChart.Chart.SetSourceData($objWorksheet.range("A1:B11"), 2)
$objChart.Chart.ChartType = 70
$objChart.Chart.ApplyDataLabels(5)

