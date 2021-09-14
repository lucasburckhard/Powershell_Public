Param(
[Parameter(Mandatory=$true)][string]$TaskName, #name of the scheduled task
[Parameter(Mandatory=$true)][string]$Executable, #name of the executable to be ran (in some cases this may need to be the full path to the executable)
[Parameter(Mandatory=$false)][string]$Arguments,  #optional, passes arguments that are applicable to the application.
[Parameter(Mandatory=$true)][string]$WorkingDirectory,  #path to the directory where the executable lives. Always end with a \
[Parameter(Mandatory=$true)][string]$StartTime,  #i.e. 12:00
[Parameter(Mandatory=$true)][string]$Enable,  #true or false
[Parameter(Mandatory=$true)][string]$RunAs, #name of service account
[Parameter(Mandatory=$true)][string]$RunAsPassword, #password of service account
[Parameter(Mandatory=$true)][string]$Interval,  # expects a number between 1-59 for M or 1-23 for hours
[Parameter(Mandatory=$true)][string]$IntervalUnits  # H for hours or  M for minutes
)
  
$computer = $env:COMPUTERNAME

$xmlTemplate = "<?xml version='1.0' encoding='UTF-16'?>
<Task version='1.2' xmlns='http://schemas.microsoft.com/windows/2004/02/mit/task'>
  <RegistrationInfo>
            <Date>{0}</Date>
            <Author>{1}</Author>
          </RegistrationInfo>
          <Triggers>
            <CalendarTrigger>
              <Repetition>
                <Interval>PT{7}{8}</Interval>
                <Duration>P1D</Duration>
                <StopAtDurationEnd>false</StopAtDurationEnd>
              </Repetition>
              <StartBoundary>{2}</StartBoundary>
              <ExecutionTimeLimit>P3D</ExecutionTimeLimit>
              <Enabled>true</Enabled>
              <ScheduleByDay>
                <DaysInterval>1</DaysInterval>
              </ScheduleByDay>
            </CalendarTrigger>
          </Triggers>
          <Principals>
            <Principal id='Author'>
              <UserId>{1}</UserId>
              <LogonType>Password</LogonType>
              <RunLevel>HighestAvailable</RunLevel>
            </Principal>
          </Principals>
          <Settings>
            <IdleSettings>
              <Duration>PT10M</Duration>
              <WaitTimeout>PT1H</WaitTimeout>
              <StopOnIdleEnd>true</StopOnIdleEnd>
              <RestartOnIdle>false</RestartOnIdle>
            </IdleSettings>
            <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
            <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
            <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
            <AllowHardTerminate>true</AllowHardTerminate>
            <StartWhenAvailable>false</StartWhenAvailable>
            <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
            <AllowStartOnDemand>true</AllowStartOnDemand>
            <Enabled>{3}</Enabled>
            <Hidden>false</Hidden>
            <RunOnlyIfIdle>false</RunOnlyIfIdle>
            <WakeToRun>false</WakeToRun>
            <ExecutionTimeLimit>P3D</ExecutionTimeLimit>
            <Priority>7</Priority>
          </Settings>
          <Actions Context='Author'>
            <Exec>
              <Command>{4}</Command>
              <Arguments>{5}</Arguments>
              <WorkingDirectory>{6}</WorkingDirectory>
            </Exec>
          </Actions>
        </Task>"

$registrationDateTime = [DateTime]::Now.ToString("yyyy-MM-dd") + "T" + [DateTime]::Now.ToString("HH:mm:ss")
$startDateTime = [DateTime]::Now.ToString("yyyy-MM-dd") + "T" + $startTime + ":00"
$xml = $xmlTemplate -f $registrationDateTime, $runAs, $startDateTime, $enable, $Executable, $arguments, $workingDirectory, $interval, $intervalUnits

try{
$sch = new-object -ComObject("Schedule.Service")
$sch.Connect($computer)
$task = $sch.NewTask($null)
$task.XmlText = $xml
$createOrUpdateFlag = 6
$sch.GetFolder("\").RegisterTaskDefinition($taskName, $task, $createOrUpdateFlag, $runAs, $runAsPassword, $null, $null) | out-null   
}
catch{
  write-host "Could not create Scheduled task:" $error
  exit 1
}


exit 0

