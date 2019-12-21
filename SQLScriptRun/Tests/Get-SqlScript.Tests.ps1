Describe "Get-SqlScript" {

    $scripts = Get-SqlScript -Path ".\scripts\rollout1"

    [array]$fileNamesExpected = @(
         "01_tbl_dbo.locations.sql"
        ,"02_tbl_dbo.staff.sql"
        ,"03_tbl_dbo.newtable.sql"
        ,"01_locationData.sql"
    )

    it "Returned SQL script files as expected" {
        [array]$fileNames = $scripts | ForEach-Object {
            ($_.Split("\"))[-1]
        }

        $fileNames | Should -Be $fileNamesExpected
    }
}
