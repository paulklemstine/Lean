# Future Directions — Ultrametric Lipschitz Bounds from Tropical Valuations on Arithmetic Height Spaces

## Synthesis

This cycle built the missing *metric-regularity bridge* between two catalog
objects: the **tropical (min-plus) valuation** `padicValRat p : ℚ → ℤ` and the
**arithmetic height** functions of Diophantine geometry. The unifying idea is
that the `p`-adic valuation is literally a tropical valuation — it sends
multiplication to tropical addition and addition to the tropical sum (`min`) —
and that every height inequality used in the *height machine* is a downstream
shadow of these two structural facts.

Concretely, `Catalog/Tropical/UltrametricHeightLipschitz.lean` contains five
theorems, all proved with no `sorry` and depending only on the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`):

1. `padicValRat_add_eq_min_of_ne` — the **sharp ultrametric ("isosceles") law**:
   for nonzero `q, r` with distinct valuations, `v(q+r) = min (v q) (v r)`.
   Mathlib only ships the one-sided `padicValRat.add_eq_of_lt`; the symmetric
   `min`-form is new here.
2. `localHeight_add_le` — the **ultrametric Lipschitz bound**:
   `localHeight p (x+y) ≤ max (localHeight p x) (localHeight p y)`.
3. `localHeight_mul_le` — **tropical additivity**:
   `localHeight p (x*y) ≤ localHeight p x + localHeight p y`.
4. `globalHeight_mul_le` / 5. `globalHeight_add_le` — the local bounds summed
   over a finite set of places give global sub-additivity of the height
   `globalHeight S x = ∑_{p∈S} localHeight p x` under both operations.

## Results Summary

The local height `localHeight p x = max 0 (- v_p x)` is the order of the pole of
`x` at `p`, i.e. the `p`-part of the naive logarithmic height. We proved it is
**simultaneously ultrametric (under `+`) and sub-additive (under `×`)**, and that
these properties are inherited by the finite-place global height. A genuine
**boundary condition** surfaced and is documented in the file: the isosceles law
*fails* without the `q ≠ 0, r ≠ 0` hypotheses, precisely because Mathlib adopts
the convention `padicValRat p 0 = 0` rather than `+∞`. The counterexample
`q = 0, r = p` (where `v(q+r) = 1 ≠ 0 = min (v 0) (v p)`) pins down exactly where
the tropical/ultrametric picture and the Mathlib convention diverge.

## Research Directions

**Direction 1 — Close the product formula to a single global height identity.**
We have sub-additivity over a *finite* set `S` of places, but the arithmetic
content of heights lives in the *product formula* `∑_{p} v_p(x)·log p + log|x|_∞ = 0`
for nonzero `x ∈ ℚ`. Conjecture: for the full (cofinite-support) global height
`H(x) = log max(|a|,|b|)` of a reduced fraction `a/b`, one has
`H(x) = ∑_{p prime} localHeight p x · log p` for all nonzero rationals, and the
sum has finite support. This is falsifiable: a single rational whose two sides
disagree numerically kills it. *The key insight is* that `localHeight p x` already
equals `v_p(denominator)` minus pole/zero bookkeeping, so the archimedean term is
forced by the product formula rather than added by hand. *Why now?* The finite-`S`
sub-additivity lemmas of this cycle are exactly the termwise estimates needed to
control the tail once finiteness of support (`padicValRat p x = 0` for `p` not
dividing numerator or denominator) is formalized.

**Direction 2 — Sharpen sub-additivity to an exact tropical formula.**
`localHeight_mul_le` is an inequality, but tropical multiplicativity should make
it an *equality up to cancellation*: conjecture `localHeight p (x*y) =
localHeight p x + localHeight p y` whenever `v_p x` and `v_p y` have the same sign
(no pole/zero cancellation), and strictly less otherwise. *The key insight is*
that the loss in `max 0 (a+b) ≤ max 0 a + max 0 b` is exactly `min (max 0 a)
(max 0 (-b))`, a computable defect measuring zero–pole cancellation at `p`. *Why
now?* The defect is an `omega`-decidable integer expression over the already-proved
`localHeight` API, so it is immediately attackable and immediately falsifiable by
a `decide`-style search over small fractions.

**Direction 3 — Lipschitz constant of the valuation as a map of ultrametric spaces.**
Equip `ℚ` with the `p`-adic metric `d_p(x,y) = p^{-v_p(x-y)}` and `ℤ` with the
order metric. Conjecture: `x ↦ localHeight p x` is `1`-Lipschitz from `(ℚ, d_p)`
to `(ℤ, |·|)` *on the unit ball* `{x : v_p x ≥ 0}`, and the constant `1` is sharp.
*The key insight is* that `localHeight_add_le` is precisely the non-expansive
(strong-triangle) inequality once `max` is read as the ultrametric ball-radius
operation. *Why now?* Mathlib's `IsUltrametricDist` and `Padic` machinery already
exist, so this reframes our combinatorial bounds as a clean statement in the
metric-space API, testable by exhibiting a pair achieving the constant.

**Direction 4 — Cross-domain bridge: heights vs. tropical matrix factor rank.**
The catalog file `Catalog/Tropical/Basic.lean` studies tropical factor rank over
`WithTop ℤ`. Conjecture: the global height vector `(localHeight p x)_{p∈S}` of a
finite family of rationals is the tropical-rank-1 generator of the
`min`-plus Gram matrix `M_{ij} = localHeight p (x_i / x_j)`, i.e. that matrix has
tropical factor rank `1`. *The key insight is* that `localHeight` is a tropical
linear functional, so its outer differences form a rank-1 min-plus matrix exactly
as in `IsTropFactorization`. *Why now?* Both objects now live in the same
namespace with proved APIs, so the bridge is a direct combination rather than new
foundations; it is falsifiable by computing the factor rank of one explicit `3×3`
height matrix.

**Direction 5 — Generalize from `ℚ` to number fields / function fields.**
Replace `padicValRat p` by the valuations of a global field `K` and conjecture
that `padicValRat_add_eq_min_of_ne`, `localHeight_add_le`, and the global
sub-additivity bounds hold verbatim for every non-archimedean place, with the
*same* `q ≠ 0` boundary condition. *The key insight is* that the proofs used only
the abstract valuation axioms (`v(xy)=v x+v y`, `min (v x)(v y) ≤ v(x+y)`), never
anything specific to `ℚ`. *Why now?* Mathlib's `Valuation`/`AddValuation` classes
package exactly these axioms, so abstracting the present file to a
`[Valued K Γ]` setting is a mechanical refactor whose failure (if any) would
immediately reveal a hidden use of the rationals.
