from pathlib import Path
import re, sys

ROOT = Path(__file__).resolve().parents[1]
errors = []

for p in ROOT.rglob("*.gd"):
    text = p.read_text(encoding="utf-8", errors="replace")
    if re.search(r"\bfunc\s*\(", text):
        errors.append(f"anonymous lambda: {p.relative_to(ROOT)}")
    if re.search(r"(^|\n)\s*var\s+[A-Za-z_]\w*\s*:=", text):
        errors.append(f"untyped :=: {p.relative_to(ROOT)}")

pairs = {"(": ")", "[": "]", "{": "}"}
for p in ROOT.rglob("*.gd"):
    s = p.read_text(encoding="utf-8", errors="replace")
    stack, line, i = [], 1, 0
    in_string = False
    quote = ""
    escape = False
    comment = False
    while i < len(s):
        c = s[i]
        if c == "\n":
            line += 1
            comment = False
            escape = False
            i += 1
            continue
        if comment:
            i += 1
            continue
        if in_string:
            if escape:
                escape = False
            elif c == "\\":
                escape = True
            elif c == quote:
                in_string = False
            i += 1
            continue
        if c == "#":
            comment = True
            i += 1
            continue
        if c in ("\"", "'"):
            in_string = True
            quote = c
            i += 1
            continue
        if c in pairs:
            stack.append((c, line))
        elif c in pairs.values():
            if not stack or pairs[stack[-1][0]] != c:
                errors.append(f"delimiter mismatch: {p.relative_to(ROOT)}:{line}")
                break
            stack.pop()
        i += 1
    if stack:
        errors.append(f"unclosed delimiter: {p.relative_to(ROOT)}:{stack[-1][1]}")

if errors:
    print("FAIL")
    print("\n".join(errors))
    sys.exit(1)
print("HELLO STRANGER STATIC VALIDATION: PASS")
