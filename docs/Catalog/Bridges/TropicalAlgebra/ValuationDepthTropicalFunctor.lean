/-
  # Valuation-Depth → Tropical Functor (Foundations)

  Bridge: connects valuation-depth complexity measures (the "cost" of building a value
  by repeated combination) to tropical valuation objects (max-plus geometry).

  **Core principle.** A *depth carrier* is a type with a binary combination `add` and a
  depth measure `depth : K → ℕ` obeying the **unit-cost ultrametric law**

      depth (add x y) ≤ max (depth x) (depth y) + 1.

  This is exactly the lax/1-Lipschitz compatibility of `depth` with the tropical addition
  `max` on ℕ, carrying a *unit cost* per combination.  The fundamental quantitative
  theorem (`depth_eval_add_le`) says: for any combination tree `t`, the depth of its
  evaluated value is bounded by the maximal leaf depth *plus the tree height*.  Thus the
  only overhead of repeated combination is the **height** of the combination tree.

  This file is self-contained foundations; follow-up conjectures (C1–C5) live in
  `Catalog/Bridges/ValuationDepthFollowups.lean`.

  -- !-- Lab Notes -- !--
  HYPOTHESIS (PI): the unit-cost law is the *intrinsic* signature of a 1-Lipschitz functor
  from depth carriers to the tropical semiring on ℕ; its overhead on any combination tree
  is governed purely by tree height, and the unit constant `1` is forced.
  EXPERIMENT: formalize `DepthCarrier`, `OpTree`, and prove `depth_eval_add_le` by structural
  induction.  Build the canonical tropical target via the existing `tropicalization_base`.
  ANALYSIS: the induction is clean; height is additive across nodes exactly because each
  node contributes one unit of cost and `max` distributes over the recursive bounds.
  CRITIQUE: ensure the witness attains equality (so the bound is sharp, not vacuous).
  SYNTHESIS: foundations support the C1–C5 follow-ups in the companion file.
-/
import Mathlib
import Bridges.CategoricalTropicalUltrametric
namespace ValuationDepthTropical

open CategoricalTropicalUltrametric

/-! ## §1. Depth carriers -/

/-- A **valuation-depth carrier**: a type `K` with a binary combination `add` and a depth
    measure obeying the unit-cost ultrametric law
    `depth (add x y) ≤ max (depth x) (depth y) + 1`. -/
structure DepthCarrier where
  K : Type
  add : K → K → K
  depth : K → ℕ
  depth_add : ∀ x y, depth (add x y) ≤ max (depth x) (depth y) + 1

/-- A depth carrier is **strict** (idempotent / no unit cost) if the depth measure is
    sub-max with *no* `+1` slack: `depth (add x y) ≤ max (depth x) (depth y)`. -/
def IsStrict (X : DepthCarrier) : Prop :=
  ∀ x y, X.depth (X.add x y) ≤ max (X.depth x) (X.depth y)

/-! ## §2. Combination trees -/

/-- Binary combination trees with leaves valued in `K`. -/
inductive OpTree (K : Type) where
  | leaf : K → OpTree K
  | node : OpTree K → OpTree K → OpTree K

namespace OpTree

/-- Evaluate a combination tree under a binary operation. -/
def eval {K : Type} (add : K → K → K) : OpTree K → K
  | leaf k => k
  | node l r => add (eval add l) (eval add r)

/-- Height of a combination tree (a leaf has height `0`). -/
def height {K : Type} : OpTree K → ℕ
  | leaf _ => 0
  | node l r => max (height l) (height r) + 1

/-- Number of leaves of a combination tree. -/
def numLeaves {K : Type} : OpTree K → ℕ
  | leaf _ => 1
  | node l r => numLeaves l + numLeaves r

/-- Maximal leaf depth of a combination tree under a depth measure. -/
def maxLeafDepth {K : Type} (depth : K → ℕ) : OpTree K → ℕ
  | leaf k => depth k
  | node l r => max (maxLeafDepth depth l) (maxLeafDepth depth r)

end OpTree

/-! ## §3. The fundamental combination-tree bound -/

/-- **Combination-tree depth bound.** For any depth carrier and combination tree, the depth
    of the evaluated value is at most the maximal leaf depth plus the tree height.  The only
    overhead of repeated combination is the height of the combination tree. -/
theorem depth_eval_add_le (X : DepthCarrier) (t : OpTree X.K) :
    X.depth (t.eval X.add) ≤ OpTree.maxLeafDepth X.depth t + t.height := by
  induction t with
  | leaf k => simp [OpTree.eval, OpTree.maxLeafDepth, OpTree.height]
  | node l r ihl ihr =>
    simp only [OpTree.eval, OpTree.maxLeafDepth, OpTree.height]
    have := X.depth_add (l.eval X.add) (r.eval X.add)
    omega

/-- **Strict carriers have no overhead.**  If the depth measure is sub-max (idempotent /
    strict), every combination tree evaluates to a value of depth at most the maximal leaf
    depth — the height cost vanishes entirely.  This is the idempotent-completion content of
    conjecture C3. -/
theorem depth_eval_add_le_strict (X : DepthCarrier) (hX : IsStrict X) (t : OpTree X.K) :
    X.depth (t.eval X.add) ≤ OpTree.maxLeafDepth X.depth t := by
  induction t with
  | leaf k => simp [OpTree.eval, OpTree.maxLeafDepth]
  | node l r ihl ihr =>
    simp only [OpTree.eval, OpTree.maxLeafDepth]
    have := hX (l.eval X.add) (r.eval X.add)
    omega

/-! ## §4. The canonical tropical target and the lax (1-Lipschitz) law -/

/-- The tropical object that every depth carrier maps into: ℕ with `max` as tropical
    addition (reusing `tropicalization_base`). -/
def depthTropObj (_X : DepthCarrier) : TropObj := ⟨ℕ, tropicalization_base⟩

/-- The functor's underlying map on points: the depth measure itself. -/
def depthTropMap (X : DepthCarrier) : X.K → ℕ := X.depth

/-- **The 1-Lipschitz (lax, unit-cost) law of the bridge.**  The depth map is compatible
    with tropical addition (`= max`) up to a single unit of cost.  This is the defining
    property of the functor `depthTropFunctor`. -/
theorem depthTropMap_lax (X : DepthCarrier) (x y : X.K) :
    depthTropMap X (X.add x y)
      ≤ tropicalization_base.add (depthTropMap X x) (depthTropMap X y) + 1 := by
  exact X.depth_add x y

/-! ## §5. The unit-cost witness -/

/-- The canonical **unit-cost operation** on ℕ: `add x y = max x y + 1`.  Every combination
    spends exactly one unit of depth. -/
def unitCostAdd : ℕ → ℕ → ℕ := fun x y => max x y + 1

/-- The **unit-cost witness carrier**: `K = ℕ`, `add = unitCostAdd`, `depth = id`.  The
    unit-cost law holds with *equality*, so it is the extremal carrier. -/
def witnessCarrier : DepthCarrier where
  K := ℕ
  add := unitCostAdd
  depth := id
  depth_add := by intro x y; simp [unitCostAdd]

/-- The witness carrier is **not strict**: combination strictly increases depth, refuting
    the zero-cost (`c = 0`) law. -/
theorem not_strict_ultrametric_witness : ¬ IsStrict witnessCarrier := by
  intro h
  simp only [IsStrict, witnessCarrier, unitCostAdd, id_eq] at h
  have := h 0 0
  omega

end ValuationDepthTropical