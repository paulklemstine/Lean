/-
# The Thermodynamics of Sorting I: The Entropy Lower Bound

This module formalizes the information-theoretic (equivalently, by Landauer's principle,
thermodynamic) lower bound on comparison-based sorting.

A comparison-based sorting algorithm is modelled as a **binary decision tree**: each
internal node is a single comparison `a ≤ b` with two outcomes, and each leaf corresponds
to one possible output ordering. To be *correct*, the tree must be able to distinguish all
`n !` permutations of the input, so it must have at least `n !` leaves.

The physical narrative: sorting collapses the uniform distribution over `n !` input
orderings (entropy `log₂(n!)` bits) to a single sorted output (entropy `0`). By Landauer's
principle each bit of entropy reduction costs at least `kT · ln 2` of thermodynamic work,
so the minimal work is `W_min = kT · ln 2 · log₂(n!)`. Since each comparison yields at most
one bit, the *number of comparisons in the worst case* (the tree height) is at least
`log₂(n!)`.

## Main results

* `DTree.leaves_le_two_pow_height`: a binary tree of height `h` has at most `2 ^ h` leaves.
* `sorting_comparison_lower_bound`: any decision tree that sorts `n` elements (i.e. has at
  least `n !` leaves) has height at least `⌈log₂(n!)⌉ = Nat.clog 2 (n!)`. This is the
  entropy lower bound.
* `factorial_ge_half_pow`: `(n/2)^(n/2) ≤ n!`, the elementary lower bound on the factorial.
* `log_factorial_ge`: `(n/2) · ⌊log₂(n/2)⌋ ≤ ⌊log₂(n!)⌋`, i.e. `log₂(n!) = Ω(n log n)`.
* `sorting_nlogn_lower_bound`: consequently any correct comparison sort performs
  `Ω(n log n)` comparisons — the `n log n` lower bound as a consequence of entropy
  (second-law) accounting.
-/

import Mathlib

namespace SortingThermodynamics

open Nat

/-- A binary decision tree modelling a comparison-based sorting algorithm.  Each `node`
is one comparison with two branches; each `leaf` is one possible output ordering. -/
inductive DTree where
  | leaf : DTree
  | node : DTree → DTree → DTree
deriving Repr

namespace DTree

/-- Number of leaves = number of distinguishable outputs of the algorithm. -/
def leaves : DTree → ℕ
  | leaf => 1
  | node l r => l.leaves + r.leaves

/-- Height = worst-case number of comparisons performed along a root-to-leaf path. -/
def height : DTree → ℕ
  | leaf => 0
  | node l r => 1 + max l.height r.height

@[simp] theorem leaves_leaf : leaves leaf = 1 := rfl
@[simp] theorem height_leaf : height leaf = 0 := rfl

/-
A binary tree of height `h` has at most `2 ^ h` leaves.
-/
theorem leaves_le_two_pow_height (t : DTree) : t.leaves ≤ 2 ^ t.height := by
  induction' t with l r ihl ihr;
  · decide +revert;
  · -- By definition of height, we have height (node l r) = 1 + max l.height r.height.
    have h_height : (l.node r).height = 1 + max l.height r.height := by
      rfl;
    cases max_choice l.height r.height <;> simp_all +decide [ pow_add ];
    · linarith! [ pow_le_pow_right₀ ( by decide : 1 ≤ 2 ) ‹_›, show ( l.node r ).leaves = l.leaves + r.leaves from rfl ];
    · rw [ show ( l.node r ).leaves = l.leaves + r.leaves by rfl ] ; linarith [ pow_le_pow_right₀ ( by decide : 1 ≤ 2 ) ‹_› ]

end DTree

/-- A decision tree *sorts `n` elements* if it has at least `n !` leaves: it must be able
to produce a distinct output for each of the `n !` permutations of its input. -/
def Sorts (t : DTree) (n : ℕ) : Prop := n ! ≤ t.leaves

/-
**Entropy lower bound.** Any decision tree that correctly sorts `n` elements has height
at least `⌈log₂(n!)⌉`.  Equivalently, its worst-case comparison count is at least the
Shannon entropy `log₂(n!)` of the uniform distribution over the `n !` input orderings.
-/
theorem sorting_comparison_lower_bound (t : DTree) (n : ℕ) (h : Sorts t n) :
    Nat.clog 2 (n !) ≤ t.height := by
  rw [ Nat.le_iff_lt_or_eq ];
  refine' lt_or_eq_of_le ( Nat.le_of_not_lt fun h' => _ );
  -- Since $t.height < clog 2 n !$, we have $2^{t.height} < n !$.
  have h_exp : 2 ^ t.height < n ! := by
    contrapose! h';
    exact Nat.le_trans ( clog_mono_right 2 h' ) ( by norm_num [ Nat.clog_pow ] );
  exact h_exp.not_ge ( le_trans h ( DTree.leaves_le_two_pow_height t ) )

/-
Elementary lower bound on the factorial: `(n/2)^(n/2) ≤ n!`.

The top `⌈n/2⌉ ≥ n/2` factors of `n! = 1·2·⋯·n` are each at least `n/2 + 1 > n/2`.
-/
theorem factorial_ge_half_pow (n : ℕ) : (n / 2) ^ (n / 2) ≤ n ! := by
  -- For $n \geq 4$, consider the following inequality:
  have h_ineq : (n / 2) ^ (n / 2) ≤ ∏ i ∈ Finset.Icc (n / 2 + 1) n, i := by
    refine' le_trans _ ( Finset.prod_le_prod' fun i hi => show i ≥ n / 2 + 1 from Finset.mem_Icc.mp hi |>.1 ) ; norm_num;
    exact Nat.pow_le_pow_left ( by omega ) _ |> le_trans <| Nat.pow_le_pow_right ( by omega ) <| by omega;
  -- Since $\prod_{i=n/2+1}^n i$ is a subset of $\prod_{i=1}^n i$, we have $\prod_{i=n/2+1}^n i \leq \prod_{i=1}^n i$.
  have h_subset : ∏ i ∈ Finset.Icc (n / 2 + 1) n, i ≤ ∏ i ∈ Finset.Icc 1 n, i := by
    exact Finset.prod_le_prod_of_subset_of_one_le' ( Finset.Icc_subset_Icc ( by omega ) le_rfl ) fun _ _ _ => by linarith [ Finset.mem_Icc.mp ‹_› ] ;
  exact h_ineq.trans <| h_subset.trans <| by erw [ Finset.prod_Ico_id_eq_factorial ] ;

/-
For `1 < b`, `k · ⌊log_b a⌋ ≤ ⌊log_b (a^k)⌋`.
-/
theorem log_pow_ge (b a k : ℕ) (hb : 1 < b) :
    k * Nat.log b a ≤ Nat.log b (a ^ k) := by
  by_cases ha : a = 0;
  · cases k <;> aesop;
  · exact Nat.le_log_of_pow_le hb ( by rw [ pow_mul' ] ; exact Nat.pow_le_pow_left ( Nat.pow_log_le_self _ ha ) _ )

/-
`log₂(n!) = Ω(n log n)`: concretely `(n/2)·⌊log₂(n/2)⌋ ≤ ⌊log₂(n!)⌋`.
-/
theorem log_factorial_ge (n : ℕ) :
    (n / 2) * Nat.log 2 (n / 2) ≤ Nat.log 2 (n !) := by
  convert log_pow_ge 2 ( n / 2 ) ( n / 2 ) ( by decide ) |> le_trans <| Nat.log_mono_right <| factorial_ge_half_pow n using 1

/-
**The `n log n` lower bound from the second law.** Any correct comparison sort of `n`
elements performs at least `(n/2)·⌊log₂(n/2)⌋` comparisons in the worst case, which is
`Ω(n log n)`.  This is the entropy `log₂(n!)` bound made asymptotically explicit.
-/
theorem sorting_nlogn_lower_bound (t : DTree) (n : ℕ) (h : Sorts t n) :
    (n / 2) * Nat.log 2 (n / 2) ≤ t.height := by
  refine le_trans ?_ ( sorting_comparison_lower_bound t n h );
  convert log_factorial_ge n |> le_trans <| Nat.log_le_clog _ _ using 1

end SortingThermodynamics