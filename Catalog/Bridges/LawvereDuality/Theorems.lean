/-
Copyright (c) 2025 Lawvere Metric Duality Project. All rights reserved.

# Closure-Cost ↔ Lawvere Duality: Main Theorems

## Main Results

* `specDist_refl` — Spectrum metric is reflexive
* `specDist_triangle` — Spectrum metric satisfies triangle inequality
* `specLawvere` — The spectrum forms a Lawvere computation system
* `obs_diff_le_cost` — Observable differences bounded by cost
* `yoneda_isometric` — **Main theorem**: Yoneda embedding is isometric
* `yoneda_injective_on_closed` — Yoneda separates closed points
* `cost_recovered` — Cost equals spectrum distance of Yoneda images
* `reconstruction_realizes` — Spectrum reconstruction realizes the system
* `fromLawvere_toLawvere_id` — Round-trip: Lawvere → ClosureCost → Lawvere is identity
* `prod_compat` — Product compatibility between both sides
-/

import Bridges.LawvereDuality.Basic

namespace LawvereDuality

open ENNReal Finset

noncomputable section

variable {α : Type*} [Fintype α] [DecidableEq α]

/-! ## Spectrum Metric Properties -/

/-
Observable differences are bounded by cost (nonexpansiveness).
-/
omit [Fintype α] [DecidableEq α] in
theorem obs_diff_le_cost (S : ClosureCostSystem α) (φ : CostObservable S) (x y : α) :
    φ x - φ y ≤ S.cost y x := by
  rw [ tsub_le_iff_right ];
  exact φ.nonexpansive y x |> le_trans <| by rw [ add_comm ] ;

/-
The spectrum metric is reflexive: d(φ, φ) = 0.
-/
omit [DecidableEq α] in
theorem specDist_refl (S : ClosureCostSystem α) (φ : CostObservable S) :
    specDist S φ φ = 0 := by
  unfold specDist;
  simp +decide

/-
The spectrum metric satisfies the triangle inequality.
-/
omit [DecidableEq α] in
theorem specDist_triangle (S : ClosureCostSystem α) (φ ψ χ : CostObservable S) :
    specDist S φ χ ≤ specDist S φ ψ + specDist S ψ χ := by
  refine' Finset.sup_le _;
  intro x _;
  refine' le_trans _ ( add_le_add ( Finset.le_sup ( f := fun x => φ.toFun x - ψ.toFun x ) ( Finset.mem_univ x ) ) ( Finset.le_sup ( f := fun x => ψ.toFun x - χ.toFun x ) ( Finset.mem_univ x ) ) );
  exact tsub_le_tsub_add_tsub

/-- The spectrum of a closure-cost system forms a Lawvere computation system.
    This is the **spectral Lawvere system** — the computational/metric side
    of the duality. -/
def specLawvere (S : ClosureCostSystem α) : LawvereCompSystem (CostObservable S) where
  dist := specDist S
  dist_refl := specDist_refl S
  dist_triangle := specDist_triangle S

/-! ## Yoneda Isometry: The Main Duality Theorem -/

/-
**Upper bound**: The spectrum distance between Yoneda images is at most cost.
    specDist(φ_x, φ_y) ≤ cost(x, y).
-/
omit [DecidableEq α] in
theorem yoneda_specDist_le (S : ClosureCostSystem α) (x y : α) :
    specDist S (yonedaObs S x) (yonedaObs S y) ≤ S.cost x y := by
  unfold specDist;
  simp +decide [ yonedaObs ];
  exact fun z => S.cost_triangle x y z

/-
**Lower bound**: The spectrum distance between Yoneda images is at least cost.
    This uses the specific witness z = y.
-/
omit [DecidableEq α] in
theorem cost_le_yoneda_specDist (S : ClosureCostSystem α) (x y : α) :
    S.cost x y ≤ specDist S (yonedaObs S x) (yonedaObs S y) := by
  have h_lower_bound : S.cost x y - S.cost y y ≤ specDist S (yonedaObs S x) (yonedaObs S y) := by
    exact Finset.le_sup ( f := fun z => S.cost x z - S.cost y z ) ( Finset.mem_univ y );
  rwa [ S.cost_refl, tsub_zero ] at h_lower_bound

omit [DecidableEq α] in
/-- **Main Isometry Theorem**: The Yoneda embedding is isometric.
    The spectrum distance between φ_x and φ_y equals cost(x, y).

    This is the central result: **cost is exactly recovered from
    the supremum of observable differences**. It proves that
    closure-cost algebra internally generates its own metric semantics. -/
theorem yoneda_isometric (S : ClosureCostSystem α) (x y : α) :
    specDist S (yonedaObs S x) (yonedaObs S y) = S.cost x y := by
  exact le_antisymm (yoneda_specDist_le S x y) (cost_le_yoneda_specDist S x y)

/-! ## Separation Theorem -/

/-
In a separated system, distinct closed elements have distinct
    Yoneda images. This is the tropical Stone separation theorem.
-/
omit [Fintype α] [DecidableEq α] in
theorem yoneda_injective_on_closed (S : ClosureCostSystem α)
    (hsep : S.Separated) (x y : α)
    (hx : S.IsClosed x) (hy : S.IsClosed y)
    (heq : ∀ z : α, S.cost x z = S.cost y z) :
    x = y := by
  have := S.cost_refl x; have := S.cost_refl y; aesop;

/-! ## Reconstruction -/

omit [DecidableEq α] in
/-- The Yoneda embedding realizes the closure-cost system in its
    spectrum Lawvere system. -/
theorem reconstruction_realizes (S : ClosureCostSystem α) :
    Realizes S (specLawvere S) (yonedaObs S) := by
  exact ⟨fun x y => yoneda_isometric S x y⟩

/-! ## Round-trip Properties -/

omit [DecidableEq α] in
/-- Round-trip: Lawvere → ClosureCost → Lawvere preserves the metric.
    The Yoneda isometry on `fromLawvere L` recovers L's distances. -/
theorem fromLawvere_roundtrip (L : LawvereCompSystem α) (x y : α) :
    specDist (fromLawvere L) (yonedaObs (fromLawvere L) x) (yonedaObs (fromLawvere L) y) =
    L.dist x y := by
  exact yoneda_isometric (fromLawvere L) x y

/-! ## Closure Quotient Invariance -/

omit [Fintype α] [DecidableEq α] in
/-- Closure does not change the Yoneda observable value at any point. -/
theorem yoneda_cl_eq (S : ClosureCostSystem α) (a x : α) :
    (yonedaObs S a).toFun (S.cl x) = (yonedaObs S a).toFun x :=
  (yonedaObs S a).map_cl x

omit [Fintype α] [DecidableEq α] in
/-- Cost to closures equals cost to originals. -/
theorem cost_to_cl (S : ClosureCostSystem α) (a x : α) :
    S.cost a (S.cl x) = S.cost a x :=
  (yonedaObs S a).map_cl x

omit [Fintype α] [DecidableEq α] in
/-- Closures are metrically equivalent (zero distance in both directions). -/
theorem cl_metrically_equiv (S : ClosureCostSystem α) (x : α) :
    S.cost x (S.cl x) = 0 ∧ S.cost (S.cl x) x = 0 :=
  ⟨S.cl_cost_zero x, S.cl_cost_zero_rev x⟩

omit [Fintype α] [DecidableEq α] in
/-- Closure nonexpansiveness: cost(cl x, cl y) ≤ cost(x, y). -/
theorem cost_cl_le (S : ClosureCostSystem α) (x y : α) :
    S.cost (S.cl x) (S.cl y) ≤ S.cost x y :=
  S.cl_nonexpansive x y

/-! ## Yoneda on Closed Elements -/

omit [Fintype α] [DecidableEq α] in
/-- On closed elements, Yoneda produces the same observable as the element itself. -/
theorem yoneda_cl_idem (S : ClosureCostSystem α) (x : α) :
    yonedaObs S (S.cl x) = yonedaObs S x := by
  apply_fun (fun f => f.toFun);
  · ext y;
    apply le_antisymm;
    · apply le_trans (S.cost_triangle (S.cl x) x y);
      simp +decide [ yonedaObs, S.cl_cost_zero_rev ];
    · have := S.cost_triangle x ( S.cl x ) y;
      simpa [ S.cl_cost_zero x ] using this;
  · exact fun f g h => by cases f; cases g; aesop;

/-! ## Product Compatibility -/

omit [Fintype α] [DecidableEq α] in
/-- The Yoneda embedding is compatible with products:
    yoneda in the product system factors through the component yonedas. -/
theorem yoneda_prod_compat {β : Type*} [Fintype β] [DecidableEq β]
    (S : ClosureCostSystem α) (T : ClosureCostSystem β)
    (a : α) (b : β) (x : α) (y : β) :
    (yonedaObs (S.prod T) (a, b)).toFun (x, y) =
    (yonedaObs S a).toFun x ⊔ (yonedaObs T b).toFun y := by
  rfl

/-! ## Generator Rank -/

/-- The generator rank: number of closed elements (fixed points of closure).
    In the duality, this equals the enriched dimension of the reconstruction. -/
noncomputable def closedRank (S : ClosureCostSystem α) : ℕ :=
  (Finset.univ.image S.cl).card

omit [Fintype α] [DecidableEq α] in
/-- Closure idempotence means cl maps onto the set of closed elements. -/
theorem cl_image_closed (S : ClosureCostSystem α) (x : α) :
    S.IsClosed (S.cl x) := S.cl_idem x

end

end LawvereDuality