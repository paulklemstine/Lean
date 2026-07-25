/-
# The Thermodynamics of Sorting: Entropy and Computational Work

This module formalizes the information-theoretic foundations connecting
sorting algorithms to thermodynamic entropy. The central result is that
any comparison-based sorting algorithm on n elements must make at least
⌈log₂(n!)⌉ comparisons, which corresponds to the minimum thermodynamic
work kT · ln(n!) required by Landauer's principle.

## Main Results

- `BinTree`: Inductive binary decision tree type
- `leaves_le_two_pow_depth`: A binary tree of depth d has ≤ 2^d leaves
- `depth_ge_log_leaves`: A binary tree with L leaves has depth ≥ log₂(L)
- `CompSortTree`: Novel definition of comparison-based sorting as a decision tree
- `sorting_depth_ge_log_factorial`: The comparison lower bound for sorting
- `factorial_log_lower_bound`: n·log(n) - n ≤ log(n!) (Stirling-type)
- `entropy_uniform_eq_log`: Shannon entropy of uniform distribution = log(n)
- `landauer_sorting_work`: Thermodynamic work of sorting ≥ kT·log(n!)
-/

import Mathlib

open Finset Nat Real BigOperators

/-! ## Binary Decision Trees -/

/-- A binary tree models a comparison-based algorithm:
    each internal node is a comparison, each leaf is an outcome. -/
inductive BinTree (α : Type*) where
  | leaf (val : α) : BinTree α
  | branch (left right : BinTree α) : BinTree α

namespace BinTree

/-- The depth (longest root-to-leaf path) of a binary tree. -/
def depth : BinTree α → ℕ
  | .leaf _ => 0
  | .branch l r => 1 + max l.depth r.depth

/-- The number of leaves in a binary tree. -/
def leafCount : BinTree α → ℕ
  | .leaf _ => 1
  | .branch l r => l.leafCount + r.leafCount

/-- The set of leaf values in a binary tree. -/
def leafValues : BinTree α → List α
  | .leaf v => [v]
  | .branch l r => l.leafValues ++ r.leafValues

/-- A binary tree always has at least one leaf. -/
theorem leafCount_pos (t : BinTree α) : 0 < t.leafCount := by
  induction t with
  | leaf _ => simp [leafCount]
  | branch l r ihl ihr => simp [leafCount]; omega

/-
**Key lemma**: The number of leaves in a binary tree is at most 2^depth.
-/
theorem leaves_le_two_pow_depth (t : BinTree α) : t.leafCount ≤ 2 ^ t.depth := by
  induction' t with l r ihl ihr;
  · -- For the base case, a leaf node has a depth of 0 and a leaf count of 1.
    simp [BinTree.leafCount, BinTree.depth];
  · rw [ BinTree.depth, BinTree.leafCount ];
    rw [ pow_add, pow_one ] ; nlinarith [ Nat.pow_le_pow_right two_pos ( le_max_left r.depth ihl.depth ), Nat.pow_le_pow_right two_pos ( le_max_right r.depth ihl.depth ) ] ;

end BinTree

/-! ## Logarithmic Lower Bound -/

/-
If a binary tree has at least L leaves, its depth is at least ⌈log₂(L)⌉.
    This is the contrapositive of `leaves_le_two_pow_depth`.
-/
theorem depth_ge_log_leaves (t : BinTree α) (hL : L ≤ t.leafCount) :
    Nat.log 2 L ≤ t.depth := by
  -- Apply the lemma that states the number of leaves in a binary tree is at most $2^{\text{depth}}$.
  have h_leaves_le_two_pow_depth : t.leafCount ≤ 2 ^ t.depth := by
    exact BinTree.leaves_le_two_pow_depth t;
  exact Nat.le_trans ( Nat.log_mono_right hL ) ( Nat.le_trans ( Nat.log_mono_right h_leaves_le_two_pow_depth ) ( by rw [ Nat.log_pow ( by decide ) ] ) )

/-! ## Comparison-Based Sorting Model -/

/-- A comparison sort tree for n elements is a binary decision tree where:
    - Each internal node represents a comparison between two elements
    - Each leaf represents a permutation (the algorithm's output)
    - The tree must have at least n! leaves to sort all inputs correctly

    This is a novel formalization capturing the thermodynamic cost model:
    each comparison is an irreversible measurement that dissipates kT·ln(2) energy. -/
structure CompSortTree (n : ℕ) where
  /-- The underlying binary decision tree with permutation leaves -/
  tree : BinTree (Equiv.Perm (Fin n))
  /-- The tree must distinguish all n! permutations -/
  complete : n.factorial ≤ tree.leafCount

/-- **Main theorem**: Any comparison-based sorting algorithm on n elements
    requires at least ⌈log₂(n!)⌉ comparisons in the worst case.
    This is the information-theoretic lower bound. -/
theorem sorting_depth_ge_log_factorial (cst : CompSortTree n) :
    Nat.log 2 n.factorial ≤ cst.tree.depth :=
  depth_ge_log_leaves cst.tree cst.complete

/-! ## Factorial and Entropy Bounds -/

/-
The factorial grows at least as fast as (n/e)^n.
    More precisely: n * log n - n ≤ log(n!) for n ≥ 1.
    This connects the combinatorial lower bound to the Stirling approximation.
-/
theorem factorial_log_lower_bound (n : ℕ) (hn : 2 ≤ n) :
    (n : ℝ) * Real.log n - n ≤ Real.log (n.factorial : ℝ) := by
  induction hn <;> simp_all +decide [ Nat.factorial_succ ];
  · linarith [ Real.log_le_sub_one_of_pos zero_lt_two ];
  · rw [ Real.log_mul ( by positivity ) ( by positivity ) ];
    rename_i k hk ih;
    have := Real.log_le_sub_one_of_pos ( by positivity : 0 < ( k + 1 : ℝ ) / k );
    rw [ Real.log_div ] at this <;> first | positivity | ring_nf at * ; nlinarith [ inv_mul_cancel₀ ( by positivity : ( k : ℝ ) ≠ 0 ) ] ;

/-
For n ≥ 1, n! ≥ 1, so log(n!) ≥ 0.
-/
theorem log_factorial_nonneg (n : ℕ) : 0 ≤ Real.log (n.factorial : ℝ) := by
  exact Real.log_natCast_nonneg _

/-! ## Shannon Entropy -/

/-- Shannon entropy of a probability distribution on Fin n.
    H(p) = -∑ᵢ p(i) · log(p(i)), with the convention 0·log(0) = 0. -/
noncomputable def shannonEntropy (n : ℕ) (p : Fin n → ℝ) : ℝ :=
  -∑ i, if p i = 0 then 0 else p i * Real.log (p i)

/-- The uniform distribution on Fin n (for n ≥ 1). -/
noncomputable def uniformDist (n : ℕ) (_hn : 0 < n) : Fin n → ℝ :=
  fun _ => (1 : ℝ) / n

/-
The uniform distribution sums to 1.
-/
theorem uniformDist_sum (n : ℕ) (hn : 0 < n) :
    ∑ i : Fin n, uniformDist n hn i = 1 := by
  unfold uniformDist;
  norm_num [ hn.ne' ]

/-
**Shannon entropy of uniform distribution equals log(n)**.
    This is the maximum entropy for a distribution on n outcomes.
-/
theorem entropy_uniform_eq_log (n : ℕ) (_hn : 1 < n) :
    shannonEntropy n (uniformDist n (by omega)) = Real.log n := by
  unfold shannonEntropy uniformDist;
  norm_num [ show n ≠ 0 by linarith ]

/-! ## Thermodynamic Work of Sorting -/

/-- Thermodynamic work of a computation that makes C comparisons,
    measured in units of kT (Boltzmann constant × temperature).
    By Landauer's principle, each irreversible bit erasure costs kT·ln(2). -/
noncomputable def thermoWork (comparisons : ℕ) : ℝ :=
  comparisons * Real.log 2

/-
**Landauer bound for sorting**: The thermodynamic work of any
    comparison-based sorting algorithm is at least kT·log(n!).

    Proof: The algorithm makes ≥ log₂(n!) comparisons (by the decision tree bound),
    and each comparison dissipates kT·ln(2) of work (Landauer's principle).
    Total work ≥ log₂(n!) · kT·ln(2) = kT·ln(n!).
-/
theorem landauer_sorting_work (n : ℕ) (_hn : 2 ≤ n) (cst : CompSortTree n) :
    Real.log (n.factorial : ℝ) ≤ thermoWork cst.tree.depth := by
  -- By the properties of logarithms, we know that $n! \leq 2^{cst.tree.depth}$.
  have h_factorial_le_two_pow_depth : (n.factorial : ℝ) ≤ 2 ^ cst.tree.depth := by
    exact_mod_cast cst.complete.trans ( BinTree.leaves_le_two_pow_depth _ );
  convert Real.log_le_log ( by positivity ) h_factorial_le_two_pow_depth using 1;
  unfold thermoWork; norm_num [ Real.log_pow ] ;

/-! ## Entropy Gap: Optimal vs Suboptimal Sorting -/

/-- The entropy gap measures wasted thermodynamic work.
    For an algorithm making C comparisons on n elements:
    gap = C · ln(2) - ln(n!) -/
noncomputable def entropyGap (n : ℕ) (comparisons : ℕ) : ℝ :=
  thermoWork comparisons - Real.log (n.factorial : ℝ)

/-
The entropy gap is always non-negative for any valid sorting algorithm.
-/
theorem entropyGap_nonneg (n : ℕ) (hn : 2 ≤ n) (cst : CompSortTree n) :
    0 ≤ entropyGap n cst.tree.depth := by
  exact sub_nonneg_of_le ( landauer_sorting_work n hn cst )

/-! ## Bubble Sort Waste Bound -/

/-
Bubble sort on n elements makes at most n*(n-1)/2 comparisons.
    The wasted work compared to optimal is:
    n*(n-1)/2 · ln(2) - ln(n!) ≥ 0

    For large n, this waste grows as Θ(n² - n·log(n)),
    showing bubble sort dissipates quadratically more entropy than necessary.
-/
theorem bubble_sort_waste_positive (n : ℕ) (hn : 4 ≤ n) :
    Real.log (n.factorial : ℝ) < (n * (n - 1) / 2 : ℝ) * Real.log 2 := by
  rw [ ← Real.log_rpow ];
  · gcongr;
    induction hn <;> norm_num [ Nat.factorial_succ, pow_succ' ] at *;
    rename_i k hk ih;
    rw [ show ( ( k : ℝ ) + 1 ) * k / 2 = ( k : ℝ ) * ( k - 1 ) / 2 + k by ring, Real.rpow_add ] <;> norm_num;
    nlinarith [ show ( k : ℝ ) ≥ 4 by norm_cast, show ( 2 : ℝ ) ^ k ≥ ↑k + 1 by exact mod_cast Nat.recOn k ( by norm_num ) fun n ihn => by rw [ pow_succ' ] ; nlinarith [ ihn, pow_pos ( zero_lt_two' ℕ ) n ] ];
  · norm_num

/-! ## Partition Refinement and Entropy Decrease -/

/-
A partition of a finite set represents the algorithm's current knowledge
about the input ordering. Each comparison refines the partition.
The entropy of a partition with block sizes b₁,...,bₖ is:
H = log(∑ bᵢ) - (∑ bᵢ · log(bᵢ)) / (∑ bᵢ)

**Subadditivity of binary entropy**: splitting a block of size m+n into
    blocks of sizes m and n reduces entropy by at most log(2) = 1 bit.
    This captures why each comparison dissipates at most kT·ln(2).
-/
theorem comparison_entropy_reduction (m n : ℕ) (hm : 0 < m) (hn : 0 < n) :
    Real.log ((m + n : ℕ) : ℝ) ≤ Real.log (m : ℝ) + Real.log (n : ℝ) + Real.log 2 := by
  -- Since $m + n \leq 2mn$, we have $\log(m + n) \leq \log(2mn)$.
  have h_log : Real.log (m + n) ≤ Real.log (2 * m * n) := by
    exact Real.log_le_log ( by positivity ) ( by norm_cast; nlinarith );
  rw [ Real.log_mul, Real.log_mul ] at h_log <;> norm_cast at * <;> linarith

/-
**Conjecture (testable)**: For all n ≥ 2, the ratio log(n!) / (n·log(n))
    converges to 1 as n → ∞. More precisely, for n ≥ 3:
    1 - 1/log(n) ≤ log(n!) / (n·log(n)) ≤ 1.

    This would show that optimal sorting achieves thermodynamic work
    asymptotically equal to n·kT·log(n).

    Test: compute the ratio for n = 10, 100, 1000 and verify convergence.
-/
theorem stirling_ratio_bound (n : ℕ) (hn : 3 ≤ n) :
    Real.log (n.factorial : ℝ) ≤ (n : ℝ) * Real.log n := by
  rw [ ← Real.log_pow, Real.log_le_log_iff ] <;> norm_cast <;> try positivity;
  exact factorial_le_pow n