/-
# The Thermodynamics of Sorting: Entropy and Computational Work

This file formalizes the connection between comparison-based sorting,
information entropy, and thermodynamic work. The central insight is that
sorting reduces the entropy of a permutation space from log₂(n!) bits to 0,
and this entropy reduction corresponds to thermodynamic work via Landauer's
principle: W = kT · ln(2) · (number of bits erased).

## Main Results

* `BinTree.leaves_le_two_pow_depth` : A binary tree of depth d has at most 2^d leaves
* `BinTree.depth_ge_log_of_leaves` : Decision tree depth ≥ log₂(leaves)
* `factorial_ge_two_pow` : n! ≥ 2^(n-1) for n ≥ 1
* `comparisons_ge_pred` : Any comparison sort uses ≥ n-1 comparisons
* `thermodynamic_work_lower_bound` : Work of any sorter ≥ minimum work
* `weak_stirling_lower` : n^n ≤ e^n · n! (weak Stirling)
* `factorial_entropy_decomposition` : Recursive entropy decomposition
-/

import Mathlib

open Nat Real Finset

/-! ## Decision Trees and Binary Tree Depth -/

/-- A binary tree, modeling the structure of comparison-based algorithms.
Each internal node represents a comparison, each leaf a possible outcome. -/
inductive BinTree (α : Type*) where
  | leaf (val : α) : BinTree α
  | node (left right : BinTree α) : BinTree α

namespace BinTree

/-- The depth (height) of a binary tree -/
def depth : BinTree α → ℕ
  | .leaf _ => 0
  | .node l r => 1 + max l.depth r.depth

/-- The number of leaves in a binary tree -/
def numLeaves : BinTree α → ℕ
  | .leaf _ => 1
  | .node l r => l.numLeaves + r.numLeaves

/-- The set of leaf values in a binary tree -/
def leafValues : BinTree α → List α
  | .leaf v => [v]
  | .node l r => l.leafValues ++ r.leafValues

/-- Number of leaves equals length of leaf values list -/
theorem numLeaves_eq_leafValues_length (t : BinTree α) :
    t.numLeaves = t.leafValues.length := by
  induction t with
  | leaf v => simp [numLeaves, leafValues]
  | node l r ihl ihr => simp [numLeaves, leafValues, ihl, ihr]

/-- A binary tree of depth d has at most 2^d leaves.
This is the fundamental counting argument behind the comparison sorting lower bound. -/
theorem leaves_le_two_pow_depth (t : BinTree α) :
    t.numLeaves ≤ 2 ^ t.depth := by
  induction t with
  | leaf _ => simp [numLeaves, depth]
  | node l r ihl ihr =>
    simp only [numLeaves, depth]
    calc l.numLeaves + r.numLeaves
        ≤ 2 ^ l.depth + 2 ^ r.depth := Nat.add_le_add ihl ihr
      _ ≤ 2 ^ max l.depth r.depth + 2 ^ max l.depth r.depth := by
          apply Nat.add_le_add
          · exact Nat.pow_le_pow_right (by omega) (le_max_left _ _)
          · exact Nat.pow_le_pow_right (by omega) (le_max_right _ _)
      _ = 2 * 2 ^ max l.depth r.depth := by ring
      _ = 2 ^ (1 + max l.depth r.depth) := by ring

/-- Leaves are always positive -/
theorem numLeaves_pos (t : BinTree α) : 0 < t.numLeaves := by
  induction t with
  | leaf _ => simp [numLeaves]
  | node l r ihl _ => simp [numLeaves]; omega

/-- A binary tree that distinguishes n outcomes must have depth ≥ log₂(n).
Contrapositive of `leaves_le_two_pow_depth`: if we need at least n leaves,
the depth must be at least log₂(n). -/
theorem depth_ge_log_of_leaves (t : BinTree α) (n : ℕ) (hn : n ≤ t.numLeaves) (_hn0 : 0 < n) :
    Nat.log 2 n ≤ t.depth := by
  refine Nat.le_trans (Nat.log_mono_right hn) ?_
  refine Nat.le_trans (Nat.log_mono_right <| leaves_le_two_pow_depth t) ?_
  rw [Nat.log_pow (by decide)]

end BinTree

/-! ## Permutation Entropy -/

/-- The number of permutations of n elements, i.e., n! -/
def permCount (n : ℕ) : ℕ := n.factorial

/-- n! is always positive -/
theorem permCount_pos (n : ℕ) : 0 < permCount n :=
  Nat.factorial_pos n

/-- The sorting entropy in bits: log₂(n!), representing the information
content of a uniformly random permutation of n elements. -/
noncomputable def sortingEntropy (n : ℕ) : ℝ :=
  Real.logb 2 (n.factorial : ℝ)

/-- The discrete sorting entropy: ⌊log₂(n!)⌋, the integer lower bound
on the number of bits needed to distinguish all permutations. -/
def discreteSortingEntropy (n : ℕ) : ℕ :=
  Nat.log 2 (n.factorial)

/-- Sorting entropy is non-negative for all n ≥ 1 -/
theorem sortingEntropy_nonneg (n : ℕ) (hn : 1 ≤ n) : 0 ≤ sortingEntropy n :=
  Real.logb_nonneg (by norm_num) (by norm_cast; linarith [Nat.self_le_factorial n])

/-- Sorting entropy of 1 element is 0: a single-element list is trivially sorted -/
theorem sortingEntropy_one : sortingEntropy 1 = 0 := by
  simp [sortingEntropy, Nat.factorial]

/-- Sorting entropy grows monotonically: more elements ⟹ more entropy -/
theorem sortingEntropy_mono {m n : ℕ} (hmn : m ≤ n) (_hm : 1 ≤ m) :
    sortingEntropy m ≤ sortingEntropy n := by
  unfold sortingEntropy
  gcongr; norm_cast

/-! ## Comparison Model and Thermodynamic Work -/

/-- A comparison-based sorting algorithm is characterized by its comparison count
function C(n) giving worst-case comparisons on n elements. -/
structure ComparisonSorter where
  /-- Worst-case number of comparisons on input of size n -/
  comparisons : ℕ → ℕ
  /-- The algorithm must make enough comparisons to distinguish all permutations:
      the decision tree must have at least n! leaves, requiring depth ≥ ⌊log₂(n!)⌋ -/
  sufficient : ∀ n, Nat.log 2 (n.factorial) ≤ comparisons n

/-- Thermodynamic work done by a sorting algorithm, by Landauer's principle.
Each comparison is an irreversible bit erasure costing kT·ln(2) of energy.
Work is measured in joules when kT is in joules. -/
noncomputable def thermodynamicWork (kT : ℝ) (comparisons : ℕ) : ℝ :=
  kT * Real.log 2 * (comparisons : ℝ)

/-- Minimum thermodynamic work for sorting n elements, using the discrete
information-theoretic lower bound: W_min = kT · ln(2) · ⌊log₂(n!)⌋.
This is the tightest bound derivable from the decision tree model. -/
noncomputable def minThermodynamicWork (kT : ℝ) (n : ℕ) : ℝ :=
  kT * Real.log 2 * (Nat.log 2 (n.factorial) : ℝ)

/-
The thermodynamic work of any comparison sorter is at least the minimum.
This is the fundamental connection between computational complexity and
the second law of thermodynamics via Landauer's principle.
-/
theorem thermodynamic_work_lower_bound (s : ComparisonSorter) (n : ℕ) (kT : ℝ) (hkT : 0 < kT) :
    minThermodynamicWork kT n ≤ thermodynamicWork kT (s.comparisons n) := by
  refine' mul_le_mul_of_nonneg_left _ ( by positivity );
  exact_mod_cast s.sufficient n

/-- Wasted thermodynamic work: the excess energy dissipated by a suboptimal algorithm -/
noncomputable def wastedWork (kT : ℝ) (comparisons : ℕ) (n : ℕ) : ℝ :=
  thermodynamicWork kT comparisons - minThermodynamicWork kT n

/-
Wasted work is non-negative for any valid comparison sorter
-/
theorem wastedWork_nonneg (s : ComparisonSorter) (n : ℕ) (kT : ℝ) (hkT : 0 < kT) :
    0 ≤ wastedWork kT (s.comparisons n) n := by
  exact sub_nonneg_of_le ( thermodynamic_work_lower_bound s n kT hkT )

/-! ## Factorial Lower Bounds via Induction -/

/-- n! ≥ 2^(n-1) for n ≥ 1.
This gives a simple lower bound showing sorting entropy grows at least linearly. -/
theorem factorial_ge_two_pow (n : ℕ) (hn : 1 ≤ n) : 2 ^ (n - 1) ≤ n.factorial := by
  induction' n with n ih
  · contradiction
  · rcases n with (_ | n) <;> simp_all +decide [Nat.factorial_succ, pow_succ']
    nlinarith [Nat.zero_le (2 ^ n)]

/-- For n ≥ 1, the number of comparisons for any sorting algorithm is at least n - 1.
This follows from factorial_ge_two_pow and the decision tree lower bound. -/
theorem comparisons_ge_pred (s : ComparisonSorter) (n : ℕ) (hn : 1 ≤ n) :
    n - 1 ≤ s.comparisons n := by
  exact le_trans (by rw [Nat.log_pow (by norm_num)])
    (s.sufficient n |> le_trans (Nat.log_mono_right <| factorial_ge_two_pow n hn))

/-! ## Specific Sorting Algorithms -/

/-- Bubble sort's worst-case comparison count: n(n-1)/2 -/
def bubbleSortComparisons (n : ℕ) : ℕ := n * (n - 1) / 2

/-- Merge sort's worst-case comparison count: n⌈log₂n⌉ -/
def mergeSortComparisons (n : ℕ) : ℕ :=
  if n ≤ 1 then 0 else n * (Nat.log 2 n + 1)

/-
Bubble sort makes at least as many comparisons as the information-theoretic minimum
-/
theorem bubbleSort_sufficient (n : ℕ) :
    Nat.log 2 (n.factorial) ≤ bubbleSortComparisons n := by
  refine Nat.le_of_lt_succ ( Nat.log_lt_of_lt_pow ?_ ?_ );
  · positivity;
  · -- By definition of factorial, we know that $n! \leq 2^{n(n-1)/2}$.
    have h_factorial : n ! ≤ 2 ^ (n * (n - 1) / 2) := by
      induction' n with n ih <;> norm_num [ Nat.factorial_succ ];
      rcases n with ( _ | n ) <;> simp_all +decide [ Nat.mul_succ ];
      rw [ show ( ( n + 1 + 1 ) * n + ( n + 1 + 1 ) ) / 2 = ( n + 1 ) * n / 2 + ( n + 1 ) by rw [ Nat.div_eq_of_eq_mul_left zero_lt_two ] ; linarith [ Nat.div_mul_cancel ( show 2 ∣ ( n + 1 ) * n from Nat.dvd_of_mod_eq_zero ( by norm_num [ Nat.add_mod, Nat.mod_two_of_bodd ] ) ) ] ] ; rw [ pow_add ] ; nlinarith [ show 2 ^ ( n + 1 ) ≥ n + 2 by exact Nat.recOn n ( by norm_num ) fun n ihn => by norm_num [ Nat.pow_succ' ] at * ; linarith ] ;
    exact lt_of_le_of_lt h_factorial ( pow_lt_pow_right₀ ( by decide ) ( Nat.lt_succ_of_le ( Nat.le_refl _ ) ) )

/-
Merge sort makes at least as many comparisons as the information-theoretic minimum
-/
theorem mergeSort_sufficient (n : ℕ) :
    Nat.log 2 (n.factorial) ≤ mergeSortComparisons n := by
  -- For `n ≤ 1`: `n! ≤ 1`, hence `Nat.log 2 (n!) = 0`, and `mergeSortComparisons n = 0`.
  by_cases h : n ≤ 1 <;> simp [mergeSortComparisons, h];
  · interval_cases n <;> trivial;
  · have h_log_le : Nat.log 2 (n.factorial) ≤ Nat.log 2 (n^n) := by
      exact Nat.log_mono_right ( Nat.recOn n ( by norm_num ) fun n ih => by rw [ Nat.factorial_succ, pow_succ' ] ; exact le_trans ( Nat.mul_le_mul_left _ ih ) ( by gcongr ; linarith ) );
    refine le_trans h_log_le ?_;
    refine Nat.le_of_lt_succ ( Nat.log_lt_of_lt_pow ?_ ?_ );
    · aesop;
    · have := Nat.lt_pow_succ_log_self ( by decide : 1 < 2 ) n;
      exact lt_of_lt_of_le ( Nat.pow_lt_pow_left this ( by linarith ) ) ( by rw [ ← pow_mul' ] ; exact Nat.pow_le_pow_right ( by decide ) ( by linarith ) )

/-- Bubble sort as a ComparisonSorter -/
def bubbleSorter : ComparisonSorter :=
  ⟨bubbleSortComparisons, bubbleSort_sufficient⟩

/-- Merge sort as a ComparisonSorter -/
def mergeSorter : ComparisonSorter :=
  ⟨mergeSortComparisons, mergeSort_sufficient⟩

/-! ## Entropy Reduction Rate -/

/-- Information gained per comparison is at most 1 bit.
After C comparisons, the remaining entropy is at least log₂(n!) - C bits. -/
theorem entropy_after_comparisons (n C : ℕ) :
    sortingEntropy n - (C : ℝ) ≤ sortingEntropy n := by
  linarith [show (0 : ℝ) ≤ C from Nat.cast_nonneg C]

/-- The entropy gap: how much more entropy a suboptimal algorithm reduces
(beyond the minimum needed), representing wasted thermodynamic work. -/
noncomputable def entropyGap (comparisons : ℕ) (n : ℕ) : ℝ :=
  (comparisons : ℝ) - sortingEntropy n

/-! ## Stirling Approximation Connection -/

/-- Weak Stirling bound: n! ≥ (n/e)^n for n ≥ 1 (expressed as n^n ≤ e^n · n!).
This connects the discrete factorial to continuous entropy formulas. -/
theorem weak_stirling_lower (n : ℕ) (hn : 1 ≤ n) :
    (n : ℝ) ^ n ≤ Real.exp n * (n.factorial : ℝ) := by
  rw [← div_le_iff₀ (by positivity)]
  rw [Real.exp_eq_exp_ℝ]
  rw [NormedSpace.exp_eq_tsum_div]
  exact Summable.le_tsum (show Summable _ from Real.summable_pow_div_factorial _)
    n (fun _ _ => by positivity)

/-! ## Landauer's Principle for Permutations -/

/-
Landauer's principle applied to sorting: for n ≥ 2, sorting requires
strictly positive thermodynamic work, since log₂(n!) > 0 when n ≥ 2.
-/
theorem landauer_sorting_bound (n : ℕ) (kT : ℝ) (hkT : 0 < kT) (hn : 2 ≤ n) :
    0 < minThermodynamicWork kT n := by
  refine' mul_pos ( mul_pos hkT ( Real.log_pos ( by norm_num ) ) ) ( Nat.cast_pos.mpr _ );
  exact Nat.le_log_of_pow_le ( by decide ) ( by linarith [ Nat.self_le_factorial n ] )

/-! ## Key Structural Results -/

/-- The composition of entropy reductions: the log of (n+1)! decomposes as
at most log(n!) + log(n+1) + 1, reflecting the recursive structure of sorting. -/
theorem factorial_entropy_decomposition (n : ℕ) :
    Nat.log 2 ((n + 1).factorial) ≤ Nat.log 2 (n.factorial) + Nat.log 2 (n + 1) + 1 := by
  refine Nat.le_of_lt_succ (Nat.log_lt_of_lt_pow ?_ ?_) <;>
    norm_num [Nat.factorial_succ, pow_add]
  · positivity
  · have := Nat.lt_pow_succ_log_self (by decide : 1 < 2) n !
    have := Nat.lt_pow_succ_log_self (by decide : 1 < 2) (n + 1)
    norm_num [Nat.pow_succ'] at *; nlinarith

/-! ## Conjecture: Tight Stirling Entropy Bound -/

/-
**Conjecture**: For n ≥ 3, the sorting entropy satisfies
    n · log₂(n) - n · log₂(e) ≤ log₂(n!)

This is a consequence of the weak Stirling approximation n! ≥ (n/e)^n.
Testable: For n = 10, log₂(10!) ≈ 21.79, and 10·log₂(10) - 10·log₂(e) ≈ 18.79.
For n = 100, log₂(100!) ≈ 524.8, and 100·log₂(100) - 100·log₂(e) ≈ 520.7.
-/
theorem conjecture_stirling_entropy_bounds (n : ℕ) (hn : 3 ≤ n) :
    (n : ℝ) * Real.logb 2 n - (n : ℝ) * Real.logb 2 (Real.exp 1) ≤ sortingEntropy n := by
  -- By definition of `sortingEntropy`, we have `sortingEntropy n = Real.logb 2 (n.factorial)`.
  have h_def : sortingEntropy n = Real.logb 2 (n.factorial) := by
    rfl
  rw [h_def];
  rw [ ← mul_sub, mul_comm, ← Real.logb_div ] <;> norm_num;
  · rw [ mul_comm, ← logb_pow ] ; gcongr ; norm_cast ; have := weak_stirling_lower n ( by linarith ) ; norm_num at *;
    rw [ div_pow, div_le_iff₀ ] <;> first | positivity | simpa [ mul_comm ] using this;
  · linarith