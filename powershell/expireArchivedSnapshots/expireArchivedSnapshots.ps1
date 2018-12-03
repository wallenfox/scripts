### usage: ./expireArchivedSnapshots.ps1 -vip mycluster -username admin [ -domain local ] -olderThan 365 [ -expire ]

### process commandline arguments
[CmdletBinding()]
param (
    [Parameter(Mandatory = $True)][string]$vip, #the cluster to connect to (DNS name or IP)
    [Parameter(Mandatory = $True)][string]$username, #username (local or AD)
    [Parameter()][string]$domain = 'local', #local or AD domain
    [Parameter(Mandatory = $True)][string]$olderThan, #archive snapshots older than x days
    [Parameter()][switch]$expire
)

### source the cohesity-api helper code
. ./cohesity-api

### authenticate
apiauth -vip $vip -username $username -domain $domain

### olderThan days in usecs
$olderThanUsecs = timeAgo $olderThan days

### find protectionRuns with old local snapshots that are archived and sort oldest to newest
"searching for old snapshots..."
$runs = api get protectionRuns?numRuns=999999 | `
    Where-Object { $_.backupRun.snapshotsDeleted -eq $false } | `
    Where-Object { $_.copyRun[0].runStartTimeUsecs -le $olderThanUsecs } | `
    Where-Object { 'kArchival' -in $_.copyRun.target.type } | `
    Where-Object { $_.backupRun.runType -ne 'kLog' } | `
    Sort-Object -Property @{Expression={ $_.copyRun[0].runStartTimeUsecs }; Ascending = $True }

"found $($runs.count) snapshots with archive tasks"

foreach ($run in $runs) {

    $runDate = usecsToDate $run.copyRun[0].runStartTimeUsecs
    $jobName = $run.jobName

    ### If the Local Snapshot is not expiring soon...
    foreach ($copyRun in $run.copyRun) {
        if ($copyRun.target.type -eq 'kArchival') {
            if ($copyRun.status -eq 'kSuccess') {
                if ($expire) {
                    ### expire the local snapshot
                    write-host "Expiring  $runDate  $jobName  (Archive kSuccessful)" -ForegroundColor Green
                    $expireRun = @{'jobRuns' = @(
                            @{'expiryTimeUsecs'     = 0;
                                'jobUid'            = $run.jobUid;
                                'runStartTimeUsecs' = $run.copyRun[0].runStartTimeUsecs;
                                'copyRunTargets'    = @(
                                    @{'daysToKeep' = 0;
                                        'type'     = 'kLocal';
                                    }
                                )
                            }
                        )
                    }
                    api put protectionRuns $expireRun
                }
                else {
                    ### display that we would expire this snapshot if -expire was set
                    write-host "To Expire $runDate  $jobName  (Archive kSuccessful)" -ForegroundColor Green
                }
            }
            else {
                #display that we're skipping this since it hasn't completed yet
                Write-Host "Skipping  $runDate  $jobName  (Archive $($copyRun.status)" -ForegroundColor Yellow
            }
        }
    }
}



