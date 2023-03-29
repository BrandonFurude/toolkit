# Prompt for credentials
$credentials = Get-Credential -Message "Please enter your credentials"

# Import the list of computers from the CSV file
$computers = Import-Csv -Path "computers.csv"

# Loop through each computer in the list
foreach ($computer in $computers) {
    $computerName = $computer.ComputerName
    Write-Host "Checking computer: $computerName"

    # Check if the computer is reachable
    if (Test-Connection -ComputerName $computerName -Count 1 -Quiet) {
        # Create a script block to run on the remote computer
        $scriptBlock = {
            # Get all the drives on the remote computer
            $drives = Get-PSDrive -PSProvider 'FileSystem'

            # Loop through each drive and search for log4j files
            foreach ($drive in $drives) {
                $driveRoot = $drive.Root
                $log4jFiles = Get-ChildItem -Path $driveRoot -Filter "*log4j*" -Recurse -ErrorAction SilentlyContinue -File
                
                if ($log4jFiles) {
                    Write-Host "Found log4j files on drive $driveRoot:"
                    $log4jFiles.FullName
                } else {
                    Write-Host "No log4j files found on drive $driveRoot"
                }
            }
        }

        # Run the script block on the remote computer using PSRemoting with the provided credentials
        Invoke-Command -ComputerName $computerName -ScriptBlock $scriptBlock -Credential $credentials -ErrorAction SilentlyContinue
    } else {
        Write-Host "Computer $computerName is not reachable."
    }
}
