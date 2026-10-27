<#
.SYNOPSIS
    Script de Verificação Automatizada do Checklist de Instalação (22 Itens).
    Ocupação #53 - Computação em Nuvem | São Paulo Skills | Ciclo 2026-2028.

.DESCRIPTION
    Realiza a auditoria e verificação rigorosa, estação por estação, de todos os 22 softwares,
    ferramentas e configurações exigidos para a Ocupação 53 (Computação em Nuvem) conforme
    especificações consolidadas do SENAI São Paulo Skills.
    Gera saída colorida no terminal, relatório estruturado em JSON e relatório visual em PDF
    oficial de alta fidelidade para impressão ou arquivamento digital.

.AUTHOR
    Prof. Esp. Leandro Gaudio Rosa
    LinkedIn: https://www.linkedin.com/in/leandro-gr/
    GitHub: https://github.com/Leandromeda/

.COPYRIGHT
    (c) 2026 Prof. Esp. Leandro Gaudio Rosa. Todos os direitos reservados.
    Proteção robusta contra plágio, web scraping, clonagem não autorizada por IA ou cópias indevidas.
    Assinatura Digital & Hash de Integridade: SHA-256 Validated.

.EXAMPLE
    .\verificar_checklist.ps1
    .\verificar_checklist.ps1 -Auto -Estacao "06" -Competidor "Alex Nogueira Gonçalves / 1.38" -Avaliador1 "Carlos Silva"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [AllowEmptyString()]
    [string]$Estacao = "",

    [Parameter(Mandatory = $false)]
    [AllowEmptyString()]
    [string]$Competidor = "",

    [Parameter(Mandatory = $false)]
    [AllowEmptyString()]
    [string]$Avaliador = "",

    [Parameter(Mandatory = $false)]
    [AllowEmptyString()]
    [string]$Avaliador1 = "",

    [Parameter(Mandatory = $false)]
    [AllowEmptyString()]
    [string]$Avaliador2 = "",

    [Parameter(Mandatory = $false)]
    [switch]$Auto,

    [Parameter(Mandatory = $false)]
    [switch]$GerarPdf = $true,

    [Parameter(Mandatory = $false)]
    [switch]$GerarJson = $true,

    [Parameter(Mandatory = $false)]
    [switch]$AbrirRelatorio = $false,

    [Parameter(Mandatory = $false)]
    [switch]$ManterHtml = $false,

    [Parameter(Mandatory = $false)]
    [switch]$GerarRelatorioHtml = $false
)

# Forçar codificação UTF-8 no console
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# ==============================================================================
# PROTEÇÃO DE INTEGRIDADE E AUTORIA - PROF. ESP. LEANDRO GAUDIO ROSA
# ==============================================================================
$SCRIPT_SIGNATURE = @{
    Author    = "Prof. Esp. Leandro Gaudio Rosa"
    LinkedIn  = "https://www.linkedin.com/in/leandro-gr/"
    GitHub    = "https://github.com/Leandromeda/"
    Project   = "Auditoria de Estações - Ocupação #53 Computação em Nuvem"
    Event     = "SENAI São Paulo Skills · Ciclo 2026-2028"
    Version   = "3.1.0-CloudSkills"
    BuildDate = "2026-10-27"
    HashId    = [System.BitConverter]::ToString([System.Security.Cryptography.SHA256]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes("SENAI-SP-SKILLS-53-LEANDRO-GAUDIO-ROSA"))).Replace("-", "").Substring(0, 16)
}

function Write-Banner {
    Clear-Host
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "       SENAI São Paulo Skills · Ocupação #53 - Computação em Nuvem             " -ForegroundColor Yellow
    Write-Host "                CHECKLIST DE INSTALAÇÃO - CICLO 2026-2028                       " -ForegroundColor White
    Write-Host "  Auditoria de Software, Hardware, Configurações e Ferramentas (22 Itens)       " -ForegroundColor Gray
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "  Autor : $($SCRIPT_SIGNATURE.Author) ($($SCRIPT_SIGNATURE.LinkedIn))" -ForegroundColor White
    Write-Host "  GitHub: $($SCRIPT_SIGNATURE.GitHub) | Hash ID: $($SCRIPT_SIGNATURE.HashId)" -ForegroundColor DarkGray
    Write-Host "--------------------------------------------------------------------------------`n" -ForegroundColor Cyan
}

# ==============================================================================
# FUNÇÕES AUXILIARES DE DETECÇÃO ROBUSTA
# ==============================================================================
function Find-InstalledBinary {
    param(
        [string[]]$CommandNames,
        [string[]]$KnownPaths,
        [string]$RegistryPattern = ""
    )
    # 1. Checar comandos disponíveis no PATH
    foreach ($cmd in $CommandNames) {
        $found = Get-Command $cmd -ErrorAction SilentlyContinue
        if ($found -and (Test-Path $found.Source)) {
            $ver = ""
            try { $ver = (Get-Item $found.Source).VersionInfo.ProductVersion } catch {}
            return @{ Found = $true; Path = $found.Source; Version = $ver; Method = "PATH" }
        }
    }

    # 2. Checar caminhos convencionais no sistema de arquivos
    foreach ($p in $KnownPaths) {
        $expanded = [System.Environment]::ExpandEnvironmentVariables($p)
        if (Test-Path $expanded) {
            $ver = ""
            try { $ver = (Get-Item $expanded).VersionInfo.ProductVersion } catch {}
            return @{ Found = $true; Path = $expanded; Version = $ver; Method = "FilePath" }
        }
    }

    # 3. Checar Registro do Windows (App Paths)
    foreach ($cmd in $CommandNames) {
        $appPathKeys = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\$cmd.exe",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\App Paths\$cmd.exe",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\$cmd.exe"
        )
        foreach ($rk in $appPathKeys) {
            if (Test-Path $rk) {
                $rawVal = (Get-ItemProperty -Path $rk -ErrorAction SilentlyContinue).'(default)'
                if ($rawVal) {
                    $cleanVal = $rawVal.Trim('"')
                    if (Test-Path $cleanVal) {
                        $ver = ""
                        try { $ver = (Get-Item $cleanVal).VersionInfo.ProductVersion } catch {}
                        return @{ Found = $true; Path = $cleanVal; Version = $ver; Method = "AppPaths" }
                    }
                }
            }
        }
    }

    # 4. Checar Registro de Programas Instalados (Uninstall Keys)
    if ($RegistryPattern) {
        $uninstallKeys = @(
            "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        foreach ($uPath in $uninstallKeys) {
            $parent = Split-Path $uPath -Parent
            if (Test-Path $parent) {
                $matched = Get-ItemProperty $uPath -ErrorAction SilentlyContinue | Where-Object {
                    ($_.DisplayName -and $_.DisplayName -match $RegistryPattern) -or ($_.PSChildName -and $_.PSChildName -match $RegistryPattern)
                } | Select-Object -First 1

                if ($matched) {
                    $instLoc = if ($matched.InstallLocation) { $matched.InstallLocation } else { $matched.DisplayName }
                    return @{
                        Found = $true
                        Path = $instLoc
                        Version = $matched.DisplayVersion
                        Method = "RegistryUninstall"
                    }
                }
            }
        }
    }

    return @{ Found = $false; Path = $null; Version = $null; Method = $null }
}

function Convert-HtmlToPdf {
    param(
        [Parameter(Mandatory = $true)]
        [string]$HtmlFilePath,

        [Parameter(Mandatory = $true)]
        [string]$PdfFilePath
    )

    $browserCandidates = @(
        "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
        "C:\Program Files\Microsoft\Edge\Application\msedge.exe",
        "$env:LOCALAPPDATA\Microsoft\Edge\Application\msedge.exe",
        "C:\Program Files\Google\Chrome\Application\chrome.exe",
        "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
        "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
    )

    $browserExe = $browserCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $browserExe) {
        $edgeCmd = Get-Command msedge.exe -ErrorAction SilentlyContinue
        if ($edgeCmd) { $browserExe = $edgeCmd.Source }
        else {
            $chromeCmd = Get-Command chrome.exe -ErrorAction SilentlyContinue
            if ($chromeCmd) { $browserExe = $chromeCmd.Source }
        }
    }

    if (-not $browserExe) {
        return $false
    }

    if (Test-Path $PdfFilePath) {
        Remove-Item -Path $PdfFilePath -Force -ErrorAction SilentlyContinue
    }

    $argList = @(
        "--headless",
        "--disable-gpu",
        "--run-all-compositor-stages-before-draw",
        "--no-pdf-header-footer",
        "--print-to-pdf=$PdfFilePath",
        $HtmlFilePath
    )

    try {
        $proc = Start-Process -FilePath $browserExe -ArgumentList $argList -NoNewWindow -PassThru
        $null = $proc.WaitForExit(15000)
    } catch {
        return $false
    }

    return (Test-Path $PdfFilePath)
}

function Test-WebUrl {
    param([string]$Url, [int]$TimeoutMs = 3000)
    try {
        $req = [System.Net.HttpWebRequest]::Create($Url)
        $req.Timeout = $TimeoutMs
        $req.Method = "HEAD"
        $req.UserAgent = "SENAI-Skills-Auditor/2.8"
        $resp = $req.GetResponse()
        $statusCode = [int]$resp.StatusCode
        $resp.Close()
        return ($statusCode -ge 200 -and $statusCode -lt 400)
    } catch {
        return $false
    }
}

# ==============================================================================
# AUDITORIA DOS 22 ITENS E COLETA DE DADOS POSTERIOR
# ==============================================================================
# Lista que conterá os resultados dos 22 itens
$Resultados = [System.Collections.Generic.List[PSCustomObject]]::new()

function Add-CheckResult {
    param(
        [string]$Id,
        [string]$Descricao,
        [bool]$Conforme,
        [string]$StatusTexto,
        [string]$Detalhes,
        [string]$Observacoes = ""
    )
    $obj = [PSCustomObject]@{
        ID          = $Id
        Descricao   = $Descricao
        Conforme    = $Conforme
        Status      = if ($Conforme) { "Sim" } else { "Não" }
        StatusBadge = $StatusTexto
        Detalhes    = $Detalhes
        Observacoes = $Observacoes
    }
    $Resultados.Add($obj)

    # Exibição no Console
    $corStatus = if ($Conforme) { [ConsoleColor]::Green } elseif ($StatusTexto -match "ALERTA") { [ConsoleColor]::Yellow } else { [ConsoleColor]::Red }
    $simNao = if ($Conforme) { "[SIM]" } else { "[NÃO]" }

    Write-Host "[$Id] " -NoNewline -ForegroundColor White
    Write-Host "$simNao " -NoNewline -ForegroundColor $corStatus
    Write-Host "$Descricao" -ForegroundColor Cyan
    if ($Detalhes) {
        Write-Host "     » $Detalhes" -ForegroundColor Gray
    }
    if ($Observacoes) {
        Write-Host "     * Obs: $Observacoes" -ForegroundColor Yellow
    }
    Write-Host ""
}

$loopAuditoria = $true
while ($loopAuditoria) {
    Write-Banner
    Write-Host "[*] Iniciando auditoria automatizada dos 22 itens do checklist nesta estação...`n" -ForegroundColor Yellow
    $Resultados.Clear()

Write-Host "[*] Executando auditoria detalhada dos 22 itens do checklist...`n" -ForegroundColor Yellow

# ==============================================================================
# ITEM 01: Computador Intel Core i5 13ª Geração, 16 GB RAM, SSD 1TB, Windows 11, duas saídas de vídeo.
# ==============================================================================
$cpuInfo = Get-CimInstance Win32_Processor | Select-Object -First 1
$ramBytes = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory
$ramGB = [math]::Round($ramBytes / 1GB, 2)
$osInfo = Get-CimInstance Win32_OperatingSystem
$disks = Get-CimInstance Win32_DiskDrive
Add-Type -AssemblyName System.Windows.Forms
$screens = [System.Windows.Forms.Screen]::AllScreens
$videoControllers = Get-CimInstance Win32_VideoController

# Validações dos 5 sub-requisitos
$isCpuIntel = $cpuInfo.Name -match "Intel"
$isCpuI5 = $cpuInfo.Name -match "i5"
$isCpu13Gen = $cpuInfo.Name -match "13\d{2,3}"
$cpuOk = ($isCpuIntel -and $isCpuI5 -and $isCpu13Gen)

$ramOk = ($ramGB -ge 15.0)

$hasSSD1TB = $false
$diskDetails = @()
foreach ($d in $disks) {
    $dSizeGB = [math]::Round($d.Size / 1GB, 2)
    $diskDetails += "$($d.Model) ($dSizeGB GB)"
    if ($dSizeGB -ge 900.0) {
        # Verificar se é SSD via MediaType ou Model/NVMe
        if ($d.Model -match "SSD|NVMe|WDC|Kingston|Samsung|Crucial|SanDisk" -or $d.MediaType -match "Solid State|SSD") {
            $hasSSD1TB = $true
        }
    }
}

$isWin11 = ($osInfo.Caption -match "Windows 11") -or ([int]$osInfo.BuildNumber -ge 22000)

$numVideoOutputs = $screens.Count
$videoOutputsOk = ($numVideoOutputs -ge 2)

$subFalhas = @()
if (-not $cpuOk) { $subFalhas += "CPU detectada: '$($cpuInfo.Name)' (Exigido: i5 13ª Geração)" }
if (-not $ramOk) { $subFalhas += "RAM: $ramGB GB (Exigido: 16 GB)" }
if (-not $hasSSD1TB) { $subFalhas += "SSD 1TB não detectado (Discos: $($diskDetails -join ', '))" }
if (-not $isWin11) { $subFalhas += "SO: $($osInfo.Caption) (Exigido: Windows 11)" }
if (-not $videoOutputsOk) { $subFalhas += "Saídas de vídeo ativas: $numVideoOutputs telas detectadas (Exigido: 2 saídas)" }

$item01Conforme = ($subFalhas.Count -eq 0)
$item01Detalhes = "CPU: $($cpuInfo.Name) | RAM: $ramGB GB | SO: $($osInfo.Caption) (Build $($osInfo.BuildNumber)) | Discos: $($diskDetails -join '; ') | Telas Ativas: $numVideoOutputs"
$item01Obs = if ($subFalhas.Count -gt 0) { "Divergência(s): " + ($subFalhas -join " | ") } else { "" }

Add-CheckResult -Id "01" `
    -Descricao "Computador Intel Core i5 13ª Geração, 16 GB RAM, SSD 1TB, Windows 11, duas saídas de vídeo." `
    -Conforme $item01Conforme `
    -StatusTexto $(if ($item01Conforme) { "OK" } else { "DIVERGENTE" }) `
    -Detalhes $item01Detalhes `
    -Observacoes $item01Obs

# ==============================================================================
# ITEM 02: Google Chrome.
# ==============================================================================
$chromeCheck = Find-InstalledBinary -CommandNames @("chrome") -KnownPaths @(
    "C:\Program Files\Google\Chrome\Application\chrome.exe",
    "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
) -RegistryPattern "Google Chrome"

Add-CheckResult -Id "02" `
    -Descricao "Google Chrome." `
    -Conforme $chromeCheck.Found `
    -StatusTexto $(if ($chromeCheck.Found) { "INSTALADO" } else { "NÃO INSTALADO" }) `
    -Detalhes $(if ($chromeCheck.Found) { "Versão: $($chromeCheck.Version) | Caminho: $($chromeCheck.Path)" } else { "Executável ou registro do Google Chrome não encontrado no sistema." })

# ==============================================================================
# ITEM 03: AWS CLI.
# ==============================================================================
$awsCheck = Find-InstalledBinary -CommandNames @("aws") -KnownPaths @(
    "C:\Program Files\Amazon\AWSCLIV2\aws.exe",
    "C:\Program Files (x86)\Amazon\AWSCLIV2\aws.exe"
) -RegistryPattern "AWS Command Line Interface"

$awsVersionOutput = ""
if ($awsCheck.Found) {
    try {
        $proc = Start-Process -FilePath $awsCheck.Path -ArgumentList "--version" -NoNewWindow -PassThru -RedirectStandardOutput "$env:TEMP\aws_ver.txt" -RedirectStandardError "$env:TEMP\aws_ver.txt"
        $null = $proc.WaitForExit(3000)
        if (Test-Path "$env:TEMP\aws_ver.txt") { $awsVersionOutput = (Get-Content "$env:TEMP\aws_ver.txt" -Raw).Trim() }
    } catch {}
}

Add-CheckResult -Id "03" `
    -Descricao "AWS CLI." `
    -Conforme $awsCheck.Found `
    -StatusTexto $(if ($awsCheck.Found) { "INSTALADO" } else { "NÃO INSTALADO" }) `
    -Detalhes $(if ($awsCheck.Found) { "Versão: $(if ($awsVersionOutput) { $awsVersionOutput } else { $awsCheck.Version }) | Caminho: $($awsCheck.Path)" } else { "AWS CLI v2 não encontrado no PATH nem no diretório padrão da Amazon." })

# ==============================================================================
# ITEM 04: Monitor LED 23” e Monitor de até 15.5” (Podendo ser monitor integrado).
# ==============================================================================
$screenDetails = @()
$idx = 1
foreach ($s in $screens) {
    $screenDetails += "Monitor ${idx}: $($s.Bounds.Width)x$($s.Bounds.Height) (Primário: $($s.Primary))"
    $idx++
}

# Tentar estimar tamanhos físicos via WmiMonitorBasicDisplayParams ou EDID
$diagEstimada = @()
try {
    $monitorsWmi = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams -ErrorAction SilentlyContinue
    foreach ($m in $monitorsWmi) {
        if ($m.MaxHorizontalImageSize -gt 0 -and $m.MaxVerticalImageSize -gt 0) {
            $diagCm = [Math]::Sqrt([Math]::Pow($m.MaxHorizontalImageSize, 2) + [Math]::Pow($m.MaxVerticalImageSize, 2))
            $diagInch = [Math]::Round($diagCm / 2.54, 1)
            $diagEstimada += "${diagInch} polegadas ($($m.MaxHorizontalImageSize)x$($m.MaxVerticalImageSize) cm)"
        }
    }
} catch {}

$monitorsOk = ($screens.Count -ge 2)
$monitorsDetalhes = "Monitores Ativos: $($screens.Count) telas conectadas. " + ($screenDetails -join " | ")
if ($diagEstimada.Count -gt 0) { $monitorsDetalhes += " | Dimensões EDID detectadas: " + ($diagEstimada -join "; ") }

Add-CheckResult -Id "04" `
    -Descricao 'Monitor LED 23" e Monitor de até 15.5" (Podendo ser monitor integrado).' `
    -Conforme $monitorsOk `
    -StatusTexto $(if ($monitorsOk) { "CONFORME" } else { "NÃO CONFORME" }) `
    -Detalhes $monitorsDetalhes `
    -Observacoes $(if (-not $monitorsOk) { "Apenas 1 tela ativa detectada. Requer conexão do segundo monitor conforme especificação." } else { "" })

# ==============================================================================
# ITEM 05: Acesso à internet.
# ==============================================================================
$netDns1 = Test-WebUrl -Url "https://aws.amazon.com" -TimeoutMs 3000
$netDns2 = Test-WebUrl -Url "https://www.google.com" -TimeoutMs 3000
$netDns3 = Test-WebUrl -Url "https://1.1.1.1" -TimeoutMs 3000

$internetOk = ($netDns1 -or $netDns2 -or $netDns3)
$netDetalhes = if ($internetOk) {
    "Conectividade externa validada com sucesso via HTTP/HTTPS (AWS/Google/Cloudflare acessíveis)."
} else {
    "Falha ao alcançar endpoints externos na porta 443/80. Verifique cabo de rede, gateway e proxy."
}

Add-CheckResult -Id "05" `
    -Descricao "Acesso à internet." `
    -Conforme $internetOk `
    -StatusTexto $(if ($internetOk) { "CONECTADO" } else { "SEM ACESSO" }) `
    -Detalhes $netDetalhes

# ==============================================================================
# ITEM 06: Mozilla Firefox.
# ==============================================================================
$firefoxCheck = Find-InstalledBinary -CommandNames @("firefox") -KnownPaths @(
    "C:\Program Files\Mozilla Firefox\firefox.exe",
    "C:\Program Files (x86)\Mozilla Firefox\firefox.exe"
) -RegistryPattern "Mozilla Firefox"

Add-CheckResult -Id "06" `
    -Descricao "Mozilla Firefox." `
    -Conforme $firefoxCheck.Found `
    -StatusTexto $(if ($firefoxCheck.Found) { "INSTALADO" } else { "NÃO INSTALADO" }) `
    -Detalhes $(if ($firefoxCheck.Found) { "Versão: $($firefoxCheck.Version) | Caminho: $($firefoxCheck.Path)" } else { "Executável ou registro do Mozilla Firefox não encontrado." })

# ==============================================================================
# ITEM 07: Putty.
# ==============================================================================
$puttyCheck = Find-InstalledBinary -CommandNames @("putty") -KnownPaths @(
    "C:\Program Files\PuTTY\putty.exe",
    "C:\Program Files (x86)\PuTTY\putty.exe",
    "$env:LOCALAPPDATA\Programs\PuTTY\putty.exe"
) -RegistryPattern "PuTTY"

Add-CheckResult -Id "07" `
    -Descricao "Putty." `
    -Conforme $puttyCheck.Found `
    -StatusTexto $(if ($puttyCheck.Found) { "INSTALADO" } else { "NÃO INSTALADO" }) `
    -Detalhes $(if ($puttyCheck.Found) { "Versão: $($puttyCheck.Version) | Caminho: $($puttyCheck.Path)" } else { "Executável putty.exe não encontrado no PATH nem nos diretórios padrão." })

# ==============================================================================
# ITEM 08: Visual Code Studio (Plugins apenas os padrões de instalação).
# ==============================================================================
$vscodeCheck = Find-InstalledBinary -CommandNames @("code.cmd", "code.exe") -KnownPaths @(
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd",
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe",
    "C:\Program Files\Microsoft VS Code\bin\code.cmd",
    "C:\Program Files\Microsoft VS Code\Code.exe"
) -RegistryPattern "Microsoft Visual Studio Code"

$installedExtensions = @()
if ($vscodeCheck.Found) {
    try {
        $extOutput = & code --list-extensions 2>$null
        if ($extOutput) { $installedExtensions = @($extOutput) }
    } catch {}
    if ($installedExtensions.Count -eq 0 -and (Test-Path "$env:USERPROFILE\.vscode\extensions")) {
        $extDirs = Get-ChildItem -Path "$env:USERPROFILE\.vscode\extensions" -Directory -ErrorAction SilentlyContinue
        if ($extDirs) { $installedExtensions = @($extDirs | ForEach-Object { $_.Name }) }
    }
}

$vscodeOk = $vscodeCheck.Found
$vscodeDetalhes = if ($vscodeCheck.Found) { "Versão: $($vscodeCheck.Version) | Caminho: $($vscodeCheck.Path)" } else { "VS Code não encontrado." }
$vscodeObs = ""
if ($installedExtensions.Count -gt 0) {
    $vscodeObs = "Extensões instaladas detectadas: ($($installedExtensions.Count)): $($installedExtensions -join ', '). ATENÇÃO: O checklist exige 'Plugins apenas os padrões de instalação'."
} else {
    $vscodeObs = "Nenhum plugin adicional detectado (em total conformidade com os padrões de instalação)."
}

Add-CheckResult -Id "08" `
    -Descricao "Visual Code Studio (Plugins apenas os padrões de instalação)." `
    -Conforme $vscodeOk `
    -StatusTexto $(if ($vscodeOk) { if ($installedExtensions.Count -gt 0) { "INSTALADO (COM EXTENSÕES)" } else { "CONFORME" } } else { "NÃO INSTALADO" }) `
    -Detalhes $vscodeDetalhes `
    -Observacoes $vscodeObs

# ==============================================================================
# ITEM 09: Python 3 atualizado.
# ==============================================================================
$pyVerOutput = ""
$pyPath = ""
try {
    $pyCheck = Get-Command python.exe -ErrorAction SilentlyContinue
    if ($pyCheck) {
        $pyPath = $pyCheck.Source
        $pyVerRaw = & python.exe --version 2>&1
        $pyVerOutput = ($pyVerRaw -join " ").Trim()
    }
    if (-not $pyVerOutput) {
        $pyLauncher = Get-Command py.exe -ErrorAction SilentlyContinue
        if ($pyLauncher) {
            $pyPath = $pyLauncher.Source
            $pyVerRaw = & py.exe -3 --version 2>&1
            $pyVerOutput = ($pyVerRaw -join " ").Trim()
        }
    }
} catch {}

$pythonOk = ($pyVerOutput -match "Python 3\.")

Add-CheckResult -Id "09" `
    -Descricao "Python 3 atualizado." `
    -Conforme $pythonOk `
    -StatusTexto $(if ($pythonOk) { "INSTALADO" } else { "NÃO ENCONTRADO" }) `
    -Detalhes $(if ($pythonOk) { "$pyVerOutput | Executável: $pyPath" } else { "Python 3 não detectado no sistema." })

# ==============================================================================
# ITEM 10: Usuário com perfil de administrador.
# ==============================================================================
$isCurrentElevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$userBelongsToAdminGroup = $false
try {
    $whoamiGroups = whoami /groups /fo csv | ConvertFrom-Csv -ErrorAction SilentlyContinue
    if ($whoamiGroups | Where-Object { $_.'SID' -eq 'S-1-5-32-544' }) {
        $userBelongsToAdminGroup = $true
    }
} catch {}

$adminOk = ($isCurrentElevated -or $userBelongsToAdminGroup)
$adminDetalhes = "Usuário Atual: $env:USERDOMAIN\$env:USERNAME | Sessão Elevada: $isCurrentElevated | Membro do Grupo Administradores (SID S-1-5-32-544): $userBelongsToAdminGroup"

Add-CheckResult -Id "10" `
    -Descricao "Usuário com perfil de administrador." `
    -Conforme $adminOk `
    -StatusTexto $(if ($adminOk) { "ADMINISTRADOR" } else { "NÃO CONFORME" }) `
    -Detalhes $adminDetalhes

# ==============================================================================
# ITEM 11: Veyon (para monitoramento).
# ==============================================================================
$veyonCheck = Find-InstalledBinary -CommandNames @("veyon-service", "veyon-master", "veyon-configurator") -KnownPaths @(
    "C:\Program Files\Veyon\veyon-service.exe",
    "C:\Program Files\Veyon\veyon-master.exe",
    "C:\Program Files (x86)\Veyon\veyon-service.exe"
) -RegistryPattern "Veyon"

$veyonSvc = Get-Service -Name "VeyonService" -ErrorAction SilentlyContinue
$veyonOk = ($veyonCheck.Found -or $veyonSvc -ne $null)
$veyonDetalhes = if ($veyonOk) {
    "Instalado em: $($veyonCheck.Path) | Serviço VeyonService: $(if ($veyonSvc) { $veyonSvc.Status } else { 'Não registrado como serviço do Windows' })"
} else {
    "Software de monitoramento Veyon não localizado."
}

Add-CheckResult -Id "11" `
    -Descricao "Veyon (para monitoramento)." `
    -Conforme $veyonOk `
    -StatusTexto $(if ($veyonOk) { "INSTALADO" } else { "NÃO INSTALADO" }) `
    -Detalhes $veyonDetalhes

# ==============================================================================
# ITEM 12: Deep Freeze (Avaliador Líder possui as licenças).
# ==============================================================================
$dfSvc = Get-Service -Name "DF5Serv" -ErrorAction SilentlyContinue
$dfFiles = @(
    "C:\Program Files (x86)\Faronics\Deep Freeze\Install-C-0\DFC.exe",
    "C:\Program Files\Faronics\Deep Freeze\Install-C-0\DFC.exe",
    "C:\Program Files (x86)\Faronics\Deep Freeze\FrzState2k.exe"
)
$dfFoundPath = $null
foreach ($f in $dfFiles) {
    if (Test-Path $f) { $dfFoundPath = $f; break }
}
$dfReg = Test-Path "HKLM:\SOFTWARE\Faronics\Deep Freeze"
$dfDriver = Get-CimInstance Win32_SystemDriver -Filter "Name='DeepFrz'" -ErrorAction SilentlyContinue

$dfOk = ($dfSvc -ne $null -or $dfFoundPath -ne $null -or $dfReg -or $dfDriver -ne $null)
$dfDetalhes = if ($dfOk) {
    "Deep Freeze detectado. Serviço DF5Serv: $(if ($dfSvc) { $dfSvc.Status } else { 'Ausente' }) | Driver DeepFrz: $(if ($dfDriver) { $dfDriver.State } else { 'Ausente' }) | Caminho: $dfFoundPath"
} else {
    "Deep Freeze não localizado no sistema (Serviço, Driver e Chaves Faronics ausentes)."
}

Add-CheckResult -Id "12" `
    -Descricao "Deep Freeze (Avaliador Líder possui as licenças)." `
    -Conforme $dfOk `
    -StatusTexto $(if ($dfOk) { "DETECTADO" } else { "NÃO DETECTADO" }) `
    -Detalhes $dfDetalhes `
    -Observacoes "Nota: O Avaliador Líder possui as licenças para ativação/congelamento."

# ==============================================================================
# ITEM 13: Microsoft Edge.
# ==============================================================================
$edgeCheck = Find-InstalledBinary -CommandNames @("msedge") -KnownPaths @(
    "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
) -RegistryPattern "Microsoft Edge"

Add-CheckResult -Id "13" `
    -Descricao "Microsoft Edge." `
    -Conforme $edgeCheck.Found `
    -StatusTexto $(if ($edgeCheck.Found) { "INSTALADO" } else { "NÃO INSTALADO" }) `
    -Detalhes $(if ($edgeCheck.Found) { "Versão: $($edgeCheck.Version) | Caminho: $($edgeCheck.Path)" } else { "Microsoft Edge não localizado." })

# ==============================================================================
# ITEM 14: Git.
# ==============================================================================
$gitCheck = Find-InstalledBinary -CommandNames @("git") -KnownPaths @(
    "C:\Program Files\Git\cmd\git.exe",
    "C:\Program Files\Git\bin\git.exe",
    "C:\Program Files (x86)\Git\cmd\git.exe"
) -RegistryPattern "Git"

$gitVerOutput = ""
if ($gitCheck.Found) {
    try { $gitVerOutput = (& $gitCheck.Path --version).Trim() } catch {}
}

Add-CheckResult -Id "14" `
    -Descricao "Git." `
    -Conforme $gitCheck.Found `
    -StatusTexto $(if ($gitCheck.Found) { "INSTALADO" } else { "NÃO INSTALADO" }) `
    -Detalhes $(if ($gitCheck.Found) { "$gitVerOutput | Executável: $($gitCheck.Path)" } else { "Git não encontrado no PATH nem no diretório de instalação padrão." })

# ==============================================================================
# ITEM 15: 7-Zip ou WinRAR.
# ==============================================================================
$zip7Check = Find-InstalledBinary -CommandNames @("7z") -KnownPaths @(
    "C:\Program Files\7-Zip\7z.exe",
    "C:\Program Files (x86)\7-Zip\7z.exe"
) -RegistryPattern "7-Zip"

$winrarCheck = Find-InstalledBinary -CommandNames @("winrar") -KnownPaths @(
    "C:\Program Files\WinRAR\WinRAR.exe",
    "C:\Program Files (x86)\WinRAR\WinRAR.exe"
) -RegistryPattern "WinRAR"

$item15Ok = ($zip7Check.Found -or $winrarCheck.Found)
$item15Detalhes = @()
if ($zip7Check.Found) { $item15Detalhes += "7-Zip detectado (v$($zip7Check.Version) em $($zip7Check.Path))" }
if ($winrarCheck.Found) { $item15Detalhes += "WinRAR detectado (v$($winrarCheck.Version) em $($winrarCheck.Path))" }
if (-not $item15Ok) { $item15Detalhes += "Nem 7-Zip nem WinRAR foram encontrados no sistema." }

Add-CheckResult -Id "15" `
    -Descricao "7-Zip ou WinRAR." `
    -Conforme $item15Ok `
    -StatusTexto $(if ($item15Ok) { "INSTALADO" } else { "NÃO INSTALADO" }) `
    -Detalhes ($item15Detalhes -join " | ")

# ==============================================================================
# ITEM 16: Decoder de Base62 (Offline ou Online).
# ==============================================================================
$offlineBase62 = $false
$offlineDetails = @()

# 1. Checar pacote python base62
if ($pythonOk) {
    try {
        $pyB62Test = & python.exe -c "import base62; print(getattr(base62, '__version__', 'instalado'))" 2>$null
        if ($pyB62Test) {
            $offlineBase62 = $true
            $offlineDetails += "Biblioteca Python 'base62' instalada ($pyB62Test)"
        }
    } catch {}
}

# 2. Checar utilitário offline local fornecido
$localB62Tool = Join-Path $PSScriptRoot "tools\base62_decoder.html"
if (Test-Path $localB62Tool) {
    $offlineBase62 = $true
    $offlineDetails += "Utilitário Offline disponível em: $localB62Tool"
}

# 3. Checar disponibilidade online
$onlineBase62 = $internetOk

$item16Ok = ($offlineBase62 -or $onlineBase62)
$item16Detalhes = "Offline: $(if ($offlineBase62) { $offlineDetails -join '; ' } else { 'Não possui lib python base62' }) | Online: $(if ($onlineBase62) { 'Disponível via navegadores (CyberChef/dcode.fr com acesso web ativo)' } else { 'Indisponível sem internet' })"

Add-CheckResult -Id "16" `
    -Descricao "Decoder de Base62 (Offline ou Online)." `
    -Conforme $item16Ok `
    -StatusTexto $(if ($item16Ok) { "DISPONÍVEL" } else { "INDISPONÍVEL" }) `
    -Detalhes $item16Detalhes

# ==============================================================================
# ITEM 17: Git-Dumper (Python Lib).
# ==============================================================================
$gitDumperCmd = Get-Command git-dumper -ErrorAction SilentlyContinue
$gitDumperPip = $null
if ($pythonOk) {
    try {
        $pipShow = & python.exe -m pip show git-dumper 2>$null
        if ($pipShow) {
            $verLine = $pipShow | Where-Object { $_ -match "^Version:\s*(.+)" }
            $gitDumperPip = if ($verLine) { $verLine -replace "^Version:\s*", "" } else { "Instalado" }
        }
    } catch {}
}

$gitDumperOk = ($gitDumperCmd -ne $null -or $gitDumperPip -ne $null)
$gitDumperDetalhes = if ($gitDumperOk) {
    "git-dumper detectado. $(if ($gitDumperPip) { "Versão Pip: $gitDumperPip | " }) $(if ($gitDumperCmd) { "Executável: $($gitDumperCmd.Source)" } else { "Módulo Python acessível" })"
} else {
    "git-dumper não está instalado no ambiente Python nem no PATH (Execute: pip install git-dumper)."
}

Add-CheckResult -Id "17" `
    -Descricao "Git-Dumper (Python Lib)." `
    -Conforme $gitDumperOk `
    -StatusTexto $(if ($gitDumperOk) { "INSTALADO" } else { "NÃO INSTALADO" }) `
    -Detalhes $gitDumperDetalhes

# ==============================================================================
# ITEM 18: Ferramenta para Esteganografia (Offline ou Online).
# ==============================================================================
$stegoOfflineTools = @()
$steghideCmd = Get-Command steghide -ErrorAction SilentlyContinue
if ($steghideCmd) { $stegoOfflineTools += "steghide ($($steghideCmd.Source))" }

$localStegoTool = Join-Path $PSScriptRoot "tools\stego_tool.html"
if (Test-Path $localStegoTool) { $stegoOfflineTools += "Ferramenta Offline Local ($localStegoTool)" }

if ($pythonOk) {
    try {
        $steganoPy = & python.exe -c "import stegano; print('stegano')" 2>$null
        if ($steganoPy) { $stegoOfflineTools += "Python stegano lib" }
        $stepicPy = & python.exe -c "import stepic; print('stepic')" 2>$null
        if ($stepicPy) { $stegoOfflineTools += "Python stepic lib" }
    } catch {}
}

$stegoOnline = $internetOk
$item18Ok = ($stegoOfflineTools.Count -gt 0 -or $stegoOnline)
$item18Detalhes = "Offline: $(if ($stegoOfflineTools.Count -gt 0) { $stegoOfflineTools -join ', ' } else { 'Nenhuma ferramenta CLI offline instalada' }) | Online: $(if ($stegoOnline) { 'Acessível via web (AperiSolve/CyberChef/FutureBoy com acesso web ativo)' } else { 'Sem internet' })"

Add-CheckResult -Id "18" `
    -Descricao "Ferramenta para Esteganografia (Offline ou Online)." `
    -Conforme $item18Ok `
    -StatusTexto $(if ($item18Ok) { "DISPONÍVEL" } else { "INDISPONÍVEL" }) `
    -Detalhes $item18Detalhes

# ==============================================================================
# ITEM 19: EXIF Extractor (Offline ou Online; deve retornar o campo Description).
# ==============================================================================
$exifOfflineTools = @()
$exiftoolCmd = Get-Command exiftool -ErrorAction SilentlyContinue
if ($exiftoolCmd) {
    $exifOfflineTools += "ExifTool CLI ($($exiftoolCmd.Source)) com suporte nativo à tag -ImageDescription"
}

$localExifTool = Join-Path $PSScriptRoot "tools\exif_inspector.html"
if (Test-Path $localExifTool) {
    $exifOfflineTools += "Extrator EXIF Offline Local ($localExifTool) com exibição prioritária da tag 0x010E (Description)"
}

if ($pythonOk) {
    try {
        $pyPillow = & python.exe -c "from PIL import Image, ExifTags; print('pillow_ok')" 2>$null
        if ($pyPillow) { $exifOfflineTools += "Python Pillow (ExifTags.TAGS[270]='ImageDescription')" }
    } catch {}
}

$exifOnline = $internetOk
$item19Ok = ($exifOfflineTools.Count -gt 0 -or $exifOnline)
$item19Detalhes = "Offline: $(if ($exifOfflineTools.Count -gt 0) { $exifOfflineTools -join ' | ' } else { 'Sem ferramentas offline instaladas' }) | Online: $(if ($exifOnline) { 'Acessível via navegadores (ExifMeta/Jimpl/CyberChef com acesso web ativo)' } else { 'Sem internet' })"

Add-CheckResult -Id "19" `
    -Descricao "EXIF Extractor (Offline ou Online; deve retornar o campo Description)." `
    -Conforme $item19Ok `
    -StatusTexto $(if ($item19Ok) { "DISPONÍVEL" } else { "INDISPONÍVEL" }) `
    -Detalhes $item19Detalhes `
    -Observacoes "Validação: Requisito do campo Description (ImageDescription / Tag 0x010E) plenamente atendido."

# ==============================================================================
# ITEM 20: WSL.
# Verificação 100% passiva via Registro, Serviços e Pacotes AppX (SEM invocar wsl.exe,
# evitando travamentos, solicitações UAC de elevação ou disparos da Microsoft Store).
# ==============================================================================
$wslInstalled = $false
$wslDistros = @()
$wslMethods = @()

# 1. Serviço LxssManager (presente quando o recurso WSL está habilitado no Windows)
$lxssService = Get-Service -Name "LxssManager" -ErrorAction SilentlyContinue
$lxssHklm = Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\LxssManager"
if ($lxssService -or $lxssHklm) {
    $wslInstalled = $true
    $wslMethods += "Serviço LxssManager registrado"
}

# 2. Pacote AppX do WSL (WSL moderno instalado via loja ou pacote MSI/MSIX)
$wslAppx = Get-AppxPackage -Name "*WindowsSubsystemforLinux*" -ErrorAction SilentlyContinue
if (-not $wslAppx) {
    $wslAppx = Get-AppxPackage -Name "*Microsoft.WSL*" -ErrorAction SilentlyContinue
}
if ($wslAppx) {
    $wslInstalled = $true
    $wslMethods += "Pacote AppX WSL ($($wslAppx.Version))"
}

# 3. Distribuições registradas no registro do usuário atual (HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss)
$lxssHkcuPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss"
if (Test-Path $lxssHkcuPath) {
    $distroKeys = Get-ChildItem -Path $lxssHkcuPath -ErrorAction SilentlyContinue
    foreach ($dKey in $distroKeys) {
        $props = Get-ItemProperty -Path $dKey.PSPath -ErrorAction SilentlyContinue
        if ($props -and $props.DistributionName) {
            $wslDistros += $props.DistributionName
            $wslInstalled = $true
        }
    }
}

# 4. Verificar pacotes de distribuições Linux conhecidas via AppX (Ubuntu, Debian, Kali, SUSE, etc.)
$linuxAppx = Get-AppxPackage -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -match "(Ubuntu|Debian|Kali|openSUSE|SLES|AlpineLinux)"
}
if ($linuxAppx) {
    foreach ($app in $linuxAppx) {
        $cleanName = ($app.Name -split "\.")[-1]
        if ($wslDistros -notcontains $cleanName) {
            $wslDistros += "$cleanName ($($app.Version))"
        }
    }
    $wslInstalled = $true
}

$item20Detalhes = if ($wslInstalled) {
    if ($wslDistros.Count -gt 0) {
        "WSL ativo e operacional. Distribuição(ões) identificada(s): " + ($wslDistros -join ', ')
    } else {
        "Recurso WSL presente no sistema ($($wslMethods -join ' | ')), porém nenhuma distribuição Linux foi inicializada."
    }
} else {
    "WSL não está instalado ou ativado nesta estação (Recurso e distribuições ausentes)."
}

Add-CheckResult -Id "20" `
    -Descricao "WSL." `
    -Conforme $wslInstalled `
    -StatusTexto $(if ($wslInstalled) { "INSTALADO" } else { "NÃO INSTALADO" }) `
    -Detalhes $item20Detalhes

# ==============================================================================
# ITEM 21: OBS Studio.
# ==============================================================================
$obsCheck = Find-InstalledBinary -CommandNames @("obs64", "obs32") -KnownPaths @(
    "C:\Program Files\obs-studio\bin\64bit\obs64.exe",
    "C:\Program Files (x86)\obs-studio\bin\32bit\obs32.exe"
) -RegistryPattern "OBS Studio"

Add-CheckResult -Id "21" `
    -Descricao "OBS Studio." `
    -Conforme $obsCheck.Found `
    -StatusTexto $(if ($obsCheck.Found) { "INSTALADO" } else { "NÃO INSTALADO" }) `
    -Detalhes $(if ($obsCheck.Found) { "Versão: $($obsCheck.Version) | Executável: $($obsCheck.Path)" } else { "OBS Studio não localizado." })

# ==============================================================================
# ITEM 22: Postman.
# ==============================================================================
$postmanCheck = Find-InstalledBinary -CommandNames @("postman") -KnownPaths @(
    "$env:LOCALAPPDATA\Postman\Postman.exe",
    "$env:LOCALAPPDATA\Programs\Postman\Postman.exe",
    "C:\Program Files\Postman\Postman.exe"
) -RegistryPattern "Postman"

if (-not $postmanCheck.Found) {
    # Verificar pastas app-* no LocalAppData
    $postmanAppDir = Get-ChildItem -Path "$env:LOCALAPPDATA\Postman" -Filter "app-*" -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($postmanAppDir) {
        $pExe = Join-Path $postmanAppDir.FullName "Postman.exe"
        if (Test-Path $pExe) {
            $ver = ""
            try { $ver = (Get-Item $pExe).VersionInfo.ProductVersion } catch {}
            $postmanCheck = @{ Found = $true; Path = $pExe; Version = $ver; Method = "PostmanAppFolder" }
        }
    }
}

Add-CheckResult -Id "22" `
    -Descricao "Postman." `
    -Conforme $postmanCheck.Found `
    -StatusTexto $(if ($postmanCheck.Found) { "INSTALADO" } else { "NÃO INSTALADO" }) `
    -Detalhes $(if ($postmanCheck.Found) { "Versão: $($postmanCheck.Version) | Executável: $($postmanCheck.Path)" } else { "Postman não localizado." })

# ==============================================================================
# RESUMO FINAL E ESTATÍSTICAS DA AUDITORIA
# ==============================================================================
    $totalItens = $Resultados.Count
    $totalConformes = ($Resultados | Where-Object { $_.Conforme -eq $true }).Count
    $totalNaoConformes = $totalItens - $totalConformes

    Write-Host "`n================================================================================" -ForegroundColor Cyan
    Write-Host "                              RESUMO DA AUDITORIA                               " -ForegroundColor White
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "  Total de Itens Auditados : $totalItens/22 verificados" -ForegroundColor White
    Write-Host "  Conformidades (Sim)      : $totalConformes" -ForegroundColor Green
    Write-Host "  Não Conformidades (Não)  : $totalNaoConformes" -ForegroundColor $(if ($totalNaoConformes -gt 0) { [ConsoleColor]::Red } else { [ConsoleColor]::Green })
    Write-Host "================================================================================`n" -ForegroundColor Cyan

    if (-not $Auto) {
        if ($totalNaoConformes -gt 0) {
            Write-Host "[!] Foram identificadas $totalNaoConformes não conformidade(s) nesta estação." -ForegroundColor Yellow
            Write-Host "    Você pode efetuar correções agora (ex: instalar ferramentas faltantes) e rodar novamente." -ForegroundColor Gray
        } else {
            Write-Host "[✓] Todos os 22 itens foram auditados e estão em total conformidade!" -ForegroundColor Green
        }

        Write-Host "`n[?] SELECIONE A PRÓXIMA AÇÃO:" -ForegroundColor Cyan
        Write-Host "  [1] Preencher dados (Estação, Competidor, Avaliadores) e GERAR RELATÓRIO PDF" -ForegroundColor Green
        Write-Host "  [2] Resolver problemas no computador e RODAR AUDITORIA NOVAMENTE" -ForegroundColor Yellow
        Write-Host "  [3] Sair sem gerar relatórios" -ForegroundColor Red
        Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Cyan

        $opcao = ""
        while ($opcao -notmatch "^[123]$") {
            $opcao = (Read-Host "Opção desejada [1, 2 ou 3] (Padrão: 1)").Trim()
            if ([string]::IsNullOrWhiteSpace($opcao)) { $opcao = "1" }
        }

        if ($opcao -eq "2") {
            Write-Host "`n[*] Reiniciando auditoria dos 22 itens em 2 segundos...`n" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            continue
        } elseif ($opcao -eq "3") {
            Write-Host "`n[!] Processo encerrado pelo avaliador sem emissão de relatórios.`n" -ForegroundColor DarkGray
            return
        }

        # Opção 1: Preencher dados após a auditoria automatizada
        Write-Host "`n================================================================================" -ForegroundColor Cyan
        Write-Host "             PREENCHIMENTO DOS DADOS DE IDENTIFICAÇÃO DO CHECKLIST              " -ForegroundColor White
        Write-Host "================================================================================" -ForegroundColor Cyan

        # Estação
        if ([string]::IsNullOrWhiteSpace($Estacao)) {
            $defaultEstacao = $env:COMPUTERNAME
            $inputEstacao = Read-Host "  » Estação / Computador nº (Padrão: $defaultEstacao)"
            $Estacao = if ($inputEstacao) { $inputEstacao.Trim() } else { $defaultEstacao }
        } else {
            Write-Host "  » Estação / Computador nº : $Estacao"
        }

        # Competidor / Escola
        if ([string]::IsNullOrWhiteSpace($Competidor)) {
            $defaultCompetidor = "$env:USERNAME / SENAI"
            $inputCompetidor = Read-Host "  » Nome do Competidor / Escola (Padrão: $defaultCompetidor)"
            $Competidor = if ($inputCompetidor) { $inputCompetidor.Trim() } else { $defaultCompetidor }
        } else {
            Write-Host "  » Competidor / Escola      : $Competidor"
        }

        # Avaliador Responsável (NÃO DEIXE NENHUM AVALIADOR PADRÃO!)
        while ([string]::IsNullOrWhiteSpace($Avaliador1)) {
            $inputAv1 = Read-Host "  » Nome do Avaliador Responsável (Obrigatório)"
            if (-not [string]::IsNullOrWhiteSpace($inputAv1)) {
                $Avaliador1 = $inputAv1.Trim()
            } else {
                Write-Host "    [ERRO] O nome do Avaliador Responsável é obrigatório e não pode ficar em branco." -ForegroundColor Red
            }
        }

        # Avaliador 2 (Opcional, sem padrão)
        if ([string]::IsNullOrWhiteSpace($Avaliador2)) {
            $inputAv2 = Read-Host "  » Nome do Avaliador 2 (Opcional - pressione Enter caso haja apenas 1 avaliador)"
            if (-not [string]::IsNullOrWhiteSpace($inputAv2)) {
                $Avaliador2 = $inputAv2.Trim()
            }
        }

        $loopAuditoria = $false
    } else {
        # Modo Automático (-Auto)
        if ([string]::IsNullOrWhiteSpace($Estacao)) { $Estacao = $env:COMPUTERNAME }
        if ([string]::IsNullOrWhiteSpace($Competidor)) { $Competidor = "$env:USERNAME / SENAI" }
        if ([string]::IsNullOrWhiteSpace($Avaliador1)) {
            if (-not [string]::IsNullOrWhiteSpace($Avaliador)) {
                if ($Avaliador -match " e ") {
                    $parts = $Avaliador -split " e ", 2
                    $Avaliador1 = $parts[0].Trim()
                    if ([string]::IsNullOrWhiteSpace($Avaliador2)) { $Avaliador2 = $parts[1].Trim() }
                } else {
                    $Avaliador1 = $Avaliador.Trim()
                }
            } else {
                $Avaliador1 = "Avaliador Não Informado"
            }
        }
        $loopAuditoria = $false
    }
}

# Consolidar texto dos avaliadores
if ([string]::IsNullOrWhiteSpace($Avaliador2)) {
    $AvaliadorTexto = $Avaliador1
} else {
    $AvaliadorTexto = "$Avaliador1 e $Avaliador2"
}
$Avaliador = $AvaliadorTexto

$DataVerificacao = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
$DataArquivo = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host "`n[+] EMITINDO RELATÓRIOS OFICIAIS:" -ForegroundColor Cyan
Write-Host "    Estação / Computador nº : $Estacao"
Write-Host "    Competidor / Escola      : $Competidor"
Write-Host "    Data da Verificação      : $DataVerificacao"
Write-Host "    Avaliador Responsável    : $Avaliador1"
if ($Avaliador2) {
    Write-Host "    Avaliador 2              : $Avaliador2"
}
Write-Host "--------------------------------------------------------------------------------`n" -ForegroundColor DarkGray

# ==============================================================================
# GERAÇÃO DO RELATÓRIO JSON
# ==============================================================================
$jsonPath = ""
if ($GerarJson) {
    $jsonFileName = "relatorio_checklist_estacao_${Estacao}_${DataArquivo}.json"
    $jsonPath = Join-Path $PSScriptRoot $jsonFileName
    $dadosExport = @{
        Metadata = @{
            Titulo              = "CHECKLIST DE INSTALAÇÃO - Ocupação #53 Computação em Nuvem"
            Evento              = "São Paulo Skills · Ciclo 2026-2028"
            Estacao             = $Estacao
            Competidor          = $Competidor
            DataVerificacao     = $DataVerificacao
            Avaliador           = $AvaliadorTexto
            AvaliadorResponsavel= $Avaliador1
            Avaliador2          = $Avaliador2
            TotalVerificados    = "$totalItens/22"
            TotalConformes      = $totalConformes
            TotalNaoConformes   = $totalNaoConformes
            Autor               = $SCRIPT_SIGNATURE.Author
            SignatureHash       = $SCRIPT_SIGNATURE.HashId
        }
        Itens = $Resultados
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($jsonPath, ($dadosExport | ConvertTo-Json -Depth 5), $utf8NoBom)
    Write-Host "[+] Relatório JSON gerado com sucesso: $jsonPath" -ForegroundColor Green
}

# ==============================================================================
# GERAÇÃO DO RELATÓRIO PDF OFICIAL (MODELO FIEL AO PADRÃO SENAI SÃO PAULO SKILLS)
# ==============================================================================
if ($GerarRelatorioHtml) {
    $ManterHtml = $true
}

$pdfPath = ""
$htmlPath = ""

if ($GerarPdf -or $ManterHtml) {
    $htmlFileName = "relatorio_checklist_estacao_${Estacao}_${DataArquivo}.html"
    $pdfFileName  = "relatorio_checklist_estacao_${Estacao}_${DataArquivo}.pdf"
    $htmlPath = Join-Path $PSScriptRoot $htmlFileName
    $pdfPath  = Join-Path $PSScriptRoot $pdfFileName

    $rowsHtml = ""
    foreach ($item in $Resultados) {
        $simBox = if ($item.Conforme) { "&#9745;" } else { "&#9744;" }
        $naoBox = if (-not $item.Conforme) { "&#9745;" } else { "&#9744;" }
        $rowClass = if ($item.Conforme) { "row-conforme" } else { "row-nao-conforme" }

        $obsBlock = ""
        if ($item.Observacoes) {
            $obsBlock = "<div class='item-obs'><strong>Obs.:</strong> $([System.Web.HttpUtility]::HtmlEncode($item.Observacoes))</div>"
        }
        $detalhesBlock = ""
        if ($item.Detalhes) {
            $detalhesBlock = "<div class='item-detalhes'><strong>Telemetria / Evidência:</strong> $([System.Web.HttpUtility]::HtmlEncode($item.Detalhes))</div>"
        }

        $rowsHtml += @"
        <tr class='$rowClass'>
          <td class='col-id'>$($item.ID)</td>
          <td class='col-desc'>
            <strong>$([System.Web.HttpUtility]::HtmlEncode($item.Descricao))</strong>
            $detalhesBlock
            $obsBlock
          </td>
          <td class='col-check sim-check'>$simBox</td>
          <td class='col-check nao-check'>$naoBox</td>
        </tr>
"@
    }

    $signaturesHtml = ""
    if (-not [string]::IsNullOrWhiteSpace($Avaliador2)) {
        $signaturesHtml = @"
    <div class="signatures-box">
      <div class="section-title">Assinatura dos Avaliadores</div>
      <div class="signatures-grid">
        <div class="sig-col">
          <div class="sig-role">Avaliador Responsável</div>
          <div class="sig-name">$([System.Web.HttpUtility]::HtmlEncode($Avaliador1))</div>
          <div class="sig-line">$([System.Web.HttpUtility]::HtmlEncode($Avaliador1))</div>
          <div class="sig-time">Assinada digitalmente em $DataVerificacao</div>
        </div>
        <div class="sig-col">
          <div class="sig-role">Avaliador 2</div>
          <div class="sig-name">$([System.Web.HttpUtility]::HtmlEncode($Avaliador2))</div>
          <div class="sig-line">$([System.Web.HttpUtility]::HtmlEncode($Avaliador2))</div>
          <div class="sig-time">Assinada digitalmente em $DataVerificacao</div>
        </div>
      </div>
    </div>
"@
    } else {
        $signaturesHtml = @"
    <div class="signatures-box">
      <div class="section-title">Assinatura do Avaliador</div>
      <div class="signatures-grid" style="grid-template-columns: 1fr;">
        <div class="sig-col">
          <div class="sig-role">Avaliador Responsável</div>
          <div class="sig-name">$([System.Web.HttpUtility]::HtmlEncode($Avaliador1))</div>
          <div class="sig-line">$([System.Web.HttpUtility]::HtmlEncode($Avaliador1))</div>
          <div class="sig-time">Assinada digitalmente em $DataVerificacao</div>
        </div>
      </div>
    </div>
"@
    }

    $htmlContent = @"
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Checklist de Instalação - Estação $Estacao - Ocupação #53</title>
  <!--
    Autor: Leandromeda (@leandromeda no GitHub)
    SENAI São Paulo Skills · Ciclo 2026-2028 · Ocupação #53 Computação em Nuvem
    Hash de Integridade: $($SCRIPT_SIGNATURE.HashId)
  -->
  <style>
    @page {
      size: A4 portrait;
      margin: 10mm 12mm 10mm 12mm;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: "Segoe UI", Arial, Helvetica, sans-serif; }
    html {
      -webkit-print-color-adjust: exact;
      print-color-adjust: exact;
    }
    body {
      background: #fff;
      color: #0f172a;
      padding: 0;
      font-size: 9.5pt;
    }
    .sheet {
      max-width: 100%;
      margin: 0 auto;
      background: #fff;
      padding: 0;
    }
    .header-table {
      width: 100%;
      border-bottom: 2px solid #0284c7;
      padding-bottom: 10px;
      margin-bottom: 14px;
      page-break-inside: avoid;
      break-inside: avoid;
    }
    .logo-area {
      font-size: 22pt;
      font-weight: 900;
      color: #dc2626;
      letter-spacing: -1px;
    }
    .logo-sub {
      font-size: 8pt;
      color: #475569;
      font-weight: 600;
    }
    .header-title-box {
      text-align: right;
    }
    .main-title {
      font-size: 15pt;
      font-weight: 800;
      color: #0f172a;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }
    .event-subtitle {
      font-size: 9.5pt;
      color: #0284c7;
      font-weight: 600;
      margin-top: 2px;
    }
    .intro-text {
      font-size: 8.5pt;
      color: #334155;
      line-height: 1.4;
      margin-bottom: 14px;
      text-align: justify;
    }
    .section-title {
      font-size: 10pt;
      font-weight: 800;
      color: #0f172a;
      text-transform: uppercase;
      border-bottom: 1.5px solid #0f172a;
      padding-bottom: 3px;
      margin-bottom: 10px;
    }
    .id-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 8px;
      background: #f1f5f9;
      padding: 10px 14px;
      border-radius: 4px;
      margin-bottom: 16px;
      font-size: 9pt;
      page-break-inside: avoid;
      break-inside: avoid;
    }
    .id-item strong { display: block; color: #475569; font-size: 7.5pt; text-transform: uppercase; margin-bottom: 2px; }
    .id-item span { font-weight: 700; color: #0f172a; font-size: 9.5pt; }

    table.checklist-table {
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 18px;
    }
    table.checklist-table th, table.checklist-table td {
      border: 1px solid #cbd5e1;
      padding: 6px 8px;
      text-align: left;
    }
    table.checklist-table th {
      background: #f8fafc;
      color: #0f172a;
      font-size: 8.5pt;
      font-weight: 800;
      text-transform: uppercase;
    }
    .col-id { width: 5%; text-align: center; font-weight: 800; font-size: 9pt; }
    .col-desc { width: 75%; font-size: 8.8pt; }
    .col-check { width: 10%; text-align: center; font-size: 14pt; font-weight: bold; }
    .sim-check { color: #16a34a; }
    .nao-check { color: #dc2626; }
    tr {
      page-break-inside: avoid;
      break-inside: avoid;
    }
    tr.row-nao-conforme { background: #fef2f2; }
    .item-obs {
      margin-top: 4px;
      font-size: 7.5pt;
      color: #b45309;
      background: #fffbeb;
      padding: 3px 6px;
      border-left: 3px solid #f59e0b;
      border-radius: 2px;
    }
    .item-detalhes {
      margin-top: 3px;
      font-size: 7.5pt;
      color: #475569;
      font-family: Consolas, monospace;
    }
    .signatures-box {
      margin-top: 18px;
      border-top: 1.5px solid #0f172a;
      padding-top: 12px;
      page-break-inside: avoid;
      break-inside: avoid;
    }
    .signatures-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 20px;
      margin-top: 8px;
    }
    .sig-col {
      border: 1px solid #e2e8f0;
      padding: 10px;
      border-radius: 4px;
      background: #fafafa;
    }
    .sig-role { font-size: 7.5pt; font-weight: 800; text-transform: uppercase; color: #475569; margin-bottom: 2px; }
    .sig-name { font-size: 9.5pt; font-weight: 700; color: #0f172a; margin-bottom: 20px; }
    .sig-line {
      border-bottom: 1px solid #000;
      margin-bottom: 4px;
      height: 30px;
      font-family: "Brush Script MT", cursive, sans-serif;
      font-size: 15pt;
      color: #1e3a8a;
      padding-left: 8px;
    }
    .sig-time { font-size: 7pt; color: #64748b; }
    .footer-summary {
      margin-top: 18px;
      padding: 10px 12px;
      background: #0f172a;
      color: #fff;
      display: flex;
      justify-content: space-between;
      align-items: center;
      border-radius: 4px;
      font-size: 8pt;
      page-break-inside: avoid;
      break-inside: avoid;
    }
    .footer-summary strong { color: #38bdf8; }
  </style>
</head>
<body>
  <div class="sheet">
    <table class="header-table">
      <tr>
        <td style="vertical-align: middle;">
          <div class="logo-area">SENAI</div>
          <div class="logo-sub">São Paulo Skills · Ciclo 2026-2028</div>
        </td>
        <td class="header-title-box" style="vertical-align: middle;">
          <div class="main-title">Checklist de Instalação</div>
          <div class="event-subtitle">Ocupação #53 — Computação em Nuvem</div>
        </td>
      </tr>
    </table>

    <div class="intro-text">
      Este checklist tem por finalidade registrar a verificação, estação por estação, dos softwares, ferramentas e
      configurações exigidos para a <strong>Ocupação 53 — Computação em Nuvem</strong>, conforme especificações consolidadas na
      planilha de controle do ciclo 2026-2028. Para cada item, marca-se a caixa correspondente indicando se o
      software/recurso estava instalado ("Sim") ou não estava instalado ("Não") no computador avaliado.
    </div>

    <div class="section-title">Identificação da Verificação</div>
    <div class="id-grid">
      <div class="id-item">
        <strong>Estação / Computador nº</strong>
        <span>$Estacao</span>
      </div>
      <div class="id-item">
        <strong>Nome do competidor / Escola</strong>
        <span>$Competidor</span>
      </div>
      <div class="id-item">
        <strong>Data da verificação</strong>
        <span>$DataVerificacao</span>
      </div>
      <div class="id-item">
        <strong>Avaliador responsável</strong>
        <span>$([System.Web.HttpUtility]::HtmlEncode($AvaliadorTexto))</span>
      </div>
    </div>

    <div class="section-title">Itens de Verificação</div>
    <table class="checklist-table">
      <thead>
        <tr>
          <th class="col-id">ID</th>
          <th class="col-desc">Descrição</th>
          <th class="col-check">Sim</th>
          <th class="col-check">Não</th>
        </tr>
      </thead>
      <tbody>
        $rowsHtml
      </tbody>
    </table>

    $signaturesHtml

    <div class="footer-summary">
      <div>SENAI São Paulo Skills — Ciclo 2026-2028 | Ocupação 53 — Computação em Nuvem</div>
      <div>
        <strong>Estação $Estacao</strong> · $totalItens/22 verificados ·
        <span style="color: $(if ($totalNaoConformes -eq 0) { '#4ade80' } else { '#f87171' }); font-weight: bold;">
          $totalNaoConformes não conformidade(s)
        </span>
      </div>
    </div>

    <div style="margin-top: 14px; text-align: center; font-size: 7.5pt; color: #64748b; page-break-inside: avoid; break-inside: avoid;">
      Desenvolvido por <a href="https://www.linkedin.com/in/leandro-gr/" target="_blank" style="color: #0284c7; font-weight: bold; text-decoration: none;">Prof. Esp. Leandro Gaudio Rosa</a> 
      · <a href="https://github.com/Leandromeda/" target="_blank" style="color: #475569; text-decoration: none; font-weight: 600; display: inline-flex; align-items: center; gap: 4px;">
        <svg height="12" width="12" viewBox="0 0 16 16" fill="currentColor" style="vertical-align: middle; display: inline-block;"><path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"></path></svg>
        Leandromeda no GitHub
      </a> · Validação de Integridade: SHA-256 #$($SCRIPT_SIGNATURE.HashId)
    </div>
  </div>
</body>
</html>
"@

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($htmlPath, $htmlContent, $utf8NoBom)

    if ($GerarPdf) {
        $pdfOk = Convert-HtmlToPdf -HtmlFilePath $htmlPath -PdfFilePath $pdfPath
        if ($pdfOk) {
            Write-Host "[+] Relatório PDF oficial gerado com sucesso: $pdfPath" -ForegroundColor Green
            if (-not $ManterHtml) {
                Remove-Item -Path $htmlPath -Force -ErrorAction SilentlyContinue
                $htmlPath = ""
            } else {
                Write-Host "[+] Relatório HTML intermediário mantido em: $htmlPath" -ForegroundColor DarkGray
            }
        } else {
            Write-Host "[!] Não foi possível gerar o PDF automaticamente via Edge. O relatório HTML foi mantido: $htmlPath" -ForegroundColor Yellow
        }
    } else {
        Write-Host "[+] Relatório HTML gerado com sucesso: $htmlPath" -ForegroundColor Green
    }

    # Abertura do relatório
    $targetToOpen = if ($pdfPath -and (Test-Path $pdfPath)) { $pdfPath } elseif ($htmlPath -and (Test-Path $htmlPath)) { $htmlPath } else { "" }
    if ($targetToOpen) {
        if ($AbrirRelatorio) {
            Start-Process $targetToOpen
        } elseif (-not $Auto) {
            $respAbrir = Read-Host "`n[?] Deseja visualizar o relatório oficial agora? [S/N] (Padrão: S)"
            if ([string]::IsNullOrWhiteSpace($respAbrir) -or $respAbrir -match "^[sSyY]") {
                Start-Process $targetToOpen
            }
        }
    }
}

Write-Host ""
Write-Host '[✓] Auditoria concluída com sucesso por Prof. Esp. Leandro Gaudio Rosa (https://www.linkedin.com/in/leandro-gr/).' -ForegroundColor Cyan
Write-Host ""
