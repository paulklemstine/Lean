# Computational Evidence — EML Complexity / Kolmogorov Bound

Concise sanity checks done before/while formalizing
`EML/KolmogorovComplexityBound.lean` and `EML/ComplexityDensityBridge.lean`.

## 1. Constant-free terms of bounded size: small cases

Counting constant-free EML terms (`var, +, ×, exp, log`) by `size` (node count):

| size n | terms of size exactly n |
|-------:|------------------------:|
| 1 | 1 (`var`) |
| 2 | 2 (`exp var`, `log var`) |
| 3 | 1 (`var+var = var*var`? distinct as terms) → `var+var`, `var*var`, `exp(exp var)`, `exp(log var)`, `log(exp var)`, `log(log var)` |

The exact term count is Catalan-like and clearly **finite at each size** — this is what
`finite_termsLE` proves. The key qualitative fact (all that the Kolmogorov argument needs) is
finiteness, not the exact count, so we formalize finiteness via the constructor inclusion
`{t | size ≤ n+1} ⊆ {var} ∪ image2 add S S ∪ image2 mul S S ∪ expOf '' S ∪ logOf '' S`.

## 2. Why the constant leaf had to be dropped

With a real-valued `const c` leaf, `{t | size ≤ 1} ⊇ {const c : c ∈ ℝ}` is already
**uncountable**, so `finite_termsLE` would be FALSE. Counterexample-hunt outcome: any finite
description alphabet works; reals as leaves break counting. Hence the constant-free algebra.

## 3. Generators are EML-computable with linear size

`expBasis k = exp(var + ⋯ + var)` (`k+1` copies):
- `eval (expBasis k) = (x ↦ e^{(k+1)x})`  — verified symbolically (`repAdd_eval`, `expBasis_eval`).
- `size (expBasis k) = 2k+2`  — verified (`expBasis_size`), giving `K(e^{(k+1)x}) ≤ 2k+2`.

Spot check: `k=0`: `exp(var)`, size 2, `e^{1·x}`. `k=1`: `exp(var+var)`, size 4, `e^{2x}`.
Both match `2k+2`.

## 4. Incompressibility, conceptually

`computableLE n` is the image of the finite set `termsLE n` under `eval`, hence finite; but
`ℝ → ℝ` is infinite (constants inject). So `(computableLE n)ᶜ` is always nonempty
(`exists_incompressible`). No counterexample to incompressibility exists by construction.

## 5. No OEIS sequence claimed

The exact size-count sequence is a weighted Catalan variant; we deliberately do not assert a
specific OEIS ID, since the formal results depend only on finiteness, not the closed form
(left as Future Direction 4).
