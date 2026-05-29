import re
import subprocess
import os

with open('Guia_Paso_a_Paso_Manual.md', 'r') as f:
    content = f.read()

# Find all mermaid blocks
pattern = r'```mermaid\n(.*?)\n```'
matches = re.finditer(pattern, content, re.DOTALL)

new_content = content
for i, match in enumerate(matches):
    mmd_code = match.group(1)
    mmd_filename = f'diagram_{i}.mmd'
    png_filename = f'diagram_{i}.png'
    
    with open(mmd_filename, 'w') as f:
        f.write(mmd_code)
    
    print(f"Generating image for diagram {i}...")
    subprocess.run(['npx', '-y', '@mermaid-js/mermaid-cli', '-i', mmd_filename, '-o', png_filename, '-b', 'transparent', '-s', '2'])
    
    # Replace in new_content
    original_block = match.group(0)
    new_content = new_content.replace(original_block, f'![Diagrama {i}]({png_filename})')

# Write temporary markdown
with open('Guia_Paso_a_Paso_Manual_temp.md', 'w') as f:
    f.write(new_content)

print("Generating PDF from modified markdown...")
subprocess.run(['npx', 'md-to-pdf', 'Guia_Paso_a_Paso_Manual_temp.md'])

# Rename PDF
if os.path.exists('Guia_Paso_a_Paso_Manual_temp.pdf'):
    os.rename('Guia_Paso_a_Paso_Manual_temp.pdf', 'Guia_Paso_a_Paso_Manual.pdf')

# Cleanup
os.remove('Guia_Paso_a_Paso_Manual_temp.md')
for i in range(len(list(re.finditer(pattern, content, re.DOTALL)))):
    if os.path.exists(f'diagram_{i}.mmd'): os.remove(f'diagram_{i}.mmd')
    if os.path.exists(f'diagram_{i}.png'): os.remove(f'diagram_{i}.png')

print("Done generating Guia_Paso_a_Paso_Manual.pdf with Mermaid images.")
