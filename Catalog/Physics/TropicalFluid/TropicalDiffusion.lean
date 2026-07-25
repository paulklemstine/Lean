/-
# Tropical Diffusion and Maximum Principles

This file formalizes the core definitions and theorems of tropical (min-plus)
diffusion on finite state spaces, establishing maximum principles and
monotonicity results that form the foundation for tropical PDE regularity theory.

## Mathematical Context

The tropical diffusion operator `T_K(u)(i) = inf_j (u(j) + K(i,j))` is the
min-plus analogue of the classical heat semigroup. When `K` has nonneg entries,
this operator cannot decrease the global minimum — the **tropical maximum principle**.
When `K` additionally has zero diagonal, the global minimum is exactly preserved.

These results are the idempotent-algebraic analogues of the classical maximum
principle for parabolic PDEs and serve as the foundation for tropical regularity
criteria and anti-blowup barriers.

## Main Results

- `tropical_min_principle`: global minimum of `u` is a lower bound for `T_K(u)`
- `tropical_min_preserved`: with zero diagonal, global minimum is preserved exactly
- `tropicalDiffusion_monotone`: `T_K` is order-preserving (monotone)
- `tropicalDiffusion_add_const`: translation equivariance
- `fmax_tropicalDiffusion_le`: global maximum does not increase under `T_K`
-/

import Mathlib

open Finset

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-! ## Core Definitions -/

/-- Finite minimum: the minimum value of `u` over all elements of `ι`. -/
noncomputable def fmin (u : ι → ℝ) : ℝ :=
  Finset.inf' Finset.univ Finset.univ_nonempty u

/-- Finite maximum: the maximum value of `u` over all elements of `ι`. -/
noncomputable def fmax (u : ι → ℝ) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty u

/-- Min-plus tropical diffusion operator. At each site `i`, computes the
infimum over all sites `j` of `u(j) + K(i,j)`. This is the Lax–Oleinik /
Bellman operator in the finite min-plus setting. -/
noncomputable def tropicalDiffusion (K : ι → ι → ℝ) (u : ι → ℝ) : ι → ℝ :=
  fun i => Finset.inf' Finset.univ Finset.univ_nonempty (fun j => u j + K i j)

/-- A kernel is a tropical viscosity kernel if it has nonneg entries and
zero diagonal. -/
def isTropicalViscosityKernel (K : ι → ι → ℝ) : Prop :=
  (∀ i j, 0 ≤ K i j) ∧ (∀ i, K i i = 0)

/-- Dissipative update: combines the current state with tropical diffusion
plus a dissipation constant. -/
noncomputable def dissipativeUpdate (K : ι → ι → ℝ) (c : ℝ) (u : ι → ℝ) : ι → ℝ :=
  fun i => min (u i) (tropicalDiffusion K u i + c)

/-- Tropical energy (oscillation): the difference between global max and min. -/
noncomputable def tropicalEnergy (u : ι → ℝ) : ℝ :=
  fmax u - fmin u

/-! ## Basic Lemmas about fmin and fmax -/

theorem fmin_le_apply (u : ι → ℝ) (i : ι) : fmin u ≤ u i :=
  Finset.inf'_le u (Finset.mem_univ i)

theorem apply_le_fmax (u : ι → ℝ) (i : ι) : u i ≤ fmax u :=
  Finset.le_sup' u (Finset.mem_univ i)

theorem fmax_le_iff (u : ι → ℝ) (c : ℝ) : fmax u ≤ c ↔ ∀ i, u i ≤ c :=
  ⟨fun h i => le_trans (apply_le_fmax u i) h,
   fun h => Finset.sup'_le _ _ (fun i _ => h i)⟩

theorem le_fmin_iff (u : ι → ℝ) (c : ℝ) : c ≤ fmin u ↔ ∀ i, c ≤ u i :=
  ⟨fun h i => le_trans h (fmin_le_apply u i),
   fun h => Finset.le_inf' _ _ (fun i _ => h i)⟩

theorem fmax_mono {u v : ι → ℝ} (h : ∀ i, u i ≤ v i) : fmax u ≤ fmax v :=
  Finset.sup'_le _ _ (fun i _ => le_trans (h i) (apply_le_fmax v i))

theorem fmin_mono {u v : ι → ℝ} (h : ∀ i, u i ≤ v i) : fmin u ≤ fmin v :=
  Finset.le_inf' _ _ (fun i _ => le_trans (fmin_le_apply u i) (h i))

/-! ## Theorem A: Tropical Maximum Principle -/

/-
**Tropical Maximum Principle (lower bound).**
If all kernel entries are nonneg, then the global minimum of `u` is a
lower bound for every value of the tropical diffusion `T_K(u)`.

Mathematically: `∀ i, min_j u(j) ≤ T_K(u)(i)` when `K ≥ 0`.
-/
theorem tropical_min_principle
    (K : ι → ι → ℝ) (u : ι → ℝ)
    (hK : ∀ i j, 0 ≤ K i j) :
    ∀ i, fmin u ≤ tropicalDiffusion K u i := by
  exact fun i => Finset.le_inf' _ _ fun j _ => le_add_of_le_of_nonneg ( fmin_le_apply _ _ ) ( hK _ _ )

/-
**Tropical Maximum Principle (preservation).**
If `K` is a tropical viscosity kernel (nonneg entries, zero diagonal),
then the global minimum is exactly preserved by tropical diffusion.

Mathematically: `min_i T_K(u)(i) = min_i u(i)` when `K ≥ 0` and `K(i,i) = 0`.
-/
theorem tropical_min_preserved
    (K : ι → ι → ℝ) (u : ι → ℝ)
    (hK : ∀ i j, 0 ≤ K i j)
    (hdiag : ∀ i, K i i = 0) :
    fmin (tropicalDiffusion K u) = fmin u := by
  refine' le_antisymm _ _;
  · unfold fmin tropicalDiffusion;
    simp +decide [ Finset.inf'_le_iff ];
    exact fun i => ⟨ i, i, by simp +decide [ hdiag ] ⟩;
  · exact Finset.le_inf' _ _ fun i _ => tropical_min_principle K u hK i

/-
**Tropical Maximum Principle (upper bound).**
If `K` is a tropical viscosity kernel, then the global maximum does not
increase under tropical diffusion.
-/
theorem fmax_tropicalDiffusion_le
    (K : ι → ι → ℝ) (u : ι → ℝ)
    (hK : ∀ i j, 0 ≤ K i j)
    (hdiag : ∀ i, K i i = 0) :
    fmax (tropicalDiffusion K u) ≤ fmax u := by
  refine' fmax_le_iff _ _ |>.2 _;
  exact fun i => le_trans ( Finset.inf'_le _ ( Finset.mem_univ i ) ) ( by linarith [ hdiag i, apply_le_fmax u i ] )

/-! ## Monotonicity and Translation Equivariance -/

/-
**Monotonicity of tropical diffusion.**
If `u ≤ v` pointwise, then `T_K(u) ≤ T_K(v)` pointwise.
-/
theorem tropicalDiffusion_monotone
    (K : ι → ι → ℝ) :
    Monotone (tropicalDiffusion K : (ι → ℝ) → (ι → ℝ)) := by
  -- Let's unfold the definition of tropical diffusion.
  unfold tropicalDiffusion
  intro u v huv i
  simp [huv];
  exact fun j => ⟨ j, by linarith [ huv j ] ⟩

/-
**Translation equivariance.**
Shifting all values by a constant `c` shifts the output by the same constant.
-/
theorem tropicalDiffusion_add_const
    (K : ι → ι → ℝ) (u : ι → ℝ) (c : ℝ) :
    tropicalDiffusion K (fun i => u i + c) = fun i => tropicalDiffusion K u i + c := by
  funext i; simp [tropicalDiffusion];
  refine' le_antisymm _ _ <;> simp +decide [ add_comm, add_left_comm, add_assoc ];
  · simpa using Finset.exists_min_image Finset.univ ( fun j => K i j + u j ) ⟨ i, Finset.mem_univ i ⟩;
  · exact fun j => ⟨ j, le_rfl ⟩