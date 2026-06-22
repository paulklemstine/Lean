import Mathlib

/-!
# A non-circular finite Banach fixed point theorem

A contraction on a nonempty finite metric space has a unique fixed point.

The proof is self-contained: it uses only finite minimization, basic metric-space
facts (`dist_eq_zero`, `dist_comm`), and ordered-ring arithmetic. It does **not**
rely on compactness, completeness, Cauchy sequences, Schauder/Brouwer, or any
existing fixed point theorem.
-/

namespace FiniteContraction

/-- If `0 ≤ r` and `r ≤ K * r` with `K < 1`, then `r = 0`. -/
lemma nonneg_eq_zero_of_le_mul_lt_one
    {r K : ℝ} (hr : 0 ≤ r) (hK : K < 1) (hle : r ≤ K * r) : r = 0 := by
  by_contra h
  have hpos : 0 < r := lt_of_le_of_ne hr (Ne.symm h)
  have : K * r < 1 * r := mul_lt_mul_of_pos_right hK hpos
  rw [one_mul] at this
  linarith

end FiniteContraction

theorem finite_contraction_fixedPoint_unique
  {X : Type*} [MetricSpace X] [Fintype X] [Nonempty X]
  (f : X → X) {K : ℝ}
  (hK : K < 1)
  (hcontr : ∀ x y : X, dist (f x) (f y) ≤ K * dist x y) :
  ∃! x : X, f x = x := by
  -- By `Finset.exists_min_image` there is `a ∈ univ` minimizing δ, i.e. for all y, δ a ≤ δ y.
  obtain ⟨a, ha⟩ : ∃ a, ∀ y, dist a (f a) ≤ dist y (f y) := by
    simpa using Finset.exists_min_image Finset.univ ( fun x => dist x ( f x ) ) Finset.univ_nonempty;
  -- By `nonneg_eq_zero_of_le_mul_lt_one`, we have `dist a (f a) = 0`, so `f a = a`.
  have hfa : dist a (f a) = 0 := by
    contrapose! ha;
    exact ⟨ f a, by have := hcontr a ( f a ) ; nlinarith [ show 0 < dist a ( f a ) from lt_of_le_of_ne ( dist_nonneg ) ha.symm, show dist ( f a ) ( f ( f a ) ) < dist a ( f a ) from lt_of_le_of_lt ( hcontr a ( f a ) ) ( mul_lt_of_lt_one_left ( lt_of_le_of_ne ( dist_nonneg ) ha.symm ) hK ) ] ⟩
  have hfa_eq : f a = a := by
    exact dist_eq_zero.mp hfa ▸ rfl;
  refine' ⟨ a, hfa_eq, fun x hx => _ ⟩;
  exact dist_le_zero.mp ( by have := hcontr x a; norm_num [ hx, hfa_eq ] at this; nlinarith [ @dist_nonneg _ _ x a ] )