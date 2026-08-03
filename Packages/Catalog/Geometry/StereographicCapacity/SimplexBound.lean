import Mathlib

/-!
# The simplex bound for spherical codes

This file proves the dimension-free simplex bound.  If a finite family of unit
vectors has every distinct pairwise inner product at most `c`, then
`c ≥ -1/(N-1)`, where `N` is the number of vectors.  The result follows from
positivity of the Gram matrix, applied to the all-ones vector.
-/

open Finset

namespace StereographicCapacity

/-- **Finite simplex bound.**  Among `N ≥ 2` unit vectors in a real inner-product
space, some distinct pair has inner product at least `-1/(N-1)`.  Equivalently,
a uniform upper bound `c` on all distinct inner products cannot be smaller than
this threshold. -/
theorem finite_simplex_bound
    {ι E : Type*} [DecidableEq ι] [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (s : Finset ι) (v : ι → E) (c : ℝ)
    (hcard : 2 ≤ s.card)
    (hunit : ∀ i ∈ s, ‖v i‖ = 1)
    (hpair : ∀ i ∈ s, ∀ j ∈ s, i ≠ j → inner ℝ (v i) (v j) ≤ c) :
    -(1 / ((s.card : ℝ) - 1)) ≤ c := by
  have hcard_nat : (2 : ℕ) ≤ s.card := hcard
  have hn : (s.card : ℝ) - 1 > 0 := by
    have : (1 : ℝ) < s.card := by exact_mod_cast hcard
    linarith
  -- Let w = sum of all vectors
  let w := ∑ i ∈ s, v i
  -- The inner product of w with itself is non-negative
  have hgram : inner ℝ w w ≥ 0 := real_inner_self_nonneg
  -- Expand inner w w
  have h_expand : inner ℝ w w = ∑ i ∈ s, ∑ j ∈ s, inner ℝ (v i) (v j) := by
    simp only [w]
    rw [inner_sum]
    congr 1 with i
    simp [sum_inner, ← real_inner_comm]
  -- Split diagonal/off-diagonal
  have h_split : ∑ i ∈ s, ∑ j ∈ s, inner ℝ (v i) (v j) =
      ∑ i ∈ s, inner ℝ (v i) (v i) + ∑ i ∈ s, ∑ j ∈ s.erase i, inner ℝ (v i) (v j) := by
    rw [← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro i hi
    rw [add_comm, ← Finset.sum_erase_add (s := s) (a := i) hi (f := fun j => inner ℝ (v i) (v j))]
  -- The diagonal sum equals s.card
  have h_diag : ∑ i ∈ s, inner ℝ (v i) (v i) = s.card := by
    have h_each : ∀ i ∈ s, inner ℝ (v i) (v i) = 1 := by
      intro i hi
      rw [real_inner_self_eq_norm_sq, hunit i hi]
      norm_num
    rw [Finset.sum_congr rfl h_each, Finset.sum_const, nsmul_eq_mul, mul_one]
  -- Bound the off-diagonal sum
  have h_off_diag : ∑ i ∈ s, ∑ j ∈ s.erase i, inner ℝ (v i) (v j) ≤ s.card * (s.card - 1) * c := by
    have h_card_erase : ∀ i ∈ s, (s.erase i).card = s.card - 1 := by
      intro i hi
      exact Finset.card_erase_of_mem hi
    have h_pair_bound : ∀ i ∈ s, ∑ j ∈ s.erase i, inner ℝ (v i) (v j) ≤ (s.card - 1) * c := by
      intro i hi
      calc ∑ j ∈ s.erase i, inner ℝ (v i) (v j)
          ≤ ∑ _j ∈ s.erase i, c := Finset.sum_le_sum (fun j hj => hpair i hi j (Finset.mem_of_mem_erase hj) (Ne.symm (Finset.ne_of_mem_erase hj)))
        _ = (s.erase i).card * c := by rw [Finset.sum_const, nsmul_eq_mul]
        _ = (s.card - 1) * c := by rw [h_card_erase i hi, Nat.cast_sub (by linarith : 1 ≤ s.card)]; norm_num
    calc ∑ i ∈ s, ∑ j ∈ s.erase i, inner ℝ (v i) (v j)
        ≤ ∑ _i ∈ s, ((s.card - 1) * c) := Finset.sum_le_sum h_pair_bound
      _ = s.card * ((s.card - 1) * c) := by rw [Finset.sum_const, nsmul_eq_mul]
      _ = s.card * (s.card - 1) * c := by ring
  -- Combine to get: 0 ≤ s.card + s.card * (s.card - 1) * c
  have h_combined : 0 ≤ s.card + s.card * (s.card - 1) * c := by
    have := h_expand ▸ hgram
    rw [h_split, h_diag] at this
    linarith [h_off_diag]
  -- Derive the bound: -1/(s.card - 1) ≤ c
  have hcard_pos : (0 : ℝ) < s.card := by exact_mod_cast Nat.lt_of_lt_of_le (by norm_num : 0 < 2) hcard
  have h1 : (0 : ℝ) ≤ 1 + (s.card - 1) * c := by nlinarith
  have h2 : -1 ≤ (s.card - 1) * c := by linarith
  have h3 : -1 / (s.card - 1) ≤ c := by
    rw [div_le_iff₀ hn]
    linarith
  convert h3 using 1
  simp [neg_div]

/-- If every distinct pair of unit vectors has inner product strictly below the
simplex threshold, then the family has fewer than `N` elements. -/
theorem card_lt_of_inner_lt_simplex_threshold
    {ι E : Type*} [DecidableEq ι] [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (s : Finset ι) (v : ι → E) (N : ℕ)
    (hN : 2 ≤ N)
    (hunit : ∀ i ∈ s, ‖v i‖ = 1)
    (hpair : ∀ i ∈ s, ∀ j ∈ s, i ≠ j →
      inner ℝ (v i) (v j) < -(1 / ((N : ℝ) - 1))) :
    s.card < N := by
  by_contra h_contra
  push_neg at h_contra
  have h2 : 2 ≤ s.card := le_trans hN h_contra
  have hn : (N : ℝ) - 1 > 0 := by
    have : (1 : ℝ) < N := by exact_mod_cast hN
    linarith
  have hcard_pos : (0 : ℝ) < s.card := by exact_mod_cast Nat.lt_of_lt_of_le (by norm_num : 0 < 2) h2
  -- Case split: s.card = N or s.card > N
  rcases h_contra.eq_or_lt with rfl | h_gt
  · -- Case s.card = N: Use Gram matrix directly
    -- inner w w = ∑ i j, inner (v i) (v j) ≥ 0
    -- But we can upper bound this using the strict inequality on off-diagonals
    let w := ∑ i ∈ s, v i
    have hgram : inner ℝ w w ≥ 0 := real_inner_self_nonneg
    -- Expand
    have h_expand : inner ℝ w w = ∑ i ∈ s, ∑ j ∈ s, inner ℝ (v i) (v j) := by
      simp only [w]
      rw [inner_sum]
      congr 1 with i
      simp [sum_inner, ← real_inner_comm]
    -- Diagonal sum = s.card = N
    have h_diag : ∑ i ∈ s, inner ℝ (v i) (v i) = ↑s.card := by
      have h_each : ∀ i ∈ s, inner ℝ (v i) (v i) = 1 := by
        intro i hi
        rw [real_inner_self_eq_norm_sq, hunit i hi]
        norm_num
      rw [Finset.sum_congr rfl h_each, Finset.sum_const, nsmul_eq_mul, mul_one]
    -- Split
    have h_split : ∑ i ∈ s, ∑ j ∈ s, inner ℝ (v i) (v j) =
        ∑ i ∈ s, inner ℝ (v i) (v i) + ∑ i ∈ s, ∑ j ∈ s.erase i, inner ℝ (v i) (v j) := by
      rw [← Finset.sum_add_distrib]
      apply Finset.sum_congr rfl
      intro i hi
      rw [add_comm, ← Finset.sum_erase_add (s := s) (a := i) hi (f := fun j => inner ℝ (v i) (v j))]
    -- Strict upper bound on off-diagonal sum
    have h_off_diag_lt : ∑ i ∈ s, ∑ j ∈ s.erase i, inner ℝ (v i) (v j) < s.card * (s.card - 1) * (-(1 / ((s.card : ℝ) - 1))) := by
      have h_card_erase : ∀ i ∈ s, (s.erase i).card = s.card - 1 := by
        intro i hi
        exact Finset.card_erase_of_mem hi
      have h_pair_lt : ∀ i ∈ s, ∑ j ∈ s.erase i, inner ℝ (v i) (v j) < (s.card - 1) * (-(1 / ((s.card : ℝ) - 1))) := by
        intro i hi
        have hs : (s.erase i).card = s.card - 1 := h_card_erase i hi
        have hs_card_pos : 0 < s.card - 1 := Nat.sub_pos_of_lt h2
        calc ∑ j ∈ s.erase i, inner ℝ (v i) (v j)
            < ∑ _j ∈ s.erase i, (-(1 / ((s.card : ℝ) - 1))) := Finset.sum_lt_sum_of_nonempty
                (Finset.card_pos.mp (by rw [hs]; exact hs_card_pos))
                (fun j hj => hpair i hi j (Finset.mem_of_mem_erase hj) (Ne.symm (Finset.ne_of_mem_erase hj)))
          _ = (s.erase i).card * (-(1 / ((s.card : ℝ) - 1))) := by rw [Finset.sum_const, nsmul_eq_mul]
          _ = (s.card - 1) * (-(1 / ((s.card : ℝ) - 1))) := by
            rw [hs]
            simp [Nat.cast_sub (by linarith : 1 ≤ s.card)]
      calc ∑ i ∈ s, ∑ j ∈ s.erase i, inner ℝ (v i) (v j)
          < ∑ _i ∈ s, ((s.card - 1) * (-(1 / ((s.card : ℝ) - 1)))) := Finset.sum_lt_sum_of_nonempty
              (Finset.card_pos.mp (Nat.lt_of_lt_of_le (by norm_num : 0 < 2) h2)) h_pair_lt
        _ = s.card * ((s.card - 1) * (-(1 / ((s.card : ℝ) - 1)))) := by rw [Finset.sum_const, nsmul_eq_mul]
        _ = s.card * (s.card - 1) * (-(1 / ((s.card : ℝ) - 1))) := by ring
    -- Now derive contradiction
    have h_sum_lt : inner ℝ w w < s.card + s.card * (s.card - 1) * (-(1 / ((s.card : ℝ) - 1))) := by
      rw [h_expand, h_split, h_diag]
      linarith [h_off_diag_lt]
    have h_zero : (s.card : ℝ) + s.card * (s.card - 1) * (-(1 / ((s.card : ℝ) - 1))) = 0 := by
      field_simp
      ring
    linarith
  · -- Case s.card > N: Use finite_simplex_bound
    have h_bound := finite_simplex_bound s v (-(1 / ((N : ℝ) - 1))) h2 hunit
      (fun i hi j hj hij => le_of_lt (hpair i hi j hj hij))
    -- h_bound says -(1/(s.card-1)) ≤ -(1/(N-1))
    -- But s.card > N implies s.card - 1 > N - 1, so 1/(s.card-1) < 1/(N-1), hence -(1/(s.card-1)) > -(1/(N-1))
    have hscard_gt : (s.card : ℝ) > N := by exact_mod_cast h_gt
    have hscard_sub_gt : (s.card : ℝ) - 1 > (N : ℝ) - 1 := by linarith
    have h1 : (1 : ℝ) / ((s.card : ℝ) - 1) < 1 / ((N : ℝ) - 1) := by
      apply div_lt_div_of_pos_left _ hn hscard_sub_gt
      norm_num
    have h2 : -(1 / ((s.card : ℝ) - 1)) > -(1 / ((N : ℝ) - 1)) := by linarith
    linarith

/-- **Chordal simplex packing bound.**  Let `N ≥ 2`.  If unit vectors have
pairwise squared distance strictly greater than `2N/(N-1)`, then there are
fewer than `N` of them.  The statement is independent of ambient dimension. -/
theorem card_lt_of_sq_chordal_separation_gt_simplex
    {ι E : Type*} [DecidableEq ι] [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (s : Finset ι) (v : ι → E) (N : ℕ)
    (hN : 2 ≤ N)
    (hunit : ∀ i ∈ s, ‖v i‖ = 1)
    (hsep : ∀ i ∈ s, ∀ j ∈ s, i ≠ j →
      2 * (N : ℝ) / ((N : ℝ) - 1) < ‖v i - v j‖ ^ 2) :
    s.card < N := by
  -- Convert squared distance condition to inner product condition
  have hinner : ∀ i ∈ s, ∀ j ∈ s, i ≠ j →
      inner ℝ (v i) (v j) < -(1 / ((N : ℝ) - 1)) := by
    intro i hi j hj hij
    have hsep' := hsep i hi j hj hij
    -- ‖v i - v j‖² = 2 - 2 * inner(v i, v j) for unit vectors
    have hsq : ‖v i - v j‖ ^ 2 = 2 - 2 * inner ℝ (v i) (v j) := by
      rw [norm_sub_sq_real]
      have hi' := hunit i hi
      have hj' := hunit j hj
      simp [hi', hj']
      ring
    rw [hsq] at hsep'
    -- 2N/(N-1) < 2 - 2 * inner → inner < -1/(N-1)
    have hN_pos : (N : ℝ) - 1 > 0 := by
      have : (1 : ℝ) < N := by exact_mod_cast hN
      linarith
    have hsep'' : (2 : ℝ) * N < (2 - 2 * inner ℝ (v i) (v j)) * ((N : ℝ) - 1) := by
      rwa [div_lt_iff₀ hN_pos] at hsep'
    -- From hsep'': 2N < 2(N-1) - 2(N-1)*inner, so (N-1)*inner < -1
    -- Goal: inner < -1/(N-1), which is (N-1)*inner < -1
    have hg' : (N - 1 : ℝ) * inner ℝ (v i) (v j) < -1 := by linarith
    rw [← neg_div, lt_div_iff₀ hN_pos]
    linarith
  exact card_lt_of_inner_lt_simplex_threshold s v N hN hunit hinner

/-- At the regular-simplex threshold, `N` unit vectors cannot have all pairwise
squared distances strictly larger than `2N/(N-1)`. -/
theorem exists_pair_sq_chordal_le_simplex
    {ι E : Type*} [DecidableEq ι] [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (s : Finset ι) (v : ι → E) (N : ℕ)
    (hN : 2 ≤ N) (hcard : N ≤ s.card)
    (hunit : ∀ i ∈ s, ‖v i‖ = 1) :
    ∃ i ∈ s, ∃ j ∈ s, i ≠ j ∧
      ‖v i - v j‖ ^ 2 ≤ 2 * (N : ℝ) / ((N : ℝ) - 1) := by
  by_contra h_neg
  push_neg at h_neg
  exact not_lt.mpr hcard (card_lt_of_sq_chordal_separation_gt_simplex s v N hN hunit h_neg)

end StereographicCapacity