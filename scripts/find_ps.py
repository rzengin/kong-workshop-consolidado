import os
os.chdir(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from docx import Document
import sys

doc = Document(sys.argv[1])
for i, p in enumerate(doc.paragraphs):
    if 'power' in p.text.lower() or 'ps1' in p.text.lower():
        print(f"Para {i}: {p.text}")
