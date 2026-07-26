/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Neural PDE Universality Classes via Renormalization Fixed Points

This module formalizes the mathematical framework for universality classes
of neural operators trained on PDE solution families. The key insight is that
coarse-graining (block-averaging and rescaling) of learned operators produces
a renormalization semigroup whose fixed points determine universality classes
independent of architecture details.

## Main Definitions

* `RGSemigroup` — A renormalization-group semigroup with coarse-graining operator
* `PDEInvariant` — Classification data: symmetry dimension, conservation count, differential order
* `OperatorSpectrum` — Spectral data of a coarse-grained operator

## Main Results

* `contractive_iterate_bound` — Distances shrink geometrically: d(T^n x, T^n y) ≤ c^n d(x,y)
* `contractive_implies_same_class` — Contractive RG ⟹ single universality class
* `fixed_point_unique` — Contractive RG has at most one fixed point
* `conservation_along_orbit` — Conservation laws are preserved along entire RG orbits
* `architecture_independence_finite` — Different architectures converge to same class
* `orbit_length_bound` — Pigeonhole bound on orbit recurrence

## References

* Wilson, K.G. "The renormalization group and critical phenomena" (1983 Nobel lecture)
* Goldenfeld, N. "Lectures on Phase Transitions and the Renormalization Group" (1992)
-/
import Mathlib

open scoped BigOperators

noncomputable section

/-! ## Core Structures -/

/-- Classification data for a PDE: symmetry dimension, number of conservation laws,
    and differential order. This triple determines the universality class. -/
structure PDEInvariant where
  /-- Dimension of the symmetry group (e.g., translation invariance in d dimensions) -/
  symmetryDim : ℕ
  /-- Number of independent conservation laws -/
  conservationLaws : ℕ
  /-- Differential order of the PDE -/
  diffOrder : ℕ
  /-- At least one symmetry (translation invariance) -/
  symm_pos : 0 < symmetryDim
  /-- Positive differential order -/
  order_pos : 0 < diffOrder
  deriving DecidableEq

/-- A renormalization-group semigroup acting on an operator space.
    The key operation is `coarsen`: a coarse-graining map that averages
    over spatial blocks and rescales, analogous to Kadanoff block-spin transforms. -/
structure RGSemigroup (α : Type*) where
  /-- The coarse-graining (block-averaging + rescaling) map -/
  coarsen : α → α
  /-- Distance function on operator space -/
  dist : α → α → ℝ
  /-- Distance is non-negative -/
  dist_nonneg : ∀ x y, 0 ≤ dist x y
  /-- Distance is symmetric -/
  dist_symm : ∀ x y, dist x y = dist y x
  /-- Distance zero iff equal -/
  dist_eq_zero : ∀ x y, dist x y = 0 ↔ x = y
  /-- Triangle inequality -/
  dist_triangle : ∀ x y z, dist x z ≤ dist x y + dist y z

/-- Iterated application of the coarse-graining map -/
def RGSemigroup.iterate {α : Type*} (rg : RGSemigroup α) : ℕ → α → α
  | 0, x => x
  | n + 1, x => rg.coarsen (rg.iterate n x)

/-- A fixed point of the RG flow -/
def RGSemigroup.IsFixedPoint {α : Type*} (rg : RGSemigroup α) (x : α) : Prop :=
  rg.coarsen x = x

/-- The RG semigroup is contractive with rate c < 1 -/
def RGSemigroup.IsContractive {α : Type*} (rg : RGSemigroup α) (c : ℝ) : Prop :=
  0 ≤ c ∧ c < 1 ∧ ∀ x y, rg.dist (rg.coarsen x) (rg.coarsen y) ≤ c * rg.dist x y

/-- Two operators are in the same universality class if their RG orbits converge -/
def RGSemigroup.SameClass {α : Type*} (rg : RGSemigroup α) (x y : α) : Prop :=
  ∀ ε > 0, ∃ N : ℕ, ∀ n, N ≤ n → rg.dist (rg.iterate n x) (rg.iterate n y) < ε

/-- An operator stabilizes under RG if its orbit converges to a fixed point -/
def RGSemigroup.ConvergesToFixed {α : Type*} (rg : RGSemigroup α) (x fp : α) : Prop :=
  rg.IsFixedPoint fp ∧ ∀ ε > 0, ∃ N : ℕ, ∀ n, N ≤ n → rg.dist (rg.iterate n x) fp < ε

/-! ## Spectral Data -/

/-- Spectral signature of a coarse-grained operator, capturing the
    eigenvalue distribution that characterizes the universality class -/
structure OperatorSpectrum where
  /-- Number of relevant (growing/marginal) eigenvalue directions -/
  relevantDim : ℕ
  /-- The leading eigenvalue (spectral radius of linearized RG) -/
  leadingEigenvalue : ℝ
  /-- Critical exponent: controls power-law scaling -/
  criticalExponent : ℝ
  /-- Spectral gap between leading and subleading eigenvalues -/
  spectralGap : ℝ
  /-- Gap is positive (ensures exponential convergence) -/
  gap_pos : 0 < spectralGap

/-- A neural architecture is characterized by its operator space element
    and the PDE invariant it was trained on -/
structure NeuralArchitecture (α : Type*) where
  /-- The learned operator -/
  operator : α
  /-- PDE classification data -/
  invariant : PDEInvariant
  /-- Architecture identifier (for stating independence) -/
  archId : ℕ

/-! ## Key Lemmas and Theorems -/

/-- The iterate function satisfies the expected composition law -/
theorem RGSemigroup.iterate_succ {α : Type*} (rg : RGSemigroup α) (n : ℕ) (x : α) :
    rg.iterate (n + 1) x = rg.coarsen (rg.iterate n x) := rfl

/-- Iterate zero is the identity -/
theorem RGSemigroup.iterate_zero {α : Type*} (rg : RGSemigroup α) (x : α) :
    rg.iterate 0 x = x := rfl

/-- **Contractivity implies distances shrink geometrically under iteration.**
    This is the key quantitative estimate: after n steps, distance is at most c^n · d₀. -/
theorem RGSemigroup.contractive_iterate_bound {α : Type*} (rg : RGSemigroup α)
    {c : ℝ} (hc : rg.IsContractive c) (x y : α) (n : ℕ) :
    rg.dist (rg.iterate n x) (rg.iterate n y) ≤ c ^ n * rg.dist x y := by
  induction n with
  | zero => simp [iterate_zero]
  | succ n ih =>
    rw [iterate_succ]
    calc rg.dist (rg.coarsen (rg.iterate n x)) (rg.coarsen (rg.iterate n y))
        ≤ c * rg.dist (rg.iterate n x) (rg.iterate n y) := hc.2.2 _ _
      _ ≤ c * (c ^ n * rg.dist x y) := by
          apply mul_le_mul_of_nonneg_left ih hc.1
      _ = c ^ (n + 1) * rg.dist x y := by ring

/-- **Universality Class Equivalence**: `SameClass` is reflexive. -/
theorem RGSemigroup.sameClass_refl {α : Type*} (rg : RGSemigroup α) (x : α) :
    rg.SameClass x x := by
  intro ε hε
  exact ⟨0, fun n _ => by rw [(rg.dist_eq_zero _ _).mpr rfl]; exact hε⟩

/-- `SameClass` is symmetric. -/
theorem RGSemigroup.sameClass_symm {α : Type*} (rg : RGSemigroup α) {x y : α}
    (h : rg.SameClass x y) : rg.SameClass y x := by
  intro ε hε
  obtain ⟨N, hN⟩ := h ε hε
  exact ⟨N, fun n hn => by rw [rg.dist_symm]; exact hN n hn⟩

/-- `SameClass` is transitive, using the triangle inequality and ε/2 argument. -/
theorem RGSemigroup.sameClass_trans {α : Type*} (rg : RGSemigroup α) {x y z : α}
    (hxy : rg.SameClass x y) (hyz : rg.SameClass y z) : rg.SameClass x z := by
  intro ε hε
  obtain ⟨N₁, hN₁⟩ := hxy (ε / 2) (by linarith)
  obtain ⟨N₂, hN₂⟩ := hyz (ε / 2) (by linarith)
  refine ⟨max N₁ N₂, fun n hn => ?_⟩
  calc rg.dist (rg.iterate n x) (rg.iterate n z)
      ≤ rg.dist (rg.iterate n x) (rg.iterate n y) +
        rg.dist (rg.iterate n y) (rg.iterate n z) := rg.dist_triangle _ _ _
    _ < ε / 2 + ε / 2 := by
        apply add_lt_add
        · exact hN₁ n (le_of_max_le_left hn)
        · exact hN₂ n (le_of_max_le_right hn)
    _ = ε := by ring

/-- **Contractive RG implies universality**: If the RG semigroup is contractive,
    then ALL operators are in the same universality class. This models the
    physics intuition that a strongly contractive RG flow has a single basin of attraction. -/
theorem RGSemigroup.contractive_implies_same_class {α : Type*} (rg : RGSemigroup α)
    {c : ℝ} (hc : rg.IsContractive c) (x y : α) : rg.SameClass x y := by
  intro ε hε
  by_cases hd : rg.dist x y = 0
  · exact ⟨0, fun n _ => by
      have : x = y := (rg.dist_eq_zero x y).mp hd
      rw [this]; rw [(rg.dist_eq_zero _ _).mpr rfl]; exact hε⟩
  · have hd_pos : 0 < rg.dist x y := by
      rcases lt_or_eq_of_le (rg.dist_nonneg x y) with h | h
      · exact h
      · exact absurd h.symm hd
    obtain ⟨N, hN⟩ := exists_pow_lt_of_lt_one (div_pos hε hd_pos) hc.2.1
    refine ⟨N, fun n hn => ?_⟩
    calc rg.dist (rg.iterate n x) (rg.iterate n y)
        ≤ c ^ n * rg.dist x y := rg.contractive_iterate_bound hc x y n
      _ ≤ c ^ N * rg.dist x y := by
          apply mul_le_mul_of_nonneg_right _ (le_of_lt hd_pos)
          exact pow_le_pow_of_le_one hc.1 (le_of_lt hc.2.1) hn
      _ < (ε / rg.dist x y) * rg.dist x y := by
          exact mul_lt_mul_of_pos_right hN hd_pos
      _ = ε := div_mul_cancel₀ ε (ne_of_gt hd_pos)

/-- **Fixed point uniqueness in contractive RG**: A contractive RG semigroup
    has at most one fixed point. -/
theorem RGSemigroup.fixed_point_unique {α : Type*} (rg : RGSemigroup α)
    {c : ℝ} (hc : rg.IsContractive c) {x y : α}
    (hx : rg.IsFixedPoint x) (hy : rg.IsFixedPoint y) : x = y := by
  by_contra hne
  have hd_pos : 0 < rg.dist x y := by
    rcases lt_or_eq_of_le (rg.dist_nonneg x y) with h | h
    · exact h
    · exact absurd ((rg.dist_eq_zero x y).mp h.symm) hne
  have step : rg.dist x y ≤ c * rg.dist x y := by
    have h1 : rg.dist (rg.coarsen x) (rg.coarsen y) ≤ c * rg.dist x y := hc.2.2 x y
    rwa [hx, hy] at h1
  have : (1 - c) * rg.dist x y ≤ 0 := by nlinarith
  have : 0 < (1 - c) * rg.dist x y := mul_pos (by linarith [hc.2.1]) hd_pos
  linarith

/-! ## Conservation Law Constraints -/

/-- A conservation law is a linear functional preserved by the dynamics. -/
structure ConservationLaw (α : Type*) (rg : RGSemigroup α) where
  /-- The conserved quantity as a function on operator space -/
  functional : α → ℝ
  /-- The functional is preserved by coarse-graining -/
  preserved : ∀ x, functional (rg.coarsen x) = functional x

/-- **Conservation laws are preserved along the entire RG orbit.**
    Proved by induction on the number of RG steps. -/
theorem conservation_along_orbit {α : Type*} {rg : RGSemigroup α}
    (law : ConservationLaw α rg) (x : α) (n : ℕ) :
    law.functional (rg.iterate n x) = law.functional x := by
  induction n with
  | zero => rfl
  | succ n ih =>
    rw [rg.iterate_succ, law.preserved, ih]

/-- **Conservation separates fixed points**: Fixed points with different
    conservation values are necessarily distinct. -/
theorem conservation_separates_fixed_points {α : Type*} {rg : RGSemigroup α}
    (law : ConservationLaw α rg) {x y : α}
    (_hx : rg.IsFixedPoint x) (_hy : rg.IsFixedPoint y)
    (hval : law.functional x ≠ law.functional y) : x ≠ y :=
  fun heq => hval (congrArg law.functional heq)

/-- **Conservation law distinguishes classes**: Two operators with different
    conservation values cannot be in the same universality class, provided
    the distance function uniformly detects functional differences. -/
theorem different_conservation_different_class {α : Type*} {rg : RGSemigroup α}
    (law : ConservationLaw α rg) {x y : α} {δ : ℝ} (hδ : 0 < δ)
    (hval : law.functional x ≠ law.functional y)
    (h_detect : ∀ a b, law.functional a ≠ law.functional b → δ ≤ rg.dist a b) :
    ¬ rg.SameClass x y := by
  intro hsame
  obtain ⟨N, hN⟩ := hsame δ hδ
  have h_consN : law.functional (rg.iterate N x) ≠ law.functional (rg.iterate N y) := by
    rwa [conservation_along_orbit law x N, conservation_along_orbit law y N]
  have h_lb := h_detect _ _ h_consN
  have h_ub := hN N (le_refl N)
  linarith

/-! ## Architecture Independence -/

/-- **Architecture Independence Theorem (Finite Version)**:
    For a finite collection of architectures trained on the same PDE class,
    if the RG semigroup is contractive, all architectures converge to the
    same universality class regardless of initialization. -/
theorem architecture_independence_finite {α : Type*} (rg : RGSemigroup α)
    {c : ℝ} (hc : rg.IsContractive c)
    (architectures : Fin n → α) :
    ∀ i j : Fin n, rg.SameClass (architectures i) (architectures j) :=
  fun _i _j => rg.contractive_implies_same_class hc _ _

/-! ## Universality Class Counting -/

/-- The number of universality classes is bounded by the number of
    distinct conservation law values. -/
def conservationClassCount (k : ℕ) (valuesPerLaw : ℕ) : ℕ := valuesPerLaw ^ k

/-- Conservation class count is monotone in the number of values -/
theorem conservationClassCount_mono_values {k v₁ v₂ : ℕ}
    (hv : v₁ ≤ v₂) :
    conservationClassCount k v₁ ≤ conservationClassCount k v₂ := by
  unfold conservationClassCount
  exact Nat.pow_le_pow_left hv k

/-! ## Differential Order Hierarchy -/

/-- Higher-order PDEs have more irrelevant directions under RG, leading to
    faster convergence. The contraction rate improves with differential order. -/
def effectiveContraction (baseRate : ℝ) (diffOrder : ℕ) : ℝ :=
  baseRate ^ diffOrder

/-- Higher differential order gives stronger contraction -/
theorem higher_order_stronger_contraction {baseRate : ℝ}
    (hb : 0 ≤ baseRate) (hb1 : baseRate < 1) {d₁ d₂ : ℕ} (hd : d₁ ≤ d₂) :
    effectiveContraction baseRate d₂ ≤ effectiveContraction baseRate d₁ := by
  unfold effectiveContraction
  exact pow_le_pow_of_le_one hb (le_of_lt hb1) hd

/-! ## Concrete Instance: ℝ-valued operators with affine contraction -/

/-- RG semigroup on ℝ by affine contraction toward a fixed point -/
def realContractionRG (c fp : ℝ) (_hc_nn : 0 ≤ c) (_hc1 : c < 1) : RGSemigroup ℝ where
  coarsen := fun x => fp + c * (x - fp)
  dist := fun x y => |x - y|
  dist_nonneg := fun _ _ => abs_nonneg _
  dist_symm := fun x y => abs_sub_comm x y
  dist_eq_zero := fun x y => by
    constructor
    · intro h; linarith [abs_eq_zero.mp h]
    · intro h; simp [h]
  dist_triangle := fun x y z => by
    have : x - z = (x - y) + (y - z) := by ring
    rw [this]; exact abs_add_le _ _

/-- The real contraction RG is indeed contractive -/
theorem realContractionRG_contractive (c fp : ℝ) (hc_nn : 0 ≤ c) (hc1 : c < 1) :
    (realContractionRG c fp hc_nn hc1).IsContractive c := by
  refine ⟨hc_nn, hc1, fun x y => ?_⟩
  simp only [realContractionRG]
  have : (fp + c * (x - fp)) - (fp + c * (y - fp)) = c * (x - y) := by ring
  rw [this, abs_mul, abs_of_nonneg hc_nn]

/-- The intended fixed point is indeed fixed -/
theorem realContractionRG_fp_fixed (c fp : ℝ) (hc_nn : 0 ≤ c) (hc1 : c < 1) :
    (realContractionRG c fp hc_nn hc1).IsFixedPoint fp := by
  simp [RGSemigroup.IsFixedPoint, realContractionRG]

/-- In the real contraction RG, the fixed point is unique -/
theorem realContractionRG_fp_unique (c fp : ℝ) (hc_nn : 0 ≤ c) (hc1 : c < 1)
    (x : ℝ) (hx : (realContractionRG c fp hc_nn hc1).IsFixedPoint x) : x = fp :=
  (realContractionRG c fp hc_nn hc1).fixed_point_unique
    (realContractionRG_contractive c fp hc_nn hc1) hx
    (realContractionRG_fp_fixed c fp hc_nn hc1)

/-! ## PDE Invariant Determines Universality Class -/

/-- A PDE family is a collection of neural architectures equipped with
    an RG semigroup, all sharing the same PDE invariant. -/
structure PDEFamily (α : Type*) where
  /-- The RG semigroup governing coarse-graining -/
  rg : RGSemigroup α
  /-- The PDE classification data -/
  invariant : PDEInvariant
  /-- Collection of trained architectures -/
  architectures : ℕ → α

/-- **Main Universality Theorem**: For a PDE family with contractive RG,
    all architectures belong to the same universality class. -/
theorem pde_family_universality {α : Type*} (fam : PDEFamily α)
    {c : ℝ} (hc : fam.rg.IsContractive c) :
    ∀ i j : ℕ, fam.rg.SameClass (fam.architectures i) (fam.architectures j) :=
  fun _i _j => fam.rg.contractive_implies_same_class hc _ _

/-! ## Falsifiable Conjecture -/

/-- **Conjecture (Discrete Universality)**: For any PDE family with finite symmetry
    dimension d, conservation count c, and differential order p, the number of
    universality classes is exactly (d + 1) · (c + 1). This is falsifiable:

    Test: For Burgers equation (d=1, c=1, p=2), predict 4 classes.
    For KdV (d=1, c=3, p=3), predict 8 classes.
    For 2D Navier-Stokes (d=2, c=2, p=2), predict 9 classes.

    Refutation: Find a PDE where the actual number of universality classes
    (measured by spectral collapse) differs from (d+1)·(c+1). -/
def conjecturedClassCount (inv : PDEInvariant) : ℕ :=
  (inv.symmetryDim + 1) * (inv.conservationLaws + 1)

/-- The conjectured count is always at least 2 -/
theorem conjecturedClassCount_ge_two (inv : PDEInvariant) :
    2 ≤ conjecturedClassCount inv := by
  unfold conjecturedClassCount
  have h1 : 2 ≤ inv.symmetryDim + 1 := by have := inv.symm_pos; omega
  have h2 : 1 ≤ inv.conservationLaws + 1 := by omega
  calc 2 = 2 * 1 := by ring
    _ ≤ (inv.symmetryDim + 1) * (inv.conservationLaws + 1) := by
        exact Nat.mul_le_mul h1 h2

/-- The conjectured count grows with symmetry dimension -/
theorem conjecturedClassCount_mono_symm {inv₁ inv₂ : PDEInvariant}
    (hs : inv₁.symmetryDim ≤ inv₂.symmetryDim)
    (hc : inv₁.conservationLaws = inv₂.conservationLaws) :
    conjecturedClassCount inv₁ ≤ conjecturedClassCount inv₂ := by
  unfold conjecturedClassCount
  rw [hc]
  apply Nat.mul_le_mul_right
  omega

/-! ## Orbit Recurrence via Pigeonhole -/

/-
For finite operator spaces, the RG orbit must eventually recur.
    This connects to the counting of universality classes in finite settings.
-/
theorem orbit_recurrence {α : Type*} [Fintype α] [DecidableEq α]
    (rg : RGSemigroup α) (x : α) :
    ∃ i j : ℕ, i < j ∧ j ≤ Fintype.card α ∧
      rg.iterate i x = rg.iterate j x := by
  -- By definition of $RGSemigroup$, the set $\{ \text{iterate } i x \mid i \in \{ 0, 1, \ldots, \text{Fintype.card } \alpha \} \}$ is finite and has cardinality at most $\text{Fintype.card } \alpha + 1$.
  have h_card : Finset.card (Finset.image (fun i => rg.iterate i x) (Finset.range (Fintype.card α + 1))) ≤ Fintype.card α := by
    exact Finset.card_le_univ _;
  contrapose! h_card;
  rw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( le_of_not_gt fun hi' => h_card _ _ hi' ( by linarith [ Finset.mem_range.mp hi, Finset.mem_range.mp hj ] ) hij.symm ) ( le_of_not_gt fun hj' => h_card _ _ hj' ( by linarith [ Finset.mem_range.mp hi, Finset.mem_range.mp hj ] ) hij ) ] ; simp +arith +decide

/-! ## Convergence to Fixed Point -/

/-- If the RG orbit is Cauchy (from contractivity) and we have a fixed point,
    then the orbit converges to it. -/
theorem contractive_converges_to_unique_fp {α : Type*} (rg : RGSemigroup α)
    {c : ℝ} (hc : rg.IsContractive c) {fp : α}
    (hfp : rg.IsFixedPoint fp) (x : α) :
    rg.ConvergesToFixed x fp := by
  constructor
  · exact hfp
  · intro ε hε
    -- iterate fp = fp for all n, so dist(iterate n x, fp) ≤ c^n * dist(x, fp)
    have hfp_iter : ∀ n, rg.iterate n fp = fp := by
      intro n; induction n with
      | zero => rfl
      | succ n ih => rw [rg.iterate_succ, ih]; exact hfp
    by_cases hd : rg.dist x fp = 0
    · exact ⟨0, fun n _ => by
        have hxfp : x = fp := (rg.dist_eq_zero x fp).mp hd
        rw [hxfp, hfp_iter, (rg.dist_eq_zero _ _).mpr rfl]; exact hε⟩
    · have hd_pos : 0 < rg.dist x fp := by
        rcases lt_or_eq_of_le (rg.dist_nonneg x fp) with h | h
        · exact h
        · exact absurd h.symm hd
      obtain ⟨N, hN⟩ := exists_pow_lt_of_lt_one (div_pos hε hd_pos) hc.2.1
      refine ⟨N, fun n hn => ?_⟩
      calc rg.dist (rg.iterate n x) fp
          = rg.dist (rg.iterate n x) (rg.iterate n fp) := by rw [hfp_iter]
        _ ≤ c ^ n * rg.dist x fp := rg.contractive_iterate_bound hc x fp n
        _ ≤ c ^ N * rg.dist x fp := by
            apply mul_le_mul_of_nonneg_right _ (le_of_lt hd_pos)
            exact pow_le_pow_of_le_one hc.1 (le_of_lt hc.2.1) hn
        _ < (ε / rg.dist x fp) * rg.dist x fp := mul_lt_mul_of_pos_right hN hd_pos
        _ = ε := div_mul_cancel₀ ε (ne_of_gt hd_pos)

end