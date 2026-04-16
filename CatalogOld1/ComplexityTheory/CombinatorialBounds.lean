/-
# Combinatorial Bounds in Complexity Theory

Formal proofs of combinatorial results that underpin computational complexity:

- **Exponential counting bounds**: Growth of function spaces
- **Information-theoretic lower bounds**: Decision tree depth from distinguishability
- **Binomial coefficient bounds**: Partial sums and tail estimates
- **VC dimension growth function bounds**
- **Probabilistic method basics**
- **Polynomial method**

These results are fundamental tools in proving lower bounds
in circuit complexity, communication complexity, and learning theory.
-/

import Mathlib

open Finset Fintype Nat

namespace ComplexityBounds

/-! ## Decision Tree Lower Bounds -/

/-- A decision tree of depth d can distinguish at most 2^d outcomes.
Therefore if we need to distinguish 2^n outcomes, we need depth ≥ n. -/
theorem decision_tree_depth_bound (d n : ℕ) (h : 2 ^ n ≤ 2 ^ d) : n ≤ d := by
  exact Nat.pow_le_pow_iff_right (by omega) |>.mp h

/-! ## Binomial Coefficient Bounds -/

/-- Sum of first k+1 binomial coefficients of n. -/
def binomialPartialSum (n k : ℕ) : ℕ := ∑ i ∈ Finset.range (k + 1), n.choose i

/-- The partial sum is at most 2^n. -/
theorem binomialPartialSum_le_pow (n k : ℕ) : binomialPartialSum n k ≤ 2 ^ n := by
  unfold binomialPartialSum
  trans (∑ i ∈ Finset.range (n + 1), n.choose i)
  · apply Finset.sum_le_sum_of_ne_zero
    intro i hi hne
    simp only [Finset.mem_range] at hi ⊢
    by_contra h; push_neg at h
    simp [Nat.choose_eq_zero_of_lt (by omega : n < i)] at hne
  · exact le_of_eq (Nat.sum_range_choose n)

/-- C(n, 0) = 1. -/
theorem choose_zero (n : ℕ) : n.choose 0 = 1 := Nat.choose_zero_right n

/-- C(n, n) = 1. -/
theorem choose_self (n : ℕ) : n.choose n = 1 := Nat.choose_self n

/-- C(n, 1) = n. -/
theorem choose_one (n : ℕ) : n.choose 1 = n := Nat.choose_one_right n

/-- Binomial sum starts at 1. -/
theorem binomialPartialSum_zero (n : ℕ) : binomialPartialSum n 0 = 1 := by
  simp [binomialPartialSum, Finset.sum_range_one, Nat.choose_zero_right]

/-- Binomial partial sum is monotone in k. -/
theorem binomialPartialSum_mono (n : ℕ) {k₁ k₂ : ℕ} (h : k₁ ≤ k₂) :
    binomialPartialSum n k₁ ≤ binomialPartialSum n k₂ := by
  unfold binomialPartialSum
  apply Finset.sum_le_sum_of_subset
  exact Finset.range_mono (by omega)

/-- For any n, binomialPartialSum n 1 = n + 1. -/
theorem binomialPartialSum_one (n : ℕ) : binomialPartialSum n 1 = n + 1 := by
  unfold binomialPartialSum
  simp [Finset.sum_range_succ, Finset.sum_range_one,
        Nat.choose_zero_right, Nat.choose_one_right]
  omega

/-! ## Communication Complexity Basics -/

/-- The number of distinct Boolean matrices of size m × n is 2^(m*n). -/
theorem card_bool_matrix (m n : ℕ) :
    Fintype.card (Fin m → Fin n → Bool) = 2 ^ (m * n) := by
  simp [Fintype.card_fun, Fintype.card_bool, Fintype.card_fin]
  ring

/-! ## Growth Functions and VC Theory

The growth function (or shatter function) Π_F(m) counts the maximum number
of distinct labelings a concept class F can produce on m points.
By Sauer-Shelah, if VC-dim = d, then Π_F(m) ≤ ∑_{i≤d} C(m,i). -/

/-
For VC dimension d, the growth function is polynomial in m for m ≥ d.
This is a consequence of Sauer-Shelah: ∑_{i≤d} C(m,i) ≤ (em/d)^d.
We prove the weaker bound: ∑_{i≤d} C(m,i) ≤ (m + 1)^d.
-/
theorem sauer_shelah_weak_bound (m d : ℕ) (hd : 1 ≤ d) (hm : d ≤ m) :
    binomialPartialSum m d ≤ (m + 1) ^ d := by
  -- By definition of growth function, $\Pi_F(m) \leq \sum_{i=0}^d \binom{m}{i}$.
  suffices h_sum_bound : (m + 1) ^ d ≥ ∑ i ∈ Finset.range (d + 1), Nat.choose m i by
    exact h_sum_bound;
  rw [ add_pow ];
  gcongr;
  norm_num +zetaDelta at *;
  exact le_trans ( Nat.choose_le_pow _ _ ) ( Nat.le_mul_of_pos_right _ ( Nat.choose_pos ( by linarith ) ) )

/-! ## Counting Subsets -/

/-
The number of subsets of size k from n elements equals C(n,k).
-/
theorem card_subsets_size_k (n k : ℕ) :
    ((Finset.univ : Finset (Finset (Fin n))).filter (fun s => s.card = k)).card = n.choose k := by
  norm_num

/-- The total number of subsets of Fin n is 2^n. -/
theorem card_powerset_fin (n : ℕ) :
    Fintype.card (Finset (Fin n)) = 2 ^ n := by
  simp [Fintype.card_finset]

/-! ## Probabilistic Method Basics -/

/-
If the expected value of a nonneg quantity over a finite space is μ,
then there exists an element achieving at least μ. This is the
fundamental tool of the probabilistic method.
-/
theorem exists_ge_average {α : Type*} [Fintype α] [Nonempty α]
    (f : α → ℚ) (hf : ∀ a, 0 ≤ f a) :
    ∃ a : α, (∑ b : α, f b) / Fintype.card α ≤ f a := by
  by_contra! h;
  exact absurd ( Finset.sum_lt_sum_of_nonempty Finset.univ_nonempty fun a _ => h a ) ( by simp +decide [ mul_div_cancel₀, Fintype.card_ne_zero ] )

/-
Dual: there exists an element achieving at most the average.
-/
theorem exists_le_average {α : Type*} [Fintype α] [Nonempty α]
    (f : α → ℚ) :
    ∃ a : α, f a ≤ (∑ b : α, f b) / Fintype.card α := by
  by_contra! h;
  exact absurd ( Finset.sum_lt_sum_of_nonempty Finset.univ_nonempty fun a _ => h a ) ( by simp +decide [ mul_div_cancel₀, Fintype.card_ne_zero ] )

/-! ## Polynomial Method -/

/-- A nonzero polynomial of degree d over an integral domain has at most d roots.
This is the foundation of the polynomial method in combinatorics. -/
theorem poly_roots_bound {R : Type*} [CommRing R] [IsDomain R]
    (p : Polynomial R) (hp : p ≠ 0) :
    p.roots.card ≤ p.natDegree := by
  exact Polynomial.card_roots' p

/-! ## Dimension Arguments -/

/-- Linear algebra dimension argument: F^d has dimension d. -/
theorem fin_fun_finrank {F : Type*} [Field F] (d : ℕ) :
    Module.finrank F (Fin d → F) = d :=
  Module.finrank_fin_fun F

end ComplexityBounds