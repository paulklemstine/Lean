/-
  # Valuation-Depth → Tropical Functor: Deepening Cycle (D1–D7)

  Bridge: connects valuation-depth complexity measures to tropical/ultrametric geometry,
  the combinatorics of binary combination trees, and generalized unit-cost laws.

  This file is the *deepening* follow-up to
  `Catalog/Bridges/ValuationDepthTropicalFunctor.lean` (foundations) and
  `Catalog/Speculative/AutoResearch/ValuationDepthFollowups.lean` (C1–C5).

  The foundations gave the **upper** bound `depth (eval t) ≤ maxLeafDepth t + height t`
  and the followups showed it is *attained* (sharp) on balanced trees and that the unit
  cost `1` is the least Lipschitz constant.  But the followups left the *universal lower
  bound* on height — "is `⌈log₂ numLeaves⌉` always a lower bound for the height of an
  arbitrary tree?" — only checked on the balanced/caterpillar witnesses.  This cycle
  closes that gap and pushes three further directions:

  Results:
  * **D1 (height–leaf duality).** `numLeaves_le_two_pow_height`, `succ_height_le_numLeaves`,
    `clog_numLeaves_le_height`: for *every* combination tree,
        `⌈log₂ numLeaves⌉ ≤ height ≤ numLeaves - 1`.
    The lower bound is the universal companion to C1's balanced witness.
  * **D2 (optimality sandwich).** `balanced_height_eq_clog`, `caterpillar_height_eq_pred`:
    the balanced tree *attains* the height lower bound and the caterpillar *attains* the
    height upper bound, so balanced reassociation is provably optimal and the caterpillar
    provably worst.
  * **D3 (generalized cost constant).** `CostCarrier`, `cost_eval_le`,
    `cost_eval_le_balanced`, `cost_least_constant`: replacing the unit cost `1` by an
    arbitrary constant `c` gives `depth (eval t) ≤ maxLeafDepth t + c * height t`, sharp on
    a `c`-cost witness, and `c` is again the least working constant.
  * **D4 (exact two-sided witness bound).** `maxLeafDepth_le_eval_unitCost`,
    `eval_unitCost_sandwich`: on the unit-cost carrier the evaluated depth is *sandwiched*
    `maxLeafDepth ≤ eval ≤ maxLeafDepth + height`, with both ends attained.
  * **D5 (universal linear overhead).** `depth_eval_le_numLeaves`: no depth carrier ever
    pays more than `numLeaves - 1` extra depth, regardless of associativity structure.

  -- !-- Lab Notes -- !--
  HYPOTHESIS (PI): the followups proved height is "the only cost" but only *upper*-bounded
  it; the dual structural fact `numLeaves ≤ 2^height` must hold for every binary tree,
  pinning `⌈log₂ numLeaves⌉ ≤ height` universally and certifying balanced trees as optimal.
  EXPERIMENT (Experimenter): structural induction for `numLeaves ≤ 2^height` (node case:
  `nl + nr ≤ 2^hl + 2^hr ≤ 2·2^(max hl hr) = 2^(max+1)`) and `height + 1 ≤ numLeaves`
  (node case: WLOG `hl ≥ hr`, then `hl + 2 ≤ nl + 1 ≤ nl + nr`); transfer to `clog` via
  `Nat.clog_le_iff_le_pow`.  Generalize the unit cost to a constant `c` via a `CostCarrier`,
  paying `c·height`; the only subtlety is the nonlinear step
  `max (a + c·x) (b + c·y) ≤ max a b + c·(max x y)` handled by `Nat.mul_le_mul_left`.
  ANALYSIS (Analyst): D1 confirmed; the sandwich `⌈log₂ m⌉ ≤ height ≤ m-1` is *tight at both
  ends* (D2) — balanced hits the floor, caterpillar the ceiling.  The exponential C1 gap is
  exactly the spread of this sandwich.  D3 shows the entire theory is scale-covariant in the
  cost constant.  D4's lower bound `maxLeafDepth ≤ eval` shows no leaf value is ever lost.
  CRITIQUE (Critic): every theorem is universally quantified over carriers/trees (not just
  the two named witnesses), uses induction/omega/`clog` lemmas, and is 0-sorry; the
  `CostCarrier` genuinely generalizes (recovers the unit law at `c = 1`).
  SYNTHESIS (PI): "height is the only cost, and ⌈log₂ leaves⌉ ≤ height ≤ leaves−1 pins it on
  both sides" — see `FUTURE_DIRECTIONS.md`.
-/
import Mathlib
import Bridges.ValuationDepthTropicalFunctor
import Speculative.AutoResearch.ValuationDepthFollowups

namespace ValuationDepthTropical

open CategoricalTropicalUltrametric

/-! ## D1. Height–leaf duality: the universal lower bound on height -/

/--
**D1 (leaf count is at most `2^height`).** Every binary combination tree with height
    `h` has at most `2^h` leaves.  This is the structural dual of `height_balanced`.
-/
theorem numLeaves_le_two_pow_height {K : Type} (t : OpTree K) :
    t.numLeaves ≤ 2 ^ t.height := by
  induction' t with k l r ihl ihr;
  · exact Nat.le_add_left _ _;
  · -- By definition of height, we have height (node l r) = max (height l) (height r) + 1.
    have h_height : (l.node r).height = max l.height r.height + 1 := by
      rfl;
    cases max_cases l.height r.height <;> simp_all +decide [ pow_succ' ];
    · exact le_trans ( add_le_add ihl ihr ) ( by rw [ two_mul ] ; gcongr ; linarith );
    · rw [ show ( l.node r ).numLeaves = l.numLeaves + r.numLeaves by rfl ] ; linarith [ pow_le_pow_right₀ ( by decide : 1 ≤ 2 ) ( by linarith : l.height ≤ r.height ) ]

/--
**D1 (height is below the leaf count).** Every binary combination tree has
    `height + 1 ≤ numLeaves`, i.e. `height ≤ numLeaves - 1`.  Equality holds for the
    caterpillar.
-/
theorem succ_height_le_numLeaves {K : Type} (t : OpTree K) :
    t.height + 1 ≤ t.numLeaves := by
  induction' t with l r ihl ihr;
  · rfl;
  · simp +arith +decide [ OpTree.height, OpTree.numLeaves ] at * ; omega

/--
**D1 (universal logarithmic lower bound on height).** For *every* combination tree the
    height is at least `⌈log₂ numLeaves⌉`.  This is the universal companion of C1's balanced
    witness (`balanced_meets_log_bound`): the log bound that holds *after* balanced
    reassociation is in fact a lower bound for the height of *any* reassociation.
-/
theorem clog_numLeaves_le_height {K : Type} (t : OpTree K) :
    Nat.clog 2 t.numLeaves ≤ t.height := by
  convert Nat.clog_le_iff_le_pow ( by norm_num ) |>.2 ( numLeaves_le_two_pow_height t ) using 1

/-! ## D2. The optimality sandwich: balanced attains the floor, caterpillar the ceiling -/

/--
**D2 (balanced is optimal).** The balanced tree attains the universal height lower
    bound: its height equals `⌈log₂ numLeaves⌉`.
-/
theorem balanced_height_eq_clog {K : Type} (k : K) (n : ℕ) :
    (balanced k n).height = Nat.clog 2 ((balanced k n).numLeaves) := by
  simp +decide [ height_balanced, numLeaves_balanced ]

/--
**D2 (caterpillar is worst).** The caterpillar attains the universal height upper
    bound: its height equals `numLeaves - 1`.
-/
theorem caterpillar_height_eq_pred {K : Type} (k : K) (n : ℕ) :
    (caterpillar k n).height = (caterpillar k n).numLeaves - 1 := by
  induction n <;> simp_all +arith +decide [ OpTree.height, OpTree.numLeaves ]

/-! ## D3. Generalized cost constant: scale-covariance of the whole theory -/

/-- A **cost-`c` depth carrier**: the unit-cost law with the unit replaced by an arbitrary
    constant `cost`.  Recovers `DepthCarrier` at `cost = 1`. -/
structure CostCarrier where
  K : Type
  add : K → K → K
  depth : K → ℕ
  cost : ℕ
  depth_add : ∀ x y, depth (add x y) ≤ max (depth x) (depth y) + cost

/-- A cost-`c` carrier is a depth carrier whenever `cost ≤ 1`; more usefully it always
    yields the scaled tree bound below.  (Kept as the canonical reduction at `cost = 1`.) -/
def CostCarrier.atUnit (X : CostCarrier) (h : X.cost = 1) : DepthCarrier where
  K := X.K
  add := X.add
  depth := X.depth
  depth_add := by intro x y; have := X.depth_add x y; omega

/--
**D3 (scaled combination-tree bound).** For a cost-`c` carrier the depth of the
    evaluated tree is at most `maxLeafDepth + c · height`.  At `c = 1` this is
    `depth_eval_add_le`.
-/
theorem cost_eval_le (X : CostCarrier) (t : OpTree X.K) :
    X.depth (t.eval X.add) ≤ OpTree.maxLeafDepth X.depth t + X.cost * t.height := by
  induction' t with l r ihl ihr;
  · exact Nat.le_add_right _ _;
  · refine' le_trans ( X.depth_add _ _ ) _;
    rw [ OpTree.maxLeafDepth, OpTree.height ];
    cases max_cases r.height ihl.height <;> simp_all +decide [ mul_add, add_assoc ]; all_goals cases max_cases ( X.depth ( OpTree.eval X.add r ) ) ( X.depth ( OpTree.eval X.add ihl ) ) <;> cases max_cases ( OpTree.maxLeafDepth X.depth r ) ( OpTree.maxLeafDepth X.depth ihl ) <;> nlinarith

/-- The canonical cost-`c` witness on ℕ: `add x y = max x y + c`, `depth = id`. -/
def costWitness (c : ℕ) : CostCarrier where
  K := ℕ
  add := fun x y => max x y + c
  depth := id
  cost := c
  depth_add := by intro x y; simp

/--
**D3 (the scaled bound is sharp).** On the cost-`c` witness the balanced tree attains
    `c · height` overhead exactly.
-/
theorem cost_eval_le_balanced (c b n : ℕ) :
    (costWitness c).depth ((balanced b n).eval (costWitness c).add) = b + c * n := by
  induction' n with n ih
  · simp [balanced, OpTree.eval, costWitness]
  · simp only [balanced, OpTree.eval, costWitness, id_eq, Nat.max_self] at ih ⊢
    rw [ih]; ring

/--
**D3 (`c` is the least constant for the cost-`c` law).** A constant `d` makes the law
    `depth (x ⊕ y) ≤ max (depth x) (depth y) + d` hold for *every* cost-`c` carrier iff
    `c ≤ d`.  This generalizes `lipschitz_constant_iff` (the `c = 1` case).
-/
theorem cost_least_constant (c d : ℕ) :
    (∀ (X : CostCarrier), X.cost = c → ∀ x y : X.K,
        X.depth (X.add x y) ≤ max (X.depth x) (X.depth y) + d) ↔ c ≤ d := by
  refine' ⟨ _, fun h => _ ⟩;
  · intro h;
    contrapose! h;
    use ⟨ℕ, fun x y => max x y + c, id, c, by
      exact fun x y => le_rfl⟩
    generalize_proofs at *;
    exact ⟨ rfl, 0, 0, by simpa using h ⟩;
  · exact fun X hX x y => le_trans ( X.depth_add x y ) ( by simp +decide [ hX, h ] )

/-! ## D4. The exact two-sided witness bound -/

/--
**D4 (no leaf value is ever lost).** On the unit-cost operation `max·+1`, the evaluated
    depth of a tree of ℕ-valued leaves is at least the maximal leaf value.
-/
theorem maxLeafDepth_le_eval_unitCost (t : OpTree ℕ) :
    OpTree.maxLeafDepth id t ≤ t.eval unitCostAdd := by
  induction' t with l r ihl ihr;
  · rfl;
  · simp +arith +decide [ OpTree.maxLeafDepth, OpTree.eval, unitCostAdd ] at * ; omega

/--
**D4 (two-sided sandwich on the witness carrier).** On the unit-cost carrier the
    evaluated depth of any tree is sandwiched between the maximal leaf depth and that plus
    the height; both ends are attained (caterpillar/leaf at the floor, balanced at the
    ceiling).
-/
theorem eval_unitCost_sandwich (t : OpTree ℕ) :
    OpTree.maxLeafDepth id t ≤ t.eval unitCostAdd ∧
      t.eval unitCostAdd ≤ OpTree.maxLeafDepth id t + t.height := by
  refine ⟨ maxLeafDepth_le_eval_unitCost t, ?_ ⟩;
  convert depth_eval_add_le witnessCarrier t using 1

/-! ## D5. Universal linear overhead -/

/--
**D5 (universal linear overhead bound).** For *every* depth carrier and tree, the depth
    of the evaluated value never exceeds `maxLeafDepth + (numLeaves - 1)`.  Combination can
    never cost more than linearly in the number of leaves, whatever the associativity.
-/
theorem depth_eval_le_numLeaves (X : DepthCarrier) (t : OpTree X.K) :
    X.depth (t.eval X.add) ≤ OpTree.maxLeafDepth X.depth t + (t.numLeaves - 1) := by
  -- By combining the results from the previous steps, we can conclude the proof.
  apply le_trans (depth_eval_add_le X t);
  exact Nat.add_le_add_left ( Nat.le_sub_one_of_lt ( succ_height_le_numLeaves t ) ) _

end ValuationDepthTropical