# Summary of changes for run 32898c05-a78d-45f4-984e-83e3476adf9e
Created `Tropical/CoefficientCertificate.lean` — a small, self-contained arithmetic certificate development with no `sorry` and using only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

Contents:
- A module docstring explaining the coefficient-certificate viewpoint (integer coefficient sequences measured by p-adic valuation, with the structural bound computed in the min-plus reading).
- `SpExpr`: the tiny expression language (`one`, `zero`, `add`, `mul`).
- `SpExpr.eval : SpExpr → ℕ → ℤ`: semantics where `one` is the delta sequence at 0, `zero` is identically 0, `add` is pointwise addition, and `mul` is the Cauchy convolution `∑ k ∈ range (n+1), eval e₁ k * eval e₂ (n-k)`. Includes convenience `@[simp]` evaluation lemmas.
- `vp p e n := emultiplicity (p : ℤ) (e.eval n)`: the p-adic valuation profile (valuation of 0 being ⊤).
- `lb : SpExpr → ℕ → ℕ∞`: the structural lower-bound certificate (`one` gives 0 at index 0 and ⊤ otherwise, `zero` gives ⊤, `add` gives `min`, `mul` gives `⨅ k : Fin (n+1), lb e₁ k + lb e₂ (n-k)`).
- Helper lemma `le_emultiplicity_finset_sum`: a finite-sum valuation lower bound proved by induction on the finset using `min_le_emultiplicity_add`.
- Main theorem `lb_le_vp (hp : Nat.Prime p) : ∀ e n, lb e n ≤ vp p e n`, proved by induction on `e`: the `add` case uses the min/sum valuation inequality, and the `mul` case expands the convolution, bounds each summand via `emultiplicity_mul` for the prime `(p : ℤ)` plus the inductive hypotheses, and takes the infimum over `k`.

No species infrastructure, no binomial-convolution language, and no dependence on unavailable catalog files (only `import Mathlib`). The file builds cleanly with no warnings.