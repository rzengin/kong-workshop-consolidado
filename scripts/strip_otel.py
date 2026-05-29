import os
os.chdir(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import glob

files = glob.glob('archivos-deck/*.yaml') + ['00-estado-base-external.yaml', '00-estado-base-internal.yaml', 'solucion-kong.yaml']

for file in files:
    if "00-b4-estado-base-global.yaml" in file:
        continue

    with open(file, 'r') as f:
        lines = f.readlines()
        
    new_lines = []
    skip = False
    in_plugins = False
    for line in lines:
        if line.startswith("plugins:"):
            in_plugins = True
            new_lines.append(line)
            continue
            
        if in_plugins and line.strip() == "- name: opentelemetry":
            skip = True
            continue
            
        if skip:
            if line.startswith("  - name:") or line.startswith("services:") or line.startswith("consumers:") or line.startswith("upstreams:") or not line.startswith(" "):
                # Next block started
                skip = False
                in_plugins = False
            else:
                continue
                
        if not skip:
            # If we just left the plugins block and it's empty, we should ideally remove "plugins:". 
            # We'll clean that up later if needed.
            new_lines.append(line)
            
    # Remove empty "plugins:" block if it's there
    cleaned_lines = []
    i = 0
    while i < len(new_lines):
        if new_lines[i].startswith("plugins:"):
            # Check if next line is another top-level key or EOF or empty
            is_empty = True
            for j in range(i+1, len(new_lines)):
                if new_lines[j].strip() == "":
                    continue
                if new_lines[j].startswith("  -"):
                    is_empty = False
                    break
                if not new_lines[j].startswith(" "):
                    break
            if is_empty:
                i += 1
                continue
        cleaned_lines.append(new_lines[i])
        i += 1
        
    with open(file, 'w') as f:
        f.writelines(cleaned_lines)
        
print("Stripped opentelemetry from non-global files.")
