# Future Directions — Arithmetic–Tropical Stability

## Synthesis

The new file `Catalog/Bridges/ArithmeticTropicalStability.lean` fuses three previously
isolated catalog ingredients into a single certified pipeline:

* arithmetic height on `ℚ` (`ArithmeticVCDim.ratArithHeight`, mirrored locally),
* p-adic valuation depth (Mathlib's `padicValRat`, the honest carrier of the
  `Computation/PadicValuationDepth.lean` ultrametric philosophy), and
* the tropical/ultrametric target objects of
  `Bridges/CategoricalTropicalUltrametric.lean`.

The unifying statement is a **duality between an L¹ arithmetic-height "size" on rational
data and the order-valued (tropical, min-plus) p-adic valuation profile of that data**. We
prove that the tropicalization map `q ↦ (padicValRat p q)_p` is a *quantitatively
nonexpanding* morphism: arithmetic approximation error provably controls tropical output
error, and great p-adic depth of a perturbation forces stability of the whole profile.

## Results Summary (all proved, `sorry`-free, classical axioms only)

1. `pow_natAbs_padicValRat_le_height` — `p ^ |padicValRat p q| ≤ ratArithHeight q`: height
   controls depth, with no coprimality assumption.
2. `padicValRat_natAbs_le_log_height` — the logarithmic form `|padicValRat p q| ≤ log_p(height)`.
3. `valuation_gap_le_log_height` — the nonexpansion/Lipschitz estimate on differences:
   `|padicValRat p (x − y)| ≤ log_p(ratArithHeight (x − y))`.
4. `profile_stable_of_deep` — depth ⇒ agreement: if `x − y` is p-adically deeper than `x`,
   then `padicValRat p y = padicValRat p x`.
5. `valuation_ultrametric` — the strong (ultrametric) triangle inequality on the valuation
   "distance", the order-theoretic shadow of tropical `add = max`.
6. `tropProfile_eq_of_deep` — multi-prime profile stability under simultaneous deep agreement.
7. `tropProfile_mul` — multiplicative functoriality: the profile is additive under
   multiplication coordinatewise (a `(·, ×) → (·, +)` monoid morphism).

## Bold, Falsifiable Research Directions

### 1. Two-sided height–depth duality (a Northcott-style reconstruction)
Conjecture: there is a *converse* control, `ratArithHeight q ≤ F(|padicValRat p q|_p over all p ≤ B)`
for an explicit `F` once the support of bad primes is bounded, making the truncated tropical
profile a faithful, invertible summary of bounded-height rationals. The key insight is that
height is the *sum* of local contributions `log_p(height)` over primes plus an archimedean
term, so a finite tropical profile plus one real coordinate should *reconstruct* height up to
an explicit, falsifiable constant. Why now? Direction 3's nonexpansion is exactly the easy
half of an adelic product formula; the catalog already isolates both the height side
(`ArithmeticVCDimension`) and the valuation side (`PadicValuationDepth`), so the missing
converse is the natural and immediately testable next inequality.

### 2. Certified truncation algorithm with a proven error bound
Conjecture: a terminating function `certifiedProfile (B : ℕ) (q : ℚ) : List ℤ` that emits the
p-adic valuations for all primes `p ≤ B` is *complete* — every nonzero coordinate of the full
profile with `p ≤ B` is captured — and the discarded tail is bounded by `log_B(height)`. The
key insight is that `pow_natAbs_padicValRat_le_height` already proves only finitely many
primes can have nonzero valuation (those dividing `num·den`), so a height bound yields a
provably exhaustive, finite certificate. Why now? Theorem 1 (`pow_natAbs_padicValRat_le_height`)
is precisely the finiteness lemma such an algorithm needs for its correctness proof; turning
it into a `Decidable`/computable certificate is a short, falsifiable step (it fails if any
prime above the cutoff carries valuation).

### 3. Hölder, not merely Lipschitz, profiles for iterated rational maps
Conjecture: for a rational dynamical map `T : ℚ → ℚ` of degree `d`, the valuation profile of
`T^[n] x` is Hölder-controlled by the profile of `x` with exponent `d^{-n}`, sharpening the
naive bound from `valuation_ultrametric` composed `n` times. The key insight is that
`tropProfile_mul`'s additivity converts multiplicative dynamics into *linear* growth of
valuations, so iteration that looks exponentially expanding in height is only linearly
expanding in depth. Why now? The `UltrametricLipschitzData`/`iter_exponent_stable` machinery
in `PadicValuationDepth.lean` already proves Lipschitz exponents are stable under ultrametric
iteration; pairing it with `tropProfile_mul` makes the Hölder refinement concrete and
falsifiable on explicit quadratic maps.

### 4. A genuine functor `ℚ-with-height ⥤ UltraNormObj` via a multi-prime norm
Conjecture: although a single prime cannot give a faithful `ℕ`-valued `UltraNormObj` on `ℚ`
(our recorded failure analysis), the *denominator functor* `q ↦ q.den` — equivalently the
product `∏_{p≤B} p^{max(0,-padicValRat p q)}` — *does* satisfy the ultrametric `norm_add ≤ max`
law and assembles into an `UltraNormObj` morphism out of the height metric. The key insight is
that the obstruction was `norm_mul` equality, which is repaired by passing from valuations to
*denominators*, where the ultrametric inequality survives but multiplicativity weakens to a
divisibility. Why now? `CategoricalTropicalUltrametric.lean` already defines `UltraNormObj` and
`valuationReconstruct`; supplying ℚ as a concrete object closes the open "Bridges ↔ Tropical"
connection the concept brief flags as structurally rich but missing.

### 5. Profile stability as certified robustness radii
Conjecture: `profile_stable_of_deep` upgrades to a quantitative *robustness certificate*:
there is an explicit radius `r(x)` (in height units) such that every `y` with
`ratArithHeight (x − y) < r(x)` shares the first `k` coordinates of `x`'s tropical profile,
directly instantiating `QuantumCertifiedRadiusData` from the categorical file. The key insight
is that `valuation_gap_le_log_height` already converts a height ball into a guaranteed depth,
and depth is exactly what `profile_stable_of_deep` consumes — so the certificate is a
composition of two theorems we now have. Why now? Both halves are proved in this cycle; only
the packaging into the catalog's `QuantumCertifiedRadiusData` structure remains, and it is
falsifiable by exhibiting a near point that flips a low-order coordinate.
