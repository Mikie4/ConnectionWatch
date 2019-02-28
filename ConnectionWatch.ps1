param([String]$PassedIP='',[switch]$logging,[String]$LogName='ConnectionWatch')

$LogPath = [Environment]::GetFolderPath("MyDocuments")

$TotalMiss = 0
$TotalHit = 0
$TotalPing = 0
$ConsMiss = 0
$maxConsMiss = 0
$minPing = 500
$maxPing = 0
$runningPing = 0
$averagePing = 0
$status = -1



IF($PassedIP -eq '')
{
    Write-Host "No IP addressed passed"
}
Else
{
    Write-Host "Connection Watch: $PassedIP"

    If($logging)
    {
        "Hit/Miss, CurrentPing, MaxPing, AveragePing, TotalHit, TotalMiss, ConsMiss, MaxConsMiss, Time" | Add-Content "$LogPath\$logName.txt" -Encoding Ascii
    }

    While($true)
    {
        IF($Host.UI.RawUI.KeyAvailable -AND ("q" -eq $Host.UI.RawUI.ReadKey("IncludeKeyUp,NoEcho").Character))
        {
            break;
        }
        
        $ping = Test-Connection $PassedIP -Count 1 -ErrorAction SilentlyContinue
        $totalPing = $totalPing + 1        

        If($ping.StatusCode -eq 0)
        {
            $status = 1
            $TotalHit = $TotalHit + 1
            $ConsMiss = 0
            $currentPing = $ping.responseTime
            $runningPing = $runningPing + $currentPing
            $averagePing = $runningPing / $TotalPing
            If($currentPing -lt $minPing)
            {
                $minPing = $currentPing
            }
            If($currentPing -gt $maxPing)
            {
                $maxPing = $currentPing
            }
        }
        Else
        {
            $currentPing = 0
            $status = 0
            $TotalMiss = $TotalMiss + 1
            $ConsMiss = $ConsMiss + 1
            If($ConsMiss -gt $maxConsMiss)
            {
                $maxConsMiss = $ConsMiss
            }
        }
        
        If( $ConsMiss%5 -eq 0 -and $ConsMiss -ne 0)
        {
            Write-Host ""
            Get-Date
        }
        
        $outputFormat = "{0:N2}" -f $averagePing
        $percent = $totalMiss / $totalPing
        $percentFormatted = "{0:N2}" -f $percent

        #Write-Host "`rHits: $TotalHit Misses: $TotalMiss ConsMiss: $ConsMiss ($maxConsMiss)`tPing: $currentPing Min: $minPing Max: $maxPing Avg: $averagePing" -NoNewLine
        Write-Host "`rHits: $TotalHit Misses: $TotalMiss ($percentFormatted%) ConsMiss: $ConsMiss ($maxConsMiss)`tPing: $currentPing ($minPing|$maxPing) Avg: $outputFormat" -NoNewLine
        
        If($logging)
        {
            $time = Get-Date
            "$status, $currentPing, $maxPing, $outputFormat, $TotalHit, $TotalMiss, $ConsMiss, $MaxConsMiss, $time" | Add-Content "$LogPath\$logName.txt" -Encoding Ascii
        }
             
        Start-Sleep -s 1
    }
    Write-Host ""
    Write-Host "Program Terminated"
}
