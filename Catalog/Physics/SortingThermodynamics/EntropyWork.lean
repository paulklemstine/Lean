import Computation.ReversibleSortingBennett
import Computation.FactorialNumberSystem

/-!
# Sorting: decision-tree entropy, reversible history, and Landauer work

Sorting distinct inputs has `n!` possible orderings.  This chapter separates three
quantities that are often conflated:

* the height of a binary comparison tree;
* the information erased by a many-to-one sorting map;
* the history space required to make that map reversible.

The same factorial controls all three, but raw comparison count does not itself measure
thermodynamic work: redundant comparisons may be inserted without changing the computed
map or its erased information.
-/

open Function

namespace SortingEntropyWork

/-- The shape of a binary comparison tree. -/
inductive ComparisonTree where
  | leaf : ComparisonTree
  | branch : ComparisonTree → ComparisonTree → ComparisonTree

namespace ComparisonTree

/-- Number of terminal transcripts. -/
def leaves : ComparisonTree → ℕ
  | leaf => 1
  | branch l r => leaves l + leaves r

/-- Worst-case number of comparisons. -/
def height : ComparisonTree → ℕ
  | leaf => 0
  | branch l r => 1 + max (height l) (height r)

/-- Insert `r` redundant comparison levels above a tree. -/
def pad : ℕ → ComparisonTree → ComparisonTree
  | 0, t => t
  | r + 1, t => branch (pad r t) (pad r t)

/-
A binary tree of height `h` has at most `2^h` terminal transcripts.
-/
theorem leaves_le_two_pow_height (t : ComparisonTree) :
    leaves t ≤ 2 ^ height t := by
      induction' t with l r ihl ihr;
      · decide +revert;
      · refine le_trans ( add_le_add ihl ihr ) ?_;
        simp +arith +decide [ ComparisonTree.height ];
        cases max_cases l.height r.height <;> simp_all +decide [ pow_add ];
        · linarith [ pow_le_pow_right₀ ( by decide : 1 ≤ 2 ) ‹_› ];
        · linarith [ pow_le_pow_right₀ ( by decide : 1 ≤ 2 ) ( by linarith : l.height ≤ r.height ) ]

/-
Padding adds an arbitrary number of comparisons to every execution.
-/
theorem height_pad (r : ℕ) (t : ComparisonTree) :
    height (pad r t) = r + height t := by
      induction' r with r ih generalizing t <;> simp_all +arith +decide;
      · rfl;
      · rw [ show pad ( r + 1 ) t = ComparisonTree.branch ( pad r t ) ( pad r t ) from rfl, ComparisonTree.height ] ; simp +arith +decide [ ih ]

/-
Padding never decreases the number of available transcripts.
-/
theorem leaves_le_pad (r : ℕ) (t : ComparisonTree) :
    leaves t ≤ leaves (pad r t) := by
      induction' r with r ih generalizing t;
      · rfl;
      · exact le_trans ( ih t ) ( by exact le_add_of_nonneg_left ( Nat.zero_le _ ) )

end ComparisonTree

/-- A comparison-tree shape can distinguish all orderings of `n` distinct items when it
has at least `n!` terminal transcripts. -/
def SortsOrderings (t : ComparisonTree) (n : ℕ) : Prop :=
  n.factorial ≤ t.leaves

/-
**Exact information lower bound.** Every comparison tree capable of distinguishing
all `n!` orderings has worst-case height at least `⌈log₂(n!)⌉`.
-/
theorem comparison_lower_bound (t : ComparisonTree) (n : ℕ)
    (hs : SortsOrderings t n) :
    Nat.clog 2 n.factorial ≤ t.height := by
      exact Nat.le_trans ( Nat.clog_mono_right _ <| show n.factorial ≤ 2 ^ t.height from hs.trans <|ComparisonTree.leaves_le_two_pow_height t ) ( by norm_num )

/-
Redundant comparisons can increase worst-case comparison count arbitrarily while
preserving the ability to sort the same inputs.
-/
theorem redundant_comparisons_preserve_sorting (t : ComparisonTree) (n r : ℕ)
    (hs : SortsOrderings t n) :
    SortsOrderings (t.pad r) n ∧ (t.pad r).height = r + t.height := by
      exact ⟨ le_trans hs ( ComparisonTree.leaves_le_pad r t ), ComparisonTree.height_pad r t ⟩

/-
**Three-way factorial synthesis.** A correct comparison tree obeys the entropy lower
bound; irreversible sorting erases exactly `log₂(n!)` bits; and every reversible
implementation needs at least `n!` history states.

Repaired statement: the erased-information input `sorting_info_erased` is available for
`1 ≤ n`, so that hypothesis is carried explicitly here.
-/
theorem factorial_controls_comparisons_entropy_and_history
    (t : ComparisonTree) (n : ℕ) (hn : 1 ≤ n) (hs : SortsOrderings t n)
    (Aux : Type*) [Fintype Aux]
    (e : Equiv.Perm (Fin n) ≃ Unit × Aux)
    (hc : ∀ σ, (e σ).1 = sortingFunction n σ) :
    Nat.clog 2 n.factorial ≤ t.height ∧
    infoErased (sortingFunction n) = Real.logb 2 n.factorial ∧
    n.factorial ≤ Fintype.card Aux := by
      refine ⟨comparison_lower_bound t n hs, sorting_info_erased n hn, ?_⟩
      convert sorting_history_lower_bound n Aux e hc using 1
      simp +decide [ Fintype.card_perm ]

/-
**Exact Landauer scale for sorting.** With natural logarithms, erasing the unknown
input permutation costs `kT · log(n!)`.  The factor `log 2` in the per-bit cost cancels
the change of base in `log₂(n!)`.

Repaired statement: as above, the hypothesis `1 ≤ n` is carried explicitly.
-/
theorem sorting_landauer_gap_exact (n : ℕ) (hn : 1 ≤ n) (kT : ℝ) :
    landauerGap (sortingFunction n) kT = kT * Real.log n.factorial := by
      unfold landauerGap landauerCost
      rw [sorting_info_erased n hn, Real.logb]
      have h2 : Real.log 2 ≠ 0 := ne_of_gt (Real.log_pos (by norm_num))
      field_simp

/-
The Landauer work assigned to irreversible sorting is unchanged when redundant
comparison levels are inserted.  Consequently, comparison count alone cannot equal
logical-erasure work without an additional physical model for how comparisons are reset.
-/
theorem padding_changes_comparisons_not_landauer_work
    (t : ComparisonTree) (n r : ℕ) (hs : SortsOrderings t n) (kT : ℝ) :
    SortsOrderings (t.pad r) n ∧
    (t.pad r).height = r + t.height ∧
    landauerGap (sortingFunction n) kT = landauerGap (sortingFunction n) kT := by
      exact ⟨ redundant_comparisons_preserve_sorting t n r hs |>.1, redundant_comparisons_preserve_sorting t n r hs |>.2, rfl ⟩

-- !-- Lab Notes -- !--
-- Hypothesis: A single factorial invariant should link decision-tree complexity,
-- reversible history, and thermodynamic erasure, while exposing the proposed law
-- “one comparison costs one bit” as too coarse.
-- Experiment: Small factorials and their binary ceilings were tabulated separately.
-- Padding a tree by duplicating both branches raises every path length while preserving
-- its suitability for the same sorting problem.
-- Analysis: The lower bound is combinatorial: `n! ≤ leaves ≤ 2^height`.  The thermodynamic
-- statement is instead a property of the computed many-to-one map.  Reversibility restores
-- the missing permutation as an auxiliary history with at least `n!` states.
-- Critique: `SortsOrderings` records transcript capacity, not comparison semantics, so it
-- gives a necessary lower bound rather than a full correctness specification.  Moreover,
-- mergesort does not always use exactly `log₂(n!)` comparisons, and bubble sort does not
-- erase one independent bit per comparison.  The padding theorem gives a structural
-- counterexample to identifying raw comparison count with Landauer work.
-- Synthesis: The surviving claim is a three-way lower-bound principle.  Factorial entropy
-- constrains comparison depth and reversible history, whereas actual dissipation depends
-- on which information is eventually erased and on the physical implementation.
-- !-- end Lab Notes -- !--

end SortingEntropyWork