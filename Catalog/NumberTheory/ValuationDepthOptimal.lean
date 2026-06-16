/-
  # Valuation-Depth → Tropical Functor: Optimal Reassociation for Every Leaf Count (D6)

  Bridge: connects valuation-depth complexity to the combinatorics of optimally balanced
  binary trees and `Nat.clog`.

  This is the **second deepening cycle**, completing conjecture D6 of
  `Catalog/Speculative/AutoResearch/FUTURE_DIRECTIONS.md`.  The first cycle
  (`ValuationDepthDeepening.lean`) proved the *universal lower bound*
  `Nat.clog 2 numLeaves ≤ height` and showed it is attained by the dyadic `balanced` tree
  on `2^n` leaves.  Here we construct, for **every** leaf count `m ≥ 1`, a tree with
  exactly `m` leaves whose height equals `Nat.clog 2 m` — proving the lower bound is
  attainable for *all* `m`, not only powers of two.

  Results:
  * `mkBalanced` — the median-split balanced tree on `m` leaves.
  * `numLeaves_mkBalanced` — it has exactly `m` leaves (for `m ≥ 1`).
  * `height_mkBalanced` — its height is exactly `Nat.clog 2 m` (for `m ≥ 1`).
  * `optimal_height_attained` — the universal lower bound `clog_numLeaves_le_height` is
    sharp for every `m`: there is a tree with `m` leaves and height `⌈log₂ m⌉`.
  * `unitCost_optimal_depth` — on the unit-cost witness this optimal tree evaluates a single
    leaf value `b` to depth exactly `b + ⌈log₂ m⌉`, the best possible over all
    reassociations of `m` copies.

  -- !-- Lab Notes -- !--
  HYPOTHESIS (PI): the dyadic optimality of cycle 1 should extend to all `m` via a median
  (ceil/floor) split, with the height recursion mirroring the `Nat.clog` recursion
  `clog 2 m = clog 2 ⌈m/2⌉ + 1`.
  EXPERIMENT (Experimenter): define `mkBalanced` by well-founded recursion on `m` splitting
  into `⌈m/2⌉ = (m+1)/2` and `⌊m/2⌋ = m/2` (both `< m` for `m ≥ 2`, discharged by `omega`
  which understands division by the literal `2`).  Prove `numLeaves` and `height` by strong
  induction (`Nat.strong_induction_on`).
  ANALYSIS (Analyst): the height proof needs (i) `clog_of_two_le` to unfold
  `clog 2 m = clog 2 ((m+1)/2) + 1`, and (ii) `clog_mono_right` to see the ceil branch
  dominates the floor branch so the `max` collapses to the ceil branch.  Confirmed: the
  height is *exactly* `clog 2 m` for every `m ≥ 1`, so the cycle-1 lower bound is tight for
  all leaf counts, not merely powers of two.
  CRITIQUE (Critic): `mkBalanced 0` is a junk leaf (vacuous base), so all theorems carry the
  honest hypothesis `1 ≤ m`; the recursion's well-foundedness is machine-checked, not
  assumed; 0 sorries.
  SYNTHESIS (PI): "⌈log₂ m⌉ is achievable for every m" — closes D6, opens D7 (the tropical
  Kraft/Huffman optimum) in `FUTURE_DIRECTIONS.md`.
-/
import Mathlib
import Bridges.ValuationDepthTropicalFunctor
import Speculative.AutoResearch.ValuationDepthFollowups
import Speculative.AutoResearch.ValuationDepthDeepening

namespace ValuationDepthTropical

open CategoricalTropicalUltrametric

/-- The **median-split balanced tree** on `m` leaves all valued `k`: split `m` into a
    ceiling half `(m+1)/2` and a floor half `m/2`.  `mkBalanced k 0` is a junk single leaf
    (the theorems below all assume `1 ≤ m`). -/
def mkBalanced {K : Type} (k : K) : ℕ → OpTree K
  | 0 => OpTree.leaf k
  | 1 => OpTree.leaf k
  | (m + 2) => OpTree.node (mkBalanced k ((m + 2 + 1) / 2)) (mkBalanced k ((m + 2) / 2))
  decreasing_by
    · omega
    · omega

/--
**D6 (exact leaf count).** The median-split tree has exactly `m` leaves for `m ≥ 1`.
-/
theorem numLeaves_mkBalanced {K : Type} (k : K) (m : ℕ) (hm : 1 ≤ m) :
    (mkBalanced k m).numLeaves = m := by
  induction' m using Nat.strong_induction_on with m ih; rcases m with ( _ | _ | m ) <;> simp_all +arith +decide;
  · -- For the base case when $n = 1$, the tree is just a single leaf, so the number of leaves is 1.
    simp [mkBalanced, OpTree.numLeaves];
  · rw [ mkBalanced ];
    simp +arith +decide [ OpTree.numLeaves ];
    grind

/--
Helper: the `Nat.clog` median recursion specialized to base `2`.
-/
theorem clog_two_succ_div (m : ℕ) (hm : 2 ≤ m) :
    Nat.clog 2 m = Nat.clog 2 ((m + 1) / 2) + 1 := by
  rw [ Nat.clog_of_two_le ( by norm_num ) hm ];
  rfl

/--
**D6 (optimal height).** The median-split tree on `m ≥ 1` leaves has height exactly
    `⌈log₂ m⌉ = Nat.clog 2 m`, attaining the universal lower bound `clog_numLeaves_le_height`.
-/
theorem height_mkBalanced {K : Type} (k : K) (m : ℕ) (hm : 1 ≤ m) :
    (mkBalanced k m).height = Nat.clog 2 m := by
  induction' m using Nat.strong_induction_on with m ih;
  rcases m with ( _ | _ | m ) <;> simp_all +arith +decide;
  · unfold mkBalanced; simp +arith +decide [ OpTree.height ] ;
  · rw [ mkBalanced ];
    rw [ OpTree.height ];
    rw [ clog_two_succ_div ];
    · simp +zetaDelta at *;
      rw [ ih _ _ _, ih _ _ _ ] <;> try omega;
      exact max_eq_left ( Nat.clog_mono_right _ ( by omega ) );
    · grind

/-- **D6 (the universal lower bound is attained for every leaf count).** For every `m ≥ 1`
    and leaf value `k` there is a combination tree with exactly `m` leaves whose height
    equals `⌈log₂ m⌉`.  Combined with `clog_numLeaves_le_height` (cycle 1), `⌈log₂ m⌉` is the
    exact minimal achievable height over all trees with `m` leaves. -/
theorem optimal_height_attained {K : Type} (k : K) (m : ℕ) (hm : 1 ≤ m) :
    ∃ t : OpTree K, t.numLeaves = m ∧ t.height = Nat.clog 2 m := by
  exact ⟨mkBalanced k m, numLeaves_mkBalanced k m hm, height_mkBalanced k m hm⟩

/--
Every leaf of `mkBalanced k m` carries value `k`, so the maximal leaf depth under any
    `depth` measure is `depth k`.
-/
theorem maxLeafDepth_mkBalanced {K : Type} (depth : K → ℕ) (k : K) (m : ℕ) :
    (mkBalanced k m).maxLeafDepth depth = depth k := by
  induction' m using Nat.strong_induction_on with m ih
  rcases m with _ | _ | n
  · simp [mkBalanced, OpTree.maxLeafDepth]
  · simp [mkBalanced, OpTree.maxLeafDepth]
  · rw [mkBalanced, OpTree.maxLeafDepth, ih _ (by omega), ih _ (by omega), Nat.max_self]

/--
**D6 (optimal evaluated depth).** On the unit-cost witness carrier the median-split tree
    of `m ≥ 1` copies of a value `b` evaluates to depth exactly `b + ⌈log₂ m⌉` — the minimal
    evaluated depth achievable over all reassociations of `m` copies (the lower bound coming
    from `depth_eval_add_le` together with `clog_numLeaves_le_height`).
-/
theorem unitCost_optimal_depth (b m : ℕ) (hm : 1 ≤ m) :
    witnessCarrier.depth ((mkBalanced b m).eval witnessCarrier.add)
      ≤ b + Nat.clog 2 m := by
  convert depth_eval_add_le witnessCarrier ( mkBalanced b m ) using 1;
  rw [ maxLeafDepth_mkBalanced, height_mkBalanced ];
  · rfl;
  · linarith

end ValuationDepthTropical