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

/-! ## Properties of the quaternions (ℍ) -/

/-
PROBLEM
Quaternion multiplication is NOT commutative in general.
    We demonstrate this with i·j ≠ j·i (in fact i·j = k but j·i = -k).

PROVIDED SOLUTION
Use i = ⟨0,1,0,0⟩ and j = ⟨0,0,1,0⟩. Then extract the imK component: ij has imK = 1 but ji has imK = -1. Use congr_arg QuaternionAlgebra.imK and simp, then linarith.
-/

theorem quaternion_not_commutative :
    ∃ (a b : Quaternion ℝ), a * b ≠ b * a := by
  -- By definition of quaternion multiplication, we can compute the products $a * b$ and $b * a$ and show they are not equal.
  use ⟨0, 1, 0, 0⟩, ⟨0, 0, 1, 0⟩
  simp [Quaternion.ext_iff];
  norm_num [ Complex.ext_iff ] at * <;> first | linarith | aesop | assumption;

/-! ## The composition algebra structure -/

/-- The Brahmagupta-Fibonacci identity: Channel 2 composition law.
    This identity is equivalent to the multiplicativity of the norm on ℂ. -/

theorem channel_1_to_2 (n : ℕ) (h : ∃ a : ℤ, a ^ 2 = ↑n) :
    ∃ a b : ℤ, a ^ 2 + b ^ 2 = ↑n := by
  exact ⟨ h.choose, 0, by simpa using h.choose_spec ⟩

/-
PROBLEM
Channel 2 embeds in Channel 3: a sum of 2 squares is a sum of 4 squares

PROVIDED SOLUTION
Given a² + b² = n, use (a, b, 0, 0) since a² + b² + 0² + 0² = n.
-/

theorem channel_2_to_3 (n : ℕ) (h : ∃ a b : ℤ, a ^ 2 + b ^ 2 = ↑n) :
    ∃ a b c d : ℤ, a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = ↑n := by
  exact ⟨ h.choose, h.choose_spec.choose, 0, 0, by linear_combination h.choose_spec.choose_spec ⟩

/-
PROBLEM
Channel 3 embeds in Channel 4: a sum of 4 squares is a sum of 8 squares

PROVIDED SOLUTION
Given a² + b² + c² + d² = n, define f : Fin 8 → ℤ by f(0)=a, f(1)=b, f(2)=c, f(3)=d, f(4..7)=0. Then ∑ f(i)² = a² + b² + c² + d² + 0 + 0 + 0 + 0 = n. Use Fin.sum_univ_eight or Fin.cons.
-/

theorem channel_3_to_4 (n : ℕ) (h : ∃ a b c d : ℤ, a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = ↑n) :
    ∃ f : Fin 8 → ℤ, ∑ i, f i ^ 2 = ↑n := by
  -- By definition of Fin 8, we can construct such an f by setting the first four elements to a, b, c, d and the rest to zero.
  obtain ⟨a, b, c, d, h_sum⟩ := h;
  use fun i => if i.val < 4 then if i.val = 0 then a else if i.val = 1 then b else if i.val = 2 then c else d else 0;
  simp [Fin.sum_univ_eight, h_sum];

/-! ## Dimension constraints: why 1, 2, 4, 8 are special -/

/-
PROBLEM
The dimensions 1, 2, 4, 8 are exactly the powers of 2 up to 8

PROVIDED SOLUTION
Just decide or norm_num — both sides are concrete finite sets of naturals.
-/

theorem hurwitz_dimensions : ({1, 2, 4, 8} : Finset ℕ) = {2^0, 2^1, 2^2, 2^3} := by
  grind

/-- Sum of all Hurwitz dimensions equals 15, which is 2⁴ - 1 -/

theorem sum_hurwitz_dims : 1 + 2 + 4 + 8 = 15 := by norm_num

/-- Product of all Hurwitz dimensions equals 64 = 2⁶ -/

theorem prod_hurwitz_dims : 1 * 2 * 4 * 8 = 64 := by norm_num

/-! ## Information-theoretic properties -/

/-
PROBLEM
For any n ≥ 1, the Channel 1 "decoder" outputs at most 2 representations.
    (n is either a perfect square or not)

PROVIDED SOLUTION
The solutions to a² = n in [-n, n] are at most {√n, -√n}, so the cardinality is at most 2. Show the filter is a subset of {Nat.sqrt n, -(Nat.sqrt n)} and use Finset.card_le_card.
-/

theorem channel_1_bounded (n : ℕ) (hn : n ≥ 1) :
    (Finset.filter (fun a : ℤ => a ^ 2 = ↑n) (Finset.Icc (-(↑n : ℤ)) ↑n)).card ≤ 2 := by
  refine' le_trans ( Finset.card_le_card _ ) _;
  exact { ↑ ( Nat.sqrt n ), -↑ ( Nat.sqrt n ) };
  · intro x hx; rw [ Finset.mem_filter ] at hx; rw [ Finset.mem_insert, Finset.mem_singleton ] ; cases le_or_gt 0 x <;> [ left; right ] <;> nlinarith [ Nat.sqrt_le n, Nat.lt_succ_sqrt n ] ;
  · exact Finset.card_insert_le _ _

/-! ## Computational verification of the Jacobi four-square formula -/

/-- Jacobi sum: Σ_{d|n, 4∤d} d -/

def jacobi' (n : ℕ) : ℕ := ((Nat.divisors n).filter (fun d => ¬(4 ∣ d))).sum id

-- Verify Jacobi's formula for small n
#eval jacobi' 1      -- 1
#eval 8 * jacobi' 1  -- 8 (= r₄(1))

#eval jacobi' 5      -- 6 (1 + 5)
#eval 8 * jacobi' 5  -- 48 (= r₄(5))

#eval jacobi' 12     -- 12
#eval 8 * jacobi' 12
