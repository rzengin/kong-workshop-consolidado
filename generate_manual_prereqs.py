import os
import re

# Update sh
with open('scripts/install_prereqs.sh', 'r') as f:
    sh_content = f.read()

# Remove terraform and deck logic from sh
sh_content = re.sub(r'\s*if ! command -v deck.*?fi', '', sh_content, flags=re.DOTALL)
sh_content = re.sub(r'\s*if ! command -v terraform.*?fi', '', sh_content, flags=re.DOTALL)
# Remove deck check and terraform check in brew
sh_content = re.sub(r'\s*if ! command -v deck.*?deck ya instalado"; fi', '', sh_content, flags=re.DOTALL)
sh_content = re.sub(r'\s*if ! command -v terraform.*?fi', '', sh_content, flags=re.DOTALL)
# Remove from validation
sh_content = re.sub(r'deck version \|\| echo -e "\$\{RED\}deck falló\$\{NC\}"\n', '', sh_content)
sh_content = re.sub(r'terraform version \| head -n 1 \|\| echo -e "\$\{RED\}terraform falló\$\{NC\}"\n', '', sh_content)

with open('scripts/install_prereqs_manual.sh', 'w') as f:
    f.write(sh_content)
os.chmod('scripts/install_prereqs_manual.sh', 0o755)

# Update bat
with open('scripts/install_prereqs.bat', 'r') as f:
    bat_content = f.read()

bat_content = re.sub(r'WHERE terraform >nul 2>nul\nIF %ERRORLEVEL% NEQ 0 \( winget install --id Hashicorp\.Terraform -e --accept-source-agreements --accept-package-agreements \) ELSE \( ECHO terraform ya instalado \)\n', '', bat_content)
bat_content = re.sub(r'ECHO\.\nECHO Descargando e instalando Kong decK\.\.\.\nIF EXIST "%USERPROFILE%\\bin\\deck\.exe" \(\n    ECHO deck ya instalado\n\) ELSE \(\n    SET DECK_VERSION=1\.59\.1\n    curl -L -o "%USERPROFILE%\\Downloads\\deck\.tar\.gz" "https://github\.com/Kong/deck/releases/download/v1\.59\.1/deck_1\.59\.1_windows_amd64\.tar\.gz"\n    IF NOT EXIST "%USERPROFILE%\\bin" mkdir "%USERPROFILE%\\bin"\n    tar -xzf "%USERPROFILE%\\Downloads\\deck\.tar\.gz" -C "%USERPROFILE%\\bin"\n    setx PATH "%PATH%;%USERPROFILE%\\bin"\n\)\n', '', bat_content)
bat_content = bat_content.replace('"%USERPROFILE%\\bin\\deck.exe" version\n', '')
bat_content = bat_content.replace('terraform version\n', '')

with open('scripts/install_prereqs_manual.bat', 'w') as f:
    f.write(bat_content)

# Update ps1
with open('scripts/install_prereqs.ps1', 'r') as f:
    ps1_content = f.read()

ps1_content = re.sub(r'if \(!\(Get-Command terraform -ErrorAction SilentlyContinue\)\) { winget install --id Hashicorp\.Terraform -e --accept-source-agreements --accept-package-agreements } else { Write-Host \'terraform ya instalado\' }\n', '', ps1_content)
ps1_content = re.sub(r'Write-Host ""\nWrite-Host -ForegroundColor Green "Descargando e instalando Kong decK\.\.\."\nif \(!\(Test-Path "\$HOME\\bin\\deck\.exe"\)\) \{[\s\S]*?\} else \{\n    Write-Host "deck ya instalado"\n\}\n', '', ps1_content)
ps1_content = ps1_content.replace('& "$HOME\\bin\\deck.exe" version\n', '')
ps1_content = ps1_content.replace('terraform version\n', '')

with open('scripts/install_prereqs_manual.ps1', 'w') as f:
    f.write(ps1_content)

# Update markdown
with open('Guia_Paso_a_Paso_Manual.md', 'r') as f:
    md_content = f.read()

md_content = md_content.replace('./scripts/install_prereqs.sh', './scripts/install_prereqs_manual.sh')
md_content = md_content.replace('.\\scripts\\install_prereqs.bat', '.\\scripts\\install_prereqs_manual.bat')
md_content = md_content.replace('.\\scripts\\install_prereqs.ps1', '.\\scripts\\install_prereqs_manual.ps1')

with open('Guia_Paso_a_Paso_Manual.md', 'w') as f:
    f.write(md_content)

