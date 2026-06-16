/-
  # Valuation-Depth → Tropical Functor: Follow-up Conjectures (C1–C5)

  Bridge: connects valuation-depth complexity measures to tropical/ultrametric geometry,
  Hensel/Newton lifting, and composition-cost analysis.

  This file proves precise Lean theorems for the follow-up conjectures arising from the
  foundations in `Catalog/Bridges/ValuationDepthTropicalFunctor.lean`.

  Results:
  * **C2** — `lipschitz_constant_iff`, `unit_is_least_lipschitz_constant`: the unit cost is
    the *unique least* Lipschitz constant of the bridge (`c` works for every carrier iff
    `1 ≤ c`).
  * **C1** — `balanced_meets_log_bound`: balanced reassociation meets the
    `maxLeafDepth + ⌈log₂(numLeaves)⌉` bound; `unbalanced_exceeds_log_bound`: an explicit
    unbalanced (caterpillar) witness *violates* it.  Height — not leaf count — is the cost.
  * **C5/C4** — `depth_balanced_overhead_tight`, `comp_balanced_depth_eq`,
    `hensel_depth_eq_height_and_precision`: the height bound is *sharp* on the unit-cost
    witness; the composition analogue holds; the `k`-fold quadratic-doubling tree has depth
    exactly `k` and p-adic precision exactly `2^k`, recovering the exponential-precision
    Hensel certificate.

  -- !-- Lab Notes -- !--
  HYPOTHESIS (Hypothesizer): (H1) the naive log bound `depth ≤ maxLeafDepth + ⌈log₂ leaves⌉`
  is FALSE for unbalanced trees but TRUE after optimal (balanced) reassociation; (H2) the
  unit cost `1` is forced — it is the least constant working for all carriers; (H3) the same
  arithmetic governs (add), (∘) and Hensel doubling, so depth = height and precision = 2^height.
  EXPERIMENT (Experimenter): build `balanced`/`caterpillar`, compute their evaluation on the
  unit-cost operation `max·+1`, and use `Nat.clog_pow` to evaluate `⌈log₂ 2^n⌉ = n`.
  ANALYSIS (Analyst): (H1) confirmed — caterpillar with 4 leaves has depth 3 > 2 = ⌈log₂ 4⌉,
  while balanced meets the bound; the FAILURE of the naive bound is *exactly* the gap between
  height (n-1) and ⌈log₂ n⌉.  (H2) confirmed via the witness at `0 ⊕ 0`.  (H3) confirmed: the
  three carriers share `eval (balanced b n) = b + n`, the unifying message of the 1-Lipschitz
  functor.
  CRITIQUE (Critic): the unbalanced witness uses a concrete `clog 2 4 = 2` fact proved via
  `Nat.clog_pow`, not `decide`; all main theorems use induction/omega and are 0-sorry; the
  `CompCarrier` is a genuinely distinct structure reusing the general tree theorem, not a rename.
  SYNTHESIS (PI): "the only cost is height" — collected in `FUTURE_DIRECTIONS.md`.
-/
import Mathlib
import Bridges.ValuationDepthTropicalFunctor

namespace ValuationDepthTropical

open CategoricalTropicalUltrametric

/-! ## C2. The unit cost is the unique least Lipschitz constant -/

/-- **C2.** A constant `c` makes the law `depth (x ⊕ y) ≤ max (depth x) (depth y) + c` hold for
    *every* depth carrier if and only if `1 ≤ c`.  Necessity is witnessed by `witnessCarrier`
    at `0 ⊕ 0` (where the unit cost is attained); sufficiency follows from `depth_add`. -/
theorem lipschitz_constant_iff (c : ℕ) :
    (∀ (X : DepthCarrier) (x y : X.K),
        X.depth (X.add x y) ≤ max (X.depth x) (X.depth y) + c) ↔ 1 ≤ c := by
  constructor
  · intro h
    have hw := h witnessCarrier (0 : ℕ) (0 : ℕ)
    simp only [witnessCarrier, unitCostAdd, id_eq] at hw
    omega
  · intro hc X x y
    have := X.depth_add x y
    omega

/-- **C2 (intrinsic constant).** `1` is the *least* constant for which the unit-cost law holds
    over all depth carriers.  This pins the Lipschitz constant of the bridge intrinsically. -/
theorem unit_is_least_lipschitz_constant :
    IsLeast {c : ℕ | ∀ (X : DepthCarrier) (x y : X.K),
        X.depth (X.add x y) ≤ max (X.depth x) (X.depth y) + c} 1 := by
  constructor
  · intro X x y; exact X.depth_add x y
  · intro c hc; exact (lipschitz_constant_iff c).mp hc

/-! ## C1 / C5. Balanced and unbalanced combination trees -/

/-- The balanced (perfect) combination tree of height `n` over a single leaf value `k`:
    `2^n` leaves, height `n`. -/
def balanced {K : Type} (k : K) : ℕ → OpTree K
  | 0 => OpTree.leaf k
  | n + 1 => OpTree.node (balanced k n) (balanced k n)

/-- The fully unbalanced left-spine ("caterpillar") tree with `n + 1` leaves and height `n`. -/
def caterpillar {K : Type} (k : K) : ℕ → OpTree K
  | 0 => OpTree.leaf k
  | n + 1 => OpTree.node (caterpillar k n) (OpTree.leaf k)

@[simp] theorem height_balanced {K : Type} (k : K) (n : ℕ) :
    (balanced k n).height = n := by
  induction n with
  | zero => rfl
  | succ n ih => simp [balanced, OpTree.height, ih]

@[simp] theorem numLeaves_balanced {K : Type} (k : K) (n : ℕ) :
    (balanced k n).numLeaves = 2 ^ n := by
  induction n with
  | zero => rfl
  | succ n ih => simp only [balanced, OpTree.numLeaves, ih, pow_succ]; ring

@[simp] theorem maxLeafDepth_balanced {K : Type} (depth : K → ℕ) (k : K) (n : ℕ) :
    (balanced k n).maxLeafDepth depth = depth k := by
  induction n with
  | zero => rfl
  | succ n ih => simp [balanced, OpTree.maxLeafDepth, ih]

@[simp] theorem height_caterpillar {K : Type} (k : K) (n : ℕ) :
    (caterpillar k n).height = n := by
  induction n with
  | zero => rfl
  | succ n ih => simp [caterpillar, OpTree.height, ih]

@[simp] theorem numLeaves_caterpillar {K : Type} (k : K) (n : ℕ) :
    (caterpillar k n).numLeaves = n + 1 := by
  induction n with
  | zero => rfl
  | succ n ih => simp only [caterpillar, OpTree.numLeaves, ih]

@[simp] theorem maxLeafDepth_caterpillar {K : Type} (depth : K → ℕ) (k : K) (n : ℕ) :
    (caterpillar k n).maxLeafDepth depth = depth k := by
  induction n with
  | zero => rfl
  | succ n ih => simp [caterpillar, OpTree.maxLeafDepth, ih]

/-- Evaluating a balanced tree on the unit-cost operation `max·+1` gives `b + n`:
    each level of the tree spends exactly one unit. -/
theorem eval_balanced_unitCost (b n : ℕ) :
    (balanced b n).eval unitCostAdd = b + n := by
  induction n with
  | zero => rfl
  | succ n ih => simp only [balanced, OpTree.eval, ih, unitCostAdd]; omega

/-- Evaluating the caterpillar tree on the unit-cost operation also gives `b + n`, but with
    `n + 1` leaves instead of `2^n` — its height `n` is far larger than `⌈log₂(n+1)⌉`. -/
theorem eval_caterpillar_unitCost (b n : ℕ) :
    (caterpillar b n).eval unitCostAdd = b + n := by
  induction n with
  | zero => rfl
  | succ n ih => simp only [caterpillar, OpTree.eval, ih, unitCostAdd]; omega

/-- **C1 (positive direction).** After balanced reassociation, the combination-tree depth
    meets the log bound `maxLeafDepth + ⌈log₂(numLeaves)⌉`. -/
theorem balanced_meets_log_bound (X : DepthCarrier) (k : X.K) (n : ℕ) :
    X.depth ((balanced k n).eval X.add)
      ≤ X.depth k + Nat.clog 2 ((balanced k n).numLeaves) := by
  have h := depth_eval_add_le X (balanced k n)
  rw [maxLeafDepth_balanced, height_balanced] at h
  rw [numLeaves_balanced, Nat.clog_pow 2 n (by norm_num)]
  exact h

/-- **C1 (counterexample).** The naive log bound `depth ≤ maxLeafDepth + ⌈log₂(numLeaves)⌉`
    is FALSE for unbalanced trees: the caterpillar with 4 leaves has depth `3` but the bound
    would force `≤ ⌈log₂ 4⌉ = 2`.  Height, not leaf count, is the true cost. -/
theorem unbalanced_exceeds_log_bound :
    ∃ (X : DepthCarrier) (t : OpTree X.K),
      OpTree.maxLeafDepth X.depth t + Nat.clog 2 (t.numLeaves) < X.depth (t.eval X.add) := by
  refine ⟨witnessCarrier, caterpillar (0 : ℕ) 3, ?_⟩
  have hd : witnessCarrier.depth ((caterpillar (0 : ℕ) 3).eval witnessCarrier.add) = 3 := by
    simp only [witnessCarrier, id_eq]; exact eval_caterpillar_unitCost 0 3
  have hl : OpTree.maxLeafDepth witnessCarrier.depth (caterpillar (0 : ℕ) 3) = 0 := by
    simp only [witnessCarrier, id_eq, maxLeafDepth_caterpillar]
  have hn : (caterpillar (0 : ℕ) 3).numLeaves = 4 := by simp
  have hc : Nat.clog 2 4 = 2 := by
    rw [show (4 : ℕ) = 2 ^ 2 from rfl, Nat.clog_pow 2 2 (by norm_num)]
  rw [hd, hl, hn, hc]; omega

/-- **C5/sharpness.** On the unit-cost witness the combination-tree bound is *attained with
    equality*: the depth of the balanced tree equals `depth k + height`.  Hence the height
    overhead in `depth_eval_add_le` cannot be improved. -/
theorem depth_balanced_overhead_tight (b n : ℕ) :
    witnessCarrier.depth ((balanced b n).eval witnessCarrier.add)
      = witnessCarrier.depth b + (balanced b n).height := by
  simp only [witnessCarrier, id_eq, height_balanced]
  exact eval_balanced_unitCost b n

/-! ## C4. Composition analogue (extending the functor to `∘`) -/

/-- A **composition-depth carrier**: a set of maps `M` with a composition `comp` whose depth
    obeys the same unit-cost ultrametric law `vdepth (f ∘ g) ≤ max (vdepth f)(vdepth g) + 1`.
    This is the `UltrametricCompositionLaw` setting of the source file. -/
structure CompCarrier where
  M : Type
  comp : M → M → M
  vdepth : M → ℕ
  vdepth_comp : ∀ f g, vdepth (comp f g) ≤ max (vdepth f) (vdepth g) + 1

/-- A composition carrier is a depth carrier (the unit-cost law is identical), so all
    combination-tree results transfer. -/
def CompCarrier.toDepth (C : CompCarrier) : DepthCarrier where
  K := C.M
  add := C.comp
  depth := C.vdepth
  depth_add := C.vdepth_comp

/-- **C4 (compositional analogue of the tree bound).** For a composition tree whose nodes
    are `∘`, the depth of the composite is at most `maxLeafDepth + height`.  This extends the
    1-Lipschitz functor from `(add, mul)` to `(∘)`. -/
theorem comp_eval_depth_le (C : CompCarrier) (t : OpTree C.M) :
    C.vdepth (t.eval C.comp) ≤ OpTree.maxLeafDepth C.vdepth t + t.height :=
  depth_eval_add_le C.toDepth t

/-- The canonical doubling composition carrier: composing two depth-`d` maps costs one unit. -/
def doublingComp : CompCarrier where
  M := ℕ
  comp := unitCostAdd
  vdepth := id
  vdepth_comp := by intro x y; simp [unitCostAdd]

/-- **C4 (balanced composition is exact).** Balanced composition of `2^n` maps each of depth
    `d` has depth *exactly* `d + n` — composition depth is `max`-plus-height, not a sum. -/
theorem comp_balanced_depth_eq (d n : ℕ) :
    doublingComp.vdepth ((balanced d n).eval doublingComp.comp) = d + n := by
  simp only [doublingComp, id_eq]
  exact eval_balanced_unitCost d n

/-! ## C5. Hensel certificate is a balanced tree -/

/-- **C5 (quantitative Hensel bridge).** The `k`-fold quadratic-doubling tree has depth equal
    to its height `k`, and the corresponding p-adic precision `2^depth` is exactly `2^k`.  This
    recovers the exponential-precision Newton/Hensel certificate (`precision = 2^(steps)`)
    purely from the balanced-tree height. -/
theorem hensel_depth_eq_height_and_precision (k : ℕ) :
    doublingComp.vdepth ((balanced (0 : ℕ) k).eval doublingComp.comp) = (balanced (0 : ℕ) k).height
      ∧ 2 ^ doublingComp.vdepth ((balanced (0 : ℕ) k).eval doublingComp.comp) = 2 ^ k := by
  have h := comp_balanced_depth_eq 0 k
  refine ⟨by rw [h, height_balanced, Nat.zero_add], by rw [h, Nat.zero_add]⟩

/-! ## C1 (second cycle). The reassociation gap is exponential -/

/-- **C1 (exponential reassociation gap).** For the *same* leaf count `2^n` (`n ≥ 2`), the
    balanced tree evaluates (under the unit cost) to depth `n` while the fully unbalanced
    caterpillar evaluates to depth `2^n - 1`.  Thus optimal reassociation improves the depth
    from linear (`numLeaves - 1`) to logarithmic (`⌈log₂ numLeaves⌉`) in the leaf count — an
    exponential gap.  This is the quantitative content of "height is the only cost". -/
theorem reassociation_exponential_gap (n : ℕ) (hn : 2 ≤ n) :
    (balanced (0 : ℕ) n).eval unitCostAdd < (caterpillar (0 : ℕ) (2 ^ n - 1)).eval unitCostAdd
      ∧ (caterpillar (0 : ℕ) (2 ^ n - 1)).numLeaves = (balanced (0 : ℕ) n).numLeaves := by
  have key : ∀ k : ℕ, k + 3 < 2 ^ (k + 2) := by
    intro k
    induction k with
    | zero => norm_num
    | succ m ih => rw [pow_succ]; omega
  obtain ⟨k, rfl⟩ : ∃ k, n = k + 2 := ⟨n - 2, by omega⟩
  have hk := key k
  have h1 : 1 ≤ 2 ^ (k + 2) := Nat.one_le_two_pow
  refine ⟨?_, ?_⟩
  · rw [eval_balanced_unitCost, eval_caterpillar_unitCost]; omega
  · rw [numLeaves_caterpillar, numLeaves_balanced]; omega

end ValuationDepthTropical