# ServiceTogglePS
ServiceManagerPS is a PowerShell tool designed to efficiently manage Windows services. It allows users to quickly view, enable, disable, start, and stop services, helping to optimize system resource usage. This is especially useful when some services are not always needed and can be turned off to free up system resources.

# Features
- Display the status of a list of specified services
- Start and enable services with a single command
- Stop and disable services to save system resources
- Manage specific services by selecting them by index
- User-friendly command input interface
# How to Use
1. Open PowerShell as Administrator.
2. Run the ServiceManagerPS.ps1 script.
3. The tool will display the status of the services you've listed.
4. Commands available within the tool:
-  Q: Quit the program.
-  D: Disable and stop all listed services.
-  E: Enable and start all listed services.
-  R: Refresh the service status display.
- Enter a list of service indices (e.g., 1 2 5), followed by an action (D for disable, E for enable) to manage specific services.
## Example Commands
```powershell
# Start the script
.\ServiceManagerPS.ps1

# Sample prompt input to disable and stop services with indices 1 and 2:
=Command> 1 2
Enter action (D: Disable & Stop, E: Enable & Start): D
```
# Installation
1. Clone the repository or download the ServiceManagerPS.ps1 file to your local machine.
    ```powershell
    git clone https://github.com/your-username/ServiceManagerPS.git
    ```
2. Open the ServiceManagerPS.ps1 file using PowerShell (Run as Administrator).
3. Alternatively, you can launch the script using Windows Run (Windows + R):
- Press Windows + R.
- Type powershell -ExecutionPolicy Bypass -File "C:\path\to\ServiceManagerPS.ps1".
- Press Enter.
# Prerequisites
- Windows OS with PowerShell
- Administrator privileges to start/stop services
