<h1>Florida DoR Edit Checks</h1>

<h2>Tools Used</h2>

- <b>T-SQL (Lots of good SQL stuff, check out the code!) </b>
- <b>PowerShell</b>

<h2>Description</h2>

I have receated the SDF & NAP edit checks (NAL is still a WIP) performed by the Florida DoR to analyze and validate tax roll assessment data. (For more information about these edit checks take a look at the following image.) With the stored procedures I created CAMA data is validated against the checks and a report is generated as an Excel file including the total counts. Any failed checks return a csv file listing the ParcelIDs of the accounts that failed the specific check. (Images of the final Excel reports are below.)

<p align="center">
<img src="https://i.imgur.com/cvJlJCy.png" height="85%" width="85%" alt="Edit Checks"/>
</p>

<h2>Screenshots</h2>
*** For the sake of security, any email addresses, network paths, and anything deemed potentially sensitive will be removed from production code & screenshots *** .
<br />

<h3>SDF Report</h3>
<p align="center">
<img src="https://i.imgur.com/wrSYeLS.png" height="95%" width="95%" alt="SDF Report Excel File"/>
</p>

<h3>NAP Report</h3>
<p align="center">
<img src="https://i.imgur.com/ALlBkoh.png" height="95%" width="95%" alt="NAP Report Excel File"/>
</p>

<h2>The Good Stuff</h2>

The following items are present in the SQL stored procedure involved:

- Dynamic SQL
- If / Else Logic
- Update / Insert
- Case Statements (IIF)
- #Temp Tables
- CTEs
- Data Validation
- Variables
- Sign
- Pat Index
- Table Variable

Links to SQL scripts involved in this process:
- [Export Data to CSV](https://github.com/Deltron2020/ExportDataToCsv)
- [CSV to Excel File wTable](https://github.com/Deltron2020/CSVtoXLSXwTable)
