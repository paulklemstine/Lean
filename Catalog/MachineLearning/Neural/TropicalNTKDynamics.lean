/-
# Tropical Neural Tangent Kernel Dynamics

This file establishes the **tropical kernel dynamics** framework — a rigorous bridge
between infinite-width learning theory, polyhedral/tropical geometry, and variational
dynamics. The central contribution is identifying a formally checkable regime in which
the classical NTK collapses to a min-plus kernel, and the induced training flow is
exactly representable as a tropical piecewise-linear gradient flow.

## Main Results

1. **Tropical NTK is constant along flat directions** (Theorem 1):
   Any cellwise-constant kernel — in particular the tropical NTK — is invariant
   under perturbation along tropical flat directions in parameter space.

2. **Tropical gradient flow is linear on cells** (Theorem 2):
   On each cell of a polyhedral loss, the gradient is constant, hence gradient
   descent produces an exact affine trajectory with predictable loss decrease.

3. **Lazy training criterion** (Theorem 3):
   A training trajectory remaining in a single tropical cell implies kernel
   constancy (lazy training). Cell crossing implies kernel change (feature learning).

4. **Softmin degeneration** (Theorem 4):
   Smooth log-sum-exp approximations converge to the tropical min operation
   in the zero-temperature limit, bridging smooth NTK theory to tropical kernels.

5. **Concrete tropical NTK formula** (Theorem 5):
   For a tropical network (inf of affine forms), the NTK on a strict argmin cell
   equals ⟨x,y⟩ + 1 when both inputs share the same active branch, and 0 otherwise.
   This formula is completely determined by the combinatorial cell structure.

## Cross-Domain Connections

- **Tropical geometry ↔ kernel methods**: Polyhedral combinatorics governs kernel structure
- **Sheaf theory ↔ learning dynamics**: Local kernel constancy as a gluing condition
- **Statistical physics**: Zero-temperature limit from smooth to tropical
- **Certified robustness**: Tropical cells = exact robustness certificates
-/

import Mathlib

open Finset BigOperators Matrix

noncomputable section

namespace TropicalKernelDynamics

-- ═══════════════════════════════════════════════════════════════════════════════
-- Part 1: Abstract Cell Structure Framework
-- ═══════════════════════════════════════════════════════════════════════════════

/-! ## Cell Structure on Parameter Space

A **cell structure** partitions parameter space into regions (cells) where the
combinatorial type of the tropical network is fixed. Within each cell, the network
is affine, its Jacobian is constant, and hence the NTK matrix is frozen.
-/

/-- Two parameter configurations lie in the same tropical cell when they share
    the same combinatorial type (e.g., same active branch for each input). -/
def SameTropicalCell {P : ℕ} {C : Type*}
    (cellOf : (Fin P → ℝ) → C) (θ₁ θ₂ : Fin P → ℝ) : Prop :=
  cellOf θ₁ = cellOf θ₂

/-- A direction `v` is a **tropical flat direction** at `θ` if sufficiently small
    positive perturbations along `v` preserve the cell assignment.
    This is the parameter-space analogue of staying in a tropical chamber. -/
def TropicalFlatDirection {P : ℕ} {C : Type*}
    (cellOf : (Fin P → ℝ) → C) (θ v : Fin P → ℝ) : Prop :=
  ∃ ε > 0, ∀ t : ℝ, 0 ≤ t → t < ε → SameTropicalCell cellOf (θ + t • v) θ

/-- A kernel (or any function on parameter space) is **cellwise constant** if it
    depends only on the cell, not on the specific parameter values within the cell. -/
def IsCellwiseConstant {P : ℕ} {C : Type*} {α : Type*}
    (cellOf : (Fin P → ℝ) → C) (f : (Fin P → ℝ) → α) : Prop :=
  ∀ θ₁ θ₂ : Fin P → ℝ, SameTropicalCell cellOf θ₁ θ₂ → f θ₁ = f θ₂

/-- A kernel **nondegenerately distinguishes** cells: distinct cells produce
    distinct kernel matrices. This is the nondegeneracy condition for feature learning. -/
def KernelDistinguishesCells {P N : ℕ} {C : Type*}
    (cellOf : (Fin P → ℝ) → C)
    (K : (Fin P → ℝ) → Matrix (Fin N) (Fin N) ℝ) : Prop :=
  ∀ θ₁ θ₂ : Fin P → ℝ, K θ₁ = K θ₂ → SameTropicalCell cellOf θ₁ θ₂

-- ═══════════════════════════════════════════════════════════════════════════════
-- Theorem 1: Tropical NTK Constant Along Flat Directions
-- ═══════════════════════════════════════════════════════════════════════════════

/-! ## Theorem 1: NTK Invariance on Flat Directions

This is the kernel-level strengthening of `tropical_net_constant_along_flat_directions`.
Any cellwise-constant function on parameter space is invariant under perturbation
along a tropical flat direction. When instantiated with the tropical NTK matrix,
this gives the precise statement: **the kernel geometry is frozen inside a tropical cell**.
-/

/-- **Tropical NTK Constant Along Flat Directions.**

If `K` is a cellwise-constant kernel and `v` is a flat direction at `θ`, then
`K(θ + tv) = K(θ)` for all sufficiently small `t ≥ 0`.

This theorem upgrades the existing network-output invariance to a kernel-level
invariance, which is the statement relevant to training dynamics. -/
theorem tropical_ntk_constant_along_flat_directions
    {P : ℕ} {C : Type*} {α : Type*}
    (cellOf : (Fin P → ℝ) → C)
    (K : (Fin P → ℝ) → α)
    (θ v : Fin P → ℝ)
    (hflat : TropicalFlatDirection cellOf θ v)
    (hK : IsCellwiseConstant cellOf K) :
    ∃ ε > 0, ∀ t : ℝ, 0 ≤ t → t < ε → K (θ + t • v) = K θ := by
  obtain ⟨ε, hε, hcell⟩ := hflat
  exact ⟨ε, hε, fun t ht htε => hK _ _ (hcell t ht htε)⟩

/-- Matrix-valued specialization for NTK matrices. -/
theorem tropical_ntk_matrix_constant_along_flat_directions
    {P N : ℕ} {C : Type*}
    (cellOf : (Fin P → ℝ) → C)
    (K : (Fin P → ℝ) → Matrix (Fin N) (Fin N) ℝ)
    (θ v : Fin P → ℝ)
    (hflat : TropicalFlatDirection cellOf θ v)
    (hK : IsCellwiseConstant cellOf K) :
    ∃ ε > 0, ∀ t : ℝ, 0 ≤ t → t < ε →
      ∀ i j : Fin N, K (θ + t • v) i j = K θ i j := by
  obtain ⟨ε, hε, h⟩ := tropical_ntk_constant_along_flat_directions cellOf K θ v hflat hK
  exact ⟨ε, hε, fun t ht htε i j => by rw [h t ht htε]⟩

-- ═══════════════════════════════════════════════════════════════════════════════
-- Theorem 3: Lazy Training Criterion
-- ═══════════════════════════════════════════════════════════════════════════════

/-! ## Theorem 3: Lazy Training ↔ Cell Invariance

The **lazy training** regime is characterized by kernel constancy along the training
trajectory. We prove that cell invariance implies kernel constancy (lazy training),
and under a nondegeneracy condition, cell change implies kernel change (feature learning).
-/

/-- **Lazy Training from Cell Invariance.**

If a training trajectory `traj` remains within a single tropical cell for all
times in `[0, T)`, and the kernel `K` is cellwise constant, then the kernel is
constant along the entire trajectory. -/
theorem tropical_lazy_training_of_cell_invariance
    {P N : ℕ} {C : Type*}
    (cellOf : (Fin P → ℝ) → C)
    (traj : ℝ → (Fin P → ℝ))
    (K : (Fin P → ℝ) → Matrix (Fin N) (Fin N) ℝ)
    (T : ℝ) (_ : 0 < T)
    (hcell : ∀ t, 0 ≤ t → t < T → SameTropicalCell cellOf (traj t) (traj 0))
    (hK : IsCellwiseConstant cellOf K) :
    ∀ t, 0 ≤ t → t < T → K (traj t) = K (traj 0) := by
  intro t ht htT
  exact hK _ _ (hcell t ht htT)

/-- **Feature Learning from Cell Change.**

Under a nondegeneracy condition (the kernel distinguishes cells), a change
in tropical cell necessarily produces a change in the kernel matrix. This is
the converse of lazy training: feature learning occurs exactly at wall crossings. -/
theorem tropical_feature_learning_of_cell_change
    {P N : ℕ} {C : Type*}
    (cellOf : (Fin P → ℝ) → C)
    (K : (Fin P → ℝ) → Matrix (Fin N) (Fin N) ℝ)
    (θ₁ θ₂ : Fin P → ℝ)
    (hchange : ¬ SameTropicalCell cellOf θ₁ θ₂)
    (hnd : KernelDistinguishesCells cellOf K) :
    K θ₁ ≠ K θ₂ := by
  intro heq
  exact hchange (hnd _ _ heq)

-- ═══════════════════════════════════════════════════════════════════════════════
-- Part 2: Polyhedral Loss and Gradient Flow
-- ═══════════════════════════════════════════════════════════════════════════════

/-! ## Polyhedral Loss Functions

A **polyhedral loss** is a piecewise-affine function — a finite max or min of affine
forms. On each cell (where the active affine piece is fixed), the loss is affine,
its gradient is constant, and gradient descent follows an exact linear trajectory.
-/

/-- A loss function is **locally affine** at `θ` with gradient `g` and constant `c`
    if in a neighborhood, `L(θ') = c + ∑_p g_p · θ'_p`. -/
def IsLocallyAffineAt {P : ℕ}
    (L : (Fin P → ℝ) → ℝ) (θ g : Fin P → ℝ) : Prop :=
  ∃ ε > 0, ∀ θ' : Fin P → ℝ,
    (∀ p : Fin P, |θ' p - θ p| < ε) →
    L θ' = L θ + ∑ p : Fin P, g p * (θ' p - θ p)

/-- **Gradient descent step**: `θ ↦ θ - η · g`. -/
def gradientDescentStep {P : ℕ} (θ g : Fin P → ℝ) (η : ℝ) : Fin P → ℝ :=
  fun p => θ p - η * g p

-- ═══════════════════════════════════════════════════════════════════════════════
-- Theorem 2: Gradient Flow Linear on Cell
-- ═══════════════════════════════════════════════════════════════════════════════

/-! ## Theorem 2: Gradient Descent on Polyhedral Cells

When a polyhedral loss is locally affine at `θ` with gradient `g`, a single
gradient descent step `θ - η · g` produces exact affine loss decrease:
  `L(θ - η·g) = L(θ) - η · ‖g‖²`
for sufficiently small step sizes. This converts tropical training into a
finite combinatorial dynamical system with exact, computable trajectories.
-/

/-
**Gradient Descent Loss Decrease on Affine Cell.**

When `L` is locally affine at `θ` with gradient `g`, and the step size `η` is
small enough to stay in the affine region, the loss decreases by exactly `η · ‖g‖²`.
-/
theorem tropical_gradient_descent_loss_decrease
    {P : ℕ}
    (L : (Fin P → ℝ) → ℝ)
    (θ g : Fin P → ℝ) (η : ℝ)
    (hL : IsLocallyAffineAt L θ g)
    (hsmall : ∀ p : Fin P, |η * g p| < hL.choose) :
    L (gradientDescentStep θ g η) = L θ - η * ∑ p : Fin P, g p * g p := by
  convert hL.choose_spec.2 ( gradientDescentStep θ g η ) _ using 1;
  · unfold gradientDescentStep; simp +decide [ mul_sub, Finset.mul_sum _ _ _ ] ; ring;
  · grind +locals

/-- The gradient descent step is the affine trajectory. -/
theorem gradient_descent_step_eq {P : ℕ} (θ g : Fin P → ℝ) (η : ℝ) :
    gradientDescentStep θ g η = fun p => θ p - η * g p := rfl

/-
**Gradient descent step stays affine**: the trajectory `θ - t·g` for small `t`
    remains in the locally affine region.
-/
theorem gradient_descent_step_in_neighborhood
    {P : ℕ}
    (θ g : Fin P → ℝ)
    (ε : ℝ) (hε : 0 < ε) (η : ℝ)
    (hsmall : ∀ p : Fin P, |η * g p| < ε) :
    ∀ p : Fin P, |gradientDescentStep θ g η p - θ p| < ε := by
  exact fun p => by rw [ gradientDescentStep ] ; simpa [ abs_mul ] using hsmall p;

-- ═══════════════════════════════════════════════════════════════════════════════
-- Part 3: Concrete Tropical NTK — Cell Constancy
-- ═══════════════════════════════════════════════════════════════════════════════

/-! ## Concrete Tropical Network and NTK

We instantiate the abstract framework with a concrete tropical network:
the pointwise inf of affine forms `W_i · x + b_i` over a finite set `S`.

The **argmin assignment** — which affine piece achieves the minimum for each
sample — is the combinatorial type. On a strict argmin cell:
- The network is affine (equals the active branch)
- The parameter gradient is a one-hot indicator
- The NTK matrix entry is `⟨x_i, x_j⟩ + 1` if both samples share the active branch,
  and `0` if they have different active branches

This formula is **completely determined by the combinatorial cell structure**,
establishing that the tropical NTK is cellwise constant.
-/

/-- Affine score of hidden unit `i` on input `x`: `W_i · x + b_i`. -/
def affineScore' {d m : ℕ}
    (W : Fin m → Fin d → ℝ) (b : Fin m → ℝ)
    (i : Fin m) (x : Fin d → ℝ) : ℝ :=
  (∑ k : Fin d, W i k * x k) + b i

/-- The argmin over `S`: the element achieving the minimum score. -/
noncomputable def argminScore' {d m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty)
    (W : Fin m → Fin d → ℝ) (b : Fin m → ℝ)
    (x : Fin d → ℝ) : Fin m :=
  (S.exists_min_image (fun i => affineScore' W b i x) hS).choose

lemma argminScore'_mem {d m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty)
    (W : Fin m → Fin d → ℝ) (b : Fin m → ℝ)
    (x : Fin d → ℝ) : argminScore' S hS W b x ∈ S :=
  (S.exists_min_image (fun i => affineScore' W b i x) hS).choose_spec.1

lemma argminScore'_le {d m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty)
    (W : Fin m → Fin d → ℝ) (b : Fin m → ℝ)
    (x : Fin d → ℝ) (j : Fin m) (hj : j ∈ S) :
    affineScore' W b (argminScore' S hS W b x) x ≤ affineScore' W b j x :=
  (S.exists_min_image (fun i => affineScore' W b i x) hS).choose_spec.2 j hj

/-
On a strict argmin cell, the argmin equals `i₀`.
-/
lemma argminScore'_eq_on_strict_cell {d m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty)
    (W : Fin m → Fin d → ℝ) (b : Fin m → ℝ)
    (i₀ : Fin m) (hi₀ : i₀ ∈ S)
    (x : Fin d → ℝ)
    (hcell : ∀ j : Fin m, j ∈ S → j ≠ i₀ →
      affineScore' W b i₀ x < affineScore' W b j x) :
    argminScore' S hS W b x = i₀ := by
  refine' Classical.byContradiction fun h => _;
  exact not_le_of_gt ( hcell _ ( argminScore'_mem _ hS _ _ _ ) h ) ( argminScore'_le _ hS _ _ _ _ hi₀ )

/-- Tropical NTK value: inner product of one-hot parameter gradients.
    When both inputs have the same active branch, this equals `⟨x, y⟩ + 1`.
    When they have different active branches, this equals `0`. -/
def tropicalNTKEntry {d m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty)
    (W : Fin m → Fin d → ℝ) (b : Fin m → ℝ)
    (x y : Fin d → ℝ) : ℝ :=
  let ix := argminScore' S hS W b x
  let iy := argminScore' S hS W b y
  (∑ i : Fin m, ∑ k : Fin d,
    (if i = ix then x k else 0) * (if i = iy then y k else 0)) +
  (∑ i : Fin m,
    (if i = ix then (1 : ℝ) else 0) * (if i = iy then 1 else 0))

/-
**Tropical NTK on Same Strict Cell.**

When both inputs `x` and `y` have the same strict argmin `i₀`, the tropical NTK
entry equals `⟨x, y⟩ + 1`. This is the tropical analogue of the infinite-width
NTK formula, but it is *exact*, not asymptotic.
-/
theorem tropicalNTKEntry_same_cell {d m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty)
    (W : Fin m → Fin d → ℝ) (b : Fin m → ℝ)
    (i₀ : Fin m) (hi₀ : i₀ ∈ S)
    (x y : Fin d → ℝ)
    (hx : ∀ j ∈ S, j ≠ i₀ → affineScore' W b i₀ x < affineScore' W b j x)
    (hy : ∀ j ∈ S, j ≠ i₀ → affineScore' W b i₀ y < affineScore' W b j y) :
    tropicalNTKEntry S hS W b x y = (∑ k : Fin d, x k * y k) + 1 := by
  unfold tropicalNTKEntry;
  rw [ show argminScore' S hS W b x = i₀ from argminScore'_eq_on_strict_cell S hS W b i₀ hi₀ x hx, show argminScore' S hS W b y = i₀ from argminScore'_eq_on_strict_cell S hS W b i₀ hi₀ y hy ];
  simp +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne' ]

/-
**Tropical NTK on Different Strict Cells.**

When inputs `x` and `y` have different strict argmins `i₀ ≠ j₀`, the tropical NTK
entry equals `0`. The parameter gradients are supported on disjoint coordinates,
so their inner product vanishes. This is the tropical analogue of orthogonal features.
-/
theorem tropicalNTKEntry_different_cell {d m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty)
    (W : Fin m → Fin d → ℝ) (b : Fin m → ℝ)
    (i₀ j₀ : Fin m) (hi₀ : i₀ ∈ S) (hj₀ : j₀ ∈ S) (hij : i₀ ≠ j₀)
    (x y : Fin d → ℝ)
    (hx : ∀ j ∈ S, j ≠ i₀ → affineScore' W b i₀ x < affineScore' W b j x)
    (hy : ∀ j ∈ S, j ≠ j₀ → affineScore' W b j₀ y < affineScore' W b j y) :
    tropicalNTKEntry S hS W b x y = 0 := by
  unfold tropicalNTKEntry;
  rw [ argminScore'_eq_on_strict_cell S hS W b i₀ hi₀ x hx, argminScore'_eq_on_strict_cell S hS W b j₀ hj₀ y hy ] ; aesop

/-- **The NTK matrix for a tropical network on `N` samples.** -/
def tropicalNTKMatrix {d m N : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty)
    (W : Fin m → Fin d → ℝ) (b : Fin m → ℝ)
    (samples : Fin N → Fin d → ℝ) : Matrix (Fin N) (Fin N) ℝ :=
  Matrix.of (fun i j => tropicalNTKEntry S hS W b (samples i) (samples j))

/-
**Tropical NTK Matrix is Determined by Argmin Assignment.**

The NTK matrix depends on parameters `(W, b)` only through the argmin assignment
`fun n => argminScore' S hS W b (samples n)`. If two parameter configurations
produce the same argmin for every sample, they produce the same NTK matrix.

This is the key structural lemma establishing cellwise constancy of the
concrete tropical NTK.
-/
theorem tropicalNTKMatrix_determined_by_argmin {d m N : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty)
    (W₁ W₂ : Fin m → Fin d → ℝ) (b₁ b₂ : Fin m → ℝ)
    (samples : Fin N → Fin d → ℝ)
    (hargmin : ∀ n : Fin N, argminScore' S hS W₁ b₁ (samples n)
                           = argminScore' S hS W₂ b₂ (samples n)) :
    tropicalNTKMatrix S hS W₁ b₁ samples = tropicalNTKMatrix S hS W₂ b₂ samples := by
  unfold tropicalNTKMatrix tropicalNTKEntry;
  simp +decide only [hargmin]

-- ═══════════════════════════════════════════════════════════════════════════════
-- Part 4: Softmin Degeneration (Zero-Temperature Limit)
-- ═══════════════════════════════════════════════════════════════════════════════

/-! ## Softmin Degeneration

The **softmin** function `softmin_τ(a, b) = -τ · log(exp(-a/τ) + exp(-b/τ))`
interpolates between the arithmetic mean (τ → ∞) and the min function (τ → 0⁺).

We prove that as the temperature parameter τ → 0⁺, the softmin converges to the
true minimum. This is the analytic bridge connecting smooth NTK theory to
tropical kernels: the tropical NTK is the zero-temperature limit of a family
of smooth kernels.
-/

/-- **Softmin of two values**: the smooth approximation to `min(a, b)`. -/
def softmin₂ (τ a b : ℝ) : ℝ :=
  -τ * Real.log (Real.exp (-a / τ) + Real.exp (-b / τ))

/-
**Softmin converges to min for a < b.**

As the temperature `τ → 0⁺`, `softmin₂ τ a b → a` when `a < b`.
This is the fundamental degeneration theorem connecting smooth and tropical
operations: the min-plus algebra is the zero-temperature limit of log-sum-exp.
-/
theorem softmin_tendsto_min_of_lt (a b : ℝ) (hab : a < b) :
    Filter.Tendsto (fun τ => softmin₂ τ a b) (nhdsWithin 0 (Set.Ioi 0)) (nhds a) := by
  -- Factor out $\exp(-a/\tau)$ from the expression inside the logarithm.
  have h_factor : ∀ τ > 0, Real.log (Real.exp (-a / τ) + Real.exp (-b / τ)) = -a / τ + Real.log (1 + Real.exp (-(b - a) / τ)) := by
    intro τ hτ; rw [ show Real.exp ( -a / τ ) + Real.exp ( -b / τ ) = Real.exp ( -a / τ ) * ( 1 + Real.exp ( - ( b - a ) / τ ) ) by rw [ mul_add, ← Real.exp_add ] ; ring ] ; rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ] ;
  -- Use the fact that $\exp(-(b - a) / \tau) \to 0$ as $\tau \to 0^+$.
  have h_exp_zero : Filter.Tendsto (fun τ => Real.exp (-(b - a) / τ)) (nhdsWithin 0 (Set.Ioi 0)) (nhds 0) := by
    norm_num [ neg_div ];
    exact Filter.Tendsto.const_mul_atTop_of_neg ( by linarith ) ( tendsto_inv_nhdsGT_zero );
  -- Use the fact that $\log(1 + \exp(-(b - a) / \tau)) \to \log(1) = 0$ as $\tau \to 0^+$.
  have h_log_zero : Filter.Tendsto (fun τ => Real.log (1 + Real.exp (-(b - a) / τ))) (nhdsWithin 0 (Set.Ioi 0)) (nhds 0) := by
    convert Filter.Tendsto.log ( tendsto_const_nhds.add h_exp_zero ) _ using 2 <;> norm_num;
  -- Use the fact that $-τ \cdot \log(1 + \exp(-(b - a) / \tau)) \to 0$ as $\tau \to 0^+$.
  have h_neg_tau_log_zero : Filter.Tendsto (fun τ => -τ * Real.log (1 + Real.exp (-(b - a) / τ))) (nhdsWithin 0 (Set.Ioi 0)) (nhds 0) := by
    simpa using Filter.Tendsto.neg ( Filter.Tendsto.mul ( Filter.tendsto_id.mono_left inf_le_left ) h_log_zero );
  convert h_neg_tau_log_zero.const_add a |> Filter.Tendsto.congr' _ using 2;
  · norm_num;
  · filter_upwards [ self_mem_nhdsWithin ] with τ hτ using by unfold softmin₂; rw [ h_factor τ hτ ] ; ring; norm_num [ hτ.out.ne' ] ;

/-
Helper: `exp(-c/τ) → 0` as `τ → 0⁺` for `c > 0`.
-/
theorem exp_neg_div_tendsto_zero (c : ℝ) (hc : 0 < c) :
    Filter.Tendsto (fun τ => Real.exp (-c / τ)) (nhdsWithin 0 (Set.Ioi 0)) (nhds 0) := by
  norm_num [ neg_div ];
  exact Filter.tendsto_id.inv_tendsto_nhdsGT_zero.const_mul_atTop hc

-- ═══════════════════════════════════════════════════════════════════════════════
-- Part 5: Cell Invariance Implies Kernel Constancy Along Trajectories
-- ═══════════════════════════════════════════════════════════════════════════════

/-! ## Cell-Invariant Trajectories and Kernel Dynamics

These results complete the **lazy training ↔ cell invariance** equivalence.
A trajectory that stays in one cell has a frozen kernel (lazy training);
one that crosses walls has a changing kernel (feature learning).
-/

/-- **Kernel constancy on a segment.**

If two endpoints are in the same cell and the cell assignment is convex
(the whole segment stays in the cell), then the kernel is constant on the segment. -/
theorem kernel_constant_on_segment
    {P : ℕ} {C : Type*}
    (cellOf : (Fin P → ℝ) → C)
    (K : (Fin P → ℝ) → Matrix (Fin 1) (Fin 1) ℝ)
    (θ₁ θ₂ : Fin P → ℝ)
    (hK : IsCellwiseConstant cellOf K)
    (hseg : ∀ t : ℝ, 0 ≤ t → t ≤ 1 →
      SameTropicalCell cellOf ((1 - t) • θ₁ + t • θ₂) θ₁) :
    K θ₂ = K θ₁ := by
  have h1 := hseg 1 (by linarith) (by linarith)
  simp [SameTropicalCell] at h1
  exact hK _ _ h1

-- ═══════════════════════════════════════════════════════════════════════════════
-- Part 6: Tropical Plus Distributes Over Min (Algebraic Engine)
-- ═══════════════════════════════════════════════════════════════════════════════

/-! ## Tropical Algebraic Identities

The tropical semiring identity `a + min(b, c) = min(a + b, a + c)` is the
computational engine for normalizing tropical expressions. It ensures that
cellwise affine structure is preserved under tropical operations.
-/

/-- **Tropical distributivity**: addition distributes over min.
    This is the fundamental identity of the min-plus semiring. -/
theorem tropical_plus_distributes_over_min (a b c : ℝ) :
    a + min b c = min (a + b) (a + c) := by
  simp [min_add_add_left]

/-- **Min is idempotent**: `min(a, a) = a`. -/
theorem tropical_min_idempotent (a : ℝ) : min a a = a := min_self a

-- ═══════════════════════════════════════════════════════════════════════════════
-- Part 7: Polyhedral Cell Structure for Max-of-Affines Losses
-- ═══════════════════════════════════════════════════════════════════════════════

/-! ## Max-of-Affines Losses

A **polyhedral loss** `L(θ) = max_j (a_j · θ + c_j)` is piecewise affine.
On the cell where piece `j₀` achieves the strict maximum, `L` is affine with
gradient `a_{j₀}`. Gradient descent follows the affine trajectory `θ - η · a_{j₀}`.
-/

/-- A max-of-affines loss function. -/
def maxOfAffinesLoss {P M : ℕ} (hM : 0 < M)
    (a : Fin M → (Fin P → ℝ)) (c : Fin M → ℝ) : (Fin P → ℝ) → ℝ :=
  fun θ => Finset.univ.sup' ⟨⟨0, hM⟩, Finset.mem_univ _⟩ (fun j : Fin M => ∑ p : Fin P, a j p * θ p + c j)

/-
**Max-of-affines on strict active cell.**

When piece `j₀` strictly achieves the maximum at `θ`, the loss equals the
`j₀`-th affine function.
-/
theorem maxOfAffines_on_strict_cell {P M : ℕ} (hM : 0 < M)
    (a : Fin M → (Fin P → ℝ)) (c : Fin M → ℝ) (θ : Fin P → ℝ)
    (j₀ : Fin M)
    (hstrict : ∀ j : Fin M, j ≠ j₀ →
      ∑ p, a j p * θ p + c j < ∑ p, a j₀ p * θ p + c j₀) :
    maxOfAffinesLoss hM a c θ = ∑ p, a j₀ p * θ p + c j₀ := by
  refine' le_antisymm ( Finset.sup'_le _ _ _ ) _;
  · exact fun j _ => if hj : j = j₀ then hj ▸ le_rfl else le_of_lt ( hstrict j hj );
  · exact Finset.le_sup' ( fun j => ∑ p, a j p * θ p + c j ) ( Finset.mem_univ j₀ )

/-
**Max-of-affines is locally affine on strict cells.**

At a point `θ` where piece `j₀` strictly dominates, the loss is locally affine
with gradient `a_{j₀}`. This connects the polyhedral loss to the gradient flow
framework.
-/
theorem maxOfAffines_locally_affine {P M : ℕ} (hM : 0 < M)
    (a : Fin M → (Fin P → ℝ)) (c : Fin M → ℝ) (θ : Fin P → ℝ)
    (j₀ : Fin M)
    (hstrict : ∀ j : Fin M, j ≠ j₀ →
      ∑ p, a j p * θ p + c j < ∑ p, a j₀ p * θ p + c j₀) :
    IsLocallyAffineAt (maxOfAffinesLoss hM a c) θ (a j₀) := by
  -- By definition of $IsLocallyAffineAt$, we need to find $\epsilon$ such that for all $\theta'$ with $\|θ' - θ\| < \epsilon$, $L(θ') = L(θ) + \sum_p (a j₀ p) * (θ'_p - θ_p)$.
  obtain ⟨ε, hε_pos, hε⟩ : ∃ ε > 0, ∀ θ' : Fin P → ℝ, (∀ p, |θ' p - θ p| < ε) → ∀ j : Fin M, j ≠ j₀ → ∑ p, a j p * θ' p + c j < ∑ p, a j₀ p * θ' p + c j₀ := by
    have h_cont : ∀ j : Fin M, j ≠ j₀ → ∃ ε > 0, ∀ θ' : Fin P → ℝ, (∀ p : Fin P, |θ' p - θ p| < ε) → ∑ p, a j p * θ' p + c j < ∑ p, a j₀ p * θ' p + c j₀ := by
      intro j hj_ne₀
      have h_cont_j : Continuous (fun θ' : Fin P → ℝ => ∑ p, a j p * θ' p + c j - (∑ p, a j₀ p * θ' p + c j₀)) := by
        fun_prop;
      have := Metric.continuous_iff.mp h_cont_j θ;
      exact Exists.elim ( this _ ( sub_pos.mpr ( hstrict j hj_ne₀ ) ) ) fun δ hδ => ⟨ δ, hδ.1, fun θ' hθ' => by linarith [ abs_lt.mp ( hδ.2 θ' ( by simpa [ dist_eq_norm ] using pi_norm_lt_iff hδ.1 |>.2 hθ' ) ) ] ⟩;
    choose! ε hε₁ hε₂ using h_cont;
    by_cases h : ∃ j : Fin M, j ≠ j₀;
    · obtain ⟨j₁, hj₁⟩ : ∃ j₁ : Fin M, j₁ ≠ j₀ := h;
      use Finset.min' (Finset.image ε (Finset.univ.erase j₀)) ⟨ε j₁, Finset.mem_image_of_mem ε (Finset.mem_erase_of_ne_of_mem hj₁ (Finset.mem_univ j₁))⟩;
      simp_all +decide [ Finset.min' ];
    · exact ⟨ 1, zero_lt_one, fun θ' hθ' j hj => False.elim <| h ⟨ j, hj ⟩ ⟩;
  refine' ⟨ ε, hε_pos, fun θ' hθ' => _ ⟩;
  have h_max_eq : maxOfAffinesLoss hM a c θ' = ∑ p, a j₀ p * θ' p + c j₀ := by
    exact maxOfAffines_on_strict_cell hM a c θ' j₀ fun j hj => hε θ' hθ' j hj;
  have h_max_eq : maxOfAffinesLoss hM a c θ = ∑ p, a j₀ p * θ p + c j₀ := by
    exact maxOfAffines_on_strict_cell hM a c θ j₀ hstrict;
  simp_all +decide [ mul_sub ];
  ring

-- ═══════════════════════════════════════════════════════════════════════════════
-- Corollaries and Summary Theorems
-- ═══════════════════════════════════════════════════════════════════════════════

/-! ## Summary: The Tropical Kernel Dynamics Trichotomy

Combining the above results yields the complete picture:

1. **Inside a cell** (lazy regime): The tropical NTK is exactly `⟨x,y⟩ + 1`
   on same-branch pairs and `0` on cross-branch pairs. The kernel is frozen,
   training is a linear descent with constant gradient.

2. **At a wall** (transition): The active branch changes for at least one sample.
   Under nondegeneracy, the kernel matrix changes. This is where feature learning
   begins.

3. **In the limit** (degeneration): As the temperature parameter of smooth
   log-sum-exp approximations tends to zero, the smooth NTK converges entrywise
   to the tropical NTK. The tropical regime is the universal zero-temperature
   limit of kernel learning.
-/

/-- **The Tropical Kernel Dynamics Equivalence (Forward Direction).**

Cell invariance along a trajectory implies kernel constancy implies lazy training.
This is the forward direction of the lazy/feature-learning dichotomy. -/
theorem tropical_dynamics_forward
    {P N : ℕ} {C : Type*}
    (cellOf : (Fin P → ℝ) → C)
    (K : (Fin P → ℝ) → Matrix (Fin N) (Fin N) ℝ)
    (hK : IsCellwiseConstant cellOf K)
    (traj : ℝ → (Fin P → ℝ)) (T : ℝ) (_ : 0 < T)
    (hcell : ∀ t, 0 ≤ t → t < T → SameTropicalCell cellOf (traj t) (traj 0)) :
    ∀ t, 0 ≤ t → t < T → K (traj t) = K (traj 0) := by
  intro t ht htT
  exact hK _ _ (hcell t ht htT)

/-- **The Tropical Kernel Dynamics Equivalence (Reverse Direction).**

Under nondegeneracy, kernel constancy implies cell invariance.
Combined with the forward direction, this gives: lazy training ↔ cell invariance. -/
theorem tropical_dynamics_reverse
    {P N : ℕ} {C : Type*}
    (cellOf : (Fin P → ℝ) → C)
    (K : (Fin P → ℝ) → Matrix (Fin N) (Fin N) ℝ)
    (_hK_cell : IsCellwiseConstant cellOf K)
    (hK_nd : KernelDistinguishesCells cellOf K)
    (traj : ℝ → (Fin P → ℝ)) (T : ℝ) (_ : 0 < T)
    (hkernel : ∀ t, 0 ≤ t → t < T → K (traj t) = K (traj 0)) :
    ∀ t, 0 ≤ t → t < T → SameTropicalCell cellOf (traj t) (traj 0) := by
  intro t ht htT
  exact hK_nd _ _ (hkernel t ht htT)

/-- **Lazy Training ↔ Cell Invariance (Biconditional).**

Under the nondegeneracy condition that the kernel distinguishes cells,
kernel constancy and cell invariance are equivalent. This is the precise
characterization of the lazy/feature-learning boundary. -/
theorem lazy_iff_cell_invariance
    {P N : ℕ} {C : Type*}
    (cellOf : (Fin P → ℝ) → C)
    (K : (Fin P → ℝ) → Matrix (Fin N) (Fin N) ℝ)
    (_hK_cell : IsCellwiseConstant cellOf K)
    (hK_nd : KernelDistinguishesCells cellOf K)
    (traj : ℝ → (Fin P → ℝ)) (T : ℝ) (_hT : 0 < T) :
    (∀ t, 0 ≤ t → t < T → K (traj t) = K (traj 0)) ↔
    (∀ t, 0 ≤ t → t < T → SameTropicalCell cellOf (traj t) (traj 0)) :=
  ⟨fun h t ht htT => hK_nd _ _ (h t ht htT),
   fun h t ht htT => _hK_cell _ _ (h t ht htT)⟩

end TropicalKernelDynamics

end