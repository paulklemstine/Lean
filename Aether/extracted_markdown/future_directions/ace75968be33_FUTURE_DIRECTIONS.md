# Future Directions — Ultrametric Lipschitz Bounds from Tropical Valuations on Arithmetic Height Spaces

## Synthesis

This cycle built the missing *metric-regularity bridge* between two catalog
objects: the **tropical (min-plus) valuation** `padicValRat p : ℚ → ℤ` (already
exercised in `Catalog/Pythagorean/PadicOrbitalValuation.lean`) and the
**arithmetic height** functions of Diophantine geometry. The unifying idea is
that the `p`-adic valuation is *literally* a tropical valuation: it sends
multiplication to tropical addition (`v(xy) = v x + v y`) and addition to the
tropical sum (`min (v x) (v y) ≤ v(x+y)`). Every height inequality used in the
height machine turns out to be a one-line downstream shadow of these two
structural facts.

Concretely, `Catalog/Tropical/UltrametricHeightLipschitz.lean` introduces the
pole-order **local height** `localHeight p x = max 0 (-v_p x)` and the
finite-place **global height** `globalHeight S x = ∑_{p∈S} localHeight p x`, and
proves (with `sorry` = 0, axioms `propext`/`Classical.choice`/`Quot.sound`):

1. `padicValRat_add_eq_min_of_ne` — the sharp ultrametric ("isosceles") law,
   packaged from Mathlib's `padicValRat.add_eq_min` in valuation-first form.
2. `localHeight_add_le` — the ultrametric Lipschitz / strong-triangle bound
   `localHeight p (x+y) ≤ max (localHeight p x) (localHeight p y)`.
3. `localHeight_mul_le` — tropical sub-additivity
   `localHeight p (x*y) ≤ localHeight p x + localHeight p y`.
4. `localHeight_mul_eq_of_poles` — that bound becomes an *equality* when both
   arguments have poles at `p` (no zero–pole cancellation).
5. `globalHeight_mul_le` / `globalHeight_add_le` — the local bounds summed over a
   finite set of primes give global sub-additivity under both operations.

A genuine **boundary condition** is recorded as a theorem,
`localHeight_isosceles_boundary_fails`: the isosceles law fails without the
nonzero hypotheses because Mathlib uses the convention `padicValRat p 0 = 0`
rather than the tropical `+∞`; the counterexample `q = 0, r = 2` pins the
divergence exactly.

## Results Summary

The local height is the order of the pole of `x` at `p`, i.e. the `p`-part of the
naive logarithmic height. We showed it is **simultaneously ultrametric (under
`+`) and sub-additive (under `×`)**, that sub-additivity is **exact for poles**,
and that all of this is inherited by the finite-place global height. The proofs
use only the abstract valuation axioms, hinting strongly that the whole package
abstracts to arbitrary non-archimedean valuations.

## Research Directions

**Direction 1 — Close the product formula to a single global height identity.**
We have sub-additivity over a *finite* set `S` of places, but the arithmetic
content of heights lives in the *product formula*
`∑_p v_p(x)·log p + log|x|_∞ = 0` for nonzero `x ∈ ℚ`. Conjecture: for the full
(cofinite-support) global height `H(x) = log max(|a|,|b|)` of a reduced fraction
`a/b`, one has `H(x) = ∑_{p prime} localHeight p x · log p` for all nonzero
rationals, with finite support. This is falsifiable: a single rational whose two
sides disagree numerically kills it. *The key insight is* that `localHeight p x`
already equals `v_p(denominator)` minus pole/zero bookkeeping, so the archimedean
term is forced by the product formula rather than added by hand. *Why now?* The
finite-`S` sub-additivity lemmas of this cycle are exactly the termwise estimates
needed to control the tail once finiteness of support
(`padicValRat p x = 0` away from numerator/denominator) is formalized.

**Direction 2 — Sharpen sub-additivity to an exact tropical formula everywhere.**
`localHeight_mul_eq_of_poles` already nails the pole/pole case. Conjecture: in
general `localHeight p x + localHeight p y − localHeight p (x*y)` equals exactly
`min (max 0 (v_p x)) (max 0 (−v_p y)) + min (max 0 (v_p y)) (max 0 (−v_p x))`, a
computable integer defect measuring zero–pole cancellation at `p`. *The key
insight is* that the loss in `max 0 (a+b) ≤ max 0 a + max 0 b` is a piecewise-linear
function of `(a,b)` that `omega` can certify case-by-case. *Why now?* The defect
is an `omega`-decidable expression over the already-proved `localHeight` API, so
it is immediately attackable and immediately falsifiable by a `decide`-style
search over small fractions.

**Direction 3 — Lipschitz constant of the height as a map of ultrametric spaces.**
Equip `ℚ` with the `p`-adic metric `d_p(x,y) = p^{−v_p(x−y)}` and `ℤ` with the
order metric. Conjecture: `x ↦ localHeight p x` is `1`-Lipschitz from `(ℚ, d_p)`
to `(ℤ, |·|)` on the unit ball `{x : v_p x ≥ 0}`, and the constant `1` is sharp.
*The key insight is* that `localHeight_add_le` is precisely the non-expansive
(strong-triangle) inequality once `max` is read as the ultrametric ball-radius
operation. *Why now?* Mathlib's `IsUltrametricDist` and `Padic` machinery already
exist, so this reframes our combinatorial bounds as a clean metric-space
statement, testable by exhibiting a pair achieving the constant.

**Direction 4 — Cross-domain bridge: heights vs. tropical matrix factor rank.**
The catalog file `Catalog/Tropical/Basic.lean` studies tropical factor rank over
`WithTop ℤ` (`tropFactorRank`). Conjecture: for a finite family `(x_i)` of
rationals, the `min`-plus difference matrix `M_{ij} = localHeight p (x_i / x_j)`
has tropical factor rank `1`. *The key insight is* that `localHeight` behaves as a
tropical linear functional, so its outer differences form a rank-1 min-plus
matrix exactly as in the `IsTropFactorization` API. *Why now?* Both objects live
in the `Catalog/Tropical` namespace with proved APIs, so the bridge is a direct
combination rather than new foundations; falsifiable by computing the factor rank
of one explicit `3×3` height matrix.

**Direction 5 — Generalize from `ℚ` to number fields / function fields.**
Replace `padicValRat p` by the valuations of a global field `K` and conjecture
that `padicValRat_add_eq_min_of_ne`, `localHeight_add_le`, `localHeight_mul_le`,
and the global bounds hold verbatim for every non-archimedean place, with the
*same* `q ≠ 0` boundary condition. *The key insight is* that the present proofs
used only the abstract valuation axioms (`v(xy)=v x+v y`,
`min (v x)(v y) ≤ v(x+y)`), never anything specific to `ℚ`. *Why now?* Mathlib's
`Valuation`/`AddValuation` classes package exactly these axioms, so abstracting
this file to a `[Valued K Γ]` setting is a mechanical refactor whose failure (if
any) would immediately expose a hidden use of the rationals.
