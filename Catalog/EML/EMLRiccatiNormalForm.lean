import Mathlib
import EML.EMLRiccatiTransform

/-!
# The Riccati Gauge: From a Full EML ODE to the Normal-Form Riccati Equation

The Kovacic algorithm decides EML ("Liouvillian") solvability of a second-order
linear ODE by testing the associated *Riccati* equation, and it is stated for the
**normal form** `u″ = r·u`, whose Riccati equation is `ṽ′ + ṽ² = r`.  A generic
exponential–logarithmic equation, however, carries a first-derivative term
`y″ + p·y′ + q·y = 0`, whose logarithmic-derivative substitution `v = y′/y` gives
the *full* Riccati equation `v′ + v² + p·v + q = 0`.

This file proves, in an arbitrary differential field `K`, the two identities that
bridge the two Riccati equations — the algebraic core of the Kovacic preprocessing
on the Riccati side:

* **Full Riccati transform** (`riccati_full_of_second_order`): a nonzero solution
  `y` of `y″ + p·y′ + q·y = 0` produces a solution `v = y′/y` of
  `v′ + v² + p·v + q = 0`.  (Built on the catalog `Differential.logDeriv_riccati`.)
* **Completing the square / the gauge** (`riccati_gauge`): the shift `ṽ = v + g`
  with `2·g = p` (the abstract `g = p/2`) removes the linear term, turning
  `v′ + v² + p·v + q = 0` into the normal-form Riccati `ṽ′ + ṽ² = g′ + g² − q`.
* **Combined** (`riccati_normalForm_of_second_order`): a nonzero solution of the full
  equation yields a solution of the normal-form Riccati `ṽ′ + ṽ² = r` with the EML
  coefficient `r = g′ + g² − q` (`= q − p²/4 − p′/2` rearranged, with `g = p/2`).

The payoff for the catalog's Airy/Kovacic obstruction (`EML.EMLAiryRiccati`,
`EML.EMLKovacicSharp`): a *first-derivative-bearing* EML equation has an EML solution
only if its **normal-form Riccati** `ṽ′ + ṽ² = r` is rationally solvable — and that is
exactly the equation whose odd-degree obstruction the catalog proves unsolvable.  So
the gauge here is what lets the normal-form obstruction theory apply to the general
EML equation.

## Main results

* `riccati_full_of_second_order` — `y ≠ 0`, `y″ + p·y′ + q·y = 0 ⇒ v = y′/y` solves
  `v′ + v² + p·v + q = 0`.
* `riccati_gauge` — `2·g = p`, `v′ + v² + p·v + q = 0 ⇒ (v+g)′ + (v+g)² = g′ + g² − q`.
* `riccati_normalForm_of_second_order` — the composite: a nonzero solution of the full
  equation gives a solution of the normal-form Riccati.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the catalog's Airy/Kovacic obstruction is stated for the
*normal-form* Riccati `ṽ′ + ṽ² = r`, but a real EML ODE has a `y′` term whose Riccati
equation is `v′ + v² + p·v + q = 0`.  We conjectured these are linked by an algebraic
gauge `ṽ = v + p/2` ("completing the square") that removes the linear term, with the
new coefficient being exactly the normal-form coefficient `r = q − p²/4 − p′/2`.

Experiment (Experimenter): `riccati_full_of_second_order` reuses the catalog
`Differential.logDeriv_riccati` (`(y′/y)′ + (y′/y)² = y″/y`), substitutes
`y″ = −p·y′ − q·y`, and finishes by `field_simp; ring`.  `riccati_gauge` is proved
*division-free* using only `2·g = p`: `(v+g)′ + (v+g)² − (g′ + g² − q)` expands (via
`map_add`) to `(v′ + v² + p·v + q) + (2g − p)·v`, closed by
`linear_combination hv + v·hg`.  No characteristic hypothesis is needed; the classical
`g = p/2` is the case `2·g = p` in characteristic `≠ 2`.

Analysis (Analyst): the gauge is the Riccati-side shadow of the substitution
`y = exp(−½∫p)·u` from `EML.EMLReductionOfOrder`: there it removed the `y′` term on the
*linear* equation, here it removes the linear term on the *quadratic* Riccati equation,
landing on the same EML coefficient `r`.  This two-sided consistency (linear gauge ↔
Riccati gauge) is the structural reason the Kovacic algorithm may assume the normal form
without loss of generality.

Critique (Critic): non-vacuous and load-bearing.  `riccati_full_of_second_order`
genuinely needs `y ≠ 0` (the logarithmic derivative is otherwise undefined).
`riccati_gauge` is proved division-free with the honest hypothesis `2·g = p`, so it is
valid in every differential field, and the `(2g − p)·v` term is exactly what the
hypothesis kills — drop it and the identity is false.  Proofs use real
`field_simp`/`linear_combination` cancellation, never `decide`/`rfl`.

Synthesis (PI): with the Riccati gauge the catalog's normal-form Airy/Kovacic
obstruction (`EMLAiryRiccati`, `EMLKovacicSharp`) extends to general second-order EML
equations with a first-derivative term: gauge the full Riccati to normal form, then the
odd-degree obstruction applies.  Combined with `EMLReductionOfOrder` (the linear-side
gauge), the preprocessing both sides of the Riccati correspondence is now formal.
-- !-- Lab Notes -- !--
-/

open scoped Differential

namespace EMLRiccatiNormalForm

variable {K : Type*} [Field K] [Differential K]

/-! ### The full Riccati transform (with first-derivative term) -/

/-- **Full Riccati transform.** A nonzero solution `y` of the general second-order EML
equation `y″ + p·y′ + q·y = 0` produces a solution `v = y′/y` of the full Riccati
equation `v′ + v² + p·v + q = 0`.  This is the catalog `Differential.logDeriv_riccati`
combined with the equation. -/
theorem riccati_full_of_second_order (p q y : K) (hy : y ≠ 0)
    (hode : (y′)′ + p * y′ + q * y = 0) :
    (y′ / y)′ + (y′ / y) ^ 2 + p * (y′ / y) + q = 0 := by
  have hr : (y′ / y)′ + (y′ / y) ^ 2 = (y′)′ / y :=
    Differential.logDeriv_riccati y hy
  rw [hr]
  have hyy : (y′)′ = -(p * y′) - q * y := by linear_combination hode
  rw [hyy]; field_simp; ring

/-! ### The gauge: completing the square removes the linear term -/

/-- **Riccati gauge (completing the square).** If `2·g = p` (abstractly `g = p/2`) and
`v` solves the full Riccati equation `v′ + v² + p·v + q = 0`, then the shift
`ṽ = v + g` solves the *normal-form* Riccati equation `ṽ′ + ṽ² = g′ + g² − q`.  The new
right-hand side `r = g′ + g² − q` is the EML normal-form coefficient (`= q − p²/4 − p′/2`
with `g = p/2`).  Proved division-free, valid in any differential field. -/
theorem riccati_gauge (p q v g : K) (hg : 2 * g = p)
    (hv : v′ + v ^ 2 + p * v + q = 0) :
    (v + g)′ + (v + g) ^ 2 = g′ + g ^ 2 - q := by
  simp only [map_add]
  linear_combination hv + v * hg

/-- **Composite: full equation ⇒ normal-form Riccati.** A nonzero solution `y` of
`y″ + p·y′ + q·y = 0`, gauged by any `g` with `2·g = p`, yields a solution
`ṽ = y′/y + g` of the normal-form Riccati equation `ṽ′ + ṽ² = g′ + g² − q`.  This is the
exact input to the catalog's normal-form Kovacic/Airy obstruction. -/
theorem riccati_normalForm_of_second_order (p q g y : K) (hy : y ≠ 0) (hg : 2 * g = p)
    (hode : (y′)′ + p * y′ + q * y = 0) :
    (y′ / y + g)′ + (y′ / y + g) ^ 2 = g′ + g ^ 2 - q :=
  riccati_gauge p q (y′ / y) g hg (riccati_full_of_second_order p q y hy hode)

end EMLRiccatiNormalForm