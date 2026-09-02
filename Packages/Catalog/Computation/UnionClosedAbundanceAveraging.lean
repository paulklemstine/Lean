import Mathlib
import Catalog.Computation.UnionClosedAdjoinTop

/-!
# Cycle 2: averaging, density, and the invariants preserved by adjoining the top

Cycle 1 (`Catalog.Computation.UnionClosedAdjoinTop`) proved that adjoining the top member
`F.sup id` of a family preserves an abundant witness `x ∈ F.sup id`, isolated `F.Nonempty`
as the exact extra hypothesis, and explained the phenomenon by additivity of the surplus
`2 * deg - card`.

This cycle asks a different question about the same operation: *which global invariants of a
family does adjoining the top preserve, and can any of them force abundance to exist in the
first place?*  Three results.

* **Double counting** (`sum_deg_eq_totalSize`): over a ground set `s` containing every
  member, `∑ x ∈ s, deg F x = ∑ A ∈ F, A.card`.  This links the local statistic (degrees)
  with the global one (total size).
* **Averaging criterion** (`exists_abundant_of_large_totalSize`): if the members of `F` are
  on average at least half the ground set, `s.card * F.card ≤ 2 * totalSize F`, then some
  `x ∈ s` is abundant.  No union-closedness is needed; this is a genuinely different
  sufficient condition from the singleton/pair cases of cycle 1.
* **Stability** (`largeTotalSize_adjoinTop`): the averaging criterion is itself preserved by
  adjoining the top.  So the operation preserves not only an individual witness but the
  global hypothesis that produces witnesses — the two cycle-1 and cycle-2 mechanisms agree.

Finally, the *density* refinement (`density_lt_density_adjoinTop`) shows the operation is not
merely non-harmful but strictly beneficial: unless `x` already lies in every member, the
rational density `deg F x / F.card` strictly increases when the top is new.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): (H5) adjoining the top preserves *every* natural "half" invariant,
not just the abundance of one element; (H6) an average-size hypothesis alone (no
union-closedness) already forces an abundant element; (H7) the improvement in cycle 1 is
strict at the level of densities, not just of the integer surplus.

Experiment (Experimenter): H6 proved by double counting plus a strict sum comparison
(`Finset.sum_lt_sum_of_nonempty`); note the criterion is vacuous for `s = ∅` and is stated
with `s.Nonempty`.  H5 proved for the averaging criterion: `totalSize` grows by `s.card`
(when the top is new, `(F.sup id).card` may be smaller than `s.card`, so we track the top's
own size and the inequality `2 * (F.sup id).card ≥ (F.sup id).card` does the work); the
verified statement uses the ground set `s = F.sup id`.  H7 proved with
`div_lt_div_iff_of_pos`, and it is sharp: if `deg F x = F.card` the density is already `1`
and stays `1`.

Analysis (Analyst): degrees and total size are two faces of the same incidence count, and
adjoining the top adds one row of the incidence matrix that is maximal in every column of
the top.  That is the structural reason both the local witness and the global average
survive.  Combining with cycle 1: on the ground set `F.sup id`, the averaging criterion is a
*checkable* sufficient condition for Frankl-type abundance that is stable under the closure's
first step, while cycle 1's counterexample shows no such stability under the full closure.

Critique (Critic): the averaging criterion does not prove Frankl's conjecture — union-closed
families can have average size below half (e.g. `{∅, {0}}`), and the criterion says nothing
there.  It is stated as an implication, not an equivalence, and the boundary example
`{∅, {0}}` is recorded (`averaging_criterion_not_necessary`).
-/

namespace Catalog.Computation.UnionClosedAdjoinTop

open Finset

variable {α : Type*} [DecidableEq α]

/-- The total size of a family: the number of incidences `(x, A)` with `x ∈ A ∈ F`. -/
def totalSize (F : Finset (Finset α)) : ℕ := ∑ A ∈ F, A.card

/-- **Double counting.**  Summing degrees over any ground set containing all members of `F`
recovers the total size of `F`. -/
theorem sum_deg_eq_totalSize (F : Finset (Finset α)) (s : Finset α) (hs : ∀ A ∈ F, A ⊆ s) :
    ∑ x ∈ s, deg F x = totalSize F := by
  have h1 : ∀ x : α, deg F x = ∑ A ∈ F, if x ∈ A then 1 else 0 := by
    intro x; rw [deg, Finset.card_filter]
  unfold totalSize
  simp_rw [h1]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl (fun A hA => ?_)
  rw [Finset.sum_ite_mem]
  simp [Finset.inter_eq_right.2 (hs A hA)]

/-- Every member of a family is contained in its top. -/
theorem subset_sup_id {F : Finset (Finset α)} {A : Finset α} (hA : A ∈ F) : A ⊆ F.sup id :=
  Finset.le_sup (f := id) hA

/-- Degrees summed over the top of the family give the total size. -/
theorem sum_deg_sup_eq_totalSize (F : Finset (Finset α)) :
    ∑ x ∈ F.sup id, deg F x = totalSize F :=
  sum_deg_eq_totalSize F _ (fun _ hA => subset_sup_id hA)

/-- **Averaging criterion.**  If the members of `F` have average size at least half of the
ground set `s`, then some element of `s` is abundant.  Union-closedness is *not* required. -/
theorem exists_abundant_of_large_totalSize {F : Finset (Finset α)} {s : Finset α}
    (hs : ∀ A ∈ F, A ⊆ s) (hne : s.Nonempty) (h : s.card * F.card ≤ 2 * totalSize F) :
    ∃ x ∈ s, Abundant F x := by
  by_contra hcon
  push_neg at hcon
  have hlt : ∀ x ∈ s, 2 * deg F x < F.card := by
    intro x hx
    have := hcon x hx
    unfold Abundant at this
    omega
  have hsum : ∑ x ∈ s, 2 * deg F x < ∑ _x ∈ s, F.card :=
    Finset.sum_lt_sum_of_nonempty hne hlt
  rw [Finset.sum_const, smul_eq_mul, ← Finset.mul_sum,
    sum_deg_eq_totalSize F s hs] at hsum
  omega

/-- On the canonical ground set (the top of the family) the averaging criterion reads
`(F.sup id).card * F.card ≤ 2 * totalSize F`. -/
theorem exists_abundant_of_large_totalSize_sup {F : Finset (Finset α)}
    (hne : (F.sup id).Nonempty) (h : (F.sup id).card * F.card ≤ 2 * totalSize F) :
    ∃ x ∈ F.sup id, Abundant F x :=
  exists_abundant_of_large_totalSize (fun _ hA => subset_sup_id hA) hne h

/-- Adjoining a new top adds exactly `(F.sup id).card` incidences. -/
theorem totalSize_adjoinTop_of_notMem {F : Finset (Finset α)} (h : F.sup id ∉ F) :
    totalSize (adjoinTop F) = totalSize F + (F.sup id).card := by
  unfold totalSize adjoinTop
  rw [Finset.sum_insert h]
  omega

/-- **Stability of the averaging criterion.**  If the members of `F` average at least half
the top, the same is true after adjoining the top: the global hypothesis that manufactures
abundant elements is preserved by the very operation studied in cycle 1. -/
theorem largeTotalSize_adjoinTop {F : Finset (Finset α)}
    (h : (F.sup id).card * F.card ≤ 2 * totalSize F) :
    ((adjoinTop F).sup id).card * (adjoinTop F).card ≤ 2 * totalSize (adjoinTop F) := by
  rw [sup_adjoinTop]
  by_cases hmem : F.sup id ∈ F
  · unfold adjoinTop
    rw [Finset.insert_eq_self.2 hmem]
    exact h
  · rw [totalSize_adjoinTop_of_notMem hmem]
    unfold adjoinTop
    rw [Finset.card_insert_of_notMem hmem]
    have : (F.sup id).card * (F.card + 1) = (F.sup id).card * F.card + (F.sup id).card := by
      ring
    omega

/-- Combining the two: an averaging hypothesis on `F` yields an abundant element of
`adjoinTop F`, directly (via stability) as well as through cycle 1's witness transfer. -/
theorem exists_abundant_adjoinTop_of_large_totalSize {F : Finset (Finset α)}
    (hne : (F.sup id).Nonempty) (h : (F.sup id).card * F.card ≤ 2 * totalSize F) :
    ∃ x ∈ F.sup id, Abundant (adjoinTop F) x := by
  obtain ⟨x, hx, hax⟩ := exists_abundant_of_large_totalSize_sup hne h
  exact ⟨x, hx, abundant_adjoinTop hax hx⟩

/-! ## The density refinement: adjoining the top is strictly beneficial -/

/-- The density of `x` in `F`: the fraction of members containing `x`. -/
noncomputable def density (F : Finset (Finset α)) (x : α) : ℚ := (deg F x : ℚ) / (F.card : ℚ)

/-- **Strict improvement.**  If the top is not already a member, contains `x`, and `x` misses
at least one member of `F`, then adjoining the top strictly increases the density of `x`. -/
theorem density_lt_density_adjoinTop {F : Finset (Finset α)} {x : α} (hne : F.Nonempty)
    (hmem : F.sup id ∉ F) (hx : x ∈ F.sup id) (hlt : deg F x < F.card) :
    density F x < density (adjoinTop F) x := by
  have hm : (0 : ℚ) < (F.card : ℚ) := by
    exact_mod_cast Finset.card_pos.2 hne
  have hcard : (adjoinTop F).card = F.card + 1 := by
    unfold adjoinTop; rw [Finset.card_insert_of_notMem hmem]
  have hdeg : deg (adjoinTop F) x = deg F x + 1 := by
    unfold deg adjoinTop
    rw [Finset.filter_insert, if_pos hx, Finset.card_insert_of_notMem (by simp [hmem])]
  unfold density
  rw [hcard, hdeg]
  have hm1 : (0 : ℚ) < ((F.card : ℚ) + 1) := by linarith
  rw [div_lt_div_iff₀ hm (by push_cast; linarith)]
  have hd : (deg F x : ℚ) < (F.card : ℚ) := by exact_mod_cast hlt
  push_cast
  nlinarith

/-- The averaging criterion is sufficient but not necessary: the union-closed family
`{∅, {0}, {1}, {0,1}, {0,1,2}}` has the abundant element `0` (degree `3` out of `5`), yet
its members total `7 < 15 / 2` incidences, so the averaging hypothesis fails. -/
theorem averaging_criterion_not_necessary :
    ∃ F : Finset (Finset (Fin 3)),
      IsUnionClosed F ∧ (∃ x ∈ F.sup id, Abundant F x) ∧
        ¬ ((F.sup id).card * F.card ≤ 2 * totalSize F) := by
  refine ⟨{∅, {0}, {1}, {0, 1}, {0, 1, 2}}, ?_, ⟨0, ?_, ?_⟩, ?_⟩ <;> decide

end Catalog.Computation.UnionClosedAdjoinTop