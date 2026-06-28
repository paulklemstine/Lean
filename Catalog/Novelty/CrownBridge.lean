/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Bridge: SCD super-exponential growth vs. the crown's polynomial floor

This file connects the super-exponential machinery of this project to the
catalog construction `Novelty.AlternatingCyclePosetLowerBound`, whose main lower
bound `crown_strictAltCycle_card_lower` states that the blown-up crown
`Crown w m` carries at least `m ^ (2 * w)` strict alternating cycles.

Both objects are "independent-choice" lower bounds on a poset-combinatorial count,
but their *growth rates are qualitatively different*:

* the certified floor for the crown's alternating-cycle count is the **polynomial**
  `m ↦ m ^ (2 * w)` (fixed width `w`), which is **not** super-exponential;
* the symmetric chain decomposition count `numSCD` is **super-exponential**.

We prove, genuinely consuming the catalog lower bound:

* `crownAltCount_tendsto_atTop` : the crown's alternating-cycle count diverges
  (using `crown_strictAltCycle_card_lower`);
* `crown_floor_not_superexp` : its certified polynomial floor is not
  super-exponential;
* `scd_strictly_outgrows_crown_floor` : the synthesis — `numSCD` is
  super-exponential while the crown's floor is not, and the crown count still
  diverges.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): "independent-choice" lower bounds come in two flavours:
*fixed arity* (crown: `2w` choices, polynomial floor `m^{2w}`) and *growing arity*
(SCD: `n` independent pairings, factorial floor `n!`).  Only the latter is
super-exponential.
EXPERIMENT (Experimenter): reuse `crown_strictAltCycle_card_lower` for the crown
floor; reuse `numSCD_superexp` and `pow_const_not_superexp` for the SCD side.
ANALYSIS (Analyst): the dividing line is exactly whether the number of
independent choices is *bounded* (poly) or *grows with `n`* (super-exp).  This is
the structural insight the conjecture leans on: `M(n)`'s middle slab supplies a
*growing* number of independent matching choices.
CRITIQUE (Critic): does the bridge truly use the catalog?  Yes —
`crownAltCount_tendsto_atTop` is proved from `crown_strictAltCycle_card_lower`.
-/
import Mathlib
import Novelty.SCD.SuperExponential
import Novelty.SCD.SymmetricChainCount
import Novelty.AlternatingCyclePosetLowerBound

open Finset Filter Topology AlternatingCyclePoset
open scoped Classical

namespace Novelty.SCD

/-- The number of strict alternating cycles carried by the blown-up crown
`Crown w m` (counted as length-`w` indexed families of pairs). -/
noncomputable def crownAltCount (w : ℕ) [NeZero w] (m : ℕ) : ℕ :=
  (Finset.univ.filter
    (fun p : Fin w → Crown w m × Crown w m => IsStrictAltCycle p)).card

/-- The catalog floor, restated for `crownAltCount`. -/
lemma pow_le_crownAltCount (w m : ℕ) [NeZero w] :
    m ^ (2 * w) ≤ crownAltCount w m := by
  unfold crownAltCount
  exact crown_strictAltCycle_card_lower w m

/-
The crown's alternating-cycle count diverges to infinity as the clone count
`m` grows (fixed width `w`).  Proved from the catalog lower bound
`crown_strictAltCycle_card_lower`.
-/
theorem crownAltCount_tendsto_atTop (w : ℕ) [NeZero w] :
    Tendsto (crownAltCount w) atTop atTop := by
  exact Filter.tendsto_atTop_mono ( fun m => pow_le_crownAltCount w m ) ( Filter.tendsto_pow_atTop ( by linarith [ NeZero.pos w ] ) )

/-- The crown's certified polynomial floor `m ↦ m ^ (2 * w)` is **not**
super-exponential. -/
theorem crown_floor_not_superexp (w : ℕ) [NeZero w] :
    ¬ SuperExp (fun m => m ^ (2 * w)) :=
  pow_const_not_superexp (2 * w)

/-- **Synthesis / bridge theorem.**  The symmetric chain decomposition count is
super-exponential, whereas the crown construction's certified floor is merely
polynomial (not super-exponential), even though the crown's alternating-cycle
count itself still diverges.  This pinpoints *growing vs. bounded arity of
independent choices* as the source of super-exponential growth. -/
theorem scd_strictly_outgrows_crown_floor (w : ℕ) [NeZero w] :
    SuperExp numSCD ∧
      ¬ SuperExp (fun m => m ^ (2 * w)) ∧
      Tendsto (crownAltCount w) atTop atTop :=
  ⟨numSCD_superexp, crown_floor_not_superexp w, crownAltCount_tendsto_atTop w⟩

end Novelty.SCD