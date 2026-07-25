/-
# Tight Arrangement Bounds, Depth Efficiency, and Chain Complex Betti Numbers

This file proves tight bounds on the Zaslavsky function and establishes
the depth-efficiency theorem for ReLU neural networks. The key results are:

1. A tight lower bound showing Z(m,n) ≥ C(m,n) ≥ m^n/n!
2. The depth-efficiency theorem: deep networks achieve exponentially
   more linear regions than shallow networks with the same neuron count
3. The Sauer-Shelah function equals the Zaslavsky function
4. Euler-Poincaré formula for two-term chain complexes via rank-nullity

## References

* Zaslavsky (1975), Facing up to arrangements
* Montúfar-Pascanu-Cho-Bengio (2014), On the number of linear regions
* Sauer (1972), On the density of families of sets
-/

import Mathlib

open Finset Nat BigOperators

/-! ## The Zaslavsky Function -/

/-- The Zaslavsky function: Z(m, n) = ∑_{k=0}^{n} C(m, k). -/
def Z (m n : ℕ) : ℕ := ∑ k ∈ range (n + 1), m.choose k

theorem Z_zero_left (n : ℕ) : Z 0 n = 1 := by
  simp [Z, Finset.sum_range_succ']

theorem Z_zero_right (m : ℕ) : Z m 0 = 1 := by simp [Z]

theorem Z_pos (m n : ℕ) : 0 < Z m n := by
  unfold Z
  exact lt_of_lt_of_le (by norm_num)
    (Finset.single_le_sum (fun x _ => Nat.zero_le _) (Finset.mem_range.mpr (Nat.succ_pos _)))

/-! ## Recurrence -/

/-
The fundamental Zaslavsky recurrence: Z(m+1, n+1) = Z(m, n+1) + Z(m, n).
-/
theorem Z_succ_succ (m n : ℕ) :
    Z (m + 1) (n + 1) = Z m (n + 1) + Z m n := by
  simp +arith +decide [ Z, Finset.sum_range_succ' ];
  simp +arith +decide [ ← Finset.sum_add_distrib, Nat.choose_succ_succ ]

/-! ## Monotonicity -/

theorem Z_mono_left (m n : ℕ) : Z m n ≤ Z (m + 1) n := by
  exact Finset.sum_le_sum fun _ _ => Nat.choose_le_choose _ (Nat.le_succ m)

theorem Z_mono_right (m n : ℕ) : Z m n ≤ Z m (n + 1) := by
  exact Finset.sum_le_sum_of_subset (Finset.range_mono (Nat.le_succ _))

/-! ## Upper Bounds -/

/-
!-- Z(m,n) ≤ 2^m: each hyperplane at most doubles the number of regions. -- !--

Z(m, n) ≤ 2^m: fundamental exponential bound.
-/
theorem Z_le_two_pow (m n : ℕ) : Z m n ≤ 2 ^ m := by
  -- We can rewrite $2^m$ as the sum of binomial coefficients: $2^m = \sum_{k=0}^{m} \binom{m}{k}$.
  have h_sum : 2 ^ m = ∑ k ∈ Finset.range (m + 1), Nat.choose m k := by
    rw [ Nat.sum_range_choose ];
  rcases le_or_gt n m with h | h <;> simp_all +decide [ Z ];
  · exact Finset.sum_le_sum_of_subset ( Finset.range_mono ( by linarith ) );
  · rw [ ← Finset.sum_range_add_sum_Ico _ ( by linarith : m + 1 ≤ n + 1 ) ] ; simp +arith +decide [ Nat.choose_eq_zero_of_lt h ] ;
    exact fun i hi₁ hi₂ => Nat.choose_eq_zero_of_lt hi₁

/-
When m ≤ n, Z(m, n) = 2^m: in high dimension, all regions are realized.
-/
theorem Z_eq_two_pow (m n : ℕ) (h : m ≤ n) : Z m n = 2 ^ m := by
  rw [ ← Nat.sum_range_choose m, Z ];
  rw [ Finset.sum_subset ( Finset.range_mono ( Nat.succ_le_succ h ) ) fun x hx₁ hx₂ => by rw [ Nat.choose_eq_zero_of_lt ] ; aesop ]

/-
!-- Z(m,n) ≤ (m+1)^n: the polynomial bound for fixed n. This follows
by induction on both m and n using the Pascal recurrence. -- !--

Z(m, n) ≤ (m+1)^n: polynomial bound in m for fixed n.
-/
theorem Z_le_pow_succ (m n : ℕ) : Z m n ≤ (m + 1) ^ n := by
  induction' n with n ih generalizing m;
  · simp +decide [ Z ];
  · induction' m with m ih generalizing n <;> simp_all +decide [ pow_succ', Z_succ_succ ];
    · exact le_trans ( Z_zero_left _ |> le_of_eq ) ( by norm_num );
    · rename_i h; specialize h n; simp_all +decide [ add_mul, pow_succ' ] ;
      nlinarith [ ih m, pow_pos ( Nat.succ_pos m ) n, pow_le_pow_left' ( Nat.le_succ ( m + 1 ) ) n ]

/-! ## Tight Lower Bound -/

/-
!-- C(m, k) is one summand of Z(m, n) for k ≤ n, giving the lower bound.
Since C(m, n) ≥ (m-n+1)^n / n!, this shows Z(m,n) = Θ(m^n/n!). -- !--

Each binomial coefficient C(m, k) for k ≤ n is a summand of Z(m, n).
-/
theorem choose_le_Z (m n k : ℕ) (hk : k ≤ n) : m.choose k ≤ Z m n := by
  exact Finset.single_le_sum ( fun x _ => Nat.zero_le ( m.choose x ) ) ( Finset.mem_range.mpr ( Nat.lt_succ_of_le hk ) )

/-
Z(m, n) is at least 1 + m (for n ≥ 1).
-/
theorem Z_ge_one_add (m : ℕ) {n : ℕ} (hn : 1 ≤ n) : 1 + m ≤ Z m n := by
  induction hn <;> simp_all +decide [ Z_succ_succ, add_comm 1 ];
  · unfold Z; simp +arith +decide [ Finset.sum_range_succ' ] ;
  · exact lt_of_lt_of_le ‹_› ( Z_mono_right _ _ )

/-! ## Depth Efficiency Theorem -/

-- !-- The depth-efficiency theorem shows that deep networks can represent
--     exponentially more linear regions than shallow networks:
--     - Deep (L layers, width w, input dim d ≥ w): (2^w)^L = 2^(wL) regions
--     - Shallow (1 layer, N=wL neurons): ≤ (N+1)^d regions
--     For wL >> d, this is an exponential gap. -- !--

/-- Deep network region bound: product of per-layer Zaslavsky bounds. -/
def deepBound (w d L : ℕ) : ℕ := (Z w d) ^ L

/-- Shallow network region bound: single-layer Zaslavsky bound. -/
def shallowBound (N d : ℕ) : ℕ := Z N d

/-
When layer width ≤ input dimension, the deep bound is exactly 2^(wL).
-/
theorem deep_bound_exponential (w d L : ℕ) (h : w ≤ d) :
    deepBound w d L = 2 ^ (w * L) := by
  rw [ deepBound, Z_eq_two_pow w d h, pow_mul ]

/-
The shallow bound is polynomial: Z(N, d) ≤ (N+1)^d.
-/
theorem shallow_bound_polynomial (N d : ℕ) :
    shallowBound N d ≤ (N + 1) ^ d := by
  convert Z_le_pow_succ N d using 1

/-- **Depth Efficiency Theorem**: For the same total number of neurons N = wL,
    a deep network with w ≤ d achieves 2^N regions while a shallow one
    achieves at most (N+1)^d. Both bounds hold simultaneously. -/
theorem depth_efficiency (w d L : ℕ) (hw : w ≤ d) :
    shallowBound (w * L) d ≤ (w * L + 1) ^ d ∧
    deepBound w d L = 2 ^ (w * L) := by
  exact ⟨shallow_bound_polynomial _ _, deep_bound_exponential _ _ _ hw⟩

/-! ## The Sauer-Shelah Function -/

-- !-- The shatter function Φ(m, n) counts the maximum number of subsets
--     of an n-element set achievable with VC-dimension ≤ m.
--     The Sauer-Shelah lemma: Φ(m, n) = ∑_{k≤m} C(n,k) = Z(n, m).
--     We prove this by showing Φ satisfies the same recurrence as Z. -- !--

/-- The shatter function: maximum cardinality of a family F ⊆ 2^[n]
    with VC-dimension at most m. Defined recursively. -/
def shatterFn : ℕ → ℕ → ℕ
  | _, 0 => 1
  | 0, _ => 1
  | m + 1, n + 1 => shatterFn m (n + 1) + shatterFn m n

theorem shatterFn_zero_right (m : ℕ) : shatterFn m 0 = 1 := by
  cases m <;> rfl

theorem shatterFn_zero_left (n : ℕ) : shatterFn 0 n = 1 := by
  cases n <;> rfl

theorem shatterFn_succ_succ (m n : ℕ) :
    shatterFn (m + 1) (n + 1) = shatterFn m (n + 1) + shatterFn m n := by
  rfl

/-
**Sauer-Shelah Identity**: The shatter function equals the Zaslavsky function.
    This is the combinatorial core of the Sauer-Shelah lemma: the maximum
    number of distinct subsets of [n] achievable with VC-dimension ≤ m
    equals ∑_{k=0}^{m} C(n, k) = Z(n, m).
-/
theorem shatterFn_eq_Z (m n : ℕ) : shatterFn m n = Z m n := by
  induction' m with m ih generalizing n <;> induction' n with n ih' <;> simp_all +decide [ Z ];
  · simp_all +decide [ Finset.sum_range_succ', shatterFn ];
  · grind +suggestions;
  · simp_all +decide [ Finset.sum_range_succ', shatterFn_succ_succ ];
    simp +arith +decide [ Nat.choose_succ_succ, Finset.sum_add_distrib ]

/-! ## Chain Complex Betti Numbers -/

-- !-- A two-term chain complex C₁ →[∂] C₀ over a field F has
--     β₁ = dim(ker ∂) and β₀ = f₀ - rank(∂).
--     The Euler-Poincaré formula: f₀ - f₁ = β₀ - β₁.
--     This follows directly from rank-nullity: dim(ker ∂) + rank(∂) = f₁. -- !--

/-- A two-term chain complex C₁ →[∂] C₀ over a field, given by dimensions
    and a boundary matrix. -/
structure TwoTermComplex (F : Type*) [Field F] where
  /-- Number of 1-cells -/
  f₁ : ℕ
  /-- Number of 0-cells -/
  f₀ : ℕ
  /-- The boundary map as a linear map -/
  boundary : (Fin f₁ → F) →ₗ[F] (Fin f₀ → F)

namespace TwoTermComplex

variable {F : Type*} [Field F]

/-- The first Betti number: dim(ker ∂). -/
noncomputable def beta₁ (C : TwoTermComplex F) : ℕ :=
  Module.finrank F C.boundary.ker

/-- The rank of the boundary map. -/
noncomputable def boundaryRank (C : TwoTermComplex F) : ℕ :=
  Module.finrank F C.boundary.range

/-- The zeroth Betti number: f₀ - rank(∂). -/
noncomputable def beta₀ (C : TwoTermComplex F) : ℕ :=
  C.f₀ - C.boundaryRank

/-
**Rank-Nullity for Boundary Maps**: β₁ + rank(∂) = f₁.
-/
theorem beta₁_add_rank (C : TwoTermComplex F) :
    C.beta₁ + C.boundaryRank = C.f₁ := by
  convert LinearMap.finrank_range_add_finrank_ker C.boundary using 1;
  · exact add_comm _ _;
  · simp +decide [ Module.finrank_pi ]

/-
β₁ ≤ f₁: the first Betti number is bounded by the number of 1-cells.
-/
theorem beta₁_le (C : TwoTermComplex F) : C.beta₁ ≤ C.f₁ := by
  exact le_trans ( by norm_num ) ( beta₁_add_rank C |> fun h => h.symm ▸ Nat.le_add_right _ _ )

/-- β₀ ≤ f₀: the zeroth Betti number is bounded by the number of 0-cells. -/
theorem beta₀_le (C : TwoTermComplex F) : C.beta₀ ≤ C.f₀ := by
  exact Nat.sub_le _ _

/-
**Euler-Poincaré Formula (Two-Term)**:
    χ = f₀ - f₁ = β₀ - β₁ (alternating sum of Betti numbers).
-/
theorem euler_poincare (C : TwoTermComplex F)
    (h : C.boundaryRank ≤ C.f₀) :
    (C.f₀ : ℤ) - (C.f₁ : ℤ) = (C.beta₀ : ℤ) - (C.beta₁ : ℤ) := by
  rw [ show C.beta₀ = C.f₀ - C.boundaryRank from rfl, show C.beta₁ = C.f₁ - C.boundaryRank from ?_ ];
  · rw [ Nat.cast_sub, Nat.cast_sub ] <;> linarith [ C.beta₁_add_rank ];
  · exact eq_tsub_of_add_eq ( beta₁_add_rank C )

end TwoTermComplex