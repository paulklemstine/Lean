import Mathlib
import Cryptography.BerggrenStars.RationalStars

/-!
# Why the stars sit at rationals, and why only finitely many of them are visible

Two complementary facts finish the explanation of the star map of the Berggren tree.

## Main results

* `no_line_through_irrational` : **there is no star at an irrational boundary point.** If two
  Berggren nodes lie on one Euclidean line through an ideal point `α` with `α` irrational, then
  they are the same node. Radial lines can only emanate from *rational* boundary points; the
  irrational directions of the picture carry no line at all, however dense the nodes are near
  them.
* `finite_visible_stars` : **the visible hierarchy is finite.** For every resolution threshold
  `ε > 0` only finitely many rationals `p/q ∈ [0,1]` have a star of resolution
  `δ(p/q) = starGapNum p q / q ≥ ε`. Combined with `BerggrenRationalStars.visible_rationals`,
  which computes the list for `ε = 2/5`, this says the star map has a discrete, computable
  hierarchy of visible directions rather than a continuum of them.
-/

namespace BerggrenRationalStars

open BerggrenHypercycleStars

/-- **No star at an irrational point.** Two Berggren nodes on a common Euclidean line through an
irrational ideal point `α` coincide. (For a rational ideal point the same line carries
infinitely many nodes, by `BerggrenRationalStars.isSeed_along_unit_ray`.) -/
theorem no_line_through_irrational (a : ℝ) (ha : Irrational a) (m n m' n' : ℕ)
    (hm : 0 < m) (hm' : 0 < m') (c : ℝ)
    (h1 : (hpoint m n hm).re = a + c * (hpoint m n hm).im)
    (h2 : (hpoint m' n' hm').re = a + c * (hpoint m' n' hm').im) :
    m = m' ∧ n = n' := by
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hM' : (0 : ℝ) < (m' : ℝ) := by exact_mod_cast hm'
  rw [hpoint_re, hpoint_im] at h1 h2
  have e1 : (n : ℝ) = a * m + c := by
    field_simp at h1
    linarith
  have e2 : (n' : ℝ) = a * m' + c := by
    field_simp at h2
    linarith
  have key : a * ((m : ℝ) - m') = (n : ℝ) - n' := by linarith
  have hmm : m = m' := by
    by_contra hne
    have hd : ((m : ℝ) - m') ≠ 0 := by
      intro h0
      exact hne (by exact_mod_cast sub_eq_zero.mp h0)
    have hval : a = ((n : ℝ) - n') / ((m : ℝ) - m') := by
      rw [eq_div_iff hd]
      linarith
    refine ha ⟨(((n : ℤ) - (n' : ℤ)) : ℚ) / (((m : ℤ) - (m' : ℤ)) : ℚ), ?_⟩
    push_cast
    exact hval.symm
  subst hmm
  refine ⟨rfl, ?_⟩
  have : (n : ℝ) = (n' : ℝ) := by linarith
  exact_mod_cast this

/-- **Only finitely many stars are visible at any resolution.** For each `ε > 0` there are only
finitely many boundary rationals `p/q` of `[0,1]` whose star has resolution at least `ε`. -/
theorem finite_visible_stars (eps : ℝ) (heps : 0 < eps) :
    {pq : ℕ × ℕ | 0 < pq.2 ∧ pq.1 ≤ pq.2 ∧ eps ≤ (starGapNum pq.1 pq.2 : ℝ) / pq.2}.Finite := by
  obtain ⟨K, hK⟩ := exists_nat_gt (2 / eps)
  have hsub : {pq : ℕ × ℕ | 0 < pq.2 ∧ pq.1 ≤ pq.2 ∧ eps ≤ (starGapNum pq.1 pq.2 : ℝ) / pq.2}
      ⊆ ↑((Finset.range (K + 1)) ×ˢ (Finset.range (K + 1))) := by
    rintro ⟨p, q⟩ ⟨hq, hpq, hge⟩
    have hQ : (0 : ℝ) < q := by exact_mod_cast hq
    have hg2 : (starGapNum p q : ℝ) ≤ 2 := by
      unfold starGapNum
      split_ifs <;> norm_num
    have hqle : (q : ℝ) ≤ 2 / eps := by
      rw [le_div_iff₀ heps]
      have : eps * q ≤ (starGapNum p q : ℝ) := by
        rw [le_div_iff₀ hQ] at hge
        linarith
      linarith
    have hqK : q < K + 1 := by
      have : (q : ℝ) < K := lt_of_le_of_lt hqle hK
      have : q < K := by exact_mod_cast this
      omega
    simp only [Finset.coe_product, Set.mem_prod, Finset.mem_coe, Finset.mem_range]
    exact ⟨by omega, by omega⟩
  exact Set.Finite.subset (Finset.finite_toSet _) hsub

end BerggrenRationalStars