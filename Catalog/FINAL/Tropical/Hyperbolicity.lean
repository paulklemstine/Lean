/-
# Gromov Hyperbolicity for Tropical Metrics

This file formalizes the four-point definition of Gromov δ-hyperbolicity
and proves key results connecting hyperbolicity to tropical geometry.

## Key results
- `IsFourPointDeltaHyperbolic`: four-point definition of δ-hyperbolicity
- `zero_hyperbolic_of_ultrametric`: ultrametric spaces are 0-hyperbolic
- `hyperbolic_mono`: monotonicity of the hyperbolicity parameter
- `exists_delta_hyperbolic_of_finite`: finite metric spaces are always δ-hyperbolic
-/
import Mathlib
import Tropical.Defs
import Tropical.SeriesParallel

namespace Hyperbolicity

/-! ## Four-point definition of Gromov hyperbolicity -/

/-- A pseudo-metric space is δ-hyperbolic in the four-point sense. -/
def IsFourPointDeltaHyperbolic (X : Type*) [PseudoMetricSpace X] (δ : ℝ) : Prop :=
  ∀ w x y z : X,
    dist w x + dist y z ≤
      max (dist w y + dist x z) (dist w z + dist x y) + 2 * δ

/-! ## Ultrametric spaces are 0-hyperbolic -/

/-- An ultrametric space satisfies d(x,z) ≤ max(d(x,y), d(y,z)). -/
def IsUltrametric (X : Type*) [PseudoMetricSpace X] : Prop :=
  ∀ x y z : X, dist x z ≤ max (dist x y) (dist y z)

/-
Ultrametric spaces are 0-hyperbolic.
-/
theorem zero_hyperbolic_of_ultrametric {X : Type*} [PseudoMetricSpace X]
    (hU : IsUltrametric X) : IsFourPointDeltaHyperbolic X 0 := by
  intros w x y z
  have h1 : dist w x ≤ max (dist w y) (dist x y) := by
    convert hU w y x using 1 ; simp +decide [ dist_comm ]
  have h2 : dist y z ≤ max (dist y x) (dist z x) := by
    convert hU y x z using 1 ; simp +decide [ dist_comm ]
  have h3 : dist x y = dist y x := by
    exact dist_comm _ _
  have h4 : dist z x = dist x z := by
    rw [ dist_comm ]
  have h5 : dist w y = dist y w := by
    exact dist_comm _ _
  have h6 : dist w z = dist z w := by
    exact dist_comm _ _;
  have h7 : dist y z ≤ max (dist y w) (dist w z) := by
    exact hU y w z
  have h8 : dist w x ≤ max (dist w z) (dist z x) := by
    exact hU _ _ _
  simp_all +decide;
  grind

/-! ## Monotonicity of hyperbolicity -/

/-
If a space is δ-hyperbolic, it is also δ'-hyperbolic for any δ' ≥ δ.
-/
theorem hyperbolic_mono {X : Type*} [PseudoMetricSpace X] {δ δ' : ℝ}
    (h : IsFourPointDeltaHyperbolic X δ) (hle : δ ≤ δ') :
    IsFourPointDeltaHyperbolic X δ' := by
  exact fun w x y z => by linarith [ h w x y z ] ;

/-! ## Finite metric spaces -/

/-
Every finite metric space is δ-hyperbolic for some δ ≥ 0.
-/
theorem exists_delta_hyperbolic_of_finite {X : Type*} [PseudoMetricSpace X] [Fintype X] :
    ∃ δ : ℝ, 0 ≤ δ ∧ IsFourPointDeltaHyperbolic X δ := by
  -- Define δ as the maximum of the distances between any two points in X.
  obtain ⟨δ, hδ⟩ : ∃ δ : ℝ, ∀ x y : X, dist x y ≤ δ := by
    -- Since X is finite, we can consider the supremum of all distances between points in X.
    have h_sup : ∃ M, ∀ x y : X, dist x y ≤ M := by
      have h_finite : Set.Finite (Set.range (fun p : X × X => dist p.1 p.2)) := by
        exact Set.toFinite _
      exact ⟨ h_finite.bddAbove.choose, fun x y => h_finite.bddAbove.choose_spec ⟨ ( x, y ), rfl ⟩ ⟩;
    exact h_sup;
  refine' ⟨ Max.max δ 0, le_max_right δ 0, _ ⟩;
  intro w x y z;
  cases max_cases ( dist w y + dist x z ) ( dist w z + dist x y ) <;> cases max_cases δ 0 <;> linarith [ hδ w x, hδ y z, hδ w y, hδ x z, hδ w z, hδ x y, @dist_nonneg _ _ w x, @dist_nonneg _ _ y z, @dist_nonneg _ _ w y, @dist_nonneg _ _ x z, @dist_nonneg _ _ w z, @dist_nonneg _ _ x y ]

/-! ## Nonneg delta always works with sufficiently large δ -/

/-
Any pseudo-metric space is trivially δ-hyperbolic for δ large enough
    relative to diameter.
-/
theorem hyperbolic_of_bounded_diam {X : Type*} [PseudoMetricSpace X]
    {D : ℝ} (hD : ∀ x y : X, dist x y ≤ D) :
    IsFourPointDeltaHyperbolic X D := by
  exact fun w x y z => by linarith [ hD w x, hD w y, hD w z, hD x y, hD x z, hD y z, show 0 ≤ dist w y + dist x z from add_nonneg dist_nonneg dist_nonneg, show 0 ≤ dist w z + dist x y from add_nonneg dist_nonneg dist_nonneg, le_max_left ( dist w y + dist x z ) ( dist w z + dist x y ), le_max_right ( dist w y + dist x z ) ( dist w z + dist x y ) ] ;

/-! ## SP network hyperbolicity -/

/-
The boundary metric on an SP network's two terminals forms a
    0-hyperbolic space (trivially, since two-point metrics are always
    0-hyperbolic in the four-point sense).
-/
theorem sp_two_terminal_zero_hyperbolic (N : SeriesParallel.SPNet) :
    ∀ w x y z : Fin 2,
      let d : Fin 2 → Fin 2 → ℝ := fun i j => if i = j then 0 else SeriesParallel.spDist N
      d w x + d y z ≤ max (d w y + d x z) (d w z + d x y) + 2 * 0 := by
  simp +decide [ Fin.forall_fin_two ];
  exact le_of_lt ( SeriesParallel.spDist_pos N )

/-! ## Gromov product -/

/-- The Gromov product of x and y with respect to basepoint w. -/
noncomputable def gromovProduct {X : Type*} [PseudoMetricSpace X]
    (w x y : X) : ℝ :=
  (dist w x + dist w y - dist x y) / 2

/-
The Gromov product is nonneg in a metric space.
-/
theorem gromovProduct_nonneg {X : Type*} [PseudoMetricSpace X]
    (w x y : X) : 0 ≤ gromovProduct w x y := by
  exact div_nonneg ( by linarith [ @dist_triangle _ _ x w y, @dist_comm _ _ x w, @dist_comm _ _ w y ] ) zero_le_two

/-
Alternative characterization: δ-hyperbolicity via Gromov products.
    (x|y)_w ≥ min((x|z)_w, (z|y)_w) - δ for all x,y,z,w.
-/
theorem hyperbolic_iff_gromov_product {X : Type*} [PseudoMetricSpace X]
    (δ : ℝ) (_hδ : 0 ≤ δ) :
    IsFourPointDeltaHyperbolic X δ ↔
    ∀ w x y z : X,
      gromovProduct w x y ≥ min (gromovProduct w x z) (gromovProduct w z y) - δ := by
  unfold gromovProduct IsFourPointDeltaHyperbolic;
  refine' ⟨ fun h w x y z => _, fun h w x y z => _ ⟩ <;> simp_all +decide [ dist_comm ];
  · contrapose! h;
    use w, z, x, y;
    cases max_cases ( dist w x + dist z y ) ( dist w y + dist z x ) <;> linarith [ dist_comm x y, dist_comm x z, dist_comm y z ];
  · cases h w x y z <;> cases h w y z x <;> cases h w z x y <;> cases h w x z y <;> cases max_cases ( dist w y + dist x z ) ( dist w z + dist x y ) <;> linarith [ dist_comm w x, dist_comm w y, dist_comm w z, dist_comm x y, dist_comm x z, dist_comm y z ]

end Hyperbolicity