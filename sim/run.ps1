# Runs the self-checking pipeline tests with Vivado's simulator (xsim).
# Usage (from any folder):  powershell -File sim\run.ps1 [-VivadoBin C:\Xilinx\Vivado\2024.2\bin]
param(
    [string]$VivadoBin = "C:\Xilinx\Vivado\2024.2\bin"
)

$ErrorActionPreference = "Stop"
$sim  = $PSScriptRoot
$root = Split-Path $sim -Parent
$build = Join-Path $sim "build"
New-Item -ItemType Directory -Force $build | Out-Null
Push-Location $build
try {
    $sources = @(
        "Main_module.v", "Fetch.v", "Decode.v", "ALU.v", "ALU_register.v",
        "hazard_unit.v", "writeback.v", "CPI calculator.v", "7_segment.v"
    ) | ForEach-Object { Join-Path $root $_ }
    $sources += (Join-Path $sim "ip_models.v"), (Join-Path $sim "tb_checks.v")

    & "$VivadoBin\xvlog.bat" $sources | Out-File compile.log
    if ($LASTEXITCODE -ne 0) { Get-Content compile.log; throw "xvlog failed" }
    & "$VivadoBin\xelab.bat" tb_checks -debug typical -s tb_checks | Out-File elab.log
    if ($LASTEXITCODE -ne 0) { Get-Content elab.log; throw "xelab failed" }

    $tests = @(
        @{ name = "load_use";   prog = "load_use.hex" },
        @{ name = "halt";       prog = "halt.hex" },
        @{ name = "branch_r1";  prog = "branch_r1.hex" },
        @{ name = "test_coe";   prog = "test_coe.hex" }
    )
    foreach ($t in $tests) {
        # xsim.bat splits arguments on '=', so plusargs go through an options file,
        # and the program is copied here so its path has no spaces.
        Copy-Item (Join-Path $sim "programs\$($t.prog)") "prog.hex" -Force
        "-testplusarg TEST=$($t.name) -testplusarg PROG=prog.hex" | Out-File -Encoding ascii "args.txt"
        & "$VivadoBin\xsim.bat" tb_checks -R -f args.txt |
            Select-String -Pattern "^(TEST|RESULT|  (PASS|FAIL|state|\())" | ForEach-Object { $_.Line }
    }
}
finally {
    Pop-Location
}
