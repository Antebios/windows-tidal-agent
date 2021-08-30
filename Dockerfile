# escape=`
FROM mcr.microsoft.com/dotnet/framework/runtime:4.8-windowsservercore-ltsc2019
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

EXPOSE 5912

WORKDIR /
RUN New-Item -Type Directory -Path "C:\\logs" | Out-Null

# THIS IS THE WINDOWS TIDAL INSTALLER
COPY TAAgent.msi C:/
RUN Start-Process msiexec.exe -ArgumentList '/i TAAgent.msi /quiet /norestart /L*V .\TAAGent.log' -NoNewWindow -Wait; `
  Remove-Item -Path C:/TAAgent.msi -Force;

COPY Wait-Service.ps1 C:/
CMD c:\Wait-Service.ps1 -StartupTimeout 60 -ServiceName 'TIDAL_AGENT_1'
