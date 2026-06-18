# Future Directions — Arithmetic-Height Ultrametrics: Duality & Representation

## Synthesis

This cycle took the catalog's existing arithmetic-height bridge
(`Bridges/ArithmeticHeightUltrametric.lean` — the real-valued `p`-adic depth
distance `hDist` on ℚ, the ℤ-valued divisibility carrier `valInt`, and the field
rigidity lemma `field_norm_rigid`) and extracted the two *structural* layers it was
missing, organized around the engine theme of **duality and representation**.

On the **geometry** side we showed that `hDist` is not merely a distance satisfying
the strong triangle inequality (`hDist_strong_triangle`, already in the catalog) but
carries the full nonarchimedean package: every triangle is isosceles
(`hDist_isosceles`), closed balls of a fixed nonnegative radius partition ℚ into
equivalence classes (`hDist_ball_equivalence`, via `hDist_ball_trans`), the distance
is an explicit negative power of `p` off the diagonal (`hDist_eq_zpow`), and the
integers form a single unit ball (`hDist_int_le_one`).

On the **representation** side we reread the catalog's rigidity obstruction as the
uniqueness half of a Gelfand-style duality: the divisibility depth `valInt p` is the
*pullback* of the trivial {0,1} norm on the residue field `ZMod p` along the
reduction map ℤ → ZMod p (`valInt_eq_trivNorm_residue`), and that residue-field norm
is the *unique* multiplicative ℕ-valued norm there (`residue_norm_unique`, a direct
application of `field_norm_rigid`). In other words, the "ℕ-spectrum" of the residue
field is a single point, and the entire arithmetic depth is captured by one pullback.

## Results Summary

All theorems are in `Catalog/Bridges/ArithmeticHeightUltrametricDuality.lean`,
proven with no `sorry` and only the standard axioms `propext`, `Classical.choice`,
`Quot.sound`.

- `hDist_isosceles` — ultrametric isosceles law: legs unequal ⇒ third side = max.
- `hDist_ball_trans` / `hDist_ball_equivalence` — closed balls partition ℚ.
- `hDist_eq_zpow` — `hDist p x y = p^(-padicValRat p (x-y))` for `x ≠ y`.
- `hDist_int_le_one` — integrality: integers sit in a single unit ball.
- `valInt_eq_trivNorm_residue` — pullback representation of the divisibility depth.
- `residue_norm_unique` — uniqueness of the residue-field norm (Gelfand point).

## Research Directions

### 1. The product-formula completion: a global adelic ultrametric bridge

Conjecture: for every nonzero rational `q`, the catalog's family of depth distances
satisfies the product formula `|q|_∞ · ∏_p hDist p q 0 = 1`, and this packages into a
single morphism from ℚˣ into a restricted product of the reconstructed
`UltraNormObj`s. The key insight is that the local `hDist_eq_zpow` formula already
isolates each local factor as `p^(-v_p(q))`, so the only missing ingredient is the
finiteness of the support and the archimedean balancing term — the bridge is local,
the product formula makes it global. Why now? Because `hDist_eq_zpow` reduces every
local factor to an explicit `zpow`, turning a hard analytic identity into a finite
bookkeeping statement over `padicValRat`, which Mathlib's `padicValRat` API and
`Rat.num`/`Rat.den` factorization already support. Falsifiable: a single rational
whose local factors fail to multiply to `1/|q|_∞` refutes it.

### 2. Completion of `(ℚ, hDist)` is the field of `p`-adic numbers

Conjecture: the metric completion of ℚ under the (real-recast) `hDist p` is
isometric, as an ultrametric space, to `ℚ_[p]`, and the integer unit ball
`hDist_int_le_one` completes to `ℤ_[p]`. The key insight is that
`hDist_ball_equivalence` already exhibits the clopen ball structure that
characterizes the `p`-adic topology, so the completion functor only has to be shown
to respect this partition. Why now? Mathlib has `Padic` and `PadicInt` with their
ultrametric instances, so the conjecture becomes a concrete `IsometryEquiv`
construction rather than a from-scratch completion — the geometric scaffolding
(isosceles + ball partition) is now in place to drive it. Falsifiable: any Cauchy
filter under `hDist` whose limit is not represented in `ℚ_[p]` breaks the equivalence.

### 3. Functoriality of the residue pullback across the prime spectrum

Conjecture: the assignment `p ↦ (valInt p as a TropicalValuationCarrier)` is
functorial in a base-change sense — for primes `p ≠ q` the only carrier morphism
between `arithDepthCarrier p` and `arithDepthCarrier q` that respects the residue
pullback is the zero/trivial one, so distinct primes give genuinely independent
points of the spectrum. The key insight is that `residue_norm_unique` pins each
carrier to a single residue-field evaluation, so cross-prime morphisms are forced to
collapse unless `p = q`. Why now? The uniqueness theorem proved this cycle is exactly
the rigidity needed to compute the (otherwise unwieldy) hom-sets between carriers, and
the catalog already has the `TropValCarrierHom` machinery to phrase it. Falsifiable: a
nontrivial residue-respecting morphism between two distinct-prime carriers.

### 4. Hensel-style lifting as a contraction in the `hDist` metric

Conjecture: for a polynomial `f ∈ ℤ[X]` with a simple root mod `p`, the Newton
iteration `x ↦ x - f(x)/f'(x)` is a strict contraction in `hDist p`, with explicit
contraction ratio `p^{-1}`, and therefore has a unique fixed point (the Hensel lift)
by the catalog's `BanachFixedPointBridge`. The key insight is that
`hDist_eq_zpow` makes the contraction ratio literally a power of `p`, converting
Hensel's lemma into a quantitative fixed-point statement the existing Banach bridge
can consume. Why now? With `hDist_eq_zpow` and `hDist_strong_triangle` both available,
the contraction estimate is a one-line valuation inequality, and cross-linking to
`BanachFixedPointBridge` is a genuine new cross-domain bridge (number theory ↔ fixed
point theory). Falsifiable: a simple-root polynomial whose Newton step fails the
`p^{-1}` contraction bound.

### 5. Stone-type duality between depth-clusters and residue evaluations

Conjecture: the Boolean algebra of clopen `hDist`-balls in ℤ is dual to the profinite
set `lim_n ℤ/p^nℤ` of residue evaluations, with the duality sending a ball to the set
of residue characters that vanish on it. The key insight is that
`hDist_ball_equivalence` produces exactly the clopen partition that Stone duality
needs as its lattice of "clopens", while `residue_norm_unique` supplies the dual
points. Why now? Both halves of a Stone-duality statement — the clopen lattice and
the space of points — were constructed this cycle from previously disconnected
catalog pieces, so the duality pairing is the natural next theorem. Falsifiable: a
clopen ball not separated by any residue evaluation, or two distinct balls inducing
the same residue-character set.
