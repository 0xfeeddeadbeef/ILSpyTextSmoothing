Set-StrictMode -Version Latest

$ErrorActionPreference = 'Stop'

# Workaround: .NET default TLS version is less than v1.2; GitHub does not support insecure protocols:
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls11, Tls12'

[Uri] $Local:GitHub = [Uri]'https://api.github.com/repos/icsharpcode/ILSpy/releases/latest'

$Local:RequestHeaders = @{
    Accept = 'application/vnd.github.v3+json'
    Authorization = "Bearer $env:GITHUB_API_TOKEN"
}

$Local:LatestRelease = Invoke-RestMethod -Method Get -UseBasicParsing -Uri $Local:GitHub -Headers $Local:RequestHeaders -ContentType 'application/json'
$Local:LatestRelease.assets |
    Where-Object -FilterScript { ($_.content_type -eq 'application/x-zip-compressed') -and ($_.name -like '*zip') } |
    Select-Object -First 1

$Local:ZipPath = "$env:APPVEYOR_BUILD_FOLDER\ILSpy.zip"

Invoke-WebRequest -UseBasicParsing -Uri $Local:Asset.browser_download_url -Method Get -OutFile $Local:ZipPath

Import-Module Microsoft.PowerShell.Archive

New-Item -Path "$env:APPVEYOR_BUILD_FOLDER\lib\" -ItemType Directory

Expand-Archive -Path $Local:ZipPath -DestinationPath "$env:APPVEYOR_BUILD_DIR\lib\" -Force -ErrorAction Stop

$Local:CSProj = "$env:APPVEYOR_BUILD_DIR\ILSpyTextSmoothing\ILSpyTextSmoothing-CI.csproj"

((Get-Content -Path $Local:CSProj -Raw -Encoding UTF8) -replace '%PATH_ICSharpCode.AvalonEdit.dll%',"$env:APPVEYOR_BUILD_DIR\lib\ICSharpCode.AvalonEdit.dll") | Set-Content -Path $Local:CSProj -Encoding UTF8
((Get-Content -Path $Local:CSProj -Raw -Encoding UTF8) -replace '%PATH_ILSpy.exe%',"$env:APPVEYOR_BUILD_DIR\lib\ILSpy.exe") | Set-Content -Path $Local:CSProj -Encoding UTF8
((Get-Content -Path $Local:CSProj -Raw -Encoding UTF8) -replace '%PATH_Microsoft.VisualStudio.Composition.dll%',"$env:APPVEYOR_BUILD_DIR\lib\Microsoft.VisualStudio.Composition.dll") | Set-Content -Path $Local:CSProj -Encoding UTF8
