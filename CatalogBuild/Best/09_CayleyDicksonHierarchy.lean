/-! # CatalogBuild.Best.09_CayleyDicksonHierarchy

Auto-generated from theorem catalog database.
Domain: Best
Declarations: 10
-/

import Mathlib

/-- Complex multiplication is commutative — a property lost in the quaternions. -/
theorem complex_norm_sq_mul (z w : ℂ) :
    Complex.normSq (z * w) = Complex.normSq z * Complex.normSq w := by
  rw [ Complex.normSq_mul ]


theorem quaternion_not_commutative :
    ∃ (a b : Quaternion ℝ), a * b ≠ b * a := by
  -- By definition of quaternion multiplication, we can compute the products $a * b$ and $b * a$ and show they are not equal.
  use ⟨0, 1, 0, 0⟩, ⟨0, 0, 1, 0⟩
  simp [Quaternion.ext_iff];
  norm_num [ Complex.ext_iff ] at * <;> first | linarith | aesop | assumption;


theorem channel_1_to_2 (n : ℕ) (h : ∃ a : ℤ, a ^ 2 = ↑n) :
    ∃ a b : ℤ, a ^ 2 + b ^ 2 = ↑n := by
  exact ⟨ h.choose, 0, by simpa using h.choose_spec ⟩


theorem channel_2_to_3 (n : ℕ) (h : ∃ a b : ℤ, a ^ 2 + b ^ 2 = ↑n) :
    ∃ a b c d : ℤ, a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = ↑n := by
  exact ⟨ h.choose, h.choose_spec.choose, 0, 0, by linear_combination h.choose_spec.choose_spec ⟩


theorem channel_3_to_4 (n : ℕ) (h : ∃ a b c d : ℤ, a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = ↑n) :
    ∃ f : Fin 8 → ℤ, ∑ i, f i ^ 2 = ↑n := by
  -- By definition of Fin 8, we can construct such an f by setting the first four elements to a, b, c, d and the rest to zero.
  obtain ⟨a, b, c, d, h_sum⟩ := h;
  use fun i => if i.val < 4 then if i.val = 0 then a else if i.val = 1 then b else if i.val = 2 then c else d else 0;
  simp [Fin.sum_univ_eight, h_sum];


theorem hurwitz_dimensions : ({1, 2, 4, 8} : Finset ℕ) = {2^0, 2^1, 2^2, 2^3} := by
  grind


/-- Sum of all Hurwitz dimensions equals 15, which is 2⁴ - 1 -/
theorem sum_hurwitz_dims : 1 + 2 + 4 + 8 = 15 := by norm_num


/-- Product of all Hurwitz dimensions equals 64 = 2⁶ -/
theorem prod_hurwitz_dims : 1 * 2 * 4 * 8 = 64 := by norm_num


theorem channel_1_bounded (n : ℕ) (hn : n ≥ 1) :
    (Finset.filter (fun a : ℤ => a ^ 2 = ↑n) (Finset.Icc (-(↑n : ℤ)) ↑n)).card ≤ 2 := by
  refine' le_trans ( Finset.card_le_card _ ) _;
  exact { ↑ ( Nat.sqrt n ), -↑ ( Nat.sqrt n ) };
  · intro x hx; rw [ Finset.mem_filter ] at hx; rw [ Finset.mem_insert, Finset.mem_singleton ] ; cases le_or_gt 0 x <;> [ left; right ] <;> nlinarith [ Nat.sqrt_le n, Nat.lt_succ_sqrt n ] ;
  · exact Finset.card_insert_le _ _


/-- Jacobi sum: Σ_{d|n, 4∤d} d -/
def jacobi' (n : ℕ) : ℕ := ((Nat.divisors n).filter (fun d => ¬(4 ∣ d))).sum id

-- Verify Jacobi's formula for small n
#eval jacobi' 1      -- 1
#eval 8 * jacobi' 1  -- 8 (= r₄(1))

#eval jacobi' 5      -- 6 (1 + 5)
#eval 8 * jacobi' 5  -- 48 (= r₄(5))

#eval jacobi' 12     -- 12
#eval 8 * jacobi' 12
