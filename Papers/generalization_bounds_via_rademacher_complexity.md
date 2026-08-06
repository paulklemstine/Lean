# Computational evidence

Small numerical experiments performed with exact rational arithmetic (`#eval` on `ℚ`)
before formalising.  These are *exploratory* computations, not proofs; the statements
they support are proved in the `.lean` files (see `Logic/Rademacher/`).

## 1. Empirical Rademacher complexity of small classes

`R(F) = 2^{-n} ∑_σ max_{v ∈ F} (1/n) ⟨σ, v⟩`, computed by exhaustive enumeration of the
`2^n` sign patterns.

| class `F ⊆ ℝⁿ`                              | `n` | `R(F)` (exact) | Massart bound `r√(2 log N)/n` |
|---------------------------------------------|-----|----------------|-------------------------------|
| `{±1}¹` (full cube)                          | 1   | `1`            | `1.177`                       |
| `{±1}²` (full cube)                          | 2   | `1`            | `1.177`                       |
| `{±1}³` (full cube)                          | 3   | `1`            | `1.177`                       |
| `{v}` (singleton)                            | 4   | `0`            | `0`                           |
| `{(1,1),(-1,-1)}`                            | 2   | `1/2`          | `0.833`                       |
| the 4 standard basis vectors                 | 4   | `7/32 = 0.219` | `0.416`                       |

The cube row is the tightness example: the true value is `1` for every `n`, while
Massart's bound is the constant `√(2 log 2) ≈ 1.1774`, so the finite class lemma is
tight up to that absolute constant.  This is proved in `Massart.lean`
(`rad_cube`, `massart_cube_tight`).

No counterexample to Massart's bound appeared in any of the enumerated classes.

## 2. Euclidean ball

For the ball `{v : ‖v‖₂ ≤ r}` the maximiser of `⟨σ, v⟩` is `v = (r/√n)·σ`, giving
`R = r/√n` exactly (`0.5` for `r = 1, n = 4`, consistent with the value `7/32` obtained
above for the four basis vectors, which form a subset of the unit ball).  Proved
exactly in `Comparison.lean` (`rad_ball`), together with the fact that the ball is an
infinite class, so no counting/VC bound applies to it at all.

## 3. Symmetrization on a tiny example

`X = Bool`, uniform `p`, `n = 2`, `F = {1_{x=true}, 1_{x=false}}`, all `2² = 4` samples
enumerated:

* `𝔼_S sup_{f∈F} (𝔼 f − Ê_S f) = 1/4`
* `2 · 𝔼_S R̂_S(F) = 1/2`

so the symmetrization inequality holds with slack, as expected (the factor `2` is not
tight for such a small class).  Proved in `Symmetrization.lean`
(`generalization_bound`).

## 4. OEIS

No integer sequence arises: all quantities studied here are real-valued complexity
measures, so an OEIS search is not applicable.
