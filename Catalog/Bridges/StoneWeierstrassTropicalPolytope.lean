/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Stone–Weierstrass for Compact Polytope Codomains

This file proves the full **coordinatewise tropical Stone–Weierstrass theorem**:
any continuous map from a compact Hausdorff space into a finite-dimensional tropical
space `Fin n → ℝ` can be uniformly approximated by elements from a tropical lattice
of functions.

## Main Results

* `TropSW.scalar_lattice_density` — Scalar lattice density (the core lemma).
* `TropSW.tropical_stone_weierstrass_fin` — Vector-valued density theorem.
* `TropSW.tropical_stone_weierstrass_into_polytope` — With retraction into `K`.
* `TropSW.dense_under_continuous_retraction` — Retraction-preserves-density bridge.
* `TropSW.coord_sup_norm_bound` — Coordinatewise → sup-norm assembly.

## Architecture

The proof proceeds by:
1. Reducing to Mathlib's `ContinuousMap.sublattice_closure_eq_top`.
2. Assembling coordinatewise approximants via the sup-norm bound.
3. Optionally composing with a continuous retraction.
-/

open Set Metric TopologicalSpace Filter ContinuousMap
open scoped BigOperators Topology

namespace TropSW

/-! ### Tropical types and operations -/

/-- Tropical n-dimensional vectors. -/
abbrev Trop (n : ℕ) := Fin n → ℝ

/-- Tropical addition (coordinatewise max). -/
def tropAdd {n : ℕ} (x y : Trop n) : Trop n := fun i => max (x i) (y i)

/-- Tropical scalar multiplication (uniform shift). -/
def tropSMul {n : ℕ} (a : ℝ) (x : Trop n) : Trop n := fun i => a + x i

/-- A subset `K` of tropical space is tropically convex if it is closed under
tropical convex combinations `max(a + x, b + y)`. -/
def IsTropConvex {n : ℕ} (K : Set (Trop n)) : Prop :=
  ∀ ⦃x y : Trop n⦄, x ∈ K → y ∈ K → ∀ a b : ℝ, (fun i => max (a + x i) (b + y i)) ∈ K

/-! ### Separation predicates -/

/-- Weak point separation. -/
def TropSeparatesPoints {X : Type*} (A : Set (X → ℝ)) : Prop :=
  ∀ x y : X, x ≠ y → ∃ f ∈ A, f x ≠ f y

/-- Strong separation: for any two points and target values, some function hits both. -/
def TropSeparatesPointsStrongly {X : Type*} (A : Set (X → ℝ)) : Prop :=
  ∀ (v : X → ℝ) (x y : X), ∃ f ∈ A, f x = v x ∧ f y = v y

/-! ### Tropical lattice structure -/

/-- A "tropical lattice": contains constants, closed under max, min, and shifts. -/
structure IsTropLattice {X : Type*} [TopologicalSpace X] (A : Set (X → ℝ)) : Prop where
  const_mem : ∀ c : ℝ, (fun _ : X => c) ∈ A
  max_mem : ∀ f g, f ∈ A → g ∈ A → (fun x => max (f x) (g x)) ∈ A
  min_mem : ∀ f g, f ∈ A → g ∈ A → (fun x => min (f x) (g x)) ∈ A
  shift_mem : ∀ (c : ℝ) f, f ∈ A → (fun x => c + f x) ∈ A

/-! ### Core scalar density theorem -/

/-- **Scalar Lattice Density**: A nonempty set of continuous functions on a compact
Hausdorff space, closed under max and min and separating points strongly, is
uniformly dense. -/
theorem scalar_lattice_density
    {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
    (A : Set (X → ℝ))
    (hA_cont : ∀ f ∈ A, Continuous f)
    (hA_nonempty : A.Nonempty)
    (hA_max : ∀ f g, f ∈ A → g ∈ A → (fun x => max (f x) (g x)) ∈ A)
    (hA_min : ∀ f g, f ∈ A → g ∈ A → (fun x => min (f x) (g x)) ∈ A)
    (hA_sep : TropSeparatesPointsStrongly A) :
    ∀ f : X → ℝ, Continuous f →
    ∀ ε > 0, ∃ g ∈ A, ∀ x, |f x - g x| ≤ ε := by
  set L : Set C(X, ℝ) := {g : C(X, ℝ) | (g : X → ℝ) ∈ A}
  have hL_nonempty : L.Nonempty := by
    obtain ⟨f, hf⟩ := hA_nonempty; exact ⟨⟨f, hA_cont f hf⟩, hf⟩
  have hL_inf : ∀ f ∈ L, ∀ g ∈ L, f ⊓ g ∈ L := by
    intro f hf g hg; show (↑(f ⊓ g) : X → ℝ) ∈ A
    have : (↑(f ⊓ g) : X → ℝ) = fun x => min (f x) (g x) := by
      ext x; simp [ContinuousMap.inf_apply]
    rw [this]; exact hA_min _ _ hf hg
  have hL_sup : ∀ f ∈ L, ∀ g ∈ L, f ⊔ g ∈ L := by
    intro f hf g hg; show (↑(f ⊔ g) : X → ℝ) ∈ A
    have : (↑(f ⊔ g) : X → ℝ) = fun x => max (f x) (g x) := by
      ext x; simp [ContinuousMap.sup_apply]
    rw [this]; exact hA_max _ _ hf hg
  have hL_sep : L.SeparatesPointsStrongly := by
    intro v x y
    obtain ⟨f, hfA, hfx, hfy⟩ := hA_sep v x y
    exact ⟨⟨f, hA_cont f hfA⟩, hfA, hfx, hfy⟩
  have hL_dense : closure L = ⊤ :=
    ContinuousMap.sublattice_closure_eq_top L hL_nonempty hL_inf hL_sup hL_sep
  intro f hf ε hε
  have hf_bun : (⟨f, hf⟩ : C(X, ℝ)) ∈ closure L := by rw [hL_dense]; exact mem_univ _
  rw [Metric.mem_closure_iff] at hf_bun
  obtain ⟨g, hgL, hg_dist⟩ := hf_bun ε hε
  refine ⟨g, hgL, fun x => ?_⟩
  have h2 : dist ((⟨f, hf⟩ : C(X, ℝ)) x) (g x) ≤ dist (⟨f, hf⟩ : C(X, ℝ)) g :=
    ContinuousMap.dist_apply_le_dist x
  simp only [ContinuousMap.coe_mk] at h2
  rw [Real.dist_eq] at h2; linarith

/-! ### Coordinatewise assembly -/

/-- Coordinatewise approximation implies sup-norm approximation for `Fin n → ℝ`. -/
theorem coord_sup_norm_bound
    {X : Type*} {n : ℕ} (f g : X → Fin n → ℝ) (ε : ℝ) (hε : 0 ≤ ε)
    (h : ∀ (i : Fin n) (x : X), |f x i - g x i| ≤ ε) :
    ∀ x : X, ‖f x - g x‖ ≤ ε := by
  intro x; rw [pi_norm_le_iff_of_nonneg hε]
  intro i; rw [Real.norm_eq_abs]; exact h i x

/-! ### Retraction density bridge -/

/-- Density is preserved under uniformly continuous retraction. -/
theorem dense_under_continuous_retraction
    {X Y Z : Type*} [TopologicalSpace X] [CompactSpace X]
    [PseudoMetricSpace Y] [PseudoMetricSpace Z]
    (A : Set (X → Y)) (r : Y → Z) (hr_unif : UniformContinuous r)
    (f : X → Z) (g0 : X → Y) (hf : f = r ∘ g0)
    (hdense : ∀ ε > 0, ∃ g ∈ A, ∀ x, dist (g x) (g0 x) ≤ ε) :
    ∀ ε > 0, ∃ h ∈ (fun g => r ∘ g) '' A, ∀ x, dist (h x) (f x) ≤ ε := by
  intro ε hε
  rw [Metric.uniformContinuous_iff] at hr_unif
  obtain ⟨δ, hδ_pos, hδ⟩ := hr_unif ε hε
  obtain ⟨g, hgA, hg_close⟩ := hdense (δ / 2) (by linarith)
  refine ⟨r ∘ g, ⟨g, hgA, rfl⟩, fun x => ?_⟩
  subst hf
  exact le_of_lt (hδ (lt_of_le_of_lt (hg_close x) (by linarith)))

/-- Retraction ensures codomain correctness. -/
theorem retraction_maps_into {X Y : Type*} (K : Set Y) (r : Y → Y)
    (hr_maps : MapsTo r univ K) (g : X → Y) : MapsTo (r ∘ g) univ K :=
  fun _ _ => hr_maps (mem_univ _)

/-! ### Vector-valued tropical Stone–Weierstrass -/

/-- **Tropical Stone–Weierstrass (finite-dimensional version)**: Given a tropical
lattice of continuous functions that separates points strongly, any continuous
`f : X → Fin n → ℝ` is uniformly approximable coordinatewise. -/
theorem tropical_stone_weierstrass_fin
    {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
    {n : ℕ}
    (A : Set (X → ℝ))
    (hA_cont : ∀ f ∈ A, Continuous f)
    (hA_nonempty : A.Nonempty)
    (hA_max : ∀ f g, f ∈ A → g ∈ A → (fun x => max (f x) (g x)) ∈ A)
    (hA_min : ∀ f g, f ∈ A → g ∈ A → (fun x => min (f x) (g x)) ∈ A)
    (hA_sep : TropSeparatesPointsStrongly A)
    (f : X → Trop n)
    (hf_cont : Continuous f) :
    ∀ ε > 0, ∃ (g : X → Trop n), (∀ (i : Fin n), (fun x => g x i) ∈ A) ∧
      ∀ x : X, ‖f x - g x‖ ≤ ε := by
  intro ε hε
  have h_coord : ∀ i : Fin n, ∃ gi ∈ A, ∀ x, |f x i - gi x| ≤ ε := by
    intro i
    exact scalar_lattice_density A hA_cont hA_nonempty hA_max hA_min hA_sep
      (fun x => f x i) (continuous_pi_iff.mp hf_cont i) ε hε
  choose gi hgi_mem hgi_close using h_coord
  exact ⟨fun x i => gi i x, fun i => hgi_mem i,
    fun x => coord_sup_norm_bound f (fun x i => gi i x) ε (le_of_lt hε)
      (fun i x => hgi_close i x) x⟩

/-- **Tropical Stone–Weierstrass into a polytope**: approximation with codomain
constraint via continuous retraction. -/
theorem tropical_stone_weierstrass_into_polytope
    {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
    {n : ℕ}
    (K : Set (Trop n))
    (r : Trop n → Trop n)
    (hr_unif : UniformContinuous r)
    (hr_retract : ∀ x ∈ K, r x = x)
    (hr_maps : MapsTo r univ K)
    (A : Set (X → ℝ))
    (hA_cont : ∀ f ∈ A, Continuous f)
    (hA_nonempty : A.Nonempty)
    (hA_max : ∀ f g, f ∈ A → g ∈ A → (fun x => max (f x) (g x)) ∈ A)
    (hA_min : ∀ f g, f ∈ A → g ∈ A → (fun x => min (f x) (g x)) ∈ A)
    (hA_sep : TropSeparatesPointsStrongly A)
    (f : X → Trop n)
    (hf_cont : Continuous f)
    (hf_maps : MapsTo f univ K) :
    ∀ ε > 0, ∃ (g : X → Trop n), MapsTo g univ K ∧
      ∀ x : X, dist (f x) (g x) ≤ ε := by
  intro ε hε
  rw [Metric.uniformContinuous_iff] at hr_unif
  obtain ⟨δ, hδ_pos, hδ⟩ := hr_unif ε hε
  obtain ⟨g₀, _, hg₀_close⟩ :=
    tropical_stone_weierstrass_fin A hA_cont hA_nonempty hA_max hA_min hA_sep
      f hf_cont (δ / 2) (by linarith)
  refine ⟨r ∘ g₀, retraction_maps_into K r hr_maps g₀, fun x => ?_⟩
  have hfx : r (f x) = f x := hr_retract (f x) (hf_maps (mem_univ x))
  rw [← hfx]
  apply le_of_lt
  apply hδ
  calc dist (f x) (g₀ x) = ‖f x - g₀ x‖ := by rw [dist_eq_norm]
    _ ≤ δ / 2 := hg₀_close x
    _ < δ := by linarith

/-! ### Finite tropical expression language -/

/-- A tropical generator family. -/
def TropGeneratorFamily (X : Type*) (ι : Type*) (_n : ℕ) := ι → X → ℝ

/-- A finite tropical expression: set of (generator, shift, coordinate) triples. -/
def TropExpr (ι : Type*) (n : ℕ) := Finset (ι × ℝ × Fin n)

/-- Evaluate a tropical expression: for each coordinate, take max of shifted generators. -/
noncomputable def evalTropExpr {X : Type*} {ι : Type*} {n : ℕ}
    (φ : TropGeneratorFamily X ι n) (E : TropExpr ι n) : X → Trop n :=
  fun x i =>
    let matching := E.filter (fun t => t.2.2 = i)
    if h : matching.Nonempty then
      matching.sup' h (fun t => t.2.1 + φ t.1 x)
    else 0

/-! ### Modulus of continuity -/

/-- A monotone modulus of continuity for `u`: `ω` is monotone, bounds the oscillation
of `u`, and vanishes at the origin. -/
def IsModulusOfContinuity {X : Type*} [PseudoMetricSpace X]
    (u : X → ℝ) (ω : ℝ → ℝ) : Prop :=
  Monotone ω ∧
  (∀ ε > 0, ∃ δ > 0, ω δ ≤ ε) ∧
  (∀ x y, |u x - u y| ≤ ω (dist x y))

/-
Vector modulus from coordinate moduli: if each coordinate of `f` has a monotone
modulus of continuity, then `f` is uniformly continuous with explicit error.
-/
theorem vector_modulus_from_coord_moduli
    {X : Type*} [PseudoMetricSpace X] {n : ℕ}
    (f : X → Trop n)
    (ω : Fin n → ℝ → ℝ)
    (hω : ∀ i, IsModulusOfContinuity (fun x => f x i) (ω i)) :
    ∀ ε > 0, ∃ δ > 0, ∀ x y, dist x y < δ → ‖f x - f y‖ ≤ ε := by
  cases n;
  · exact fun ε εpos => ⟨ ε, εpos, fun x y hxy => by simp +decide [ Norm.norm ] ; linarith ⟩;
  · intro ε hε;
    choose δ hδ using fun i => ( hω i ).2.1 ε hε;
    use Finset.min' ( Finset.univ.image δ ) ⟨ _, Finset.mem_image_of_mem δ ( Finset.mem_univ 0 ) ⟩;
    simp +decide [ Finset.min', hδ ];
    intro x y hxy;
    refine' pi_norm_le_iff_of_nonneg hε.le |>.2 fun i => _;
    exact le_trans ( hω i |>.2.2 x y ) ( le_trans ( hω i |>.1 ( le_of_lt ( hxy i ) ) ) ( hδ i |>.2 ) )

end TropSW