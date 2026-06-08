/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Canonical Kernel Calculus on Metric Graph Models

This file develops the first formal **canonical-kernel calculus for tropical curves**:
a theory where harmonic representatives, Jacobian classes, and energy pairings are
computable, canonical, and stable under refinement.

## Mathematical Context

A **metric graph** (or tropical curve) is a compact connected metric space that locally
looks like a finite union of intervals. In practice, it is modeled by a finite graph
with positive edge lengths. The **metric Laplacian** with conductance weights 1/ℓ(e)
governs potential theory on such objects.

## Cross-Domain Connections

- **Electrical Networks**: The Dirichlet energy is total power dissipation; canonical
  kernels compute effective resistances.
- **Quantum Graphs**: The metric Laplacian governs quantum graph dynamics.
- **Tropical Geometry**: The S-supported Jacobian quotient is the computational heart
  of the tropical Abel–Jacobi map.
- **Statistical Mechanics**: The energy form is the covariance kernel for Gaussian
  free fields on networks.

## Main Results

* `mL_row_sum_zero` — row-sum-zero (conservation law)
* `mL_symm` — Laplacian symmetry
* `Lf_constant` — constants in the kernel
* `Lf_total_sum_zero` — principal divisors have degree zero
* `metric_leaf_eq_neighbor` — leaf rigidity
* `harmonicOn_compl_leaf_eq_neighbor` — S-complement leaf rigidity
* `energy_nonneg` — E(f) ≥ 0
* `energy_zero_of_constant` — E(c) = 0
* `energy_eq_zero_iff_constant` — E(f) = 0 ↔ f constant (connected)
* `harmonic_meanZero_eq_zero` — harmonic + mean-zero = zero
* `normalized_kernel_unique` — mean-zero kernel uniqueness
* `sPrincipal_degree_zero` — S-principal divisors have degree zero
* `energyForm_symm` — symmetry of the energy bilinear form

## References

* Baker–Norine, "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)
* Baker–Faber, "Metrized graphs, Laplacian operators, and electrical networks" (2006)
* Mikhalkin–Zharkov, "Tropical curves, their Jacobians and theta functions" (2008)
-/

import Mathlib

open Finset BigOperators

/-! ## Section 1: Metric Graph Model -/

/-- A **metric graph model**: finite simple graph with positive symmetric edge lengths.
    Conductance weights `1/ℓ(e)` define the metric Laplacian. -/
structure WMGraph where
  V : Type
  [instFintype : Fintype V]
  [instDecEq : DecidableEq V]
  G : SimpleGraph V
  [instDecAdj : DecidableRel G.Adj]
  len : V → V → ℝ
  len_pos : ∀ i j, G.Adj i j → 0 < len i j
  len_symm : ∀ i j, len i j = len j i

attribute [instance] WMGraph.instFintype WMGraph.instDecEq WMGraph.instDecAdj

namespace WMGraph

variable (M : WMGraph)

/-- Conductance = 1 / edge_length. -/
noncomputable def cond (i j : M.V) : ℝ := 1 / M.len i j

theorem cond_pos (i j : M.V) (hadj : M.G.Adj i j) : 0 < M.cond i j :=
  div_pos one_pos (M.len_pos i j hadj)

theorem cond_symm (i j : M.V) : M.cond i j = M.cond j i := by
  simp [cond, M.len_symm]

/-- The **metric Laplacian matrix**. -/
noncomputable def mL : Matrix M.V M.V ℝ :=
  fun i j =>
    if i = j then ∑ k ∈ Finset.univ.filter (M.G.Adj i), M.cond i k
    else if M.G.Adj i j then -(M.cond i j)
    else 0

/-- Apply the metric Laplacian to a vertex potential. -/
noncomputable def Lf (f : M.V → ℝ) (v : M.V) : ℝ :=
  ∑ j : M.V, M.mL v j * f j

/-- Harmonicity on a set. -/
def harmonicOn (T : Finset M.V) (f : M.V → ℝ) : Prop :=
  ∀ v ∈ T, M.Lf f v = 0

/-- Dirichlet energy: f^T L f. -/
noncomputable def energy (f : M.V → ℝ) : ℝ :=
  ∑ i : M.V, ∑ j : M.V, M.mL i j * f i * f j

/-- Mean-zero normalization. -/
def meanZero (f : M.V → ℝ) : Prop := ∑ v : M.V, f v = 0

/-- Leaf predicate. -/
def isLeaf (v : M.V) : Prop := M.G.degree v = 1

/-- S-principal divisor. -/
def isSPrincipal (S : Finset M.V) (D : M.V → ℝ) : Prop :=
  ∃ f : M.V → ℝ, (∀ v, v ∉ S → M.Lf f v = 0) ∧ ∀ v, M.Lf f v = D v

/-- S-supported divisor. -/
def isSSupported (S : Finset M.V) (D : M.V → ℝ) : Prop :=
  ∀ v, v ∉ S → D v = 0

/-- Energy bilinear form (polarization of Dirichlet energy). -/
noncomputable def energyForm (f g : M.V → ℝ) : ℝ :=
  ∑ i : M.V, ∑ j : M.V, M.mL i j * f i * g j

/-! ## Section 2: Core Algebraic Properties -/

/-
**Row-sum-zero**: each row of the metric Laplacian sums to zero.
-/
theorem mL_row_sum_zero (i : M.V) : ∑ j : M.V, M.mL i j = 0 := by
  simp +decide only [mL, sum_ite];
  simp +decide [ Finset.filter_eq, Finset.filter_ne ];
  rw [ Finset.filter_erase ] ; aesop

/-
**Symmetry** of the metric Laplacian.
-/
theorem mL_symm (i j : M.V) : M.mL i j = M.mL j i := by
  unfold WMGraph.mL;
  split_ifs <;> simp_all +decide [ SimpleGraph.adj_comm, WMGraph.cond_symm ]

/-- **Constants in the kernel**: L·(c,...,c) = 0. -/
theorem Lf_constant (c : ℝ) (v : M.V) : M.Lf (fun _ => c) v = 0 := by
  unfold Lf
  rw [← Finset.sum_mul]
  rw [show ∑ j : M.V, M.mL v j = 0 from M.mL_row_sum_zero v]
  exact zero_mul c

/-- Constants are harmonic everywhere. -/
theorem constant_harmonicOn (c : ℝ) (T : Finset M.V) :
    M.harmonicOn T (fun _ => c) :=
  fun v _ => M.Lf_constant c v

/-
**Degree-zero**: ∑ Lf(v) = 0 for any f.
-/
theorem Lf_total_sum_zero (f : M.V → ℝ) : ∑ v : M.V, M.Lf f v = 0 := by
  -- By swapping the order of the sums and using the symmetry of the metric Laplacian, we can factor out $f_j$.
  have h_swap : ∑ v, M.Lf f v = ∑ j, f j * ∑ i, M.mL i j := by
    simp +decide only [Lf, mul_comm, Finset.mul_sum _ _ _];
    exact Finset.sum_comm;
  simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mL_symm ];
  simp +decide [ mL_row_sum_zero ]

/-! ## Section 3: Linearity -/

/-- L(f + g) = Lf + Lg. -/
theorem Lf_add (f g : M.V → ℝ) (v : M.V) :
    M.Lf (f + g) v = M.Lf f v + M.Lf g v := by
  simp only [Lf, Pi.add_apply, mul_add, Finset.sum_add_distrib]

/-- L(c·f) = c·Lf. -/
theorem Lf_smul (c : ℝ) (f : M.V → ℝ) (v : M.V) :
    M.Lf (c • f) v = c * M.Lf f v := by
  simp only [Lf, Pi.smul_apply, smul_eq_mul]
  rw [Finset.mul_sum]
  congr 1; ext j; ring

/-- L(f - g) = Lf - Lg. -/
theorem Lf_sub (f g : M.V → ℝ) (v : M.V) :
    M.Lf (f - g) v = M.Lf f v - M.Lf g v := by
  simp only [Lf, Pi.sub_apply, mul_sub, Finset.sum_sub_distrib]

/-- L(-f) = -Lf. -/
theorem Lf_neg (f : M.V → ℝ) (v : M.V) :
    M.Lf (-f) v = -(M.Lf f v) := by
  simp only [Lf, Pi.neg_apply, mul_neg, Finset.sum_neg_distrib]

/-! ## Section 4: Pendant-Edge Rigidity -/

/-
**Metric leaf rigidity.** At a leaf vertex `w` with unique neighbor `v`,
    harmonicity at `w` forces `f(w) = f(v)`.
-/
theorem metric_leaf_eq_neighbor
    {v w : M.V} (f : M.V → ℝ)
    (hdeg : M.G.degree w = 1)
    (hadj : M.G.Adj w v)
    (hharm : M.Lf f w = 0) :
    f w = f v := by
      -- Since w has degree 1, the neighbor filter {k | G.Adj w k} = {v}.
      have h_filter : Finset.filter (fun k => M.G.Adj w k) Finset.univ = {v} := by
        have := Finset.card_eq_one.mp hdeg;
        simp_all +decide [ Finset.eq_singleton_iff_unique_mem ];
        grind;
      unfold WMGraph.Lf at hharm;
      simp_all +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne', WMGraph.mL ];
      simp_all +decide [ Finset.sum_filter, Finset.filter_eq, Finset.filter_ne ];
      simp_all +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne' ];
      exact mul_left_cancel₀ ( ne_of_gt ( M.cond_pos w v hadj ) ) ( by linarith )

/-
**Leaf rigidity on S-complements.**
-/
theorem harmonicOn_compl_leaf_eq_neighbor
    {v w : M.V} (f : M.V → ℝ) (S : Finset M.V)
    (hdeg : M.G.degree w = 1)
    (hadj : M.G.Adj w v)
    (hw_not_in_S : w ∉ S)
    (hharm : M.harmonicOn Sᶜ f) :
    f w = f v := by
      -- Apply the metric_leaf_eq_neighbor theorem with the given hypotheses.
      apply metric_leaf_eq_neighbor M f hdeg hadj (hharm w (by simpa using hw_not_in_S))

/-! ## Section 5: Dirichlet Energy Theory -/

/-
**Energy non-negativity**: E(f) ≥ 0 for all vertex potentials.
-/
theorem energy_nonneg (f : M.V → ℝ) : 0 ≤ M.energy f := by
  -- By definition of $mL$, we can rewrite $E(f)$ as a sum of squares.
  have h_sum_squares : M.energy f = (1 / 2) * ∑ i, ∑ j, (if M.G.Adj i j then M.cond i j * (f i - f j)^2 else 0) := by
    unfold WMGraph.energy WMGraph.mL;
    simp +decide [ Finset.sum_ite, Finset.filter_ne, Finset.filter_eq, mul_assoc, sub_sq ];
    simp +decide [ Finset.sum_filter, Finset.sum_add_distrib, sub_mul, add_mul, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _ ] ; ring;
    -- By combining terms, we can factor out common factors and simplify the expression.
    have h_simp : ∑ x : M.V, ∑ x_1 : M.V, (if M.G.Adj x x_1 then f x ^ 2 * M.cond x x_1 else 0) = ∑ x : M.V, ∑ x_1 : M.V, (if M.G.Adj x x_1 then f x_1 ^ 2 * M.cond x x_1 else 0) := by
      rw [ Finset.sum_comm ];
      simp +decide only [SimpleGraph.adj_comm, cond_symm];
    norm_num [ Finset.sum_ite ] at *;
    norm_num [ ← Finset.sum_mul _ _ _, h_simp ] ; ring;
  exact h_sum_squares.symm ▸ mul_nonneg ( by norm_num ) ( Finset.sum_nonneg fun i hi => Finset.sum_nonneg fun j hj => by split_ifs <;> first | positivity | exact mul_nonneg ( le_of_lt ( M.cond_pos i j ( by aesop ) ) ) ( sq_nonneg _ ) ) ;

/-
Constant functions have zero Dirichlet energy.
-/
theorem energy_zero_of_constant (c : ℝ) : M.energy (fun _ => c) = 0 := by
  unfold WMGraph.energy;
  simp +decide [ ← mul_assoc, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mL_row_sum_zero ]

/-- E(f) = ∑ f(v) · Lf(v). -/
theorem energy_eq_sum_Lf (f : M.V → ℝ) :
    M.energy f = ∑ v : M.V, f v * M.Lf f v := by
  simp only [energy, Lf, Finset.mul_sum]
  congr 1; ext i; congr 1; ext j; ring

/-
**Energy zero iff constant** on connected graphs.
-/
theorem energy_eq_zero_iff_constant
    (f : M.V → ℝ) (hconn : M.G.Connected) :
    M.energy f = 0 ↔ ∃ c : ℝ, f = fun _ => c := by
      constructor;
      · -- By definition of energy, we have $2 * M.energy f = \sum_{i \sim j} \text{cond}(i,j) * (f(i) - f(j))^2$.
        have h_energy_def : 2 * M.energy f = ∑ i : M.V, ∑ j ∈ M.G.neighborFinset i, M.cond i j * (f i - f j)^2 := by
          unfold WMGraph.energy;
          simp +decide [ WMGraph.mL, Finset.sum_ite, Finset.filter_ne, Finset.filter_eq, mul_assoc, mul_sub, sub_mul, sq ];
          simp +decide [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul, mul_assoc, mul_comm, mul_left_comm, SimpleGraph.neighborFinset ] ; ring;
          simp +decide [ SimpleGraph.neighborSet, Finset.sum_filter ];
          rw [ ← Finset.sum_comm ] ; ring;
          simp +decide [ SimpleGraph.adj_comm, mul_comm ] ; ring;
          simp +decide [ WMGraph.cond, WMGraph.len_symm ] ; ring;
        intro h_zero
        have h_const : ∀ i j, M.G.Adj i j → f i = f j := by
          intro i j hij; contrapose! h_energy_def; simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg, mul_nonneg, sq_nonneg ] ;
          refine' ne_of_lt ( lt_of_lt_of_le _ ( Finset.single_le_sum ( fun i _ => Finset.sum_nonneg fun j _ => mul_nonneg ( le_of_lt ( M.cond_pos i j ( by aesop ) ) ) ( sq_nonneg _ ) ) ( Finset.mem_univ i ) ) );
          exact lt_of_lt_of_le ( mul_pos ( M.cond_pos i j hij ) ( sq_pos_of_ne_zero ( sub_ne_zero_of_ne h_energy_def ) ) ) ( Finset.single_le_sum ( fun x _ => mul_nonneg ( le_of_lt ( M.cond_pos i x ( by aesop ) ) ) ( sq_nonneg ( f i - f x ) ) ) ( by aesop ) );
        -- Since $f$ is constant on each � connected� component of $M.G$, and $M.G$ is connected, $f$ must be constant on $M.G$.
        have h_const_on_connected : ∀ u v : M.V, M.G.Reachable u v → f u = f v := by
          rintro u v ⟨ p ⟩;
          induction p <;> [ rfl; linarith [ h_const _ _ ‹_› ] ];
        cases isEmpty_or_nonempty M.V <;> [ exact ⟨ 0, funext fun x => False.elim <| ‹IsEmpty M.V›.elim x ⟩ ; exact ⟨ f ( Classical.arbitrary M.V ), funext fun x => h_const_on_connected _ _ <| hconn _ _ ⟩ ];
      · exact fun ⟨ c, hc ⟩ => hc ▸ energy_zero_of_constant M c

/-! ## Section 6: Harmonic Uniqueness -/

/-
**Global harmonic + mean-zero = zero** on connected graphs.
-/
theorem harmonic_meanZero_eq_zero
    (f : M.V → ℝ) (hconn : M.G.Connected)
    (hharm : ∀ v, M.Lf f v = 0) (hmean : M.meanZero f) :
    f = fun _ => 0 := by
      -- Since f is globally harmonic, we have E(f) = f(v) * Lf(v) = 0 by � energy�_eq_sum_Lf.
      have h_energy_zero : M.energy f = 0 := by
        simp_all +decide [ energy_eq_sum_Lf ];
      -- By energy_eq_zero_iff_constant �,� f is constant: f = fun _ => c.
      obtain ⟨c, hc⟩ : ∃ c : ℝ, f = fun _ => c := by
        convert M.energy_eq_zero_iff_constant f hconn |>.1 h_energy_zero;
      cases isEmpty_or_nonempty M.V <;> simp_all +decide [ WMGraph.meanZero ];
      exact Subsingleton.elim _ _

/-
**Normalized kernel uniqueness.** Two mean-zero potentials with the same
    Laplacian image are identical.
-/
theorem normalized_kernel_unique
    (f₁ f₂ : M.V → ℝ) (hconn : M.G.Connected)
    (hLf : ∀ v, M.Lf f₁ v = M.Lf f₂ v)
    (hm₁ : M.meanZero f₁) (hm₂ : M.meanZero f₂) :
    f₁ = f₂ := by
      -- Let $h = f₁ - f₂$. Since $M.Lf f₁ v = M.Lf f₂ v$ for all $v$, we have $M.Lf h v = 0$ for all $v$.
      set h : M.V → ℝ := f₁ - f₂
      have hharm : ∀ v, M.Lf h v = 0 := by
        exact fun v => by rw [ Lf_sub, hLf, sub_self ] ;
      exact sub_eq_zero.mp ( harmonic_meanZero_eq_zero M h hconn hharm ( by rw [ WMGraph.meanZero ] at *; aesop ) )

/-! ## Section 7: S-Supported Theory -/

/-
**S-principal divisors have degree zero.**
-/
theorem sPrincipal_degree_zero (S : Finset M.V) (D : M.V → ℝ)
    (hprinc : M.isSPrincipal S D) :
    ∑ v : M.V, D v = 0 := by
      -- By definition of S-principal divisors, � there� exists a function f such that D = Lf f.
      obtain ⟨f, hLf⟩ := hprinc;
      rw [ ← funext hLf.2, Lf_total_sum_zero ]

/-- Sum of harmonics is harmonic. -/
theorem harmonicOn_add (T : Finset M.V) {f g : M.V → ℝ}
    (hf : M.harmonicOn T f) (hg : M.harmonicOn T g) :
    M.harmonicOn T (f + g) := by
  intro v hv; rw [M.Lf_add]; rw [hf v hv, hg v hv, add_zero]

/-- Scalar multiple of harmonic is harmonic. -/
theorem harmonicOn_smul (T : Finset M.V) {f : M.V → ℝ} (c : ℝ)
    (hf : M.harmonicOn T f) :
    M.harmonicOn T (c • f) := by
  intro v hv; rw [M.Lf_smul]; rw [hf v hv, mul_zero]

/-
Off-diagonal entries are non-positive.
-/
theorem mL_off_diag_nonpos (i j : M.V) (hij : i ≠ j) : M.mL i j ≤ 0 := by
  by_cases h : M.G.Adj i j <;> simp_all +decide [ WMGraph.mL ];
  exact one_div_nonneg.2 ( le_of_lt ( M.len_pos i j h ) )

/-! ## Section 8: Energy Bilinear Form -/

/-- The energy form equals ∑ f(v)·(Lg)(v). -/
theorem energyForm_eq_sum_fLg (f g : M.V → ℝ) :
    M.energyForm f g = ∑ v : M.V, f v * M.Lf g v := by
  simp only [energyForm, Lf, Finset.mul_sum]
  congr 1; ext i; congr 1; ext j; ring

/-
**Symmetry of the energy form.**
-/
theorem energyForm_symm (f g : M.V → ℝ) :
    M.energyForm f g = M.energyForm g f := by
      unfold WMGraph.energyForm;
      rw [ Finset.sum_comm ] ; congr ; ext ; congr ; ext ; ring;
      rw [ M.mL_symm ] ; ring

/-- The energy form at (f,f) equals the Dirichlet energy. -/
theorem energyForm_self (f : M.V → ℝ) :
    M.energyForm f f = M.energy f := rfl

end WMGraph