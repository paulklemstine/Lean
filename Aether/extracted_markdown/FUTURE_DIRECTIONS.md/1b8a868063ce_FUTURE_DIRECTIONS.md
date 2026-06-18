# Future Directions — Tropicalized Arithmetic Height as a Logarithmic Valuation Functor

## Synthesis

This cycle fused two previously separate corners of the catalog: the arithmetic-height
machinery of `Bridges/ArithmeticVCDimension.lean` (`ratArithHeight`, positivity facts)
and the categorical tropical↔ultrametric interface of
`Bridges/CategoricalTropicalUltrametric.lean` (`UltraNormObj`, `TropicalValuationObject`).
The fusion is realized in `Bridges/TropicalHeightValuation.lean` through the **max-height**
`mH(q) = max(|num q|, den q)` and its tropicalization `tH(q) = log (mH q)`.

The central scientific finding is a *negative-then-positive* dichotomy that the concept
predicted as falsifiable:

* **The naive ultrametric bridge is false.** `maxHeight_not_ultrametric` exhibits the
  witness `1 + 1`, where `mH(2) = 2 > 1 = max(mH 1, mH 1)`. More structurally,
  `multiplicative_nat_norm_trivial` shows that *any* multiplicative `ℕ`-valued norm on `ℚ`
  with `N 1 = 1` collapses to the trivial valuation (`N q = 1` for all `q ≠ 0`), purely
  because `q · q⁻¹ = 1`. So the catalog `UltraNormObj` interface admits **no nontrivial**
  height on `ℚ`; the only instance is `ratTrivialUltra`.

* **The archimedean logarithmic bridge is true.** `maxHeight` is sign- and
  inversion-invariant, submultiplicative (`maxHeight_mul_le`), and obeys the explicit
  archimedean sum bound `mH(x+y) ≤ 2·mH(x)·mH(y)` (`maxHeight_add_le`). Tropicalized, these
  become `tH(xy) ≤ tH x + tH y` and `tH(x+y) ≤ tH x + tH y + log 2`, packaged as a genuine
  `LogHeightObject` (`ratLogHeight`). The two heights `maxHeight` and the catalog
  `ratArithHeight` are bi-Lipschitz on the log scale (factor `2`).

## Results Summary

| Theorem | Statement |
|---|---|
| `maxHeight_mul_le` | `mH(xy) ≤ mH(x)·mH(y)` (submultiplicativity) |
| `maxHeight_add_le` | `mH(x+y) ≤ 2·mH(x)·mH(y)` (archimedean sum bound) |
| `maxHeight_inv` / `maxHeight_neg` | inversion- and sign-invariance |
| `multiplicative_nat_norm_trivial` | rigidity: only the trivial ℕ-valued multiplicative norm exists on ℚ |
| `maxHeight_not_ultrametric` | concrete failure of the strong triangle inequality |
| `tropHeight_mul_le` / `tropHeight_add_le` | tropical product/sum laws |
| `ratLogHeight` | the rationals as a `LogHeightObject` (the bridge object) |
| `ratTrivialUltra` | the unique catalog `UltraNormObj` on ℚ (trivial valuation) |

## Research Directions

### 1. Sharpen the sum slack and prove it is optimal.
The proven bound `mH(x+y) ≤ 2·mH(x)·mH(y)` carries a factor `2`; the conjecture is that
`2` is tight, i.e. `tH(x+y) ≤ tH x + tH y + log 2` cannot be improved to any smaller
additive constant on all of `ℚ`, yet *can* be improved to slack `0` on the restricted
domain of rationals with a common denominator (where `mH(x+y) ≤ mH(x)·mH(y)` should hold).
The key insight is that the factor `2` is entirely an artifact of cross terms
`num x · den y + den x · num y`, which collapse to a single term once denominators agree.
Why now? Both halves are one `Rat.add_num_den` manipulation away from the lemmas already
proven here, so the optimality witness and the restricted-domain improvement are immediately
testable against `maxHeight_add_le`.

### 2. A per-place refinement: the p-adic valuation IS the missing ultrametric factor.
Conjecture: for each prime `p`, the map `vₚ(q) = padicValRat p q` gives a genuinely
ultrametric component, and the global max-height factors (up to log-equivalence) as a sum
of an archimedean part and the non-archimedean `∑ₚ max(vₚ, 0) log p`, recovering a
height-style product formula. The key insight is that rigidity blocks an ℕ-valued
ultrametric only because we forced multiplicativity *and* integrality simultaneously; moving
the codomain to `ℝ` (via `p^{-vₚ}`) restores the strong triangle inequality on each place.
Why now? Mathlib already supplies `padicValRat`, `padicNorm`, and the product-formula
scaffolding, so the decomposition can be stated and verified directly against `maxHeight`.

### 3. Functoriality: `ratLogHeight` is a monoid morphism into max-plus, up to slack.
Conjecture: `tropHeight` restricted to `ℚ*` (nonzero rationals) is a *quasi-morphism* of
monoids into `(ℝ, +)` with defect bounded by `0` on products (it is genuinely subadditive)
and by `log 2` on sums, and this makes `LogHeightObject` into a category with a faithful
functor from `(ℚ*, ·, ⁻¹)`. The key insight is that inversion-invariance
(`tropHeight_inv`) plus product-subadditivity is exactly the data of a length function on
the group `ℚ*`, so the height defines a left-invariant pseudo-metric `d(x,y) = tH(x/y)`.
Why now? The `LogHeightObject` structure is already in place; defining `UltraHom`-style
morphisms between `LogHeightObject`s and proving identity/composition laws mirrors the
existing `UltraHom.comp` development in the catalog almost verbatim.

### 4. Height-bounded states form finite Northcott codebooks compatible with VC bounds.
Conjecture: for each bound `B`, the set `{ q : ℚ | mH q ≤ B }` is finite with cardinality
`Θ(B²)`, and this finiteness composes with the trace-counting pipeline of
`ArithmeticVCDimension.lean` to yield pseudo-dimension bounds expressed in the *tropical*
metric rather than the additive height. The key insight is that `mH q ≤ B` constrains both
`|num|` and `den` simultaneously by `B`, so the codebook is a lattice box and its size is an
exact quadratic count. Why now? `ratArithHeight` finiteness lemmas already exist in the
catalog; replacing the additive height by `maxHeight` (shown here to be equivalent up to
factor `2`) lets the VC machinery inherit the ultrametric/tropical geometry for free.

### 5. Transfer the dichotomy to number fields and function fields.
Conjecture: the rigidity theorem `multiplicative_nat_norm_trivial` generalizes to any field
`K` with `K* = K* ` torsion-controlled — every ℕ-valued multiplicative norm with `N 1 = 1`
is trivial on `K*` — while the archimedean `LogHeightObject` survives for the Weil height on
`K` with a slack depending only on `[K : ℚ]`. The key insight is that the rigidity proof
used *only* `x · x⁻¹ = 1` and `Nat.eq_one_of_mul_eq_one_right`, so it is a statement about
groups, not about `ℚ` specifically. Why now? Mathlib's `NumberField` and `AbsoluteValue`
APIs make the group-theoretic core directly reusable, turning a ℚ-specific observation into
a field-agnostic structural theorem.
