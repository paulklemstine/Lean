#!/usr/bin/env python3
"""Repair tool for the auto-generated `Shared/` catalog files.

Two mechanical defects are fixed:

* the module docstring is emitted before `import Mathlib` (illegal in Lean 4),
* declarations are emitted in an arbitrary order, so a declaration may use a
  definition or lemma that appears later in the same file, and some base
  definitions are missing altogether.

The script normalises the header, topologically sorts the declaration blocks by
their dependencies (stably, so the original order is kept whenever possible) and
inserts the missing base declarations listed in `BASE` when a file refers to
them without defining them.
"""
import re
import sys

BASE = {
    "one_plus_exp_pos": """/-- 1 + eˣ > 0 for all x -/
lemma one_plus_exp_pos (x : ℝ) : (1 : ℝ) + Real.exp x > 0 := by
  linarith [Real.exp_pos x]""",
    "softplus": """/-- Softplus(x) = log (1 + eˣ). -/
def softplus (x : ℝ) : ℝ := Real.log (1 + Real.exp x)""",
    "logisticSigmoid": """/-- The logistic sigmoid function S(x) = eˣ / (1 + eˣ). -/
def logisticSigmoid (x : ℝ) : ℝ := Real.exp x / (1 + Real.exp x)""",
    "spb": """/-- The velocity-addition ("speed boost") law. -/
def spb (x y : ℝ) : ℝ := (x + y) / (1 - x * y)""",
    "IsPythTriple": """/-- `(a, b, c)` is a Pythagorean triple. -/
def IsPythTriple (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2""",
    "quatNorm": """/-- The norm form of the Lipschitz quaternions. -/
def quatNorm (a b c d : ℤ) : ℤ := a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2""",
    "cayley": """/-- The Cayley transform maps a real number to a point on the unit circle
in the complex plane: `cayley(x) = (1 + ix)/(1 - ix)`. -/
def cayley (x : ℝ) : ℂ := (1 + x * Complex.I) / (1 - x * Complex.I)""",
    "spbH": """/-- The hyperbolic (Einstein) velocity-addition law. -/
def spbH (u v : ℝ) : ℝ := (u + v) / (1 + u * v)""",
    "crossRatio": """/-- The cross ratio of four real numbers. -/
def crossRatio (a b c d : ℝ) : ℝ := ((a - c) * (b - d)) / ((a - d) * (b - c))""",
    "spb_zero_right": """/-- Zero is a right identity for `spb`. -/
theorem spb_zero_right (x : ℝ) : spb x 0 = x := by unfold spb; simp""",
    "spb_zero_left": """/-- Zero is a left identity for `spb`. -/
theorem spb_zero_left (x : ℝ) : spb 0 x = x := by unfold spb; simp""",
    "cauchy_pullback": """/-- The Cauchy pull-back identity for `spb`. -/
theorem cauchy_pullback (x a : ℝ) (h : 1 - x * a ≠ 0) :
    (1 + spb x a ^ 2) * (1 - x * a) ^ 2 = (1 + a ^ 2) * (1 + x ^ 2) := by
  unfold spb; field_simp; ring""",
    "tan_add_eq_spb": """/-- The tangent addition formula is the `spb` law. -/
theorem tan_add_eq_spb (a b : ℝ) (ha : Real.cos a ≠ 0) (hb : Real.cos b ≠ 0) :
    Real.tan (a + b) = spb (Real.tan a) (Real.tan b) := by
  unfold spb
  rw [Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos,
    Real.sin_add, Real.cos_add]
  rcases eq_or_ne (Real.cos a * Real.cos b - Real.sin a * Real.sin b) 0 with h | h
  · rw [h]
    have h2 : 1 - Real.sin a / Real.cos a * (Real.sin b / Real.cos b) = 0 := by
      field_simp
      linarith [h]
    rw [h2]
    simp
  · field_simp""",
    "spbMat": """/-- The `spb` matrix `M(a) = !![1, a; -a, 1]`. -/
def spbMat (a : ℝ) : Matrix (Fin 2) (Fin 2) ℝ := !![1, a; -a, 1]""",
    "spbMat_trace": """/-- The trace of the `spb` matrix. -/
theorem spbMat_trace (a : ℝ) : (spbMat a).trace = 2 := by
  simp [spbMat, Matrix.trace_fin_two]; norm_num""",
    "spbMat_det": """/-- The determinant of the `spb` matrix. -/
theorem spbMat_det (a : ℝ) : (spbMat a).det = 1 + a ^ 2 := by
  simp [spbMat, Matrix.det_fin_two]; ring""",
    "eml": """/-- The EML (exp-minus-log) operation `eml x y = eˣ - log y`. -/
def eml (x y : ℝ) : ℝ := Real.exp x - Real.log y""",
    "emlDiag": """/-- The diagonal of the EML operation, `emlDiag z = e^z - log z`. -/
def emlDiag (z : ℝ) : ℝ := Real.exp z - Real.log z""",
    "IsPythTriple'": """/-- `(a, b, c)` is a Pythagorean triple. -/
def IsPythTriple' (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2""",
}

# Fully qualified names that the generator emitted unqualified or under a
# namespace that the file does not open.
RENAME = [
    (r"(?<![\w.])SPB\.", ""),
]

DECL_RE = re.compile(
    r"^(?:noncomputable\s+|private\s+|protected\s+|@\[[^\]]*\]\s*)*"
    r"(def|theorem|lemma|abbrev|instance|structure|inductive|example)\s+"
    r"([A-Za-z_][A-Za-z0-9_'.]*)?")
IDENT_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_'.]*")
COMMENT_RE = re.compile(r"/-.*?-/", re.S)


def strip_comments(text):
    return re.sub(r"--.*", "", COMMENT_RE.sub(" ", text))


def split_header(lines):
    """Return (imports, doc, rest) with the module docstring moved after imports."""
    imports, doc = [], []
    i, n = 0, len(lines)
    while i < n:
        line = lines[i]
        if line.startswith("import "):
            imports.append(line)
            i += 1
        elif line.strip() == "":
            i += 1
        elif line.startswith("/-!"):
            while i < n:
                doc.append(lines[i])
                if "-/" in lines[i]:
                    i += 1
                    break
                i += 1
        else:
            break
    return imports, doc, lines[i:]


def parse_blocks(lines):
    """Split a declaration body into blocks, each running to the next one."""
    starts = []
    in_doc = False
    awaiting_decl = False  # a doc comment was seen, its declaration follows
    for i, line in enumerate(lines):
        if in_doc:
            if "-/" in line:
                in_doc = False
            continue
        if line.startswith("/--"):
            starts.append(i)
            awaiting_decl = True
            if "-/" not in line:
                in_doc = True
            continue
        if DECL_RE.match(line):
            if awaiting_decl:
                awaiting_decl = False
                continue  # belongs to the doc comment that opened this block
            starts.append(i)
    if not starts:
        return lines, []
    blocks = []
    for k, s in enumerate(starts):
        e = starts[k + 1] if k + 1 < len(starts) else len(lines)
        blocks.append(lines[s:e])
    return lines[:starts[0]], blocks


def block_name(block):
    for line in block:
        m = DECL_RE.match(line)
        if m:
            return m.group(2)
    return None


def block_names(blocks):
    names = {}
    for idx, b in enumerate(blocks):
        nm = block_name(b)
        if nm is not None and nm not in names:
            names[nm] = idx
    return names


def toposort(blocks):
    names = block_names(blocks)
    deps = []
    for idx, b in enumerate(blocks):
        body = strip_comments("\n".join(b))
        d = set()
        for ident in IDENT_RE.findall(body):
            for cand in {ident, ident.split(".")[0]}:
                j = names.get(cand)
                if j is not None and j != idx:
                    d.add(j)
        deps.append(d)
    order, state = [], [0] * len(blocks)

    def visit(i, stack):
        if state[i] == 2 or i in stack:
            return
        state[i] = 1
        for j in sorted(deps[i]):
            visit(j, stack | {i})
        state[i] = 2
        order.append(i)

    for i in range(len(blocks)):
        visit(i, frozenset())
    return [blocks[i] for i in order], set(names)


def needed_opens(text):
    opens = []
    if re.search(r"(?<![\w.])(cos|sin|tan|arctan|exp|log|sqrt)\b", text):
        opens.append("open Real")
    if re.search(r"(?<![\w.])(det_fin_two|det_mul|mul_apply|det_one)\b", text):
        opens.append("open Matrix")
    if re.search(r"(?<![\w.])(Ioi|Ioo|Icc|Ico|Ioc)\b", text):
        opens.append("open Set")
    return opens


def main(path):
    src = open(path).read()
    for pat, rep in RENAME:
        src = re.sub(pat, rep, src)
    lines = src.split("\n")
    imports, doc, rest = split_header(lines)
    if not imports:
        imports = ["import Mathlib"]
    while rest and rest[-1].strip() == "":
        rest.pop()
    while rest and rest[-1].strip() == "end":
        rest.pop()
        while rest and rest[-1].strip() == "":
            rest.pop()
    prefix, blocks = parse_blocks(rest)
    nscopes = sum(1 for l in prefix
                  if re.match(r"^(noncomputable\s+)?(section|namespace)\b", l))
    tail = ["end"] * nscopes
    defined = set(block_names(blocks))
    text = strip_comments("\n".join(sum(blocks, [])))
    changed = True
    while changed:
        changed = False
        for nm, snippet in BASE.items():
            if nm not in defined and re.search(r"(?<![\w.])%s(?![\w'])" % re.escape(nm), text):
                blocks.append(snippet.split("\n"))
                defined.add(nm)
                text += "\n" + snippet
                changed = True
    opens = needed_opens(text)
    blocks, _ = toposort(blocks)
    extra = []
    out = imports + [""] + doc + [""] + opens
    if opens:
        out.append("")
    out += [l for l in prefix if l.strip() != ""]
    out.append("")
    for b in extra + blocks:
        while b and b[-1].strip() == "":
            b.pop()
        out += b
        out.append("")
    out += tail
    open(path, "w").write("\n".join(out) + "\n")


if __name__ == "__main__":
    for p in sys.argv[1:]:
        main(p)
