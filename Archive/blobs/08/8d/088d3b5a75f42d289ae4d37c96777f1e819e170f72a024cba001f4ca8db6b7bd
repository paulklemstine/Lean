# Summary of changes for run 3622f540-3cd3-41a6-8f2a-81eb960a9b52
Created a standalone, no-sorry Lean 4 formalization at `Tropical/CoefficientCertificate.lean` (module `Tropical.CoefficientCertificate`), a coefficient-level abstraction of the species/tropical idea that imports only Mathlib (no species infrastructure).

Contents:
- `SpExpr` — the syntax `inductive SpExpr | one | zero | add | mul`.
- `SpExpr.eval : SpExpr → ℕ → ℤ` — integer coefficient-sequence semantics, with `add` pointwise and `mul` as ordinary finite convolution `∑ k ∈ range (n+1), eval e₁ k * eval e₂ (n-k)` (plain convolution chosen over the binomial variant, since the binomial factor only raises valuations and adds needless overhead; this is the arithmetic core certificate). Includes `@[simp]` evaluation lemmas.
- `vp p e n := emultiplicity (p:ℤ) (eval e n)` — the p-adic valuation profile in `ℕ∞`.
- `lb : SpExpr → ℕ → ℕ∞` — the structural tropical lower bound: `one ↦ 0`, `zero ↦ ⊤`, `add ↦ min`, `mul ↦ Finset.inf'` of `lb e₁ k + lb e₂ (n-k)` over `range (n+1)`.

Supporting lemmas and proof structure (as requested):
1. Base cases handled via `emultiplicity_eq_zero`/`hp.not_dvd_one` (for 1) and `emultiplicity_zero` (for 0).
2. Addition lower bound via Mathlib's `min_le_emultiplicity_add`.
3. Product additivity via `emultiplicity_mul` (equality, since p is prime).
4. `le_emultiplicity_sum` — a finite-sum lower bound proved by `Finset.induction` combining the min/add lemmas.
5. Main theorem `lb_le_vp : ∀ (p) (hp : p.Prime) (e) (n), lb e n ≤ vp p e n`, proved by structural induction on `e`, with the `mul` case bounding each convolution summand (via the induction hypotheses and `Finset.inf'_le`) and applying the finite-sum lower bound.

The target module builds successfully and `#print axioms SpExpr.lb_le_vp` reports only `[propext, Classical.choice, Quot.sound]`; a grep confirms no `sorry`. (Note: the surrounding project's default build targets reference some pre-existing missing files unrelated to this work, e.g. `Algebra/SumThreeCubes/Defs.lean`, so verification was done by building this module directly.)