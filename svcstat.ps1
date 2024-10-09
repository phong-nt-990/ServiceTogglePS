function Get-ServiceStatus {
    param (
        [string[]]$ServiceNames  # Input parameter: array of service names
    )

        function StopAndDisableServices {
        foreach ($name in $ServiceNames) {
            $service = Get-Service -Name $name -ErrorAction SilentlyContinue
            if ($service) {
                if ($service.Status -eq 'Running') {
                    Stop-Service -Name $service.Name -Force
                    Write-Host "$($service.Name) stopped."
                }
                Set-Service -Name $service.Name -StartupType Disabled
                Write-Host "$($service.Name) disabled."
            } else {
                Write-Host "$($name) not found." -ForegroundColor Yellow
            }
        }
    }

    function StartAndEnableServices {
        foreach ($name in $ServiceNames) {
            $service = Get-Service -Name $name -ErrorAction SilentlyContinue
            if ($service) {
                Set-Service -Name $service.Name -StartupType Automatic
                Write-Host "$($service.Name) enabled."
                if ($service.Status -ne 'Running') {
                    Start-Service -Name $service.Name
                    Write-Host "$($service.Name) started."
                }
            } else {
                Write-Host "$($name) not found." -ForegroundColor Yellow
            }
        }
    }
    function StartAndEnableEachServices {
        param (
            [string[]]$ServiceNames
        )
        foreach ($name in $ServiceNames) {
            $service = Get-Service -Name $name -ErrorAction SilentlyContinue
            if ($service) {
                Set-Service -Name $service.Name -StartupType Automatic
                Write-Host "$($service.Name) enabled."
                if ($service.Status -ne 'Running') {
                    Start-Service -Name $service.Name
                    Write-Host "$($service.Name) started."
                }
            } else {
                Write-Host "$($name) not found." -ForegroundColor Yellow
            }
        }
    }

    function StopAndDisableEachServices {
        param (
            [string[]]$ServiceNames
        )
        foreach ($name in $ServiceNames) {
            $service = Get-Service -Name $name -ErrorAction SilentlyContinue
            if ($service) {
                if ($service.Status -ne 'Stopped') {
                    Stop-Service -Name $service.Name
                    Write-Host "$($service.Name) stopped."
                }
                Set-Service -Name $service.Name -StartupType Disabled
                Write-Host "$($service.Name) disabled."
            } else {
                Write-Host "$($name) not found." -ForegroundColor Yellow
            }
        }
    }


    function ProcessServiceIndices {
        param (
            [string]$indices,
            [string]$action
        )
        $indexArray = $indices.Split(" ") | ForEach-Object { [int]$_}
        foreach ($index in $indexArray) {
            if ($index -le $ServiceNames.Length -and $index -gt 0) {
                $serviceName = $ServiceNames[$index - 1]
                echo $serviceName
                if ($action -eq 'D') {
                    StopAndDisableEachServices -ServiceNames $serviceName
                } elseif ($action -eq 'E') {
                    StartAndEnableEachServices -ServiceNames $serviceName
                }
            } else {
                Write-Host "Index $index is out of range." -ForegroundColor Red
            }
        }
    }

    function Start-ProcessAsAdministrator {
        param (
            [string]$processFilePath,
            [string]$arguments = ""
        )
        Start-Process -FilePath $processFilePath -ArgumentList $arguments -Verb RunAs
    }


    function IsAdmin {
        $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }

    if (!(IsAdmin)) {
        Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
    }

    function DisplayServiceStatus {
        Write-Host "===================================== CURRENT SERVICE STATUS ======================================"
        Write-Host "---------------------------------------------------------------------------------------------------"
        Write-Host "No. |  Name                          | DisplayName                        | Status   | Startup Type"
        Write-Host "---------------------------------------------------------------------------------------------------"

        # Initialize an index counter
        $index = 1

        foreach ($name in $ServiceNames) {
            # Get the service information
            $service = Get-Service -Name $name -ErrorAction SilentlyContinue

            if ($service) {
                # Set the status text and color based on the service status
                $statusText = if ($service.Status -eq 'Running') { 'STARTED' } else { 'STOPPED' }
                $statusColor = if ($service.Status -eq 'Running') { 'Green' } else { 'Red' }
                $startupTypeColor = if ($service.StartType -eq 'Automatic') {
                    'Green'
                } elseif ($service.StartType -eq 'Manual') {
                    'Yellow'
                } else {
                    'Red'
                }
                # Write-Host ("{0,-7}{1,-31}" -f $index, $service.Name) -NoNewline
                Write-Host ("{0,-7}{1,-32}{2,-37}" -f $index, $service.Name, $service.DisplayName) -NoNewline
                Write-Host ("{0,-11}" -f $statusText) -ForegroundColor $statusColor -NoNewline
                Write-Host ("{0}" -f $service.StartType) -ForegroundColor $startupTypeColor 
            } else {
                Write-Host ("{0,-6}{1,-31} {2,-25} {3}" -f $index, $name, 'NOT FOUND', 'N/A') -ForegroundColor Yellow
            }
            # Increment the index counter
            $index++
        }
        Write-Host "---------------------------------------------------------------------------------------------------"
    }

    DisplayServiceStatus

    while ($true) {
        Write-Host "Enter a command (Q: Quit"
        Write-Host "                 D: Disable & Stop"
        Write-Host "                 E: Enable & Start"
        Write-Host "                 R: Refresh"
        Write-Host "               No.: List of indices)"
        $userInput = Read-Host "=Command>"
        switch ($userInput.ToUpper()) {
            "Q" {
                Write-Host "Exiting program..."
                return
            }
            "D" {
                Write-Host "Disabling and stopping all services..."
                StopAndDisableServices
                Read-Host "Press Enter to continue..."
                Clear-Host
                DisplayServiceStatus  # Re-show status after disabling and stopping
            }
            "E" {
                Write-Host "Enabling and starting all services..."
                StartAndEnableServices
                Read-Host "Press Enter to continue..."
                Clear-Host
                DisplayServiceStatus  # Re-show status after enabling and starting
            }
            "R" {
                Clear-Host
                DisplayServiceStatus  # Re-show status after enabling and starting
            }
            default {
                if ($userInput -match '^\d+(\s\d+)*$') {
                    $action = Read-Host "Enter action (D: Disable & Stop, E: Enable & Start)"
                    ProcessServiceIndices -indices $userInput -action $action.ToUpper()
                    Read-Host "Press Enter to continue..."
                    Clear-Host
                    DisplayServiceStatus  # Re-show status after processing indices
                } else {
                    Write-Host "Invalid command. Please enter Q, D, E, or a list of indices." -ForegroundColor Yellow
                }
            }
        }
    }
}


# Example usage
Get-ServiceStatus -ServiceNames 'CloudflareWARP', 'VMAuthdService', 'VmwareAutostartService', 'VMnetDHCP', 'VMware NAT Service', 'VMUSBArbService', 'spacedeskService', 'Bonjour Service', 'Apple Mobile Device Service', 'com.docker.service'
