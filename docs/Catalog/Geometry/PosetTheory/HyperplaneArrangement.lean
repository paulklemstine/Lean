/-
# Hyperplane Arrangement Region Counting and Zaslavsky's Theorem

This file formalizes the combinatorics of hyperplane arrangements in ℝⁿ,
establishing the Zaslavsky recurrence and the binomial sum formula for the
maximum number of regions created by m hyperplanes in n-dimensional space.

## Main Results

* `zaslavsky` — The Zaslavsky function Z(m, n) = Σ_{k=0}^{n} C(m, k) counts
  the maximum number of regions formed by m hyperplanes in ℝⁿ.

* `zaslavsky_recurrence` — The fundamental recurrence:
  Z(m+1, n+1) = Z(m, n+1) + Z(m, n), analogous to Pascal's triangle.

* `zaslavsky_exponential_bound` — Z(m, n) ≤ 2^m for all m, n.

* `zaslavsky_full_dim` — When m ≤ n, Z(m, n) = 2^m.

## Mathematical Context

Zaslavsky's theorem (1975) gives the exact count of regions (connected components
of the complement) of a real hyperplane arrangement in general position.
The formula Z(m, n) = Σ C(m, k) for k ≤ n appears as the Whitney number
sum of the intersection lattice. This is the geometric foundation for
understanding the expressivity of ReLU neural networks.
-/

import Mathlib

open Finset Nat BigOperators

/-! ## The Zaslavsky Function -/

/-- The Zaslavsky function: maximum number of regions formed by m hyperplanes
in n-dimensional space. Defined as Z(m, n) = Σ_{k=0}^{n} C(m, k). -/
def zaslavsky (m n : ℕ) : ℕ :=
  ∑ k ∈ range (n + 1), m.choose k

/-- Z(0, n) = 1: zero hyperplanes yield one region. -/
theorem zaslavsky_zero (n : ℕ) : zaslavsky 0 n = 1 := by
  simp [zaslavsky]
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Finset.sum_range_succ]
    simp [Nat.choose_zero_succ, ih]

/-- Z(m, 0) = 1: in 0-dimensional space, there is always exactly one region. -/
theorem zaslavsky_dim_zero (m : ℕ) : zaslavsky m 0 = 1 := by
  simp [zaslavsky]

/-
The fundamental Zaslavsky recurrence:
Z(m+1, n+1) = Z(m, n+1) + Z(m, n).

This mirrors Pascal's rule for binomial coefficients. Adding one hyperplane
in general position intersects the existing arrangement, creating Z(m, n)
new regions (one for each region of the induced (n-1)-dimensional arrangement
on the new hyperplane).
-/
theorem zaslavsky_recurrence (m n : ℕ) :
    zaslavsky (m + 1) (n + 1) = zaslavsky m (n + 1) + zaslavsky m n := by
  unfold zaslavsky;
  simp +decide [ add_comm 1, Finset.sum_range_succ', Nat.choose_succ_succ ];
  simpa only [ Finset.sum_add_distrib ] using by ring;

/-
Z(m, n) ≤ 2^m: the number of regions never exceeds 2^m.

This is the fundamental exponential bound. Each hyperplane can at most
double the number of regions, giving 2^m as an upper bound.
Equality holds when n ≥ m (general position, full dimension).
-/
theorem zaslavsky_exponential_bound (m n : ℕ) :
    zaslavsky m n ≤ 2 ^ m := by
  rcases le_or_gt m n with h | h;
  · unfold zaslavsky;
    rw [ ← Nat.sum_range_choose m ];
    rw [ Finset.sum_subset ( Finset.range_mono ( Nat.succ_le_succ h ) ) fun x hx₁ hx₂ => by rw [ Nat.choose_eq_zero_of_lt ] ; aesop ];
  · rw [ ← Nat.sum_range_choose m ];
    exact Finset.sum_le_sum_of_subset ( Finset.range_mono ( by linarith ) )

/-
When m ≤ n, Z(m, n) = 2^m: in high enough dimension,
m hyperplanes in general position create exactly 2^m regions.
-/
theorem zaslavsky_full_dim (m n : ℕ) (h : m ≤ n) :
    zaslavsky m n = 2 ^ m := by
  rw [ ← Nat.sum_range_choose m, zaslavsky ];
  rw [ Finset.sum_subset ( Finset.range_mono ( by linarith : m + 1 ≤ n + 1 ) ) fun x hx₁ hx₂ => by rw [ Nat.choose_eq_zero_of_lt ] ; aesop ]

/-
Z(1, n) = 2 for n ≥ 1: one hyperplane always creates exactly two regions.
-/
theorem zaslavsky_one (n : ℕ) (hn : 1 ≤ n) : zaslavsky 1 n = 2 := by
  induction hn <;> simp_all +arith +decide [ zaslavsky_recurrence, zaslavsky_zero ]

/-
Monotonicity in dimension: Z(m, n) ≤ Z(m, n+1).
-/
theorem zaslavsky_mono_dim (m n : ℕ) :
    zaslavsky m n ≤ zaslavsky m (n + 1) := by
  exact Finset.sum_le_sum_of_subset ( Finset.range_mono ( Nat.le_succ _ ) )

/-
Monotonicity in hyperplane count: Z(m, n) ≤ Z(m+1, n).
-/
theorem zaslavsky_mono_hyperplanes (m n : ℕ) :
    zaslavsky m n ≤ zaslavsky (m + 1) n := by
  exact Finset.sum_le_sum fun _ _ => Nat.choose_le_choose _ ( Nat.le_succ m )

/-! ## Hyperplane Arrangement Structure -/

/-- A hyperplane arrangement in ℝⁿ described by its combinatorial data. -/
structure HyperplaneArrangement where
  /-- Number of hyperplanes -/
  numHyperplanes : ℕ
  /-- Ambient dimension -/
  ambientDim : ℕ
  /-- Number of regions (connected components of the complement) -/
  numRegions : ℕ
  /-- The region count is bounded by the Zaslavsky function -/
  region_bound : numRegions ≤ zaslavsky numHyperplanes ambientDim

/-- Every arrangement has at most 2^m regions. -/
theorem HyperplaneArrangement.exponential_bound (A : HyperplaneArrangement) :
    A.numRegions ≤ 2 ^ A.numHyperplanes :=
  le_trans A.region_bound (zaslavsky_exponential_bound _ _)

/-! ## Connection to ReLU Networks -/

/-- A ReLU network architecture described by its layer widths. -/
structure ReLUArchitecture where
  /-- Input dimension -/
  inputDim : ℕ
  /-- Width of each hidden layer -/
  layerWidths : List ℕ
  /-- At least one hidden layer -/
  nonempty_layers : layerWidths ≠ []

/-- Total number of neurons across all hidden layers. -/
def ReLUArchitecture.totalNeurons (A : ReLUArchitecture) : ℕ :=
  A.layerWidths.sum

/-- Number of hidden layers (depth). -/
def ReLUArchitecture.depth (A : ReLUArchitecture) : ℕ :=
  A.layerWidths.length

/-- The deep network region bound: L layers each of width w create
at most Z(w, n)^L linear regions (by the composition theorem). -/
def deepNetworkBound (w n L : ℕ) : ℕ :=
  (zaslavsky w n) ^ L

/-
The deep network bound never exceeds 2^(w*L) = 2^N where N is total neurons.
-/
theorem deep_network_exponential_bound (w n L : ℕ) :
    deepNetworkBound w n L ≤ 2 ^ (w * L) := by
  convert Nat.pow_le_pow_left ( zaslavsky_exponential_bound w n ) L using 1 ; ring

/-
**Depth-width tradeoff theorem**: When the input dimension exceeds the width,
the deep network bound equals the Zaslavsky power.
When w ≤ n (fewer neurons per layer than input dims), Z(w,n) = 2^w,
so a deep network achieves (2^w)^L = 2^(w·L) regions.
-/
theorem depth_advantage (w n L : ℕ) (hw : w ≤ n) (_hL : 1 ≤ L) :
    deepNetworkBound w n L = (2 ^ w) ^ L := by
  exact congr_arg ( · ^ L ) ( zaslavsky_full_dim w n hw )

/-
The shallow bound: Z(N, n) ≤ (N+1)^n for any N, n.
-/
theorem shallow_polynomial_bound (N n : ℕ) :
    zaslavsky N n ≤ (N + 1) ^ n := by
  induction' n with n ih generalizing N;
  · grind +suggestions;
  · induction' N with N ihN;
    · norm_num [ zaslavsky_zero ];
    · simp_all +decide [ zaslavsky_recurrence, pow_succ' ];
      nlinarith [ ih N, pow_pos ( Nat.succ_pos N ) n, pow_le_pow_left' ( Nat.le_succ ( N + 1 ) ) n ]

/-! ## Activation Patterns and the Boolean Cube -/

/-- An activation pattern for a network with N neurons. -/
def ActivationPattern (N : ℕ) := Fin N → Bool

/-
The number of possible activation patterns is 2^N.
-/
theorem activation_pattern_card (N : ℕ) :
    Fintype.card (Fin N → Bool) = 2 ^ N := by
  norm_num [ Fintype.card_pi ]

/-- Not all activation patterns are realizable. The Zaslavsky bound tells us
that at most Z(N, n) out of 2^N patterns are realizable. -/
theorem realizable_fraction_bound (N n : ℕ) :
    zaslavsky N n ≤ 2 ^ N :=
  zaslavsky_exponential_bound N n