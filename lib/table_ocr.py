#!/usr/bin/env python3

import os
import sys
from pypdf import PdfReader
arg = sys.argv[1]

reader = PdfReader(arg)
all_text = ""
for page in reader.pages:
    # Extract text preserving horizontal positioning without excess vertical whitespace
    text = page.extract_text(extraction_mode="layout", layout_mode_space_vertically=False)
    all_text += text + "\n"
print(all_text)
