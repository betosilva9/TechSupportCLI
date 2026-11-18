
# ========================================
# TECHSUPPORT CLI - VERSAO 1.0
# Manutencao e diagnostico Windows
# ========================================

# 1 - DIAGNOSTICO



# VERIFICAR PERMISSAO DE ADMINISTRADOR

$identidade = [Security.Principal.WindowsIdentity]::GetCurrent()

$principal = New-Object Security.Principal.WindowsPrincipal($identidade)

$admin = $principal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if (-not $admin) {
    Write-Host "Solicitando permissao de administrador..." -ForegroundColor Yellow

    $argumentos = @(
        "-NoProfile"
        "-File"
        "`"$PSCommandPath`""
    )

    try {
        Start-Process -FilePath "powershell.exe" `
            -ArgumentList $argumentos `
            -Verb RunAs `
            -ErrorAction Stop

        exit
    }
    catch {
        Write-Host "Permissao negada ou elevacao cancelada." -ForegroundColor Red
        Read-Host "Pressione Enter para sair"
        exit
    }
}

function Diagnosticar-PC {
    Write-Host "`n=== DIAGNOSTICO DO COMPUTADOR ===" -ForegroundColor Cyan

    Get-CimInstance Win32_Processor |
        Select-Object Name | Format-List

    Get-CimInstance Win32_ComputerSystem |
        Select-Object Manufacturer, Model,
            @{Name="RAM_GB";Expression={
                [math]::Round($_.TotalPhysicalMemory / 1GB, 2)
            }} | Format-List

    Get-Volume |
        Where-Object DriveLetter |
        Select-Object DriveLetter, FileSystem,
            @{Name="Livre_GB";Expression={
                [math]::Round($_.SizeRemaining / 1GB, 2)
            }} | Format-Table -AutoSize
}

# 2 - REPARAR WINDOWS
function Reparar-Windows {
    Write-Host "`n=== REPARAR WINDOWS ===" -ForegroundColor Yellow

    DISM.exe /Online /Cleanup-Image /RestoreHealth

    if ($LASTEXITCODE -ne 0) {
        Write-Host "DISM apresentou erro. Verifique o resultado." -ForegroundColor Red
        return
    }

    sfc.exe /scannow

    Write-Host "Verificacao concluida. Confira o resultado acima."
}

# 3 - LIMPAR TEMPORARIOS
function Limpar-Temporarios {
    Write-Host "`n=== LIMPEZA DE TEMPORARIOS ===" -ForegroundColor Cyan

    $limite = (Get-Date).AddDays(-7)

    $arquivos = @(
        Get-ChildItem -LiteralPath $env:TEMP -File -Force `
            -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -lt $limite }
    )

    Write-Host "Arquivos encontrados: $($arquivos.Count)"

    $confirmar = Read-Host "Deseja excluir? (S/N)"

    if ($confirmar -eq "S") {
        $removidos = 0

        foreach ($arquivo in $arquivos) {
            try {
                Remove-Item -LiteralPath $arquivo.FullName `
                    -Force -ErrorAction Stop
                $removidos++
            }
            catch {
                Write-Host "Nao removido: $($arquivo.Name)"
            }
        }

        Write-Host "Arquivos removidos: $removidos" -ForegroundColor Green
    }
    else {
        Write-Host "Limpeza cancelada."
    }
}

# 4 - ATUALIZAR DRIVERS
function Atualizar-Drivers {
    Write-Host "`n=== ATUALIZAR DRIVERS ===" -ForegroundColor Cyan

    Start-Process "ms-settings:windowsupdate"
    Write-Host "Verifique as atualizacoes e os drivers opcionais."
}

# 5 - OTIMIZAR DISCO
function Otimizar-Disco {
    Write-Host "`n=== OTIMIZAR DISCO ===" -ForegroundColor Cyan

    $confirmar = Read-Host "Otimizar unidade $env:SystemDrive ? (S/N)"

    if ($confirmar -eq "S") {
        defrag.exe $env:SystemDrive /O /U /V
        Write-Host "Operacao finalizada."
    }
    else {
        Write-Host "Operacao cancelada."
    }
}

# 6 - VERIFICAR DISCO
function Verificar-Disco {
    Write-Host "`n=== VERIFICAR DISCO ===" -ForegroundColor Cyan

    chkdsk.exe $env:SystemDrive /scan

    Write-Host "Verificacao finalizada."
}

# VERIFICAR PERMISSAO DE ADMINISTRADOR
function Testar-Administrador {
    $identidade = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identidade)

    return $principal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
}

# MENU PRINCIPAL
do {
    Clear-Host

    Write-Host "========================================" -ForegroundColor Blue
    Write-Host "          TECHSUPPORT CLI v1.0          " -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Blue

    Write-Host "1 - Diagnosticar computador"
    Write-Host "2 - Reparar Windows"
    Write-Host "3 - Limpar arquivos temporarios"
    Write-Host "4 - Atualizar drivers (Windows Update)"
    Write-Host "5 - Otimizar HDD / SSD"
    Write-Host "6 - Verificar integridade do disco"
    Write-Host "0 - Sair"

    Write-Host "========================================" -ForegroundColor Blue

    $opcao = Read-Host "Escolha uma opcao"

    switch ($opcao) {
        "1" {
            Diagnosticar-PC
        }
        "2" {
            if (Testar-Administrador) {
                Reparar-Windows
            }
            else {
                Write-Host "Execute como administrador!" -ForegroundColor Red
            }
        }
        "3" {
            Limpar-Temporarios
        }
        "4" {
            Atualizar-Drivers
        }
        "5" {
            if (Testar-Administrador) {
                Otimizar-Disco
            }
            else {
                Write-Host "Execute como administrador!" -ForegroundColor Red
            }
        }
        "6" {
            if (Testar-Administrador) {
                Verificar-Disco
            }
            else {
                Write-Host "Execute como administrador!" -ForegroundColor Red
            }
        }
        "0" {
            Write-Host "Encerrando TechSupport CLI..."
        }
        default {
            Write-Host "Opcao invalida!" -ForegroundColor Red
        }
    }

    if ($opcao -ne "0") {
        Read-Host "`nPressione Enter para continuar"
    }

} while ($opcao -ne "0")
