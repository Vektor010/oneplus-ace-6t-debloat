import os
import re
import sys

repo_dir = r"C:\Users\User\Documents\oneplus-ace-6t-debloat"
errors = []

link_pattern = re.compile(r'\[([^\]]+)\]\(([^)]+)\)')

for root, dirs, files in os.walk(repo_dir):
    # skip .git or node_modules if any
    for f in files:
        if f.endswith(".md") or f.endswith(".yml"):
            filepath = os.path.join(root, f)
            rel_doc = os.path.relpath(filepath, repo_dir)
            with open(filepath, "r", encoding="utf-8", errors="ignore") as file:
                lines = file.readlines()

            for line_idx, line in enumerate(lines, 1):
                # find markdown links
                matches = link_pattern.findall(line)
                for text, target in matches:
                    # skip external URLs and anchors
                    if target.startswith("http://") or target.startswith("https://") or target.startswith("#") or target.startswith("mailto:"):
                        continue
                    # split anchor if any (e.g. file.md#section)
                    target_file = target.split("#")[0]
                    if not target_file:
                        continue
                    # resolve target relative to current document folder
                    doc_dir = os.path.dirname(filepath)
                    resolved = os.path.normpath(os.path.join(doc_dir, target_file))
                    if not os.path.exists(resolved):
                        errors.append(f"{rel_doc}:{line_idx} Broken link: [{text}]({target}) -> Resolved: {resolved}")

print("======================================================================")
print("             MARKDOWN & CONFIG RELATIVE LINK VALIDATION              ")
print("======================================================================")
if not errors:
    print("✓ PASS: All relative markdown and configuration links resolved successfully.")
    sys.exit(0)
else:
    print(f"✗ FAIL: Discovered {len(errors)} broken relative link(s):")
    for err in errors:
        print("  -", err)
    sys.exit(1)
