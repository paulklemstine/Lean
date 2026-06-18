Formalize a small, self-contained arithmetic certificate theorem in Lean 4.

Target file: `Catalog/Tropical/CoefficientCertificate.lean`

Do not use any species infrastructure. Do not mention binomial convolution. Work only with a tiny expression language and p-adic valuation lower bounds on integer coefficient sequences.

Define:

1. `inductive SpExpr`
   - `one`
   - `zero`
   - `add (e₁ e₂ : SpExpr)`
   - `mul (e₁ e₂ : SpExpr)`

2. `SpExpr.eval : SpExpr → ℕ → ℤ`
   with semantics:
   - `one` is the delta sequence at 0: coefficient 1 at 0 and 0 elsewhere
   - `zero` is identically 0
   - `add` is pointwise addition
   - `mul` is ordinary Cauchy convolution:
     `eval (mul e₁ e₂) n = ∑ k in Finset.range (n+1), eval e₁ k * eval e₂ (n-k)`

3. For a fixed prime integer `p`, define
   `vp (p : ℕ) (e : SpExpr) (n : ℕ) : ℕ∞ := emultiplicity (p : ℤ) (e.eval n)`
   Assume primality through hypotheses on the main lemmas, e.g. `Nat.Prime p`.

4. Define a structural lower bound
   `lb : SpExpr → ℕ → ℕ∞`
   by recursion:
   - `lb one 0 = 0`
   - `lb one (n+1) = ⊤`
   - `lb zero n = ⊤`
   - `lb (add e₁ e₂) n = min (lb e₁ n) (lb e₂ n)`
   - `lb (mul e₁ e₂) n = ⨅ k : Fin (n+1), (lb e₁ k) + (lb e₂ (n-k))`
     or an equivalent finite infimum over `Finset.range (n+1)` if that is easier to formalize.

Main theorem:

`theorem lb_le_vp (hp : Nat.Prime p) : ∀ e n, lb e n ≤ vp p e n`

Required proof strategy:
- Induction on `e`
- For `add`, use the valuation inequality for sums:
  `min (vp of lhs) (vp of rhs) ≤ vp of sum`
- For `mul`, expand the convolution and prove a finite-sum lower-bound lemma:
  every summand has valuation at least `(lb e₁ k) + (lb e₂ (n-k))`, hence the whole sum has valuation at least the infimum over k.
- Use only existing arithmetic lemmas from Mathlib about `emultiplicity`, divisibility/valuation of sums and products, and finite sums.

Important simplifications:
- If exact multiplicativity for `emultiplicity` over multiplication is awkward, a lower bound `vp(a) + vp(b) ≤ vp(a*b)` is sufficient.
- If a direct `iInf` formulation over `Fin (n+1)` is cumbersome, define the multiplicative lower bound using a finite `Finset.inf'`-style construction or any equivalent finite minimum in `ℕ∞` that is convenient in Lean.
- The theorem should be complete and compile with no `sorry`.

What to include in the file:
- brief module docstring explaining the coefficient-certificate viewpoint
- the syntax, semantics, valuation profile, structural lower bound
- auxiliary lemmas for `one`, `zero`, finite sums, and products as needed
- the final theorem `lb_le_vp`

What to avoid:
- no species definitions
- no unformalized tropical rhetoric beyond the lower-bound interpretation
- no dependence on unavailable catalog files unless they are actually imported
- no partial proof skeleton; the main theorem must be finished

If necessary, slightly adapt the precise shape of `lb` so long as it remains a genuine structural lower bound and the final theorem is proved completely.