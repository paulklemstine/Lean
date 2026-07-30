import Mathlib

namespace MachineLearning.HodgeCycles.ContrarianStability

/-- All three chain groups in the counterexample are one-dimensional over `ℚ`. -/
abbrev ChainSpace := ℚ

/-- Multiplication by `t`, viewed as the lower cellular differential. -/
def lowerBoundary (t : ℚ) : ChainSpace →ₗ[ℚ] ChainSpace :=
  (LinearMap.lsmul ℚ ChainSpace) t

/-- The upper differential in the family is zero. -/
def upperBoundary : ChainSpace →ₗ[ℚ] ChainSpace := 0

/-- A middle-chain element is a cycle when the lower differential kills it. -/
def IsMiddleCycle (t x : ℚ) : Prop := lowerBoundary t x = 0

/-- A middle-chain element is a boundary when it lies in the image of the upper
boundary map. -/
def IsMiddleBoundary (x : ℚ) : Prop :=
  ∃ y : ℚ, upperBoundary y = x

/-- Constructive nonvanishing of middle homology: some cycle is not a boundary. -/
def HasNonzeroMiddleHomology (t : ℚ) : Prop :=
  ∃ x : ℚ, IsMiddleCycle t x ∧ ¬ IsMiddleBoundary x

/-- The family is a chain complex for every parameter. -/
lemma boundary_square_zero (t : ℚ) :
    (lowerBoundary t).comp upperBoundary = 0 := by
  simp [upperBoundary]

/-- Since the upper differential is zero, its only boundary is zero. -/
lemma middle_boundary_iff (x : ℚ) : IsMiddleBoundary x ↔ x = 0 := by
  simp only [IsMiddleBoundary, upperBoundary, LinearMap.zero_apply, exists_const]
  exact eq_comm

/-- The cycle condition is the scalar equation `t * x = 0`. -/
lemma cycle_iff_mul_eq_zero (t x : ℚ) :
    IsMiddleCycle t x ↔ t * x = 0 := by
  simp [IsMiddleCycle, lowerBoundary]

/-- At the singular parameter, `1` represents a nonzero middle class. -/
lemma nontrivial_at_zero : HasNonzeroMiddleHomology 0 := by
  refine ⟨1, ?_, ?_⟩
  · simp [IsMiddleCycle, lowerBoundary]
  · simp [middle_boundary_iff]

/-- At every nonsingular parameter, middle homology vanishes. -/
lemma trivial_away_from_zero {t : ℚ} (ht : t ≠ 0) :
    ¬ HasNonzeroMiddleHomology t := by
  rintro ⟨x, hx, hxb⟩
  have htx : t * x = 0 := (cycle_iff_mul_eq_zero t x).mp hx
  have hx0 : x = 0 := (mul_eq_zero.mp htx).resolve_left ht
  exact hxb ((middle_boundary_iff x).2 hx0)

/-- Complete phase diagram: this one-dimensional complex has nonzero middle
homology exactly at the singular parameter `t = 0`. -/
theorem nonzero_middle_homology_iff (t : ℚ) :
    HasNonzeroMiddleHomology t ↔ t = 0 := by
  constructor
  · intro h
    by_contra ht
    exact trivial_away_from_zero ht h
  · rintro rfl
    exact nontrivial_at_zero

/-- Every positive rational neighborhood of zero contains a nonzero rational. -/
lemma small_nonzero_rational {ε : ℚ} (hε : 0 < ε) :
    ∃ t : ℚ, t ≠ 0 ∧ |t| < ε := by
  refine ⟨ε / 2, ?_, ?_⟩
  · positivity
  · rw [abs_of_pos (by positivity : 0 < ε / 2)]
    linarith

/-- **Counterexample to naive homology stability.** Every positive rational
neighborhood of the zero differential contains a complex with vanishing middle
homology, although middle homology is nonzero at the zero differential itself. -/
theorem middle_homology_not_locally_stable :
    ∀ ε : ℚ, 0 < ε →
      ∃ t : ℚ, |t| < ε ∧
        HasNonzeroMiddleHomology 0 ∧ ¬ HasNonzeroMiddleHomology t := by
  intro ε hε
  obtain ⟨t, ht0, htε⟩ := small_nonzero_rational hε
  exact ⟨t, htε, nontrivial_at_zero, trivial_away_from_zero ht0⟩

/-- A sharper cycle-level form of the jump: away from zero, the only cellular
cycle is zero. -/
theorem every_cycle_zero_away_from_singularity {t x : ℚ} (ht : t ≠ 0)
    (hx : IsMiddleCycle t x) : x = 0 := by
  apply (mul_eq_zero.mp ((cycle_iff_mul_eq_zero t x).mp hx)).resolve_left ht

end MachineLearning.HodgeCycles.ContrarianStability