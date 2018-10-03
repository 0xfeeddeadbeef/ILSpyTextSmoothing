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
$Local:Asset = $Local:LatestRelease.assets |
    Where-Object -FilterScript { ($_.content_type -eq 'application/x-zip-compressed') -and ($_.name -like '*zip') } |
    Select-Object -First 1

$Local:ZipPath = "C:\Projects\ILSpyTextSmoothing\ILSpy.zip"

Invoke-WebRequest -UseBasicParsing -Uri $Local:Asset.browser_download_url -Method Get -OutFile $Local:ZipPath

Import-Module Microsoft.PowerShell.Archive

New-Item -Path "C:\Projects\ILSpyTextSmoothing\lib\" -ItemType Directory -Verbose | Out-Null

Expand-Archive -Path $Local:ZipPath -DestinationPath "C:\Projects\ILSpyTextSmoothing\lib\" -Force -ErrorAction Stop -Verbose

$Local:CSProj = "C:\Projects\ILSpyTextSmoothing\ILSpyTextSmoothing\ILSpyTextSmoothing-CI.csproj"

((Get-Content -Path $Local:CSProj -Raw -Encoding UTF8) -replace '%PATH_ICSharpCode.AvalonEdit.dll%',"C:\Projects\ILSpyTextSmoothing\lib\ICSharpCode.AvalonEdit.dll") | Set-Content -Path $Local:CSProj -Encoding UTF8
((Get-Content -Path $Local:CSProj -Raw -Encoding UTF8) -replace '%PATH_ILSpy.exe%',"C:\Projects\ILSpyTextSmoothing\lib\ILSpy.exe") | Set-Content -Path $Local:CSProj -Encoding UTF8
((Get-Content -Path $Local:CSProj -Raw -Encoding UTF8) -replace '%PATH_Microsoft.VisualStudio.Composition.dll%',"C:\Projects\ILSpyTextSmoothing\lib\Microsoft.VisualStudio.Composition.dll") | Set-Content -Path $Local:CSProj -Encoding UTF8
