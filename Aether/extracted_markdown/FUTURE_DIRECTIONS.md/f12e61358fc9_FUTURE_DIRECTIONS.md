# FUTURE DIRECTIONS
## Functorial tropical ultrametric from p-adic valuation depth on `α →₀ ℤ`

Cycle artifact: `Catalog/Bridges/TropicalPadicFinsupp.lean`.

This cycle built the concrete bridge object: the pointwise p-adic valuation on
finite-support integer functions, aggregated by `min` into the tropical semiring
`ℕ∞ = WithTop ℕ`, giving a non-archimedean valuation `fval` with the min-form
ultrametric `min (fval f) (fval g) ≤ fval (f + g)`, an induced codistance `dval`
satisfying the strong triangle inequality, and full functoriality in the index type
(`fval_embDomain`, `dval_embDomain`). The order-reversing dictionary to Mathlib's
`padicNorm` is recorded in `vp_padicNorm`.

Below are precise, falsifiable conjectures to drive the next cycles.

---

### C1. Gauss multiplicativity of `fval` on the group ring `ℤ[α]` (additivity of the valuation)
For a (left/right cancellative, or ordered) monoid `α`, equip `α →₀ ℤ` with the
convolution product (`AddMonoidAlgebra ℤ α`). **Conjecture:** `fval` is a *valuation
homomorphism* into the tropical semiring, i.e.
`fval p (f * g) = fval p f + fval p g`.
The pointwise scalar shadow `vp_mul` already proves the `ℤ`-level additivity; the
group-ring version is the genuine Gauss lemma. *Falsifiable*: search for a small
non-cancellative monoid `α` (e.g. with `a·b = a·c`, `b ≠ c`) where carries inside a
single convolution coefficient strictly lower the valuation, breaking equality to a
strict `≥`. Predicted boundary: equality holds iff `α` is cancellative.

### C2. `dval` upgrades to a genuine `ℝ`-valued ultrametric (a `MetricSpace`/`UltrametricSpace`)
Define `ndist p f g := (p : ℝ)⁻¹ ^ (toReal (dval p f g))` with the convention
`p^(-⊤) = 0`. **Conjecture:** `ndist` is an honest ultrametric on `α →₀ ℤ`:
`ndist f g = 0 ↔ f = g`, symmetry, and the *strong* triangle
`ndist f h ≤ max (ndist f g) (ndist g h)`, instantiating Mathlib's `IsUltrametricDist`.
*Falsifiable*: the only risky axiom is `ndist f g = 0 → f = g` on an infinite index
type, where the infimum could fail to be attained; predict it still holds because
`fval f - g = ⊤ ↔ f - g = 0` (each coordinate forced to valuation `⊤`).

### C3. Valuation-depth balls are exactly cosets of `p^k`-congruence subgroups
For `k : ℕ`, the closed ball `{g | k ≤ dval p f g}` should equal the coset
`f + (α →₀ p^k • ℤ)`, i.e. functions congruent to `f` mod `p^k` pointwise.
**Conjecture:** `k ≤ dval p f g ↔ ∀ x, (p:ℤ)^k ∣ (f x - g x)`. This identifies the
ultrametric topology with the `p`-adic (pro-`p`) topology on the free `ℤ`-module and
makes every ball a subgroup-coset. *Falsifiable*: check the `k = 0` edge case (always
true) and a `single`-supported counterexample where one coordinate's valuation is
exactly `k`.

### C4. Functoriality strengthens to a contraction/expansion calculus under `mapDomain`
`embDomain` (injective) is an isometry (proved). **Conjecture:** for an arbitrary
`mapDomain h` along non-injective `h : α → β`, valuation can only *increase*:
`fval p f ≤ fval p (Finsupp.mapDomain h f)`, with equality iff no two support points
of `f` collide into a cancelling sum. This makes `fval` a *lax* functor on the index
category `Finset`/`Type` with collisions as the obstruction. *Falsifiable*: collide
`single a 1` and `single b (p-1)` into one coordinate to force a strict jump in
valuation; predict the jump size equals `vp p (sum) - min(vp of the parts)`.

### C5. A strict valuation-depth hierarchy `VAL_k` on `α →₀ ℤ` separating by support/valuation
Connect to `Computation/PadicValuationDepth.lean`'s `ValDepthClassSet`. Define
`VAL_k := {f | k ≤ fval p f}` (functions divisible by `p^k`). **Conjecture:** this is a
strictly decreasing chain of subgroups `VAL_0 ⊋ VAL_1 ⊋ VAL_2 ⊋ ...` (over any
nonempty `α`), with `⋂_k VAL_k = {0}` and each quotient `VAL_k / VAL_{k+1} ≅ (α →₀ 𝔽_p)`.
This realizes the abstract "stratified computation / depth witness" hierarchy as a
concrete filtration by valuation depth. *Falsifiable*: strictness fails iff `α` is
empty; the quotient iso fails if `single` generators are not free over `𝔽_p` — predict
both hold for all nonempty `α`.
