import Mathlib
import Shared.GraphTheory.FractalTruthMetric
import MachineLearning.CantorCompactness
import MachineLearning.CantorSubshiftDimension
import MachineLearning.GoldenMeanChaos
import MachineLearning.GoldenMeanRigidity

/-!
# The subshift as an abstract Cantor space, and the second rung of the rigidity hierarchy

Tenth cycle of the research thread.  Two consolidations.

**First**, the topological facts scattered over cycles 1–3 are packaged into the Brouwer
characterisation: the golden-mean subshift is nonempty, compact, perfect and totally
disconnected in a metrisable space, i.e. it is an abstract Cantor space.  This is the
conceptual reason behind the explicit homeomorphism of cycle 3, and it is proved here from
`goldenMean_perfect`, `isCompact_goldenMean` and the total separatedness of the ambient space
rather than from the substitution.

**Second**, cycle 8 separated the golden-mean shift from the full shift by counting fixed
points (`1` versus `2`).  Here we compute the next rung: the golden-mean shift has exactly
three points of period `2`, versus four for the full shift.  Both counts agree with the Lucas
numbers `L 1 = 1`, `L 2 = 3`, which is the pattern conjectured in `FUTURE_DIRECTIONS.md`.

## Main results

* `perfect_goldenMean` — `Perfect GoldenMean` in Mathlib's sense.
* `totallyDisconnectedSpace_goldenMean` — the subspace is totally disconnected.
* `goldenMean_isCantorSpace` — the Brouwer package: nonempty, compact, perfect, totally
  disconnected.
* `periodTwo_cantor`, `periodTwo_goldenMean` — the period-`2` sets, computed explicitly.
* `ncard_periodTwo_goldenMean` (`= 3`) and `ncard_periodTwo_cantor` (`= 4`) — the second
  conjugacy obstruction.
-/

namespace FractalTruthCompactness

open FractalTruthMetric Metric

/-! ## The Brouwer package -/

/-- The golden-mean subshift is perfect in Mathlib's sense: closed with no isolated points. -/
theorem perfect_goldenMean : Perfect GoldenMean := by
  refine ⟨isClosed_goldenMean, ?_⟩
  rw [preperfect_iff_nhds]
  intro x hx U hU
  obtain ⟨ε, hε, hball⟩ := Metric.mem_nhds_iff.mp hU
  obtain ⟨y, hy, hyx, hd⟩ := goldenMean_perfect hx hε
  exact ⟨y, ⟨hball (by rwa [mem_ball, dist_comm]), hy⟩, hyx⟩

/-- The subshift, as a subspace, is totally disconnected: it inherits total separatedness from
the ambient Cantor truth space. -/
theorem totallyDisconnectedSpace_goldenMean : TotallyDisconnectedSpace GoldenMean :=
  inferInstance

/-- **The golden-mean subshift is an abstract Cantor space.**  It is nonempty, compact, perfect
and totally disconnected inside a metric space — exactly Brouwer's characterisation, which is
the structural explanation of the explicit homeomorphism `goldenMeanHomeomorph`. -/
theorem goldenMean_isCantorSpace :
    GoldenMean.Nonempty ∧ IsCompact GoldenMean ∧ Perfect GoldenMean ∧
      TotallyDisconnectedSpace GoldenMean :=
  ⟨goldenMean_nonempty, isCompact_goldenMean, perfect_goldenMean,
    totallyDisconnectedSpace_goldenMean⟩

/-! ## Points of period two -/

/-- The `2`-periodic stream alternating between `a` and `b`. -/
def per2 (a b : Bool) : Cantor := fun k => if k % 2 = 0 then a else b

theorem per2_of_even {a b : Bool} {k : ℕ} (h : k % 2 = 0) : per2 a b k = a := if_pos h

theorem per2_of_odd {a b : Bool} {k : ℕ} (h : k % 2 = 1) : per2 a b k = b :=
  if_neg (by omega)

theorem shift_iterate_two_per2 (a b : Bool) : shift^[2] (per2 a b) = per2 a b := by
  funext k
  rw [shift_iterate_apply]
  show (if (k + 2) % 2 = 0 then a else b) = (if k % 2 = 0 then a else b)
  have h : (k + 2) % 2 = k % 2 := by omega
  rw [h]

/-- An alternating stream is admissible exactly when its two letters are not both `true`. -/
theorem per2_mem_goldenMean {a b : Bool} (h : ¬(a = true ∧ b = true)) :
    per2 a b ∈ GoldenMean := by
  intro k hk
  rcases Nat.even_or_odd k with he | ho
  · have h1 : k % 2 = 0 := Nat.even_iff.mp he
    have h2 : (k + 1) % 2 = 1 := by omega
    rw [per2_of_even h1, per2_of_odd h2] at hk
    exact h hk
  · have h1 : k % 2 = 1 := Nat.odd_iff.mp ho
    have h2 : (k + 1) % 2 = 0 := by omega
    rw [per2_of_odd h1, per2_of_even h2] at hk
    exact h ⟨hk.2, hk.1⟩

/-- A stream of period `2` is the alternation of its first two letters. -/
theorem eq_per2_of_period_two {x : Cantor} (hx : shift^[2] x = x) : x = per2 (x 0) (x 1) := by
  funext k
  induction k using Nat.strong_induction_on with
  | _ k ih =>
      match k with
      | 0 => rfl
      | 1 => rfl
      | (m + 2) =>
          have hval : x (m + 2) = x m := by
            have hc := congrFun hx m
            rw [shift_iterate_apply] at hc
            exact hc
          have hm : x m = per2 (x 0) (x 1) m := ih m (by omega)
          rw [hval, hm]
          show (if m % 2 = 0 then x 0 else x 1) = (if (m + 2) % 2 = 0 then x 0 else x 1)
          have h2 : (m + 2) % 2 = m % 2 := by omega
          rw [h2]

theorem per2_injective {a b a' b' : Bool} (h : per2 a b = per2 a' b') : a = a' ∧ b = b' :=
  ⟨congrFun h 0, congrFun h 1⟩

theorem per2_ne_fst {a b a' b' : Bool} (h : a ≠ a') : per2 a b ≠ per2 a' b' :=
  fun he => h (per2_injective he).1

theorem per2_ne_snd {a b a' b' : Bool} (h : b ≠ b') : per2 a b ≠ per2 a' b' :=
  fun he => h (per2_injective he).2

/-- **The full shift has exactly four points of period `2`.** -/
theorem periodTwo_cantor :
    {x : Cantor | shift^[2] x = x} =
      {per2 false false, per2 false true, per2 true false, per2 true true} := by
  ext x
  simp only [Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_singleton_iff]
  constructor
  · intro h
    have hx := eq_per2_of_period_two h
    cases h0 : x 0 <;> cases h1 : x 1 <;> rw [h0, h1] at hx
    · exact Or.inl hx
    · exact Or.inr (Or.inl hx)
    · exact Or.inr (Or.inr (Or.inl hx))
    · exact Or.inr (Or.inr (Or.inr hx))
  · rintro (rfl | rfl | rfl | rfl) <;> exact shift_iterate_two_per2 _ _

/-- **The golden-mean shift has exactly three points of period `2`**: the alternation of two
`true`s is forbidden. -/
theorem periodTwo_goldenMean :
    {x : Cantor | x ∈ GoldenMean ∧ shift^[2] x = x} =
      {per2 false false, per2 false true, per2 true false} := by
  ext x
  simp only [Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_singleton_iff]
  constructor
  · rintro ⟨hmem, hper⟩
    have hx := eq_per2_of_period_two hper
    have hne : ¬(x 0 = true ∧ x 1 = true) := hmem 0
    cases h0 : x 0 <;> cases h1 : x 1 <;> rw [h0, h1] at hx
    · exact Or.inl hx
    · exact Or.inr (Or.inl hx)
    · exact Or.inr (Or.inr hx)
    · exact absurd ⟨h0, h1⟩ hne
  · rintro (rfl | rfl | rfl) <;>
      exact ⟨per2_mem_goldenMean (by simp), shift_iterate_two_per2 _ _⟩

/-- The period-`2` census of the golden-mean shift: three points, matching the Lucas number
`L 2 = 3`. -/
theorem ncard_periodTwo_goldenMean :
    {x : Cantor | x ∈ GoldenMean ∧ shift^[2] x = x}.ncard = 3 := by
  rw [periodTwo_goldenMean, Set.ncard_eq_three]
  exact ⟨per2 false false, per2 false true, per2 true false,
    per2_ne_snd (by simp), per2_ne_fst (by simp), per2_ne_fst (by simp), rfl⟩

/-- The period-`2` census of the full shift: four points. -/
theorem ncard_periodTwo_cantor : {x : Cantor | shift^[2] x = x}.ncard = 4 := by
  rw [periodTwo_cantor]
  have f1 : ({per2 true true} : Set Cantor).Finite := Set.finite_singleton _
  have f2 : ({per2 true false, per2 true true} : Set Cantor).Finite := f1.insert _
  have f3 : ({per2 false true, per2 true false, per2 true true} : Set Cantor).Finite := f2.insert _
  have h01 : per2 false false ≠ per2 false true := per2_ne_snd (by simp)
  have h02 : per2 false false ≠ per2 true false := per2_ne_fst (by simp)
  have h03 : per2 false false ≠ per2 true true := per2_ne_fst (by simp)
  have h12 : per2 false true ≠ per2 true false := per2_ne_fst (by simp)
  have h13 : per2 false true ≠ per2 true true := per2_ne_fst (by simp)
  have h23 : per2 true false ≠ per2 true true := per2_ne_snd (by simp)
  rw [Set.ncard_insert_of_notMem (by simp [h01, h02, h03]) f3,
    Set.ncard_insert_of_notMem (by simp [h12, h13]) f2,
    Set.ncard_insert_of_notMem (by simp [h23]) f1, Set.ncard_singleton]

/-- **Second rung of the rigidity hierarchy.**  Cycle 8 separated the two systems at period
`1` (`1` fixed point versus `2`); they are also separated at period `2` (`3` versus `4`).  Both
golden-mean counts are Lucas numbers, as conjectured. -/
theorem periodTwo_census_differs :
    {x : Cantor | x ∈ GoldenMean ∧ shift^[2] x = x}.ncard = 3 ∧
    {x : Cantor | shift^[2] x = x}.ncard = 4 ∧
    {x : Cantor | x ∈ GoldenMean ∧ shift^[2] x = x}.ncard ≠
      {x : Cantor | shift^[2] x = x}.ncard := by
  refine ⟨ncard_periodTwo_goldenMean, ncard_periodTwo_cantor, ?_⟩
  rw [ncard_periodTwo_goldenMean, ncard_periodTwo_cantor]
  omega

end FractalTruthCompactness