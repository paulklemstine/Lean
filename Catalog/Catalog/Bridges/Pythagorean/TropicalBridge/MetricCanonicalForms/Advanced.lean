/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Metric Canonical Forms — Advanced Theorems

This file extends the canonical kernel theory on metric graph models with:
- S-supported Jacobian quotient equivalence relations
- Energy bilinear form and its descent to equivalence classes
- Principal divisor lattice structure (closure under addition, negation, scaling)
- Pendant-tree harmonic propagation and rigidity
- Refinement theory (model refinement structures)

## Cross-Domain Connections

- **Electrical networks**: The energy bilinear form computes effective
  resistances; the Jacobian quotient parametrizes independent current modes.
- **Quantum graphs**: Subdivision invariance of the principal divisor
  lattice corresponds to spectral stability under mesh refinement.
- **Tropical geometry**: The S-supported Jacobian quotient is the
  computational heart of the tropical Abel–Jacobi map.

## Catalog Dependencies

Builds directly on the discrete Laplacian theory from:
- `Pythagorean.TropicalBridge.Defs` (graphLaplacian, rootedSubsetDivisor)
- `Pythagorean.TropicalBridge.Theorems` (row-sum-zero, symmetry)
- `Pythagorean.TropicalBridge.MetricCanonicalForms.Theorems`
  (MGModel, weighted Laplacian, leaf rigidity, energy positivity)

## References

* Baker, M. and Faber, X. "Metrized graphs, Laplacian operators, and
  electrical networks" (2006)
* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a
  finite graph" (2007)
* Mikhalkin, G. and Zharkov, I. "Tropical curves, their Jacobians and
  theta functions" (2008)
-/

import Mathlib

open Finset BigOperators

/-! ## Metric Graph Model -/

/-- A metric graph model: finite simple graph with positive symmetric edge lengths. -/
structure MGM where
  V : Type
  [instFintype : Fintype V]
  [instDecEq : DecidableEq V]
  G : SimpleGraph V
  [instDecAdj : DecidableRel G.Adj]
  edgeLength : V → V → ℝ
  length_pos : ∀ i j, G.Adj i j → 0 < edgeLength i j
  length_symm : ∀ i j, edgeLength i j = edgeLength j i

attribute [instance] MGM.instFintype MGM.instDecEq MGM.instDecAdj

namespace MGM

variable (M : MGM)

/-- Conductance = 1 / edge_length. -/
noncomputable def cond (i j : M.V) : ℝ := 1 / M.edgeLength i j

theorem cond_pos (i j : M.V) (hadj : M.G.Adj i j) : 0 < M.cond i j :=
  div_pos one_pos (M.length_pos i j hadj)

theorem cond_symm (i j : M.V) : M.cond i j = M.cond j i := by
  simp [cond, M.length_symm]

/-- The metric Laplacian matrix. -/
noncomputable def mL : Matrix M.V M.V ℝ :=
  fun i j =>
    if i = j then ∑ k ∈ Finset.univ.filter (M.G.Adj i), M.cond i k
    else if M.G.Adj i j then -(M.cond i j)
    else 0

/-- Apply the metric Laplacian to a vertex function. -/
noncomputable def Lf (f : M.V → ℝ) (v : M.V) : ℝ :=
  ∑ j : M.V, M.mL v j * f j

/-- Harmonicity on a set. -/
def harmonicOn (S : Finset M.V) (f : M.V → ℝ) : Prop :=
  ∀ v ∈ S, M.Lf f v = 0

/-- Dirichlet energy. -/
noncomputable def energy (f : M.V → ℝ) : ℝ :=
  ∑ i : M.V, ∑ j : M.V, M.mL i j * f i * f j

/-- Mean-zero condition. -/
def meanZero (f : M.V → ℝ) : Prop := ∑ v : M.V, f v = 0

/-- Leaf predicate. -/
def isLeaf (v : M.V) : Prop := M.G.degree v = 1

/-- S-principal divisor: in the image of the Laplacian with harmonicity off S. -/
def IsSPrincipal (S : Finset M.V) (D : M.V → ℝ) : Prop :=
  ∃ f : M.V → ℝ, (∀ v, v ∉ S → M.Lf f v = 0) ∧ ∀ v, M.Lf f v = D v

/-- Degree-zero condition for a divisor. -/
def isDegZero (D : M.V → ℝ) : Prop := ∑ v : M.V, D v = 0

/-- S-supported: vanishes outside S. -/
def IsSSupported (S : Finset M.V) (D : M.V → ℝ) : Prop :=
  ∀ v, v ∉ S → D v = 0

/-! ## Row-sum-zero and symmetry -/

theorem mL_row_sum_zero (i : M.V) : ∑ j : M.V, M.mL i j = 0 := by
  simp +decide only [mL, sum_ite]
  simp +decide [Finset.filter_ne, Finset.filter_and]
  simp +decide [Finset.filter_eq, Finset.filter_erase]

theorem mL_symm (i j : M.V) : M.mL i j = M.mL j i := by
  unfold MGM.mL
  split_ifs <;> simp_all +decide [MGM.cond_symm, SimpleGraph.adj_comm]

theorem Lf_constant (c : ℝ) (v : M.V) : M.Lf (fun _ => c) v = 0 := by
  convert congr_arg (fun x => x * c) (M.mL_row_sum_zero v) using 1
  · simp +decide only [Lf, sum_mul]
  · ring

theorem Lf_total_sum_zero (f : M.V → ℝ) : ∑ v : M.V, M.Lf f v = 0 := by
  simp only [Lf]
  rw [Finset.sum_comm]
  apply Finset.sum_eq_zero; intro w _
  rw [← Finset.sum_mul]
  have : ∑ v : M.V, M.mL v w = 0 := by
    convert M.mL_row_sum_zero w using 1
    exact Finset.sum_congr rfl fun _ _ => M.mL_symm _ _
  rw [this, zero_mul]

/-! ## Theorem 1: Laplacian linearity -/

/-- The Laplacian of a sum equals the sum of Laplacians. -/
theorem Lf_add (f g : M.V → ℝ) (v : M.V) :
    M.Lf (fun w => f w + g w) v = M.Lf f v + M.Lf g v := by
  unfold Lf; simp [mul_add, Finset.sum_add_distrib]

/-- The Laplacian of a scalar multiple. -/
theorem Lf_smul (c : ℝ) (f : M.V → ℝ) (v : M.V) :
    M.Lf (fun w => c * f w) v = c * M.Lf f v := by
  unfold Lf; rw [Finset.mul_sum]; congr 1; ext j; ring

/-- The Laplacian of a negation. -/
theorem Lf_neg (f : M.V → ℝ) (v : M.V) :
    M.Lf (fun w => -f w) v = -M.Lf f v := by
  have := M.Lf_smul (-1) f v; simp at this; exact this

/-- The Laplacian of a difference. -/
theorem Lf_sub (f g : M.V → ℝ) (v : M.V) :
    M.Lf (fun w => f w - g w) v = M.Lf f v - M.Lf g v := by
  simp only [sub_eq_add_neg]; rw [show (fun w => f w + -g w) = (fun w => f w + (-1) * g w) from by ext; ring]
  rw [M.Lf_add, M.Lf_smul]; ring

/-! ## Theorem 2: Pendant-edge rigidity (metric version) -/

/-
At a leaf vertex with unique neighbor, harmonicity forces constancy.
    This is the metric generalization of the catalog's `harmonic_at_leaf_eq_neighbor`.
-/
theorem harmonic_leaf_eq_neighbor
    {v w : M.V} (f : M.V → ℝ)
    (hdeg : M.G.degree w = 1)
    (hadj : M.G.Adj w v)
    (hharm : M.Lf f w = 0) :
    f w = f v := by
  -- Since w has degree 1, the neighbor filter {k | G.Adj w k} = {v}. Therefore, the Laplacian equation simplifies to the conductance times (f(w) - f(v)) = 0. Hence, f(w) = f(v).
  have h_filter : Finset.filter (fun k => M.G.Adj w k) Finset.univ = {v} := by
    have := Finset.card_eq_one.mp hdeg;
    simp_all +decide [ Finset.eq_singleton_iff_unique_mem ];
    obtain ⟨ a, ha₁, ha₂ ⟩ := this; have := ha₂ v hadj; aesop;
  simp_all +decide [ MGM.Lf ];
  simp_all +decide [ Finset.ext_iff, Set.ext_iff, MGM.mL ];
  simp_all +decide [ Finset.sum_ite, Finset.filter_eq, Finset.filter_ne ];
  split_ifs at hharm <;> simp_all +decide [ Finset.sum_filter, MGM.cond ];
  exact mul_left_cancel₀ ( inv_ne_zero ( show M.edgeLength w v ≠ 0 from ne_of_gt ( M.length_pos _ _ ( by aesop ) ) ) ) ( by linarith )

/-! ## Theorem 3: Energy non-negativity -/

/-
The Dirichlet energy is non-negative for all vertex potentials.
    This connects to electrical networks: energy = total power dissipation.
-/
theorem energy_nonneg (f : M.V → ℝ) : 0 ≤ M.energy f := by
  -- The Dirichlet energy can be written as (1/2) * sum over adjacent pairs of cond(i,j) * (f(i) - f(j))^2.
  have h_energy : M.energy f = (1 / 2) * ∑ i : M.V, ∑ j : M.V, (if M.G.Adj i j then M.cond i j * (f i - f j)^2 else 0) := by
    unfold MGM.energy MGM.mL;
    simp +decide [ Finset.sum_ite, Finset.filter_eq, Finset.filter_ne, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul, sub_sq, mul_assoc, mul_comm, mul_left_comm ] ; ring;
    -- Combine like terms and simplify the expression.
    have h_simp : ∑ x : M.V, ∑ x_1 : M.V, (if M.G.Adj x x_1 then M.cond x x_1 * f x ^ 2 else 0) = ∑ x : M.V, ∑ x_1 : M.V, (if M.G.Adj x x_1 then M.cond x x_1 * f x_1 ^ 2 else 0) := by
      rw [ Finset.sum_comm ];
      simp +decide only [SimpleGraph.adj_comm, M.cond_symm];
    simp_all +decide [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, mul_assoc, mul_comm, mul_left_comm, Finset.sum_ite, Finset.filter_erase ] ; ring;
    norm_num [ ← Finset.sum_mul _ _ _, h_simp ] ; ring;
    simp_all +decide [ Finset.sum_mul _ _ _, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_add_distrib ] ; ring;
    norm_num [ ← Finset.sum_mul _ _ _ ] ; ring;
  exact h_energy.symm ▸ mul_nonneg ( by norm_num ) ( Finset.sum_nonneg fun i hi => Finset.sum_nonneg fun j hj => by split_ifs <;> [ exact mul_nonneg ( le_of_lt ( M.cond_pos i j ‹_› ) ) ( sq_nonneg _ ) ; norm_num ] )

/-- Constant functions have zero Dirichlet energy. -/
theorem energy_zero_of_constant (c : ℝ) : M.energy (fun _ => c) = 0 := by
  unfold energy
  simp_rw [show ∀ i j, M.mL i j * c * c = c * c * M.mL i j from fun i j => by ring]
  simp [← Finset.mul_sum, M.mL_row_sum_zero]

/-! ## Theorem 4: Principal divisors have degree zero -/

/-- Every principal divisor has degree zero — the fundamental conservation law. -/
theorem principal_divisor_deg_zero {D : M.V → ℝ}
    (hprin : ∃ f : M.V → ℝ, ∀ v, M.Lf f v = D v) :
    M.isDegZero D := by
  obtain ⟨f, hf⟩ := hprin
  unfold isDegZero
  calc ∑ v : M.V, D v = ∑ v : M.V, M.Lf f v :=
        Finset.sum_congr rfl fun v _ => (hf v).symm
    _ = 0 := M.Lf_total_sum_zero f

/-! ## Theorem 5: S-principal divisors are degree zero and S-supported -/

/-- S-principal divisors have degree zero. -/
theorem s_principal_deg_zero {S : Finset M.V} {D : M.V → ℝ}
    (hprin : M.IsSPrincipal S D) :
    M.isDegZero D := by
  obtain ⟨f, _, hf⟩ := hprin
  exact M.principal_divisor_deg_zero ⟨f, hf⟩

/-- S-principal divisors are S-supported: they vanish outside S. -/
theorem s_principal_supported {S : Finset M.V} {D : M.V → ℝ}
    (hprin : M.IsSPrincipal S D) :
    M.IsSSupported S D := by
  obtain ⟨f, hharm, hLf⟩ := hprin
  intro v hv
  rw [← hLf v]
  exact hharm v hv

/-! ## Theorem 6: S-principal divisor lattice structure -/

/-- The zero divisor is S-principal. -/
theorem IsSPrincipal_zero (S : Finset M.V) :
    M.IsSPrincipal S (fun _ => 0) :=
  ⟨fun _ => 0, fun v _ => M.Lf_constant 0 v, fun v => M.Lf_constant 0 v⟩

/-- The set of S-principal divisors is closed under addition. -/
theorem IsSPrincipal_add {S : Finset M.V} {D₁ D₂ : M.V → ℝ}
    (h₁ : M.IsSPrincipal S D₁) (h₂ : M.IsSPrincipal S D₂) :
    M.IsSPrincipal S (fun v => D₁ v + D₂ v) := by
  obtain ⟨f₁, hh₁, hL₁⟩ := h₁
  obtain ⟨f₂, hh₂, hL₂⟩ := h₂
  exact ⟨fun v => f₁ v + f₂ v,
    fun v hv => by rw [M.Lf_add]; simp [hh₁ v hv, hh₂ v hv],
    fun v => by rw [M.Lf_add, hL₁, hL₂]⟩

/-- The set of S-principal divisors is closed under negation. -/
theorem IsSPrincipal_neg {S : Finset M.V} {D : M.V → ℝ}
    (h : M.IsSPrincipal S D) :
    M.IsSPrincipal S (fun v => -D v) := by
  obtain ⟨f, hh, hL⟩ := h
  exact ⟨fun v => -f v,
    fun v hv => by rw [M.Lf_neg]; simp [hh v hv],
    fun v => by rw [M.Lf_neg, hL]⟩

/-- The set of S-principal divisors is closed under scalar multiplication. -/
theorem IsSPrincipal_smul {S : Finset M.V} {D : M.V → ℝ} (c : ℝ)
    (h : M.IsSPrincipal S D) :
    M.IsSPrincipal S (fun v => c * D v) := by
  obtain ⟨f, hh, hL⟩ := h
  exact ⟨fun v => c * f v,
    fun v hv => by rw [M.Lf_smul]; simp [hh v hv],
    fun v => by rw [M.Lf_smul, hL]⟩

/-! ## Theorem 7: Lf produces S-principal divisors -/

/-- If `f` is harmonic on `Sᶜ`, then `Lf` is S-supported. -/
theorem Lf_supported_of_harmonic_complement {S : Finset M.V} {f : M.V → ℝ}
    (hharm : ∀ v, v ∉ S → M.Lf f v = 0) :
    M.IsSSupported S (M.Lf f) :=
  hharm

/-- If `f` is harmonic on `Sᶜ`, then `Lf` is S-principal. -/
theorem Lf_is_s_principal_of_harmonic {S : Finset M.V} {f : M.V → ℝ}
    (hharm : ∀ v, v ∉ S → M.Lf f v = 0) :
    M.IsSPrincipal S (M.Lf f) :=
  ⟨f, hharm, fun _ => rfl⟩

/-! ## Theorem 8: Energy bilinear form -/

/-- The energy bilinear form: `B(f, g) = ∑ᵢⱼ L(i,j) f(i) g(j)`. -/
noncomputable def energyBilin (f g : M.V → ℝ) : ℝ :=
  ∑ i : M.V, ∑ j : M.V, M.mL i j * f i * g j

/-- The energy bilinear form is symmetric. -/
theorem energyBilin_symm (f g : M.V → ℝ) :
    M.energyBilin f g = M.energyBilin g f := by
  unfold energyBilin
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl; intro i _
  apply Finset.sum_congr rfl; intro j _
  rw [M.mL_symm j i]; ring

/-- The energy bilinear form evaluated at `(f, f)` equals the Dirichlet energy. -/
theorem energyBilin_self_eq_energy (f : M.V → ℝ) :
    M.energyBilin f f = M.energy f := rfl

/-- Energy bilinear form is positive semidefinite: `B(f, f) ≥ 0`. -/
theorem energyBilin_psd (f : M.V → ℝ) :
    0 ≤ M.energyBilin f f := by
  rw [energyBilin_self_eq_energy]; exact M.energy_nonneg f

/-! ## Theorem 9: S-equivalence relation -/

/-- Two divisors are S-equivalent if their difference is S-principal. -/
def SEquiv (S : Finset M.V) (D₁ D₂ : M.V → ℝ) : Prop :=
  M.IsSPrincipal S (fun v => D₁ v - D₂ v)

/-- S-equivalence is reflexive. -/
theorem SEquiv_refl (S : Finset M.V) (D : M.V → ℝ) :
    M.SEquiv S D D := by
  unfold SEquiv
  convert M.IsSPrincipal_zero S using 1
  ext v; ring

/-- S-equivalence is symmetric. -/
theorem SEquiv_symm {S : Finset M.V} {D₁ D₂ : M.V → ℝ}
    (h : M.SEquiv S D₁ D₂) :
    M.SEquiv S D₂ D₁ := by
  unfold SEquiv at *
  convert M.IsSPrincipal_neg h using 1
  ext v; ring

/-- S-equivalence is transitive. -/
theorem SEquiv_trans {S : Finset M.V} {D₁ D₂ D₃ : M.V → ℝ}
    (h₁₂ : M.SEquiv S D₁ D₂) (h₂₃ : M.SEquiv S D₂ D₃) :
    M.SEquiv S D₁ D₃ := by
  unfold SEquiv at *
  have key : (fun v => D₁ v - D₃ v) = (fun v => (D₁ v - D₂ v) + (D₂ v - D₃ v)) := by
    ext v; ring
  rw [key]; exact M.IsSPrincipal_add h₁₂ h₂₃

/-- S-equivalence is an equivalence relation. -/
theorem SEquiv_equivalence (S : Finset M.V) :
    Equivalence (M.SEquiv S) :=
  ⟨M.SEquiv_refl S, fun h => M.SEquiv_symm h, fun h₁ h₂ => M.SEquiv_trans h₁ h₂⟩

/-! ## Theorem 10: Energy bilinear form respects constant shifts -/

/-- The energy bilinear form is invariant under constant shifts in the
    first argument. This means energy descends to quotients mod constants. -/
theorem energyBilin_shift_invariant (f g : M.V → ℝ) (c : ℝ) :
    M.energyBilin (fun v => f v + c) g = M.energyBilin f g := by
  unfold energyBilin
  simp_rw [show ∀ i j, M.mL i j * (f i + c) * g j =
    M.mL i j * f i * g j + M.mL i j * c * g j from fun i j => by ring]
  simp_rw [Finset.sum_add_distrib]
  suffices h : ∑ i : M.V, ∑ j : M.V, M.mL i j * c * g j = 0 by linarith
  simp_rw [show ∀ i j, M.mL i j * c * g j = c * (M.mL i j * g j) from fun i j => by ring]
  simp_rw [← Finset.mul_sum]
  suffices ∑ i : M.V, ∑ j : M.V, M.mL i j * g j = 0 by
    rw [this]; ring
  rw [Finset.sum_comm]
  apply Finset.sum_eq_zero; intro j _
  rw [← Finset.sum_mul]
  have : ∑ i : M.V, M.mL i j = 0 := by
    convert M.mL_row_sum_zero j using 1
    exact Finset.sum_congr rfl fun _ _ => M.mL_symm _ _
  rw [this, zero_mul]

/-! ## Theorem 11: Pendant-edge harmonic propagation -/

/-- If `f` is harmonic at all non-S vertices, and a leaf `w` is not in `S`,
    then `f(w)` equals `f` at its unique neighbor. This is the metric
    version of `harmonic_tree_attachment_forces_unique_firing`. -/
theorem harmonic_leaf_propagation
    {S : Finset M.V} {f : M.V → ℝ}
    {v w : M.V}
    (hharm : ∀ u, u ∉ S → M.Lf f u = 0)
    (hleaf : M.G.degree w = 1)
    (hadj : M.G.Adj w v)
    (hnotS : w ∉ S) :
    f w = f v :=
  M.harmonic_leaf_eq_neighbor f hleaf hadj (hharm w hnotS)

/-! ## Theorem 12: Harmonic function algebra -/

/-- Sum of harmonic functions is harmonic. -/
theorem harmonicOn_add (S : Finset M.V) {f g : M.V → ℝ}
    (hf : M.harmonicOn S f) (hg : M.harmonicOn S g) :
    M.harmonicOn S (fun v => f v + g v) := by
  intro v hv; rw [M.Lf_add]; simp [hf v hv, hg v hv]

/-- Scalar multiple of harmonic function is harmonic. -/
theorem harmonicOn_smul (S : Finset M.V) (k : ℝ) {f : M.V → ℝ}
    (hf : M.harmonicOn S f) :
    M.harmonicOn S (fun v => k * f v) := by
  intro v hv; rw [M.Lf_smul]; simp [hf v hv]

/-- Zero function is harmonic. -/
theorem harmonicOn_zero (S : Finset M.V) :
    M.harmonicOn S (fun _ => (0 : ℝ)) :=
  fun v _ => M.Lf_constant 0 v

/-! ## Model Refinement -/

/-- A model refinement: `M₂` refines `M₁` via an injection of vertices
    that preserves the graph structure and edge lengths. -/
structure Refines (M₁ M₂ : MGM) where
  /-- Injection from M₁ vertices into M₂ vertices -/
  ι : M₁.V → M₂.V
  /-- The injection is injective -/
  ι_inj : Function.Injective ι
  /-- Adjacency is preserved (as reachability in the refinement) -/
  adj_preserved : ∀ i j, M₁.G.Adj i j → M₂.G.Reachable (ι i) (ι j)

/-- Push a vertex divisor from a coarse model to a refined model. -/
noncomputable def Refines.pushDivisor {M₁ M₂ : MGM} (href : Refines M₁ M₂)
    (D : M₁.V → ℝ) : M₂.V → ℝ :=
  fun w => if h : ∃ v, href.ι v = w then D h.choose else 0

/-! ## Theorem 13: S-principal divisor subtraction -/

/-- The set of S-principal divisors is closed under subtraction. -/
theorem IsSPrincipal_sub {S : Finset M.V} {D₁ D₂ : M.V → ℝ}
    (h₁ : M.IsSPrincipal S D₁) (h₂ : M.IsSPrincipal S D₂) :
    M.IsSPrincipal S (fun v => D₁ v - D₂ v) := by
  have key : (fun v => D₁ v - D₂ v) = (fun v => D₁ v + (-D₂ v)) := by ext v; ring
  rw [key]; exact M.IsSPrincipal_add h₁ (M.IsSPrincipal_neg h₂)

/-! ## Theorem 14: Degree zero preserved by S-equivalence -/

/-- If two divisors are S-equivalent and one has degree zero, so does the other. -/
theorem SEquiv_preserves_deg_zero {S : Finset M.V} {D₁ D₂ : M.V → ℝ}
    (heq : M.SEquiv S D₁ D₂)
    (hdeg : M.isDegZero D₁) :
    M.isDegZero D₂ := by
  unfold isDegZero at *
  have h_diff_zero := M.s_principal_deg_zero heq
  unfold isDegZero at h_diff_zero
  have : ∑ v : M.V, (D₁ v - D₂ v) = 0 := h_diff_zero
  simp [Finset.sum_sub_distrib] at this
  linarith

/-! ## Theorem 15: S-supported divisor of Laplacian -/

/-- The Laplacian image of any function is a principal divisor. -/
theorem Lf_is_principal (f : M.V → ℝ) :
    ∃ g : M.V → ℝ, ∀ v, M.Lf g v = M.Lf f v :=
  ⟨f, fun _ => rfl⟩

/-! ## Theorem 16: Energy bilinear form is bilinear -/

/-- Energy bilinear form is linear in the first argument. -/
theorem energyBilin_add_left (f₁ f₂ g : M.V → ℝ) :
    M.energyBilin (fun v => f₁ v + f₂ v) g =
    M.energyBilin f₁ g + M.energyBilin f₂ g := by
  unfold energyBilin
  simp_rw [show ∀ i j, M.mL i j * (f₁ i + f₂ i) * g j =
    M.mL i j * f₁ i * g j + M.mL i j * f₂ i * g j from fun i j => by ring]
  simp [Finset.sum_add_distrib]

/-- Energy bilinear form is linear in the second argument. -/
theorem energyBilin_add_right (f g₁ g₂ : M.V → ℝ) :
    M.energyBilin f (fun v => g₁ v + g₂ v) =
    M.energyBilin f g₁ + M.energyBilin f g₂ := by
  rw [M.energyBilin_symm, M.energyBilin_add_left, M.energyBilin_symm g₁,
    M.energyBilin_symm g₂]

/-- Energy bilinear form scales in the first argument. -/
theorem energyBilin_smul_left (c : ℝ) (f g : M.V → ℝ) :
    M.energyBilin (fun v => c * f v) g = c * M.energyBilin f g := by
  unfold energyBilin
  simp_rw [show ∀ i j, M.mL i j * (c * f i) * g j =
    c * (M.mL i j * f i * g j) from fun i j => by ring]
  simp [Finset.mul_sum]

end MGM