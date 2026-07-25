/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Scalar Tropical Stone–Weierstrass Theorem

We prove that a sublattice of continuous scalar functions `X → ℝ` on a compact Hausdorff
space that separates points strongly is uniformly dense, and derive concrete corollaries
for tropical (max-plus) function algebras.

The proof reduces to Mathlib's `ContinuousMap.sublattice_closure_eq_top`.

## Main Results

* `scalar_lattice_density` — Uniform density of a strongly separating sublattice.
* `scalar_tropical_stone_weierstrass` — Same with tropical lattice structure hypotheses.
* `coord_uniform_error_implies_sup_norm_error` — Coordinatewise → sup-norm approximation.
-/

open Set Metric TopologicalSpace Filter ContinuousMap
open scoped Topology

/-! ### Separation predicates -/

/-- Weak separation: some function distinguishes any two distinct points. -/
def TropSeparatesPoints {X : Type*} (A : Set (X → ℝ)) : Prop :=
  ∀ x y : X, x ≠ y → ∃ f ∈ A, f x ≠ f y

/-- Strong separation: for any two points and any target values, some function
hits both targets. This is the hypothesis for lattice Stone–Weierstrass. -/
def TropSeparatesPointsStrongly {X : Type*} (A : Set (X → ℝ)) : Prop :=
  ∀ (v : X → ℝ) (x y : X), ∃ f ∈ A, f x = v x ∧ f y = v y

/-! ### Tropical lattice structure -/

/-- A "tropical lattice" of functions: contains constants, closed under max, min, shifts. -/
structure IsTropLattice {X : Type*} [TopologicalSpace X]
    (A : Set (X → ℝ)) : Prop where
  /-- Contains all constant functions -/
  const_mem : ∀ c : ℝ, (fun _ : X => c) ∈ A
  /-- Closed under pointwise maximum -/
  max_mem : ∀ f g, f ∈ A → g ∈ A → (fun x => max (f x) (g x)) ∈ A
  /-- Closed under pointwise minimum -/
  min_mem : ∀ f g, f ∈ A → g ∈ A → (fun x => min (f x) (g x)) ∈ A
  /-- Closed under additive shift -/
  shift_mem : ∀ (c : ℝ) f, f ∈ A → (fun x => c + f x) ∈ A

/-! ### The bundled set of ContinuousMaps -/

/-- Bundle a set of continuous unbundled functions into a set of `ContinuousMap`s. -/
def toBundledSet {X : Type*} [TopologicalSpace X]
    (A : Set (X → ℝ)) (_hA_cont : ∀ f ∈ A, Continuous f) : Set C(X, ℝ) :=
  {g : C(X, ℝ) | (g : X → ℝ) ∈ A}

/-! ### Main scalar density theorem -/

/-- **Scalar Lattice Density Theorem**: A nonempty set of continuous functions on a
compact Hausdorff space, closed under max and min and separating points strongly,
is uniformly dense. For any continuous `f` and `ε > 0`, there exists `g ∈ A` with
`|f(x) - g(x)| ≤ ε` for all `x`. -/
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
  -- Step 1: Build the bundled set L ⊆ C(X, ℝ)
  set L := toBundledSet A hA_cont with hL_def
  -- Step 2: Show L is nonempty
  have hL_nonempty : L.Nonempty := by
    obtain ⟨f, hf⟩ := hA_nonempty
    exact ⟨⟨f, hA_cont f hf⟩, hf⟩
  -- Step 3: Show L is closed under inf (= min)
  have hL_inf : ∀ f ∈ L, ∀ g ∈ L, f ⊓ g ∈ L := by
    intro f hf g hg
    show (↑(f ⊓ g) : X → ℝ) ∈ A
    have : (↑(f ⊓ g) : X → ℝ) = fun x => min (f x) (g x) := by
      ext x; simp [ContinuousMap.inf_apply]
    rw [this]
    exact hA_min _ _ hf hg
  -- Step 4: Show L is closed under sup (= max)
  have hL_sup : ∀ f ∈ L, ∀ g ∈ L, f ⊔ g ∈ L := by
    intro f hf g hg
    show (↑(f ⊔ g) : X → ℝ) ∈ A
    have : (↑(f ⊔ g) : X → ℝ) = fun x => max (f x) (g x) := by
      ext x; simp [ContinuousMap.sup_apply]
    rw [this]
    exact hA_max _ _ hf hg
  -- Step 5: Show L separates points strongly
  have hL_sep : L.SeparatesPointsStrongly := by
    intro v x y
    obtain ⟨f, hfA, hfx, hfy⟩ := hA_sep v x y
    exact ⟨⟨f, hA_cont f hfA⟩, hfA, hfx, hfy⟩
  -- Step 6: Apply Mathlib's sublattice_closure_eq_top
  have hL_dense : closure L = ⊤ :=
    ContinuousMap.sublattice_closure_eq_top L hL_nonempty hL_inf hL_sup hL_sep
  -- Step 7: Extract the approximation
  intro f hf ε hε
  have hf_bun : (⟨f, hf⟩ : C(X, ℝ)) ∈ closure L := by
    rw [hL_dense]; exact mem_univ _
  rw [Metric.mem_closure_iff] at hf_bun
  obtain ⟨g, hgL, hg_dist⟩ := hf_bun ε hε
  refine ⟨g, hgL, fun x => ?_⟩
  have h2 : dist ((⟨f, hf⟩ : C(X, ℝ)) x) (g x) ≤ dist (⟨f, hf⟩ : C(X, ℝ)) g :=
    ContinuousMap.dist_apply_le_dist x
  simp only [ContinuousMap.coe_mk] at h2
  rw [Real.dist_eq] at h2
  linarith

/-- **Scalar Tropical Stone–Weierstrass**: A tropical lattice of continuous functions
that separates points strongly is uniformly dense. -/
theorem scalar_tropical_stone_weierstrass
    {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
    (A : Set (X → ℝ))
    (hA_cont : ∀ f ∈ A, Continuous f)
    (hA_lattice : IsTropLattice A)
    (hA_sep : TropSeparatesPointsStrongly A) :
    ∀ f : X → ℝ, Continuous f →
    ∀ ε > 0, ∃ g ∈ A, ∀ x, |f x - g x| ≤ ε :=
  scalar_lattice_density A hA_cont ⟨_, hA_lattice.const_mem 0⟩
    hA_lattice.max_mem hA_lattice.min_mem hA_sep

/-! ### Coordinatewise assembly -/

/-- If each coordinate of a vector-valued function is ε-approximated,
then the sup-norm error is at most ε. -/
theorem coord_uniform_error_implies_sup_norm_error
    {X : Type*} {n : ℕ}
    (f g : X → Fin n → ℝ)
    (ε : ℝ) (hε : 0 ≤ ε)
    (h : ∀ (i : Fin n) (x : X), |f x i - g x i| ≤ ε) :
    ∀ x : X, ‖f x - g x‖ ≤ ε := by
  intro x
  rw [pi_norm_le_iff_of_nonneg hε]
  intro i
  rw [Real.norm_eq_abs]
  exact h i x